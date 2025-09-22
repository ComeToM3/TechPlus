import { Request, Response, NextFunction } from 'express';
import { performance } from 'perf_hooks';
import logger from '../utils/logger';
import { captureMetric, addSentryBreadcrumb } from '../config/sentry-simple';

/**
 * Interface pour les métriques d'uptime
 */
interface UptimeMetrics {
  startTime: number;
  requestCount: number;
  totalResponseTime: number;
  averageResponseTime: number;
  errorCount: number;
  lastRequestTime: number;
  healthCheckCount: number;
  lastHealthCheckTime: number;
}

/**
 * Métriques globales d'uptime
 */
const uptimeMetrics: UptimeMetrics = {
  startTime: Date.now(),
  requestCount: 0,
  totalResponseTime: 0,
  averageResponseTime: 0,
  errorCount: 0,
  lastRequestTime: 0,
  healthCheckCount: 0,
  lastHealthCheckTime: 0,
};

/**
 * Middleware de monitoring d'uptime
 */
export const uptimeMonitoringMiddleware = (
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  const startTime = performance.now();
  uptimeMetrics.lastRequestTime = Date.now();
  uptimeMetrics.requestCount++;

  // Ajouter des breadcrumbs Sentry
  addSentryBreadcrumb(`Request: ${req.method} ${req.path}`, 'http', 'info', {
    method: req.method,
    path: req.path,
    user_agent: req.get('User-Agent'),
    ip: req.ip,
  });

  // Intercepter la fin de la réponse
  const originalEnd = res.end;
  res.end = function (chunk?: any, encoding?: any): Response {
    const endTime = performance.now();
    const responseTime = endTime - startTime;

    // Mettre à jour les métriques
    uptimeMetrics.totalResponseTime += responseTime;
    uptimeMetrics.averageResponseTime =
      uptimeMetrics.totalResponseTime / uptimeMetrics.requestCount;

    if (res.statusCode >= 400) {
      uptimeMetrics.errorCount++;
    }

    // Capturer les métriques Sentry
    captureMetric('http.request.duration', responseTime, 'millisecond', {
      method: req.method,
      status_code: res.statusCode.toString(),
      endpoint: req.path,
    });

    captureMetric('http.request.count', 1, 'none', {
      method: req.method,
      status_code: res.statusCode.toString(),
      endpoint: req.path,
    });

    if (res.statusCode >= 400) {
      captureMetric('http.error.count', 1, 'none', {
        method: req.method,
        status_code: res.statusCode.toString(),
        endpoint: req.path,
      });
    }

    // Logger les métriques importantes
    if (responseTime > 1000) {
      // Requêtes lentes > 1s
      logger.warn('Slow request detected', {
        method: req.method,
        path: req.path,
        responseTime: `${responseTime.toFixed(2)}ms`,
        statusCode: res.statusCode,
        ip: req.ip,
      });
    }

    return originalEnd.call(this, chunk, encoding);
  };

  next();
};

/**
 * Middleware spécialisé pour les health checks
 */
export const healthCheckMonitoringMiddleware = (
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  uptimeMetrics.healthCheckCount++;
  uptimeMetrics.lastHealthCheckTime = Date.now();

  // Capturer les métriques de health check
  captureMetric('health.check.count', 1, 'none', {
    endpoint: req.path,
  });

  next();
};

/**
 * Fonction pour obtenir les métriques d'uptime
 */
export const getUptimeMetrics = (): UptimeMetrics & {
  uptime: number;
  uptimeFormatted: string;
  errorRate: number;
  requestsPerMinute: number;
} => {
  const now = Date.now();
  const uptime = now - uptimeMetrics.startTime;
  const uptimeMinutes = uptime / (1000 * 60);

  return {
    ...uptimeMetrics,
    uptime,
    uptimeFormatted: formatUptime(uptime),
    errorRate:
      uptimeMetrics.requestCount > 0
        ? (uptimeMetrics.errorCount / uptimeMetrics.requestCount) * 100
        : 0,
    requestsPerMinute: uptimeMinutes > 0 ? uptimeMetrics.requestCount / uptimeMinutes : 0,
  };
};

/**
 * Fonction pour formater l'uptime
 */
const formatUptime = (uptime: number): string => {
  const seconds = Math.floor(uptime / 1000);
  const minutes = Math.floor(seconds / 60);
  const hours = Math.floor(minutes / 60);
  const days = Math.floor(hours / 24);

  const parts = [];
  if (days > 0) parts.push(`${days}d`);
  if (hours % 24 > 0) parts.push(`${hours % 24}h`);
  if (minutes % 60 > 0) parts.push(`${minutes % 60}m`);
  if (seconds % 60 > 0) parts.push(`${seconds % 60}s`);

  return parts.join(' ') || '0s';
};

