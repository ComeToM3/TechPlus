import { Request, Response, NextFunction } from 'express';
import { body, param, query, validationResult } from 'express-validator';
import Joi from 'joi';
import { logSecurityEvent } from '../config/security';
import logger from '../utils/logger';

/**
 * Middleware de validation des entrées avec express-validator
 */
export const validateInput = (validations: any[]) => {
  return async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    // Exécuter toutes les validations
    await Promise.all(validations.map(validation => validation.run(req)));

    // Vérifier les erreurs de validation
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      const errorDetails = errors.array().map(error => ({
        field: error.type === 'field' ? (error as any).path : 'unknown',
        message: error.msg,
        value: error.type === 'field' ? (error as any).value : undefined,
      }));

      logSecurityEvent('Input validation failed', {
        ip: req.ip,
        url: req.url,
        method: req.method,
        errors: errorDetails,
      });

      res.status(400).json({
        error: 'Validation failed',
        details: errorDetails,
      });
      return;
    }

    next();
  };
};

/**
 * Middleware de sanitization des entrées
 */
export const sanitizeInput = (req: Request, res: Response, next: NextFunction) => {
  // Sanitizer les paramètres de requête
  if (req.query) {
    for (const key in req.query) {
      if (typeof req.query[key] === 'string') {
        req.query[key] = sanitizeString(req.query[key] as string);
      }
    }
  }

  // Sanitizer les paramètres de route
  if (req.params) {
    for (const key in req.params) {
      if (typeof req.params[key] === 'string') {
        req.params[key] = sanitizeString(req.params[key] as string);
      }
    }
  }

  // Sanitizer le body
  if (req.body && typeof req.body === 'object') {
    req.body = sanitizeObject(req.body);
  }

  next();
};

/**
 * Fonction de sanitization des chaînes
 */
const sanitizeString = (str: string): string => {
  return str
    .replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, '') // Supprimer les scripts
    .replace(/<[^>]*>/g, '') // Supprimer les balises HTML
    .replace(/javascript:/gi, '') // Supprimer les liens JavaScript
    .replace(/on\w+\s*=/gi, '') // Supprimer les événements JavaScript
    .trim();
};

/**
 * Fonction de sanitization des objets
 */
const sanitizeObject = (obj: any): any => {
  if (typeof obj === 'string') {
    return sanitizeString(obj);
  }
  
  if (Array.isArray(obj)) {
    return obj.map(item => sanitizeObject(item));
  }
  
  if (obj && typeof obj === 'object') {
    const sanitized: any = {};
    for (const key in obj) {
      sanitized[key] = sanitizeObject(obj[key]);
    }
    return sanitized;
  }
  
  return obj;
};

/**
 * Middleware de validation avec Joi
 */
export const validateWithJoi = (schema: Joi.ObjectSchema) => {
  return (req: Request, res: Response, next: NextFunction): void => {
    const { error, value } = schema.validate(req.body, {
      abortEarly: false,
      stripUnknown: true,
      allowUnknown: false,
    });

    if (error) {
      const errorDetails = error.details.map(detail => ({
        field: detail.path.join('.'),
        message: detail.message,
        value: detail.context?.value,
      }));

      logSecurityEvent('Joi validation failed', {
        ip: req.ip,
        url: req.url,
        method: req.method,
        errors: errorDetails,
      });

      res.status(400).json({
        error: 'Validation failed',
        details: errorDetails,
      });
      return;
    }

    // Remplacer le body par la version validée et nettoyée
    req.body = value;
    next();
  };
};

/**
 * Middleware de protection contre les injections SQL
 */
