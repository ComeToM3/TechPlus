import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
import { Request, Response, NextFunction } from 'express';
import logger from '../utils/logger';

/**
 * Configuration de sécurité complète pour l'application
 */

// Configuration Helmet pour les headers de sécurité
export const helmetConfig = helmet({
  // Content Security Policy
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'", 'https://fonts.googleapis.com'],
      fontSrc: ["'self'", 'https://fonts.gstatic.com'],
      imgSrc: ["'self'", 'data:', 'https:'],
      scriptSrc: ["'self'"],
      connectSrc: ["'self'"],
      frameSrc: ["'none'"],
      objectSrc: ["'none'"],
      mediaSrc: ["'self'"],
      manifestSrc: ["'self'"],
      workerSrc: ["'self'"],
      childSrc: ["'none'"],
      formAction: ["'self'"],
      frameAncestors: ["'none'"],
      baseUri: ["'self'"],
      upgradeInsecureRequests: [],
    },
  },

  // X-Frame-Options
  frameguard: { action: 'deny' },

  // X-Content-Type-Options
  noSniff: true,

  // X-XSS-Protection
  xssFilter: true,

  // Strict-Transport-Security
  hsts: {
    maxAge: 31536000, // 1 an
    includeSubDomains: true,
    preload: true,
  },

  // Referrer Policy
  referrerPolicy: { policy: 'strict-origin-when-cross-origin' },

  // Permissions Policy (removed as it's not supported in current helmet version)

  // Cross-Origin Embedder Policy
  crossOriginEmbedderPolicy: false, // Désactivé pour compatibilité

  // Cross-Origin Opener Policy
  crossOriginOpenerPolicy: { policy: 'same-origin' },

  // Cross-Origin Resource Policy
  crossOriginResourcePolicy: { policy: 'cross-origin' },
});

// Configuration CORS stricte
export const corsConfig = {
  origin: (origin: string | undefined, callback: (err: Error | null, allow?: boolean) => void) => {
    // Liste des origines autorisées
    const allowedOrigins = [
      'http://localhost:3000',
      'http://localhost:3001',
      'http://localhost:8080',
      'https://techplus.com',
      'https://www.techplus.com',
      'https://staging.techplus.com',
    ];

    // En développement, autoriser localhost
    if (process.env.NODE_ENV === 'development') {
      allowedOrigins.push(
        'http://localhost:3000',
        'http://localhost:3001',
        'http://localhost:8080',
        'http://localhost:8081',
        'http://localhost:8082',
        'http://localhost:8083',
        'http://localhost:8084',
        'http://localhost:8085',
        'http://localhost:8086',
        'http://localhost:8087',
        'http://localhost:8088',
        'http://localhost:8089',
        'http://localhost:8090',
        'http://localhost:8091',
        'http://localhost:8092',
        'http://localhost:8093',
        'http://localhost:8094',
        'http://localhost:8095',
        'http://localhost:8096',
        'http://localhost:8097',
        'http://localhost:8098',
        'http://localhost:8099',
        'http://localhost:8100',
        'http://127.0.0.1:3000',
        'http://127.0.0.1:3001',
        'http://127.0.0.1:8080',
        'http://127.0.0.1:8081',
        'http://127.0.0.1:8082',
        'http://127.0.0.1:8083',
        'http://127.0.0.1:8084',
        'http://127.0.0.1:8085',
        'http://127.0.0.1:8086',
        'http://127.0.0.1:8087',
        'http://127.0.0.1:8088',
        'http://127.0.0.1:8089',
        'http://127.0.0.1:8090',
        'http://127.0.0.1:8091',
        'http://127.0.0.1:8092',
        'http://127.0.0.1:8093',
        'http://127.0.0.1:8094',
        'http://127.0.0.1:8095',
        'http://127.0.0.1:8096',
        'http://127.0.0.1:8097',
        'http://127.0.0.1:8098',
        'http://127.0.0.1:8099',
        'http://127.0.0.1:8100'
      );

      // Autoriser tous les ports Flutter Web (ports dynamiques)
      for (let port = 30000; port <= 65000; port++) {
        allowedOrigins.push(`http://127.0.0.1:${port}`);
        allowedOrigins.push(`http://localhost:${port}`);
      }
    }

    // Autoriser les requêtes sans origine (mobile apps, Postman, etc.)
    if (!origin) return callback(null, true);

    if (allowedOrigins.includes(origin)) {
      callback(null, true);
    } else {
      logger.warn('CORS blocked request from origin', { origin });
      callback(new Error('Not allowed by CORS'), false);
    }
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: [
    'Origin',
    'X-Requested-With',
    'Content-Type',
    'Accept',
    'Authorization',
    'X-CSRF-Token',
    'X-API-Key',
  ],
  exposedHeaders: ['X-Total-Count', 'X-Page-Count'],
  maxAge: 86400, // 24 heures
};

// Rate limiting général
export const generalRateLimit = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // 100 requêtes par IP par fenêtre
  message: {
    error: 'Too many requests from this IP, please try again later.',
    retryAfter: '15 minutes',
  },
  standardHeaders: true,
  legacyHeaders: false,
  handler: (req: Request, res: Response) => {
    logger.warn('Rate limit exceeded', {
      ip: req.ip,
      userAgent: req.get('User-Agent'),
      url: req.url,
      method: req.method,
    });

    res.status(429).json({
      error: 'Too many requests from this IP, please try again later.',
      retryAfter: '15 minutes',
    });
  },
});

