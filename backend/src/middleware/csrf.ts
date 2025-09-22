import { Request, Response, NextFunction } from 'express';
import csrf from 'csurf';
import { logSecurityEvent } from '../config/security';
import logger from '../utils/logger';

// Configuration CSRF
const csrfProtection = csrf({
  cookie: {
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    sameSite: 'strict' as const,
    maxAge: 24 * 60 * 60 * 1000, // 24 heures
  },
  value: (req: Request) => {
    // Récupérer le token CSRF depuis le header ou le body
    return req.body._csrf || req.headers['x-csrf-token'] || req.headers['csrf-token'];
  },
});

/**
 * Middleware de protection CSRF
 */
export const csrfProtectionMiddleware = (req: Request, res: Response, next: NextFunction): void => {
  // Exclure certaines routes de la protection CSRF
  const excludedPaths = [
    '/api/health',
    '/api/ready',
    '/api/live',
    '/api/metrics',
    '/api/webhooks/stripe', // Webhooks externes
  ];

  if (excludedPaths.some(path => req.path.startsWith(path))) {
    return next();
  }

  // Appliquer la protection CSRF
  csrfProtection(req, res, err => {
    if (err) {
      logSecurityEvent('CSRF token validation failed', {
        ip: req.ip,
        url: req.url,
        method: req.method,
        error: err.message,
        userAgent: req.get('User-Agent'),
      });

      res.status(403).json({
        error: 'CSRF token validation failed',
        message: 'Invalid or missing CSRF token',
        code: 'CSRF_ERROR',
      });
      return;
    }

    next();
  });
};

/**
 * Middleware pour fournir le token CSRF aux clients
 */
export const provideCsrfToken = (req: Request, res: Response, next: NextFunction): void => {
  // Ajouter le token CSRF à la réponse pour les clients
  res.locals.csrfToken = req.csrfToken();

  // Ajouter le token dans les headers pour les clients SPA
  res.setHeader('X-CSRF-Token', req.csrfToken());

  next();
};

/**
 * Middleware pour les routes qui nécessitent un token CSRF
 */
export const requireCsrfToken = (req: Request, res: Response, next: NextFunction): void => {
  const token = req.body._csrf || req.headers['x-csrf-token'] || req.headers['csrf-token'];

  if (!token) {
    logSecurityEvent('CSRF token missing', {
      ip: req.ip,
      url: req.url,
      method: req.method,
      userAgent: req.get('User-Agent'),
    });

    res.status(403).json({
      error: 'CSRF token required',
      message: 'CSRF token is required for this request',
      code: 'CSRF_TOKEN_REQUIRED',
    });
    return;
  }

  next();
};

/**
 * Fonction utilitaire pour valider le token CSRF
 */
export const validateCsrfToken = (req: Request, token: string): boolean => {
  try {
    return req.csrfToken() === token;
  } catch (error) {
    logger.error('CSRF token validation error', { error });
    return false;
  }
};

/**
 * Middleware pour les routes d'authentification avec CSRF
 */
export const authCsrfProtection = (req: Request, res: Response, next: NextFunction): void => {
  // Pour les routes d'authentification, on peut être plus permissif
  if (req.method === 'GET') {
    return next();
  }

  // Vérifier si c'est une requête de login/register
  if (req.path.includes('/auth/login') || req.path.includes('/auth/register')) {
    // Pour les routes d'auth, on peut accepter les tokens dans le body ou les headers
    const token = req.body._csrf || req.headers['x-csrf-token'];

    if (!token) {
      logSecurityEvent('CSRF token missing for auth route', {
        ip: req.ip,
        url: req.url,
        method: req.method,
      });

      res.status(403).json({
        error: 'CSRF token required',
        message: 'CSRF token is required for authentication',
        code: 'AUTH_CSRF_REQUIRED',
      });
      return;
    }
  }

  next();
};
