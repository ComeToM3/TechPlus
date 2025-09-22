import { Request, Response, NextFunction } from 'express';
// @ts-ignore
import expressSanitizer from 'express-sanitizer';
import { CustomError } from './error';
import logger from '@/utils/logger';

/**
 * Middleware de sanitization des données
 */
export const sanitizeInput = (req: Request, res: Response, next: NextFunction): void => {
  try {
    // Sanitizer les données du body
    if (req.body) {
      req.body = sanitizeObject(req.body);
    }

    // Sanitizer les query parameters
    if (req.query) {
      req.query = sanitizeObject(req.query);
    }

    // Sanitizer les paramètres de route
    if (req.params) {
      req.params = sanitizeObject(req.params);
    }

    next();
  } catch (error) {
    logger.error('Sanitization failed:', error);
    throw new CustomError('Input sanitization failed', 400, {
      type: 'SANITIZATION_ERROR',
    });
  }
};

/**
 * Fonction récursive pour sanitizer un objet
 */
function sanitizeObject(obj: any): any {
  if (obj === null || obj === undefined) {
    return obj;
  }

  if (typeof obj === 'string') {
    return sanitizeString(obj);
  }

  if (Array.isArray(obj)) {
    return obj.map(item => sanitizeObject(item));
  }

  if (typeof obj === 'object') {
    const sanitized: any = {};
    for (const [key, value] of Object.entries(obj)) {
      sanitized[sanitizeString(key)] = sanitizeObject(value);
    }
    return sanitized;
  }

  return obj;
}

/**
 * Sanitize une chaîne de caractères
 */
function sanitizeString(str: string): string {
  if (typeof str !== 'string') {
    return str;
  }

  let sanitized = str;

  // Supprimer les balises HTML dangereuses
  sanitized = sanitized.replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, '');
  sanitized = sanitized.replace(/<iframe\b[^<]*(?:(?!<\/iframe>)<[^<]*)*<\/iframe>/gi, '');
  sanitized = sanitized.replace(/<object\b[^<]*(?:(?!<\/object>)<[^<]*)*<\/object>/gi, '');
  sanitized = sanitized.replace(/<embed\b[^<]*(?:(?!<\/embed>)<[^<]*)*<\/embed>/gi, '');
  sanitized = sanitized.replace(/<link\b[^<]*>/gi, '');
  sanitized = sanitized.replace(/<meta\b[^<]*>/gi, '');
  sanitized = sanitized.replace(/<style\b[^<]*(?:(?!<\/style>)<[^<]*)*<\/style>/gi, '');

  // Supprimer les attributs dangereux
  sanitized = sanitized.replace(/\s*on\w+\s*=\s*["'][^"']*["']/gi, '');
  sanitized = sanitized.replace(/\s*javascript\s*:/gi, '');
  sanitized = sanitized.replace(/\s*vbscript\s*:/gi, '');
  sanitized = sanitized.replace(/\s*data\s*:/gi, '');

  // Échapper les caractères HTML
  sanitized = sanitized
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#x27;')
    .replace(/\//g, '&#x2F;');

  // Supprimer les caractères de contrôle
  sanitized = sanitized.replace(/[\u0000-\u0008\u000B\u000C\u000E-\u001F\u007F]/g, '');

  // Normaliser les espaces
  sanitized = sanitized.replace(/\s+/g, ' ').trim();

  return sanitized;
}

/**
 * Middleware de validation des types de contenu
 */
export const validateContentType = (req: Request, res: Response, next: NextFunction): void => {
  const contentType = req.get('Content-Type');

  // Pour les requêtes POST/PUT/PATCH, vérifier le Content-Type
  if (['POST', 'PUT', 'PATCH'].includes(req.method)) {
    if (!contentType?.includes('application/json')) {
      throw new CustomError('Content-Type must be application/json', 400, {
        type: 'CONTENT_TYPE_ERROR',
      });
    }
  }

  next();
};

/**
 * Middleware de validation de la taille des requêtes
 */
export const validateRequestSize = (maxSize: number = 1024 * 1024) => {
  // 1MB par défaut
  return (req: Request, res: Response, next: NextFunction): void => {
    const contentLength = parseInt(req.get('Content-Length') || '0');

    if (contentLength > maxSize) {
      throw new CustomError(`Request size exceeds maximum allowed size of ${maxSize} bytes`, 413, {
        type: 'REQUEST_SIZE_ERROR',
      });
    }

    next();
  };
};

/**
 * Middleware de validation des headers
 */
