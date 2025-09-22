import { Request, Response, NextFunction } from 'express';
import { PrismaClient } from '@prisma/client';
import logger from '../utils/logger';
import { captureMetric, addSentryBreadcrumb } from '../config/sentry-simple';

/**
 * Interface pour les métriques de base de données
 */
interface DatabaseMetrics {
  queryCount: number;
  totalQueryTime: number;
  averageQueryTime: number;
  slowQueryCount: number;
  errorCount: number;
  connectionCount: number;
  lastQueryTime: number;
  slowQueries: Array<{
    query: string;
    duration: number;
    timestamp: number;
  }>;
}

/**
 * Métriques globales de base de données
 */
const dbMetrics: DatabaseMetrics = {
  queryCount: 0,
  totalQueryTime: 0,
  averageQueryTime: 0,
  slowQueryCount: 0,
  errorCount: 0,
  connectionCount: 0,
  lastQueryTime: 0,
  slowQueries: [],
};

/**
 * Configuration du monitoring de base de données
 */
export const setupDatabaseMonitoring = (prisma: PrismaClient): void => {
  // Note: Prisma $use n'est pas disponible dans cette version
  // Utiliser un wrapper ou middleware personnalisé à la place
  logger.info('Database monitoring setup (simplified version)');
};

/**
 * Middleware pour capturer les métriques de connexion
 */
export const databaseConnectionMonitoring = (
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  // Capturer les métriques de connexion
  captureMetric('database.connection.check', 1, 'none', {
    endpoint: req.path,
  });

  next();
};

/**
 * Fonction pour obtenir les métriques de base de données
 */
export const getDatabaseMetrics = (): DatabaseMetrics & {
  errorRate: number;
  slowQueryRate: number;
  queriesPerMinute: number;
} => {
  const now = Date.now();
  const uptime = now - (dbMetrics.lastQueryTime || now);
  const uptimeMinutes = uptime / (1000 * 60);

  return {
    ...dbMetrics,
    errorRate: dbMetrics.queryCount > 0 ? (dbMetrics.errorCount / dbMetrics.queryCount) * 100 : 0,
    slowQueryRate:
      dbMetrics.queryCount > 0 ? (dbMetrics.slowQueryCount / dbMetrics.queryCount) * 100 : 0,
    queriesPerMinute: uptimeMinutes > 0 ? dbMetrics.queryCount / uptimeMinutes : 0,
  };
};

/**
 * Fonction pour réinitialiser les métriques de base de données
 */
export const resetDatabaseMetrics = (): void => {
  dbMetrics.queryCount = 0;
  dbMetrics.totalQueryTime = 0;
  dbMetrics.averageQueryTime = 0;
  dbMetrics.slowQueryCount = 0;
  dbMetrics.errorCount = 0;
  dbMetrics.connectionCount = 0;
  dbMetrics.lastQueryTime = 0;
  dbMetrics.slowQueries = [];

  logger.info('Database metrics reset');
};

/**
 * Fonction pour analyser les performances de base de données
 */
export const analyzeDatabasePerformance = (): {
  status: 'excellent' | 'good' | 'warning' | 'critical';
  score: number;
  recommendations: string[];
  metrics: DatabaseMetrics;
} => {
  const metrics = getDatabaseMetrics();
  let score = 100;
  const recommendations: string[] = [];

  // Analyser le taux d'erreur
  if (metrics.errorRate > 5) {
    score -= 30;
    recommendations.push('High error rate detected. Check database connectivity and query syntax.');
  } else if (metrics.errorRate > 1) {
    score -= 15;
    recommendations.push('Moderate error rate. Monitor database health.');
  }

  // Analyser les requêtes lentes
  if (metrics.slowQueryRate > 10) {
    score -= 25;
    recommendations.push(
      'High percentage of slow queries. Consider query optimization and indexing.'
    );
  } else if (metrics.slowQueryRate > 5) {
    score -= 10;
    recommendations.push('Some slow queries detected. Review query performance.');
  }

  // Analyser le temps de réponse moyen
  if (metrics.averageQueryTime > 500) {
    score -= 20;
    recommendations.push('Average query time is high. Consider database optimization.');
  } else if (metrics.averageQueryTime > 200) {
    score -= 10;
    recommendations.push('Query response time could be improved.');
  }

  // Analyser le volume de requêtes
  if (metrics.queriesPerMinute > 100) {
    score -= 5;
    recommendations.push('High query volume. Consider connection pooling optimization.');
  }

  let status: 'excellent' | 'good' | 'warning' | 'critical';
  if (score >= 90) {
    status = 'excellent';
  } else if (score >= 75) {
    status = 'good';
  } else if (score >= 50) {
    status = 'warning';
  } else {
    status = 'critical';
  }

  return {
    status,
    score,
    recommendations,
    metrics,
  };
};

