import { Request, Response, NextFunction } from 'express';
import { httpLogger } from '../utils/logger';

/**
 * Middleware de logging des requêtes HTTP
 * Enregistre toutes les requêtes avec leurs métriques de performance
 */
export const httpLoggingMiddleware = (req: Request, res: Response, next: NextFunction) => {
  const startTime = Date.now();

  // Intercepter la méthode end de la réponse pour calculer le temps de réponse
  const originalEnd = res.end;
  res.end = function(chunk?: any, encoding?: any): Response {
    const responseTime = Date.now() - startTime;
    
    // Log de la requête HTTP
    httpLogger.http('HTTP Request', {
      method: req.method,
      url: req.url,
      statusCode: res.statusCode,
      responseTime: `${responseTime}ms`,
      userAgent: req.get('User-Agent'),
      ip: req.ip || req.connection.remoteAddress,
      userId: (req as any).user?.id || null,
      contentLength: res.get('Content-Length') || 0,
      referer: req.get('Referer'),
    });

    // Appeler la méthode end originale
    return originalEnd.call(this, chunk, encoding);
  };

  next();
};

/**
 * Middleware de logging des erreurs
 * Capture et enregistre toutes les erreurs non gérées
 */
export const errorLoggingMiddleware = (err: Error, req: Request, res: Response, next: NextFunction) => {
  httpLogger.error('Unhandled Error', {
    error: err.message,
    stack: err.stack,
    method: req.method,
    url: req.url,
    ip: req.ip || req.connection.remoteAddress,
    userAgent: req.get('User-Agent'),
    userId: (req as any).user?.id || null,
  });

  next(err);
};

/**
 * Middleware de logging des requêtes lentes
 * Alerte sur les requêtes qui prennent plus de temps que le seuil défini
 */
export const slowRequestLoggingMiddleware = (thresholdMs: number = 1000) => {
  return (req: Request, res: Response, next: NextFunction) => {
    const startTime = Date.now();

    const originalEnd = res.end;
    res.end = function(chunk?: any, encoding?: any): Response {
      const responseTime = Date.now() - startTime;
      
      if (responseTime > thresholdMs) {
        httpLogger.warn('Slow Request Detected', {
          method: req.method,
          url: req.url,
          responseTime: `${responseTime}ms`,
          threshold: `${thresholdMs}ms`,
          ip: req.ip || req.connection.remoteAddress,
          userId: (req as any).user?.id || null,
        });
      }

      return originalEnd.call(this, chunk, encoding);
    };

    next();
  };
};

/**
 * Middleware de logging des tentatives d'authentification
 * Enregistre les tentatives de connexion (succès et échecs)
 */
export const authLoggingMiddleware = (req: Request, res: Response, next: NextFunction) => {
  const originalJson = res.json;
  
  res.json = function(body: any) {
    // Log des tentatives d'authentification
    if (req.path.includes('/auth/login') || req.path.includes('/auth/register')) {
      const isSuccess = res.statusCode >= 200 && res.statusCode < 300;
      
      httpLogger.info('Authentication Attempt', {
        method: req.method,
        path: req.path,
        success: isSuccess,
        statusCode: res.statusCode,
        ip: req.ip || req.connection.remoteAddress,
        userAgent: req.get('User-Agent'),
        email: req.body?.email || null,
        userId: body?.user?.id || null,
      });
    }

    return originalJson.call(this, body);
  };

  next();
};

/**
 * Middleware de logging des opérations sensibles
 * Enregistre les opérations qui modifient des données importantes
 */
export const sensitiveOperationLoggingMiddleware = (req: Request, res: Response, next: NextFunction) => {
  const originalJson = res.json;
  
  res.json = function(body: any) {
    // Log des opérations sensibles
    const sensitivePaths = [
      '/api/reservations',
      '/api/admin',
      '/api/payments',
      '/api/users',
    ];

    const isSensitiveOperation = sensitivePaths.some(path => req.path.includes(path));
    const isModifyingOperation = ['POST', 'PUT', 'PATCH', 'DELETE'].includes(req.method);

    if (isSensitiveOperation && isModifyingOperation) {
      httpLogger.info('Sensitive Operation', {
        method: req.method,
        path: req.path,
        statusCode: res.statusCode,
        ip: req.ip || req.connection.remoteAddress,
        userId: (req as any).user?.id || null,
        userRole: (req as any).user?.role || null,
        operation: `${req.method} ${req.path}`,
        success: res.statusCode >= 200 && res.statusCode < 300,
      });
    }

    return originalJson.call(this, body);
  };

  next();
};
