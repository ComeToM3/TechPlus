import winston from 'winston';
import DailyRotateFile from 'winston-daily-rotate-file';
import path from 'path';

// Configuration des niveaux de log personnalisés
const logLevels = {
  error: 0,
  warn: 1,
  info: 2,
  http: 3,
  debug: 4,
};

// Configuration des couleurs pour les logs
const logColors = {
  error: 'red',
  warn: 'yellow',
  info: 'green',
  http: 'magenta',
  debug: 'white',
};

winston.addColors(logColors);

// Format personnalisé pour les logs
const logFormat = winston.format.combine(
  winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss:ms' }),
  winston.format.errors({ stack: true }),
  winston.format.json(),
  winston.format.printf(info => {
    const { timestamp, level, message, stack, ...meta } = info;

    // Format structuré pour les logs JSON
    const logEntry: Record<string, any> = {
      timestamp,
      level,
      message,
      service: 'techplus-backend',
      environment: process.env.NODE_ENV || 'development',
    };

    if (stack) {
      logEntry.stack = stack;
    }

    if (Object.keys(meta).length > 0) {
      logEntry.meta = meta;
    }

    return JSON.stringify(logEntry);
  })
);

// Format pour la console (plus lisible)
const consoleFormat = winston.format.combine(
  winston.format.colorize({ all: true }),
  winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
  winston.format.printf(info => {
    const { timestamp, level, message, stack } = info;
    return `${timestamp} [${level}]: ${message}${stack ? `\n${stack}` : ''}`;
  })
);

// Configuration des transports
const transports: winston.transport[] = [];

// Transport console (toujours actif)
transports.push(
  new winston.transports.Console({
    level: process.env.NODE_ENV === 'production' ? 'info' : 'debug',
    format: consoleFormat,
  })
);

// Transport fichier pour les erreurs
transports.push(
  new DailyRotateFile({
    filename: path.join('logs', 'error-%DATE%.log'),
    datePattern: 'YYYY-MM-DD',
    level: 'error',
    format: logFormat,
    maxSize: '20m',
    maxFiles: '14d', // Rétention 14 jours
    zippedArchive: true,
  })
);

// Transport fichier pour tous les logs
transports.push(
  new DailyRotateFile({
    filename: path.join('logs', 'combined-%DATE%.log'),
    datePattern: 'YYYY-MM-DD',
    format: logFormat,
    maxSize: '20m',
    maxFiles: '7d', // Rétention 7 jours
    zippedArchive: true,
  })
);

// Transport fichier pour les logs HTTP (requêtes API)
transports.push(
  new DailyRotateFile({
    filename: path.join('logs', 'http-%DATE%.log'),
    datePattern: 'YYYY-MM-DD',
    level: 'http',
    format: logFormat,
    maxSize: '20m',
    maxFiles: '3d', // Rétention 3 jours
    zippedArchive: true,
  })
);

// Création du logger principal
const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || (process.env.NODE_ENV === 'production' ? 'info' : 'debug'),
  levels: logLevels,
  transports,
  // Gestion des exceptions non capturées
  exceptionHandlers: [
    new winston.transports.File({
      filename: path.join('logs', 'exceptions.log'),
      format: logFormat,
    }),
  ],
  // Gestion des rejets de promesses non gérés
  rejectionHandlers: [
    new winston.transports.File({
      filename: path.join('logs', 'rejections.log'),
      format: logFormat,
    }),
  ],
  // Sortie en cas d'erreur
  exitOnError: false,
});

// Logger spécialisé pour les requêtes HTTP
export const httpLogger = winston.createLogger({
  level: 'http',
  levels: logLevels,
  transports: [
    new winston.transports.Console({
      format: consoleFormat,
    }),
    new DailyRotateFile({
      filename: path.join('logs', 'http-%DATE%.log'),
      datePattern: 'YYYY-MM-DD',
      format: logFormat,
      maxSize: '20m',
      maxFiles: '3d',
      zippedArchive: true,
    }),
  ],
});

// Logger spécialisé pour les erreurs
export const errorLogger = winston.createLogger({
  level: 'error',
  levels: logLevels,
  transports: [
    new winston.transports.Console({
      format: consoleFormat,
    }),
    new DailyRotateFile({
      filename: path.join('logs', 'error-%DATE%.log'),
      datePattern: 'YYYY-MM-DD',
      format: logFormat,
      maxSize: '20m',
      maxFiles: '14d',
      zippedArchive: true,
    }),
  ],
});

// Logger spécialisé pour les métriques de performance
export const metricsLogger = winston.createLogger({
  level: 'info',
  levels: logLevels,
  transports: [
    new winston.transports.Console({
      format: consoleFormat,
    }),
    new DailyRotateFile({
      filename: path.join('logs', 'metrics-%DATE%.log'),
      datePattern: 'YYYY-MM-DD',
      format: logFormat,
      maxSize: '20m',
      maxFiles: '30d', // Rétention 30 jours pour les métriques
      zippedArchive: true,
    }),
  ],
});

// Méthodes utilitaires pour le logging structuré
export const logWithContext = (
  level: string,
  message: string,
  context: Record<string, any> = {}
) => {
  logger.log(level, message, { context });
};

export const logError = (error: Error, context: Record<string, any> = {}) => {
  errorLogger.error(error.message, {
    stack: error.stack,
    name: error.name,
    context,
  });
};

export const logHttpRequest = (req: any, res: any, responseTime: number) => {
  const logData = {
    method: req.method,
    url: req.url,
    statusCode: res.statusCode,
    responseTime: `${responseTime}ms`,
    userAgent: req.get('User-Agent'),
    ip: req.ip || req.connection.remoteAddress,
    userId: req.user?.id || null,
  };

  httpLogger.http('HTTP Request', logData);
};

export const logPerformance = (
  operation: string,
  duration: number,
  metadata: Record<string, any> = {}
) => {
  metricsLogger.info('Performance Metric', {
    operation,
    duration: `${duration}ms`,
    ...metadata,
  });
};

export const logSecurity = (event: string, details: Record<string, any> = {}) => {
  logger.warn('Security Event', {
    event,
    ...details,
    timestamp: new Date().toISOString(),
  });
};

export const logBusiness = (event: string, details: Record<string, any> = {}) => {
  logger.info('Business Event', {
    event,
    ...details,
    timestamp: new Date().toISOString(),
  });
};

// Configuration pour les tests (logs silencieux)
if (process.env.NODE_ENV === 'test') {
  logger.transports.forEach(transport => {
    if (transport instanceof winston.transports.Console) {
      transport.silent = true;
    }
  });
}

export default logger;
