import { Request, Response, NextFunction } from 'express';
import { metricsLogger } from './logger';

// Interface pour les métriques de performance
interface PerformanceMetrics {
  requestCount: number;
  totalResponseTime: number;
  averageResponseTime: number;
  minResponseTime: number;
  maxResponseTime: number;
  errorCount: number;
  lastReset: Date;
}

// Stockage des métriques en mémoire (en production, utiliser Redis)
const metrics: Map<string, PerformanceMetrics> = new Map();

/**
 * Middleware de collecte des métriques de performance
 */
export const performanceMetricsMiddleware = (req: Request, res: Response, next: NextFunction) => {
  const startTime = Date.now();
  const route = `${req.method} ${req.route?.path || req.path}`;

  // Initialiser les métriques pour cette route si elles n'existent pas
  if (!metrics.has(route)) {
    metrics.set(route, {
      requestCount: 0,
      totalResponseTime: 0,
      averageResponseTime: 0,
      minResponseTime: Infinity,
      maxResponseTime: 0,
      errorCount: 0,
      lastReset: new Date(),
    });
  }

  const routeMetrics = metrics.get(route)!;

  // Intercepter la fin de la réponse
  const originalEnd = res.end;
  res.end = function (chunk?: any, encoding?: any): Response {
    const responseTime = Date.now() - startTime;

    // Mettre à jour les métriques
    routeMetrics.requestCount++;
    routeMetrics.totalResponseTime += responseTime;
    routeMetrics.averageResponseTime = routeMetrics.totalResponseTime / routeMetrics.requestCount;
    routeMetrics.minResponseTime = Math.min(routeMetrics.minResponseTime, responseTime);
    routeMetrics.maxResponseTime = Math.max(routeMetrics.maxResponseTime, responseTime);

    if (res.statusCode >= 400) {
      routeMetrics.errorCount++;
    }

    // Log des métriques de performance
    metricsLogger.info('Performance Metric', {
      route,
      responseTime: `${responseTime}ms`,
      statusCode: res.statusCode,
      requestCount: routeMetrics.requestCount,
      averageResponseTime: `${routeMetrics.averageResponseTime.toFixed(2)}ms`,
      minResponseTime: `${routeMetrics.minResponseTime}ms`,
      maxResponseTime: `${routeMetrics.maxResponseTime}ms`,
      errorCount: routeMetrics.errorCount,
      errorRate: `${((routeMetrics.errorCount / routeMetrics.requestCount) * 100).toFixed(2)}%`,
    });

    return originalEnd.call(this, chunk, encoding);
  };

  next();
};

/**
 * Fonction pour obtenir les métriques de performance
 */
export const getPerformanceMetrics = (): Record<string, PerformanceMetrics> => {
  const result: Record<string, PerformanceMetrics> = {};

  for (const [route, routeMetrics] of metrics.entries()) {
    result[route] = { ...routeMetrics };
  }

  return result;
};

/**
 * Fonction pour réinitialiser les métriques
 */
export const resetPerformanceMetrics = (): void => {
  metrics.clear();
  metricsLogger.info('Performance metrics reset');
};

/**
 * Fonction pour obtenir les métriques d'une route spécifique
 */
export const getRouteMetrics = (route: string): PerformanceMetrics | null => {
  return metrics.get(route) || null;
};

/**
 * Middleware pour mesurer le temps d'exécution d'une fonction
 */
export const measureExecutionTime = (operation: string) => {
  return (target: any, propertyName: string, descriptor: PropertyDescriptor) => {
    const method = descriptor.value;

    descriptor.value = async function (...args: any[]) {
      const startTime = Date.now();

      try {
        const result = await method.apply(this, args);
        const executionTime = Date.now() - startTime;

        metricsLogger.info('Function Execution Time', {
          operation,
          function: propertyName,
          executionTime: `${executionTime}ms`,
          success: true,
        });

        return result;
      } catch (error) {
        const executionTime = Date.now() - startTime;

        metricsLogger.error('Function Execution Time', {
          operation,
          function: propertyName,
          executionTime: `${executionTime}ms`,
          success: false,
          error: error instanceof Error ? error.message : 'Unknown error',
        });

        throw error;
      }
    };

    return descriptor;
  };
};

/**
 * Fonction utilitaire pour mesurer le temps d'exécution d'une fonction
 */
export const measureTime = async <T>(operation: string, fn: () => Promise<T>): Promise<T> => {
  const startTime = Date.now();

  try {
    const result = await fn();
    const executionTime = Date.now() - startTime;

    metricsLogger.info('Operation Execution Time', {
      operation,
      executionTime: `${executionTime}ms`,
      success: true,
    });

    return result;
  } catch (error) {
    const executionTime = Date.now() - startTime;

    metricsLogger.error('Operation Execution Time', {
      operation,
      executionTime: `${executionTime}ms`,
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error',
    });

    throw error;
  }
};

/**
 * Middleware pour surveiller l'utilisation de la mémoire
 */
export const memoryUsageMiddleware = (req: Request, res: Response, next: NextFunction) => {
  const memoryUsage = process.memoryUsage();

  // Log de l'utilisation de la mémoire toutes les 100 requêtes
  if (Math.random() < 0.01) {
    // 1% de chance
    metricsLogger.info('Memory Usage', {
      rss: `${Math.round(memoryUsage.rss / 1024 / 1024)}MB`,
      heapTotal: `${Math.round(memoryUsage.heapTotal / 1024 / 1024)}MB`,
      heapUsed: `${Math.round(memoryUsage.heapUsed / 1024 / 1024)}MB`,
      external: `${Math.round(memoryUsage.external / 1024 / 1024)}MB`,
      arrayBuffers: `${Math.round(memoryUsage.arrayBuffers / 1024 / 1024)}MB`,
    });
  }

  next();
};

/**
 * Fonction pour obtenir l'utilisation actuelle de la mémoire
 */
export const getMemoryUsage = () => {
  const memoryUsage = process.memoryUsage();

  return {
    rss: Math.round(memoryUsage.rss / 1024 / 1024), // MB
    heapTotal: Math.round(memoryUsage.heapTotal / 1024 / 1024), // MB
    heapUsed: Math.round(memoryUsage.heapUsed / 1024 / 1024), // MB
    external: Math.round(memoryUsage.external / 1024 / 1024), // MB
    arrayBuffers: Math.round(memoryUsage.arrayBuffers / 1024 / 1024), // MB
  };
};

/**
 * Fonction pour obtenir l'uptime du processus
 */
export const getUptime = () => {
  const uptime = process.uptime();

  return {
    seconds: Math.floor(uptime),
    minutes: Math.floor(uptime / 60),
    hours: Math.floor(uptime / 3600),
    days: Math.floor(uptime / 86400),
    formatted: `${Math.floor(uptime / 3600)}h ${Math.floor((uptime % 3600) / 60)}m ${Math.floor(uptime % 60)}s`,
  };
};
