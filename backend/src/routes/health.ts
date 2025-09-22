import { Router, Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { createClient } from 'redis';
import { getPerformanceMetrics, getMemoryUsage, getUptime } from '../utils/performance';
import { getUptimeMetrics, getSystemHealth, generateUptimeReport } from '../middleware/uptime';
import { getDatabaseMetrics, generateDatabaseReport, monitorDatabaseConnections } from '../middleware/database-monitoring';
import logger from '../utils/logger';

const router = Router();
const prisma = new PrismaClient();

// Configuration Redis
const redis = createClient({
  url: process.env.REDIS_URL || 'redis://localhost:6379/0'
});

/**
 * Health Check Endpoint
 * Vérifie l'état général de l'application
 */
router.get('/health', async (req: Request, res: Response) => {
  try {
    const healthCheck = {
      status: 'healthy',
      timestamp: new Date().toISOString(),
      uptime: getUptime(),
      environment: process.env.NODE_ENV || 'development',
      version: process.env.npm_package_version || '1.0.0',
    };

    logger.info('Health check requested', { ip: req.ip });
    res.status(200).json(healthCheck);
  } catch (error) {
    logger.error('Health check failed', { error: error instanceof Error ? error.message : 'Unknown error' });
    res.status(500).json({
      status: 'unhealthy',
      timestamp: new Date().toISOString(),
      error: 'Internal server error',
    });
  }
});

/**
 * Readiness Check Endpoint
 * Vérifie si l'application est prête à recevoir du trafic
 */
router.get('/ready', async (req: Request, res: Response) => {
  const checks = {
    database: false,
    redis: false,
    timestamp: new Date().toISOString(),
  };

  try {
    // Vérification de la base de données
    await prisma.$queryRaw`SELECT 1`;
    checks.database = true;
  } catch (error) {
    logger.error('Database readiness check failed', { error: error instanceof Error ? error.message : 'Unknown error' });
  }

  try {
    // Vérification de Redis
    if (redis.isOpen) {
      await redis.ping();
      checks.redis = true;
    } else {
      await redis.connect();
      await redis.ping();
      checks.redis = true;
    }
  } catch (error) {
    logger.error('Redis readiness check failed', { error: error instanceof Error ? error.message : 'Unknown error' });
  }

  const isReady = checks.database && checks.redis;
  const statusCode = isReady ? 200 : 503;

  logger.info('Readiness check', { ...checks, isReady });

  res.status(statusCode).json({
    status: isReady ? 'ready' : 'not ready',
    checks,
  });
});

/**
 * Liveness Check Endpoint
 * Vérifie si l'application est vivante (simple ping)
 */
router.get('/live', (req: Request, res: Response) => {
  res.status(200).json({
    status: 'alive',
    timestamp: new Date().toISOString(),
    uptime: getUptime(),
  });
});

/**
 * Metrics Endpoint
 * Retourne les métriques de performance de l'application
 */
router.get('/metrics', (req: Request, res: Response) => {
  try {
    const metrics = {
      performance: getPerformanceMetrics(),
      memory: getMemoryUsage(),
      uptime: getUptime(),
      timestamp: new Date().toISOString(),
    };

    logger.info('Metrics requested', { ip: req.ip });
    res.status(200).json(metrics);
  } catch (error) {
    logger.error('Metrics request failed', { error: error instanceof Error ? error.message : 'Unknown error' });
    res.status(500).json({
      error: 'Failed to retrieve metrics',
      timestamp: new Date().toISOString(),
    });
  }
});

/**
 * Database Status Endpoint
 * Vérifie l'état de la base de données
 */
router.get('/db-status', async (req: Request, res: Response) => {
  try {
    const startTime = Date.now();
    
    // Test de connexion
    await prisma.$queryRaw`SELECT 1`;
    const connectionTime = Date.now() - startTime;

    // Statistiques de la base de données
    const stats = await prisma.$queryRaw`
      SELECT 
        schemaname,
        tablename,
        n_tup_ins as inserts,
        n_tup_upd as updates,
        n_tup_del as deletes
      FROM pg_stat_user_tables 
      ORDER BY n_tup_ins + n_tup_upd + n_tup_del DESC
      LIMIT 10
    `;

    const dbStatus = {
      status: 'connected',
      connectionTime: `${connectionTime}ms`,
      timestamp: new Date().toISOString(),
      stats,
    };

    logger.info('Database status check', { connectionTime });
    res.status(200).json(dbStatus);
  } catch (error) {
    logger.error('Database status check failed', { error: error instanceof Error ? error.message : 'Unknown error' });
    res.status(500).json({
      status: 'disconnected',
      error: error instanceof Error ? error.message : 'Unknown error',
      timestamp: new Date().toISOString(),
    });
  }
});

/**
 * Redis Status Endpoint
 * Vérifie l'état de Redis
 */
router.get('/redis-status', async (req: Request, res: Response) => {
  try {
    const startTime = Date.now();
    
    // Test de connexion
    const pong = await redis.ping();
    const connectionTime = Date.now() - startTime;

    // Informations Redis
    const info = await redis.info('memory');
    const memoryInfo = info.split('\n').reduce((acc: Record<string, string>, line: string) => {
      if (line.includes(':')) {
        const [key, value] = line.split(':');
        if (key && value) {
          acc[key] = value;
        }
      }
      return acc;
    }, {});

    const redisStatus = {
      status: 'connected',
      ping: pong,
      connectionTime: `${connectionTime}ms`,
      timestamp: new Date().toISOString(),
      memory: memoryInfo,
    };

    logger.info('Redis status check', { connectionTime });
    res.status(200).json(redisStatus);
  } catch (error) {
    logger.error('Redis status check failed', { error: error instanceof Error ? error.message : 'Unknown error' });
    res.status(500).json({
      status: 'disconnected',
      error: error instanceof Error ? error.message : 'Unknown error',
      timestamp: new Date().toISOString(),
    });
  }
});

/**
 * System Info Endpoint
 * Retourne les informations système
 */
router.get('/system', (req: Request, res: Response) => {
  try {
    const systemInfo = {
      nodeVersion: process.version,
      platform: process.platform,
      arch: process.arch,
      pid: process.pid,
      uptime: getUptime(),
      memory: getMemoryUsage(),
      cpuUsage: process.cpuUsage(),
      timestamp: new Date().toISOString(),
    };

    logger.info('System info requested', { ip: req.ip });
    res.status(200).json(systemInfo);
  } catch (error) {
    logger.error('System info request failed', { error: error instanceof Error ? error.message : 'Unknown error' });
    res.status(500).json({
      error: 'Failed to retrieve system info',
      timestamp: new Date().toISOString(),
    });
  }
});

/**
 * @route GET /api/health/uptime
 * @description Returns detailed uptime metrics and system health.
 * @access Admin (or restricted)
 */
router.get('/uptime', (req: Request, res: Response) => {
  logger.info('Uptime metrics requested', { ip: req.ip });
  const uptimeReport = generateUptimeReport();
  const systemHealth = getSystemHealth();

  res.status(200).json({
    ...uptimeReport,
    systemHealth,
  });
});

/**
 * @route GET /api/health/database
 * @description Returns detailed database performance metrics.
 * @access Admin (or restricted)
 */
router.get('/database', async (req: Request, res: Response) => {
  logger.info('Database metrics requested', { ip: req.ip });
  const databaseReport = generateDatabaseReport();
  const connectionStatus = await monitorDatabaseConnections(prisma);

  res.status(200).json({
    ...databaseReport,
    connectionStatus,
  });
});

export default router;
