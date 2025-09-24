import { Request, Response, NextFunction } from 'express';
import crypto from 'crypto';
import { logSecurityEvent } from '../config/security';
import logger from '../utils/logger';

// Store pour les tokens CSRF (en production, utiliser Redis)
const csrfTokens = new Map<string, { token: string; expires: number }>();

/**
 * Génère un token CSRF sécurisé
 */
const generateCsrfToken = (): string => {
  return crypto.randomBytes(32).toString('hex');
};

/**
 * Valide un token CSRF
 */
const validateCsrfToken = (sessionId: string, token: string): boolean => {
  const stored = csrfTokens.get(sessionId);
  if (!stored) return false;

  // Vérifier l'expiration
  if (Date.now() > stored.expires) {
    csrfTokens.delete(sessionId);
    return false;
  }

  // Vérifier le token
  return crypto.timingSafeEqual(Buffer.from(stored.token, 'hex'), Buffer.from(token, 'hex'));
};

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

  // Ignorer les méthodes GET, HEAD, OPTIONS
  if (['GET', 'HEAD', 'OPTIONS'].includes(req.method)) {
    return next();
  }

  const sessionId = req.sessionID ?? req.ip ?? 'anonymous';
  const token = req.body._csrf ?? req.headers['x-csrf-token'] ?? req.headers['csrf-token'];

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

  if (!validateCsrfToken(sessionId, token as string)) {
    logSecurityEvent('CSRF token validation failed', {
      ip: req.ip,
      url: req.url,
      method: req.method,
      error: 'Invalid CSRF token',
      userAgent: req.get('User-Agent'),
    });

    res.status(403).json({
      error: 'CSRF token validation failed',
      message: 'Invalid or expired CSRF token',
      code: 'CSRF_ERROR',
    });
    return;
  }

  next();
};

/**
 * Middleware pour fournir le token CSRF aux clients
 */
export const provideCsrfToken = (req: Request, res: Response, next: NextFunction): void => {
  const sessionId = req.sessionID ?? req.ip ?? 'anonymous';
  const token = generateCsrfToken();

  // Stocker le token avec expiration (24h)
  csrfTokens.set(sessionId, {
    token,
    expires: Date.now() + 24 * 60 * 60 * 1000,
  });

  // Ajouter le token CSRF à la réponse pour les clients
  res.locals.csrfToken = token;

  // Ajouter le token dans les headers pour les clients SPA
  res.setHeader('X-CSRF-Token', token);

  next();
};

/**
 * Middleware pour les routes qui nécessitent un token CSRF
 */
export const requireCsrfToken = (req: Request, res: Response, next: NextFunction): void => {
  const sessionId = req.sessionID ?? req.ip ?? 'anonymous';
  const token = req.body._csrf ?? req.headers['x-csrf-token'] ?? req.headers['csrf-token'];

  if (!token) {
    logSecurityEvent('CSRF token missing for protected route', {
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

  if (!validateCsrfToken(sessionId, token as string)) {
    logSecurityEvent('CSRF token validation failed for protected route', {
      ip: req.ip,
      url: req.url,
      method: req.method,
      userAgent: req.get('User-Agent'),
    });

    res.status(403).json({
      error: 'CSRF token validation failed',
      message: 'Invalid or expired CSRF token',
      code: 'CSRF_ERROR',
    });
    return;
  }

  next();
};

/**
 * Fonction utilitaire pour valider le token CSRF
 */
export const validateCsrfTokenUtil = (req: Request, token: string): boolean => {
  try {
    const sessionId = req.sessionID ?? req.ip ?? 'anonymous';
    return validateCsrfToken(sessionId, token);
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
    const sessionId = req.sessionID ?? req.ip ?? 'anonymous';
    const token = req.body._csrf ?? req.headers['x-csrf-token'];

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

    if (!validateCsrfToken(sessionId, token as string)) {
      logSecurityEvent('CSRF token validation failed for auth route', {
        ip: req.ip,
        url: req.url,
        method: req.method,
      });

      res.status(403).json({
        error: 'CSRF token validation failed',
        message: 'Invalid or expired CSRF token',
        code: 'CSRF_ERROR',
      });
      return;
    }
  }

  next();
};