export const validateHeaders = (req: Request, res: Response, next: NextFunction): void => {
  const userAgent = req.get('User-Agent');
  const accept = req.get('Accept');

  // Vérifier que User-Agent est présent
  if (!userAgent) {
    throw new CustomError('User-Agent header is required', 400, {
      type: 'HEADER_VALIDATION_ERROR',
    });
  }

  // Vérifier que User-Agent n'est pas suspect
  const suspiciousPatterns = [
    /bot/i,
    /crawler/i,
    /spider/i,
    /scraper/i,
    /curl/i,
    /wget/i,
    /python/i,
    /java/i,
    /php/i,
  ];

  const isSuspicious = suspiciousPatterns.some(pattern => pattern.test(userAgent));

  if (isSuspicious) {
    logger.warn('Suspicious User-Agent detected:', {
      userAgent,
      ip: req.ip,
      path: req.path,
    });
  }

  // Pour les requêtes API, vérifier Accept header
  if (req.path.startsWith('/api/') && !accept?.includes('application/json')) {
    throw new CustomError('Accept header must include application/json for API requests', 400, {
      type: 'HEADER_VALIDATION_ERROR',
    });
  }

  next();
};

/**
 * Middleware de validation des paramètres d'URL
 */
export const validateUrlParams = (req: Request, res: Response, next: NextFunction): void => {
  const url = req.url;

  // Vérifier la longueur de l'URL
  if (url.length > 2048) {
    throw new CustomError('URL too long', 414, {
      type: 'URL_VALIDATION_ERROR',
    });
  }

  // Vérifier les caractères suspects dans l'URL
  const suspiciousChars = /[<>'"&]/;
  if (suspiciousChars.test(url)) {
    throw new CustomError('URL contains suspicious characters', 400, {
      type: 'URL_VALIDATION_ERROR',
    });
  }

  // Vérifier les tentatives de path traversal
  if (url.includes('..') || url.includes('~')) {
    throw new CustomError('Path traversal attempt detected', 400, {
      type: 'SECURITY_ERROR',
    });
  }

  next();
};

/**
 * Middleware de validation des données JSON
 */
export const validateJsonData = (req: Request, res: Response, next: NextFunction): void => {
  if (req.body && typeof req.body === 'object') {
    // Vérifier la profondeur de l'objet JSON
    const depth = getObjectDepth(req.body);
    if (depth > 10) {
      throw new CustomError('JSON object too deep', 400, {
        type: 'JSON_VALIDATION_ERROR',
      });
    }

    // Vérifier le nombre de propriétés
    const propertyCount = getObjectPropertyCount(req.body);
    if (propertyCount > 100) {
      throw new CustomError('Too many properties in JSON object', 400, {
        type: 'JSON_VALIDATION_ERROR',
      });
    }
  }

  next();
};

/**
 * Calculer la profondeur d'un objet
 */
function getObjectDepth(obj: any, currentDepth: number = 0): number {
  if (obj === null || typeof obj !== 'object') {
    return currentDepth;
  }

  if (Array.isArray(obj)) {
    return Math.max(...obj.map(item => getObjectDepth(item, currentDepth + 1)));
  }

  const depths = Object.values(obj).map(value => getObjectDepth(value, currentDepth + 1));
  return depths.length > 0 ? Math.max(...depths) : currentDepth;
}

/**
 * Compter le nombre de propriétés dans un objet
 */
function getObjectPropertyCount(obj: any): number {
  if (obj === null || typeof obj !== 'object') {
    return 0;
  }

  if (Array.isArray(obj)) {
    return obj.reduce((count, item) => count + getObjectPropertyCount(item), 0);
  }

  let count = Object.keys(obj).length;
  for (const value of Object.values(obj)) {
    count += getObjectPropertyCount(value);
  }

  return count;
}

/**
 * Middleware de validation des fichiers uploadés
 */
export const validateFileUpload = (req: Request, res: Response, next: NextFunction): void => {
  // Cette fonction peut être étendue pour valider les fichiers uploadés
  // Pour l'instant, on vérifie juste que les données sont valides

  // Vérifier si des fichiers sont présents (avec multer ou autre middleware)
  const files = (req as any).files;

  if (files) {
    const fileArray = Array.isArray(files) ? files : Object.values(files);

    for (const file of fileArray) {
      if (file.size > 5 * 1024 * 1024) {
        // 5MB max
        throw new CustomError('File size exceeds maximum allowed size of 5MB', 413, {
          type: 'FILE_SIZE_ERROR',
        });
      }

      // Vérifier le type MIME
      const allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
      if (!allowedTypes.includes(file.mimetype)) {
        throw new CustomError('File type not allowed', 400, {
          type: 'FILE_TYPE_ERROR',
        });
      }
    }
  }

  next();
};

/**
 * Configuration express-sanitizer
 */
export const setupSanitizer = expressSanitizer({
  // Options de configuration
  allowedTags: ['b', 'i', 'em', 'strong', 'a', 'p', 'br'],
  allowedAttributes: {
    a: ['href', 'title'],
  },
  allowedSchemes: ['http', 'https', 'mailto'],
  allowedSchemesByTag: {
    a: ['http', 'https', 'mailto'],
  },
});