/**
 * Fonction pour réinitialiser les métriques d'uptime
 */
export const resetUptimeMetrics = (): void => {
  const now = Date.now();
  uptimeMetrics.startTime = now;
  uptimeMetrics.requestCount = 0;
  uptimeMetrics.totalResponseTime = 0;
  uptimeMetrics.averageResponseTime = 0;
  uptimeMetrics.errorCount = 0;
  uptimeMetrics.lastRequestTime = now;
  uptimeMetrics.healthCheckCount = 0;
  uptimeMetrics.lastHealthCheckTime = now;

  logger.info('Uptime metrics reset');
};

/**
 * Middleware pour capturer les métriques de disponibilité
 */
export const availabilityMonitoringMiddleware = (
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  // Capturer la disponibilité de l'endpoint
  captureMetric('endpoint.availability', 1, 'none', {
    endpoint: req.path,
    method: req.method,
  });

  // Vérifier si l'endpoint est critique
  const criticalEndpoints = ['/api/auth/login', '/api/reservations', '/api/payments'];
  const isCritical = criticalEndpoints.some(endpoint => req.path.startsWith(endpoint));

  if (isCritical) {
    captureMetric('critical.endpoint.availability', 1, 'none', {
      endpoint: req.path,
      method: req.method,
    });
  }

  next();
};

/**
 * Fonction pour vérifier la santé globale du système
 */
export const getSystemHealth = (): {
  status: 'healthy' | 'degraded' | 'unhealthy';
  uptime: number;
  uptimeFormatted: string;
  metrics: UptimeMetrics;
  healthScore: number;
} => {
  const metrics = getUptimeMetrics();

  // Calculer un score de santé basé sur les métriques
  let healthScore = 100;

  // Pénaliser les erreurs
  if (metrics.errorRate > 5) healthScore -= 20;
  if (metrics.errorRate > 10) healthScore -= 30;

  // Pénaliser les temps de réponse lents
  if (metrics.averageResponseTime > 1000) healthScore -= 15;
  if (metrics.averageResponseTime > 2000) healthScore -= 25;

  // Pénaliser le manque de trafic (possible problème)
  if (metrics.requestsPerMinute < 0.1 && metrics.uptime > 5 * 60 * 1000) healthScore -= 10;

  let status: 'healthy' | 'degraded' | 'unhealthy';
  if (healthScore >= 90) {
    status = 'healthy';
  } else if (healthScore >= 70) {
    status = 'degraded';
  } else {
    status = 'unhealthy';
  }

  return {
    status,
    uptime: metrics.uptime,
    uptimeFormatted: metrics.uptimeFormatted,
    metrics: uptimeMetrics,
    healthScore,
  };
};

/**
 * Fonction pour générer un rapport d'uptime
 */
export const generateUptimeReport = (): {
  summary: {
    uptime: string;
    totalRequests: number;
    averageResponseTime: number;
    errorRate: number;
    requestsPerMinute: number;
    healthScore: number;
    status: string;
  };
  details: UptimeMetrics;
  timestamp: string;
} => {
  const health = getSystemHealth();
  const metrics = getUptimeMetrics();

  return {
    summary: {
      uptime: metrics.uptimeFormatted,
      totalRequests: metrics.requestCount,
      averageResponseTime: Math.round(metrics.averageResponseTime * 100) / 100,
      errorRate: Math.round(metrics.errorRate * 100) / 100,
      requestsPerMinute: Math.round(metrics.requestsPerMinute * 100) / 100,
      healthScore: health.healthScore,
      status: health.status,
    },
    details: uptimeMetrics,
    timestamp: new Date().toISOString(),
  };
};

/**
 * Middleware pour logger les métriques d'uptime périodiquement
 */
export const periodicUptimeLogging = (): void => {
  setInterval(
    () => {
      const report = generateUptimeReport();

      if (report.summary.status === 'unhealthy') {
        logger.error('System health degraded', report);
      } else if (report.summary.status === 'degraded') {
        logger.warn('System health warning', report);
      } else {
        logger.info('System health check', report);
      }
    },
    5 * 60 * 1000
  ); // Toutes les 5 minutes
};

export default {
  uptimeMonitoringMiddleware,
  healthCheckMonitoringMiddleware,
  availabilityMonitoringMiddleware,
  getUptimeMetrics,
  resetUptimeMetrics,
  getSystemHealth,
  generateUptimeReport,
  periodicUptimeLogging,
};