export const sqlInjectionProtection = (req: Request, res: Response, next: NextFunction): void => {
  const sqlPatterns = [
    /(\b(SELECT|INSERT|UPDATE|DELETE|DROP|CREATE|ALTER|EXEC|UNION|SCRIPT)\b)/i,
    /(\b(OR|AND)\s+\d+\s*=\s*\d+)/i,
    /(\b(OR|AND)\s+['"]\s*=\s*['"])/i,
    /(\b(OR|AND)\s+1\s*=\s*1)/i,
    /(\b(OR|AND)\s+0\s*=\s*0)/i,
    /(UNION\s+SELECT)/i,
    /(DROP\s+TABLE)/i,
    /(DELETE\s+FROM)/i,
    /(INSERT\s+INTO)/i,
    /(UPDATE\s+SET)/i,
  ];

  const checkForSqlInjection = (value: any, path: string): boolean => {
    if (typeof value === 'string') {
      for (const pattern of sqlPatterns) {
        if (pattern.test(value)) {
          logSecurityEvent('SQL injection attempt detected', {
            ip: req.ip,
            url: req.url,
            method: req.method,
            path,
            value: value.substring(0, 100), // Limiter la taille du log
            pattern: pattern.toString(),
          });
          return true;
        }
      }
    } else if (typeof value === 'object' && value !== null) {
      for (const key in value) {
        if (checkForSqlInjection(value[key], `${path}.${key}`)) {
          return true;
        }
      }
    }
    return false;
  };

  // Vérifier le body
  if (req.body && checkForSqlInjection(req.body, 'body')) {
    res.status(400).json({
      error: 'Invalid input detected',
    });
    return;
  }

  // Vérifier les paramètres de requête
  if (req.query && checkForSqlInjection(req.query, 'query')) {
    res.status(400).json({
      error: 'Invalid input detected',
    });
    return;
  }

  // Vérifier les paramètres de route
  if (req.params && checkForSqlInjection(req.params, 'params')) {
    res.status(400).json({
      error: 'Invalid input detected',
    });
    return;
  }

  next();
};

/**
 * Middleware de protection contre les attaques XSS
 */
export const xssProtection = (req: Request, res: Response, next: NextFunction): void => {
  const xssPatterns = [
    /<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi,
    /<iframe\b[^<]*(?:(?!<\/iframe>)<[^<]*)*<\/iframe>/gi,
    /<object\b[^<]*(?:(?!<\/object>)<[^<]*)*<\/object>/gi,
    /<embed\b[^<]*(?:(?!<\/embed>)<[^<]*)*<\/embed>/gi,
    /<link\b[^<]*(?:(?!<\/link>)<[^<]*)*<\/link>/gi,
    /<meta\b[^<]*(?:(?!<\/meta>)<[^<]*)*<\/meta>/gi,
    /javascript:/gi,
    /vbscript:/gi,
    /onload\s*=/gi,
    /onerror\s*=/gi,
    /onclick\s*=/gi,
    /onmouseover\s*=/gi,
    /onfocus\s*=/gi,
    /onblur\s*=/gi,
    /onchange\s*=/gi,
    /onsubmit\s*=/gi,
    /onreset\s*=/gi,
    /onselect\s*=/gi,
    /onkeydown\s*=/gi,
    /onkeyup\s*=/gi,
    /onkeypress\s*=/gi,
  ];

  const checkForXSS = (value: any, path: string): boolean => {
    if (typeof value === 'string') {
      for (const pattern of xssPatterns) {
        if (pattern.test(value)) {
          logSecurityEvent('XSS attempt detected', {
            ip: req.ip,
            url: req.url,
            method: req.method,
            path,
            value: value.substring(0, 100), // Limiter la taille du log
            pattern: pattern.toString(),
          });
          return true;
        }
      }
    } else if (typeof value === 'object' && value !== null) {
      for (const key in value) {
        if (checkForXSS(value[key], `${path}.${key}`)) {
          return true;
        }
      }
    }
    return false;
  };

  // Vérifier le body
  if (req.body && checkForXSS(req.body, 'body')) {
    res.status(400).json({
      error: 'Invalid input detected',
    });
    return;
  }

  // Vérifier les paramètres de requête
  if (req.query && checkForXSS(req.query, 'query')) {
    res.status(400).json({
      error: 'Invalid input detected',
    });
    return;
  }

  // Vérifier les paramètres de route
  if (req.params && checkForXSS(req.params, 'params')) {
    res.status(400).json({
      error: 'Invalid input detected',
    });
    return;
  }

  next();
};

/**
 * Middleware de protection contre les attaques par énumération
 */
export const enumerationProtection = (req: Request, res: Response, next: NextFunction): void => {
  // Masquer les erreurs d'authentification pour éviter l'énumération d'utilisateurs
  if (req.path.includes('/auth/login') || req.path.includes('/auth/register')) {
    const originalJson = res.json;
    res.json = function(body: any) {
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

/**
 * Middleware de protection contre les attaques par déni de service
 */
export const dosProtection = (req: Request, res: Response, next: NextFunction): void => {
  // Vérifier la taille du body
  const contentLength = parseInt(req.get('Content-Length') || '0');
  const maxBodySize = 10 * 1024 * 1024; // 10MB

  if (contentLength > maxBodySize) {
    logSecurityEvent('Request body too large', {
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
    logSecurityEvent('Too many query parameters', {
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

/**
 * Middleware de validation des headers de sécurité
 */
export const securityHeadersValidation = (req: Request, res: Response, next: NextFunction): void => {
  // Vérifier la présence de headers suspects
  const suspiciousHeaders = [
    'x-forwarded-for',
    'x-real-ip',
    'x-cluster-client-ip',
    'x-forwarded',
    'forwarded-for',
    'forwarded',
  ];

  const hasSuspiciousHeaders = suspiciousHeaders.some(header => 
    req.headers[header] && typeof req.headers[header] === 'string' && 
    (req.headers[header] as string).includes('..')
  );

  if (hasSuspiciousHeaders) {
    logSecurityEvent('Suspicious headers detected', {
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
  if (headerSize > 8192) { // 8KB max
    logSecurityEvent('Headers too large', {
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

/**
 * Middleware de protection contre les attaques par timing
 */
export const timingAttackProtection = (req: Request, res: Response, next: NextFunction): void => {
  // Ajouter un délai aléatoire pour les requêtes d'authentification
  if (req.path.includes('/auth/login') || req.path.includes('/auth/register')) {
    const randomDelay = Math.random() * 100; // 0-100ms
    setTimeout(() => {
      next();
    }, randomDelay);
  } else {
    next();
  }
};

/**
 * Middleware de protection contre les attaques par énumération de ressources
 */
export const resourceEnumerationProtection = (req: Request, res: Response, next: NextFunction): void => {
  // Masquer les erreurs 404 pour éviter l'énumération de ressources
  if (req.path.includes('/api/')) {
    const originalJson = res.json;
    res.json = function(body: any) {
      if (res.statusCode === 404) {
        const maskedBody = {
          error: 'Resource not found',
          timestamp: new Date().toISOString(),
        };
        return originalJson.call(this, maskedBody);
      }
      return originalJson.call(this, body);
    };
  }

  next();
};