// Rate limiting pour l'authentification
export const authRateLimit = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // 5 tentatives de connexion par IP par fenêtre
  message: {
    error: 'Too many authentication attempts, please try again later.',
    retryAfter: '15 minutes',
  },
  standardHeaders: true,
  legacyHeaders: false,
  skipSuccessfulRequests: true, // Ne pas compter les requêtes réussies
  handler: (req: Request, res: Response) => {
    logger.warn('Auth rate limit exceeded', {
      ip: req.ip,
      userAgent: req.get('User-Agent'),
      url: req.url,
      method: req.method,
    });

    res.status(429).json({
      error: 'Too many authentication attempts, please try again later.',
      retryAfter: '15 minutes',
    });
  },
});

// Rate limiting pour la réinitialisation de mot de passe
export const passwordResetRateLimit = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 heure
  max: 3, // 3 tentatives par IP par heure
  message: {
    error: 'Too many password reset attempts, please try again later.',
    retryAfter: '1 hour',
  },
  standardHeaders: true,
  legacyHeaders: false,
  handler: (req: Request, res: Response) => {
    logger.warn('Password reset rate limit exceeded', {
      ip: req.ip,
      userAgent: req.get('User-Agent'),
      url: req.url,
      method: req.method,
    });

    res.status(429).json({
      error: 'Too many password reset attempts, please try again later.',
      retryAfter: '1 hour',
    });
  },
});

// Rate limiting pour les API publiques
export const publicApiRateLimit = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 200, // 200 requêtes par IP par fenêtre
  message: {
    error: 'Too many requests to public API, please try again later.',
    retryAfter: '15 minutes',
  },
  standardHeaders: true,
  legacyHeaders: false,
  handler: (req: Request, res: Response) => {
    logger.warn('Public API rate limit exceeded', {
      ip: req.ip,
      userAgent: req.get('User-Agent'),
      url: req.url,
      method: req.method,
    });

    res.status(429).json({
      error: 'Too many requests to public API, please try again later.',
      retryAfter: '15 minutes',
    });
  },
});

// Middleware de validation des headers de sécurité
export const securityHeadersMiddleware = (
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  // Vérifier la présence de headers suspects
  const suspiciousHeaders = [
    'x-forwarded-for',
    'x-real-ip',
    'x-cluster-client-ip',
    'x-forwarded',
    'forwarded-for',
    'forwarded',
  ];

  const hasSuspiciousHeaders = suspiciousHeaders.some(
    header =>
      req.headers[header] &&
      typeof req.headers[header] === 'string' &&
      (req.headers[header] as string).includes('..')
  );

  if (hasSuspiciousHeaders) {
    logger.warn('Suspicious headers detected', {
      ip: req.ip,
      headers: req.headers,
      url: req.url,
      method: req.method,
    });

    res.status(400).json({
      error: 'Invalid request headers',
    });
    return;
  }

  // Vérifier la taille des headers
  const headerSize = JSON.stringify(req.headers).length;
  if (headerSize > 8192) {
    // 8KB max
    logger.warn('Headers too large', {
      ip: req.ip,
      headerSize,
      url: req.url,
      method: req.method,
    });

    res.status(400).json({
      error: 'Request headers too large',
    });
    return;
  }

  next();
};