/**
 * Fonction pour générer un rapport de performance de base de données
 */
export const generateDatabaseReport = (): {
  summary: {
    totalQueries: number;
    averageQueryTime: number;
    errorRate: number;
    slowQueryRate: number;
    queriesPerMinute: number;
    performanceScore: number;
    status: string;
  };
  slowQueries: Array<{
    query: string;
    duration: number;
    timestamp: string;
  }>;
  recommendations: string[];
  timestamp: string;
} => {
  const analysis = analyzeDatabasePerformance();
  const metrics = getDatabaseMetrics();

  return {
    summary: {
      totalQueries: metrics.queryCount,
      averageQueryTime: Math.round(metrics.averageQueryTime * 100) / 100,
      errorRate: Math.round(metrics.errorRate * 100) / 100,
      slowQueryRate: Math.round(metrics.slowQueryRate * 100) / 100,
      queriesPerMinute: Math.round(metrics.queriesPerMinute * 100) / 100,
      performanceScore: analysis.score,
      status: analysis.status,
    },
    slowQueries: metrics.slowQueries.map(query => ({
      query: query.query,
      duration: query.duration,
      timestamp: new Date(query.timestamp).toISOString(),
    })),
    recommendations: analysis.recommendations,
    timestamp: new Date().toISOString(),
  };
};

/**
 * Middleware pour logger les métriques de base de données périodiquement
 */
export const periodicDatabaseLogging = (): void => {
  setInterval(
    () => {
      const report = generateDatabaseReport();

      if (report.summary.status === 'critical') {
        logger.error('Database performance critical', report);
      } else if (report.summary.status === 'warning') {
        logger.warn('Database performance warning', report);
      } else {
        logger.info('Database performance check', report);
      }
    },
    10 * 60 * 1000
  ); // Toutes les 10 minutes
};

/**
 * Fonction pour surveiller les connexions de base de données
 */
export const monitorDatabaseConnections = async (
  prisma: PrismaClient
): Promise<{
  activeConnections: number;
  maxConnections: number;
  connectionUtilization: number;
  status: 'healthy' | 'warning' | 'critical';
}> => {
  try {
    // Exécuter une requête simple pour tester la connexion
    const startTime = Date.now();
    await prisma.$queryRaw`SELECT 1`;
    const responseTime = Date.now() - startTime;

    // Capturer les métriques de connexion
    captureMetric('database.connection.response_time', responseTime, 'millisecond');
    captureMetric('database.connection.test', 1, 'none');

    // Simuler les métriques de connexion (dans un vrai environnement,
    // vous utiliseriez les métriques réelles de PostgreSQL)
    const activeConnections = Math.floor(Math.random() * 20) + 5; // Simulation
    const maxConnections = 100; // Configuration typique
    const connectionUtilization = (activeConnections / maxConnections) * 100;

    let status: 'healthy' | 'warning' | 'critical';
    if (connectionUtilization > 80) {
      status = 'critical';
    } else if (connectionUtilization > 60) {
      status = 'warning';
    } else {
      status = 'healthy';
    }

    return {
      activeConnections,
      maxConnections,
      connectionUtilization: Math.round(connectionUtilization * 100) / 100,
      status,
    };
  } catch (error) {
    logger.error('Database connection monitoring failed', {
      error: error instanceof Error ? error.message : 'Unknown error',
    });

    return {
      activeConnections: 0,
      maxConnections: 100,
      connectionUtilization: 0,
      status: 'critical',
    };
  }
};

export default {
  setupDatabaseMonitoring,
  databaseConnectionMonitoring,
  getDatabaseMetrics,
  resetDatabaseMetrics,
  analyzeDatabasePerformance,
  generateDatabaseReport,
  periodicDatabaseLogging,
  monitorDatabaseConnections,
};
