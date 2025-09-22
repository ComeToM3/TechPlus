import * as Sentry from '@sentry/node';
import { config } from './environment';
import logger from '../utils/logger';

/**
 * Configuration Sentry simplifiée pour le tracking des erreurs
 */
export const initSentry = (): void => {
  // Vérifier si Sentry est configuré
  if (!process.env.SENTRY_DSN) {
    logger.warn('Sentry DSN not configured. Error tracking will be disabled.');
    return;
  }

  Sentry.init({
    dsn: process.env.SENTRY_DSN,
    environment: config.nodeEnv,

    // Configuration des traces
    tracesSampleRate: config.nodeEnv === 'production' ? 0.1 : 1.0,

    // Configuration des breadcrumbs
    maxBreadcrumbs: 50,

    // Configuration des releases
    release: process.env.npm_package_version || '1.0.0',

    // Configuration des tags
    initialScope: {
      tags: {
        component: 'backend',
        service: 'techplus-api',
      },
    },

    // Configuration des filtres d'erreurs
    beforeSend(event, hint) {
      // Filtrer les erreurs de développement
      if (config.nodeEnv === 'development') {
        // Ne pas envoyer les erreurs de validation en développement
        if (event.exception) {
          const error = hint.originalException;
          if (error instanceof Error && error.message.includes('Validation failed')) {
            return null;
          }
        }
      }

      // Logger l'erreur localement
      logger.error('Sentry error captured', {
        eventId: event.event_id,
        level: event.level,
        message: event.message,
        exception: event.exception,
      });

      return event;
    },

    // Configuration des erreurs ignorées
    ignoreErrors: [
      // Erreurs de réseau communes
      'Network Error',
      'Network request failed',
      'ECONNRESET',
      'ENOTFOUND',
      'ECONNREFUSED',

      // Erreurs de validation communes
      'Validation failed',
      'Invalid input',

      // Erreurs de rate limiting
      'Too many requests',
      'Rate limit exceeded',
    ],

    // Configuration des URLs ignorées
    ignoreTransactions: ['/health', '/api/health', '/favicon.ico'],
  });

  logger.info('Sentry initialized successfully', {
    environment: config.nodeEnv,
    dsn: process.env.SENTRY_DSN ? 'configured' : 'not configured',
  });
};

/**
 * Middleware Sentry pour Express
 */
export const sentryRequestHandler = (req: any, res: any, next: any) => {
  next();
};

/**
 * Middleware Sentry pour le tracing
 */
export const sentryTracingHandler = (req: any, res: any, next: any) => {
  next();
};

/**
 * Middleware Sentry pour les erreurs
 */
export const sentryErrorHandler = (err: any, req: any, res: any, next: any) => {
  next(err);
};

/**
 * Fonction utilitaire pour capturer des erreurs manuellement
 */
export const captureError = (error: Error, context?: Record<string, any>): void => {
  Sentry.withScope(scope => {
    if (context) {
      Object.keys(context).forEach(key => {
        scope.setContext(key, context[key]);
      });
    }

    scope.setLevel('error');
    Sentry.captureException(error);
  });
};

/**
 * Fonction utilitaire pour capturer des messages
 */
export const captureMessage = (
  message: string,
  level: Sentry.SeverityLevel = 'info',
  context?: Record<string, any>
): void => {
  Sentry.withScope(scope => {
    if (context) {
      Object.keys(context).forEach(key => {
        scope.setContext(key, context[key]);
      });
    }

    scope.setLevel(level);
    Sentry.captureMessage(message);
  });
};

/**
 * Fonction utilitaire pour ajouter des tags
 */
export const addSentryTag = (key: string, value: string): void => {
  Sentry.setTag(key, value);
};

/**
 * Fonction utilitaire pour ajouter du contexte
 */
export const addSentryContext = (key: string, context: Record<string, any>): void => {
  Sentry.setContext(key, context);
};

/**
 * Fonction utilitaire pour ajouter des breadcrumbs
 */
export const addSentryBreadcrumb = (
  message: string,
  category: string,
  level: Sentry.SeverityLevel = 'info',
  data?: Record<string, any>
): void => {
  Sentry.addBreadcrumb({
    message,
    category,
    level,
    data: data || {},
    timestamp: Date.now() / 1000,
  });
};

/**
 * Fonction pour configurer le contexte utilisateur
 */
export const setSentryUser = (user: { id: string; email?: string; username?: string }): void => {
  const userData: any = { id: user.id };
  if (user.email) userData.email = user.email;
  if (user.username) userData.username = user.username;

  Sentry.setUser(userData);
};

/**
 * Fonction pour nettoyer le contexte utilisateur
 */
export const clearSentryUser = (): void => {
  Sentry.setUser(null);
};

/**
 * Fonction pour capturer des métriques personnalisées
 */
export const captureMetric = (
  name: string,
  value: number,
  unit: string = 'none',
  tags?: Record<string, string>
): void => {
  // Utiliser les breadcrumbs pour les métriques
  addSentryBreadcrumb(`Metric: ${name}`, 'metric', 'info', {
    value,
    unit,
    tags,
  });
};

/**
 * Fonction pour capturer des événements business
 */
export const captureBusinessEvent = (event: string, data: Record<string, any>): void => {
  addSentryBreadcrumb(`Business Event: ${event}`, 'business', 'info', data);
  captureMessage(`Business Event: ${event}`, 'info', data);
};

export default Sentry;