// Middleware de protection contre les attaques par déni de service
export const dosProtectionMiddleware = (req: Request, res: Response, next: NextFunction): void => {
  // Vérifier la taille du body
  const contentLength = parseInt(req.get('Content-Length') || '0');
  const maxBodySize = 10 * 1024 * 1024; // 10MB

  if (contentLength > maxBodySize) {
    logger.warn('Request body too large', {
      ip: req.ip,
      contentLength,
      maxBodySize,
      url: req.url,
      method: req.method,
    });

    res.status(413).json({
      error: 'Request body too large',
      maxSize: '10MB',
    });
    return;
  }

  // Vérifier le nombre de paramètres de requête
  const queryParams = Object.keys(req.query).length;
  if (queryParams > 50) {
    logger.warn('Too many query parameters', {
      ip: req.ip,
      queryParams,
      url: req.url,
      method: req.method,
    });

    res.status(400).json({
      error: 'Too many query parameters',
      maxParams: 50,
    });
    return;
  }

  next();
};

// Middleware de protection contre les attaques par énumération
export const enumerationProtectionMiddleware = (
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  // Masquer les erreurs d'authentification pour éviter l'énumération d'utilisateurs
  if (req.path.includes('/auth/login') || req.path.includes('/auth/register')) {
    const originalJson = res.json;
    res.json = function (body: any) {
      // Si c'est une erreur d'authentification, masquer les détails
      if (res.statusCode >= 400 && body?.error) {
        const maskedBody = {
          error: 'Authentication failed',
          timestamp: new Date().toISOString(),
        };
        return originalJson.call(this, maskedBody);
      }
      return originalJson.call(this, body);
    };
  }

  next();
};

// Configuration de sécurité pour les sessions
export const sessionSecurityConfig = {
  name: 'techplus.sid',
  secret: process.env.SESSION_SECRET || 'your-super-secret-session-key-change-in-production',
  resave: false,
  saveUninitialized: false,
  rolling: true, // Renouveler la session à chaque requête
  cookie: {
    secure: process.env.NODE_ENV === 'production', // HTTPS uniquement en production
    httpOnly: true, // Empêcher l'accès via JavaScript
    maxAge: 24 * 60 * 60 * 1000, // 24 heures
    sameSite: 'strict' as const, // Protection CSRF
    domain: process.env.NODE_ENV === 'production' ? '.techplus.com' : undefined,
  },
};

// Configuration CSRF
export const csrfConfig = {
  cookie: {
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    sameSite: 'strict' as const,
    maxAge: 24 * 60 * 60 * 1000, // 24 heures
  },
  // Routes exclues de la protection CSRF
  excludedPaths: [
    '/api/health',
    '/api/ready',
    '/api/live',
    '/api/metrics',
    '/api/webhooks/stripe', // Webhooks externes
  ],
};

// Fonction utilitaire pour valider les origines
export const validateOrigin = (origin: string): boolean => {
  const allowedOrigins = [
    'http://localhost:3000',
    'http://localhost:3001',
    'http://localhost:8080',
    'https://techplus.com',
    'https://www.techplus.com',
    'https://staging.techplus.com',
  ];

  if (process.env.NODE_ENV === 'development') {
    allowedOrigins.push('http://localhost:3000', 'http://localhost:3001', 'http://localhost:8080');
  }

  return allowedOrigins.includes(origin);
};

// Fonction utilitaire pour logger les tentatives de sécurité
export const logSecurityEvent = (event: string, details: Record<string, any>): void => {
  logger.warn('Security Event', {
    event,
    ...details,
    timestamp: new Date().toISOString(),
    severity: 'medium',
  });
};
