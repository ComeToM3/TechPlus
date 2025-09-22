import rateLimit from 'express-rate-limit';
import { config } from '@/config/environment';

/**
 * Rate limiter général pour l'API
 */
export const generalLimiter = rateLimit({
  windowMs: config.rateLimit.windowMs, // 15 minutes par défaut
  max: config.rateLimit.max, // 100 requêtes par fenêtre
  message: {
    error: 'Too many requests',
    message: 'Too many requests from this IP, please try again later.',
    retryAfter: Math.ceil(config.rateLimit.windowMs / 1000),
  },
  standardHeaders: true,
  legacyHeaders: false,
  // Ignorer les requêtes de health check
  skip: req => req.path === '/health',
});

/**
 * Rate limiter strict pour l'authentification
 */
export const authLimiter = rateLimit({
  windowMs: config.rateLimit.authWindowMs, // 15 minutes
  max: config.rateLimit.authMax, // 5 tentatives par fenêtre
  message: {
    error: 'Too many authentication attempts',
    message: 'Too many login attempts, please try again later.',
    retryAfter: Math.ceil(config.rateLimit.authWindowMs / 1000),
  },
  standardHeaders: true,
  legacyHeaders: false,
  // Utiliser l'IP par défaut (gère IPv4 et IPv6 automatiquement)
});

/**
 * Rate limiter pour les réservations
 */
export const reservationLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 10, // 10 réservations par fenêtre
  message: {
    error: 'Too many reservation attempts',
    message: 'Too many reservation attempts, please try again later.',
    retryAfter: 900, // 15 minutes
  },
  standardHeaders: true,
  legacyHeaders: false,
});

/**
 * Rate limiter pour les tokens de gestion
 */
export const managementTokenLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 20, // 20 tentatives par fenêtre
  message: {
    error: 'Too many management token attempts',
    message: 'Too many attempts to access management tokens, please try again later.',
    retryAfter: 900, // 15 minutes
  },
  standardHeaders: true,
  legacyHeaders: false,
});

/**
 * Rate limiter pour les paiements
 */
export const paymentLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // 5 tentatives de paiement par fenêtre
  message: {
    error: 'Too many payment attempts',
    message: 'Too many payment attempts, please try again later.',
    retryAfter: 900, // 15 minutes
  },
  standardHeaders: true,
  legacyHeaders: false,
});

/**
 * Rate limiter pour les webhooks Stripe
 */
export const webhookLimiter = rateLimit({
  windowMs: 1 * 60 * 1000, // 1 minute
  max: 100, // 100 webhooks par minute
  message: {
    error: 'Too many webhook requests',
    message: 'Too many webhook requests from this IP.',
    retryAfter: 60, // 1 minute
  },
  standardHeaders: true,
  legacyHeaders: false,
  // Ignorer les webhooks Stripe légitimes
  skip: req => {
    const userAgent = req.get('User-Agent') || '';
    return userAgent.includes('Stripe');
  },
});

/**
 * Rate limiter pour les notifications
 */
export const notificationLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 heure
  max: 50, // 50 notifications par heure
  message: {
    error: 'Too many notification requests',
    message: 'Too many notification requests, please try again later.',
    retryAfter: 3600, // 1 heure
  },
  standardHeaders: true,
  legacyHeaders: false,
});

/**
 * Rate limiter pour les uploads de fichiers
 */
export const uploadLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 heure
  max: 20, // 20 uploads par heure
  message: {
    error: 'Too many file uploads',
    message: 'Too many file uploads, please try again later.',
    retryAfter: 3600, // 1 heure
  },
  standardHeaders: true,
  legacyHeaders: false,
});

/**
 * Rate limiter pour les requêtes d'administration
 */
export const adminLimiter = rateLimit({
  windowMs: 5 * 60 * 1000, // 5 minutes
  max: 200, // 200 requêtes par fenêtre
  message: {
    error: 'Too many admin requests',
    message: 'Too many admin requests, please try again later.',
    retryAfter: 300, // 5 minutes
  },
  standardHeaders: true,
  legacyHeaders: false,
});

/**
 * Rate limiter pour les requêtes d'analytics
 */
export const analyticsLimiter = rateLimit({
  windowMs: 60 * 1000, // 1 minute
  max: 30, // 30 requêtes par minute
  message: {
    error: 'Too many analytics requests',
    message: 'Too many analytics requests, please try again later.',
    retryAfter: 60, // 1 minute
  },
  standardHeaders: true,
  legacyHeaders: false,
});

/**
 * Middleware pour créer un rate limiter personnalisé
 */
export const createCustomLimiter = (options: {
  windowMs: number;
  max: number;
  message?: string;
  keyGenerator?: (req: any) => string;
  skip?: (req: any) => boolean;
}) => {
  const rateLimitOptions: any = {
    windowMs: options.windowMs,
    max: options.max,
    message: {
      error: 'Rate limit exceeded',
      message: options.message || 'Too many requests, please try again later.',
      retryAfter: Math.ceil(options.windowMs / 1000),
    },
    standardHeaders: true,
    legacyHeaders: false,
  };

  if (options.keyGenerator) {
    rateLimitOptions.keyGenerator = options.keyGenerator;
  }

  if (options.skip) {
    rateLimitOptions.skip = options.skip;
  }

  return rateLimit(rateLimitOptions);
};
