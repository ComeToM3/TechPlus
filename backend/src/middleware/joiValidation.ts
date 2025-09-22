import Joi from 'joi';
import { Request, Response, NextFunction } from 'express';
import { CustomError } from './error';
import logger from '@/utils/logger';

/**
 * Middleware de validation Joi pour les requêtes
 */
export const validateRequest = (schema: {
  body?: Joi.ObjectSchema;
  query?: Joi.ObjectSchema;
  params?: Joi.ObjectSchema;
  headers?: Joi.ObjectSchema;
}) => {
  return (req: Request, res: Response, next: NextFunction): void => {
    const errors: string[] = [];

    // Validation du body
    if (schema.body) {
      const { error } = schema.body.validate(req.body, {
        abortEarly: false,
        stripUnknown: true,
        allowUnknown: false,
      });
      if (error) {
        errors.push(...error.details.map(detail => `Body: ${detail.message}`));
      }
    }

    // Validation des query parameters
    if (schema.query) {
      const { error } = schema.query.validate(req.query, {
        abortEarly: false,
        stripUnknown: true,
        allowUnknown: false,
      });
      if (error) {
        errors.push(...error.details.map(detail => `Query: ${detail.message}`));
      }
    }

    // Validation des paramètres de route
    if (schema.params) {
      const { error } = schema.params.validate(req.params, {
        abortEarly: false,
        stripUnknown: true,
        allowUnknown: false,
      });
      if (error) {
        errors.push(...error.details.map(detail => `Params: ${detail.message}`));
      }
    }

    // Validation des headers
    if (schema.headers) {
      const { error } = schema.headers.validate(req.headers, {
        abortEarly: false,
        stripUnknown: true,
        allowUnknown: true, // Headers peuvent contenir des champs non définis
      });
      if (error) {
        errors.push(...error.details.map(detail => `Headers: ${detail.message}`));
      }
    }

    if (errors.length > 0) {
      logger.warn('Validation failed:', {
        errors,
        body: req.body,
        query: req.query,
        params: req.params,
        ip: req.ip,
        userAgent: req.get('User-Agent'),
      });

      throw new CustomError('Validation failed', 400, {
        details: errors,
        type: 'VALIDATION_ERROR',
      });
    }

    next();
  };
};

/**
 * Schémas de validation communs
 */
export const commonSchemas = {
  // Validation des IDs MongoDB
  mongoId: Joi.string()
    .pattern(/^[0-9a-fA-F]{24}$/)
    .required()
    .messages({
      'string.pattern.base': 'must be a valid MongoDB ObjectId',
      'any.required': 'is required',
    }),

  // Validation des emails
  email: Joi.string().email().lowercase().trim().required().messages({
    'string.email': 'must be a valid email address',
    'any.required': 'is required',
  }),

  // Validation des mots de passe
  password: Joi.string()
    .min(8)
    .max(128)
    .pattern(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/)
    .required()
    .messages({
      'string.min': 'must be at least 8 characters long',
      'string.max': 'must not exceed 128 characters',
      'string.pattern.base':
        'must contain at least one lowercase letter, one uppercase letter, one number, and one special character',
      'any.required': 'is required',
    }),

  // Validation des numéros de téléphone
  phone: Joi.string()
    .pattern(/^(\+33|0)[1-9](\d{8})$/)
    .required()
    .messages({
      'string.pattern.base': 'must be a valid French phone number',
      'any.required': 'is required',
    }),

  // Validation des noms
  name: Joi.string()
    .min(2)
    .max(50)
    .pattern(/^[a-zA-ZÀ-ÿ\s'-]+$/)
    .trim()
    .required()
    .messages({
      'string.min': 'must be at least 2 characters long',
      'string.max': 'must not exceed 50 characters',
      'string.pattern.base': 'must contain only letters, spaces, hyphens, and apostrophes',
      'any.required': 'is required',
    }),

  // Validation des dates
  date: Joi.date().iso().min('now').required().messages({
    'date.format': 'must be a valid ISO date',
    'date.min': 'must be in the future',
    'any.required': 'is required',
  }),

  // Validation des heures
  time: Joi.string()
    .pattern(/^([01]?[0-9]|2[0-3]):[0-5][0-9]$/)
    .required()
    .messages({
      'string.pattern.base': 'must be a valid time in HH:MM format',
      'any.required': 'is required',
    }),

  // Validation des nombres de personnes
  partySize: Joi.number().integer().min(1).max(20).required().messages({
    'number.base': 'must be a number',
    'number.integer': 'must be an integer',
    'number.min': 'must be at least 1',
    'number.max': 'must not exceed 20',
    'any.required': 'is required',
  }),

  // Validation des montants
  amount: Joi.number().positive().precision(2).max(10000).required().messages({
    'number.base': 'must be a number',
    'number.positive': 'must be positive',
    'number.precision': 'must have at most 2 decimal places',
    'number.max': 'must not exceed 10000',
    'any.required': 'is required',
  }),

  // Validation des statuts
  status: Joi.string()
    .valid('PENDING', 'CONFIRMED', 'CANCELLED', 'COMPLETED', 'NO_SHOW')
    .required()
    .messages({
      'any.only': 'must be one of: PENDING, CONFIRMED, CANCELLED, COMPLETED, NO_SHOW',
      'any.required': 'is required',
    }),

  // Validation des rôles
  role: Joi.string().valid('CLIENT', 'ADMIN', 'SUPER_ADMIN').default('CLIENT').messages({
    'any.only': 'must be one of: CLIENT, ADMIN, SUPER_ADMIN',
  }),

  // Validation des paginations
  pagination: {
    page: Joi.number().integer().min(1).default(1),
    limit: Joi.number().integer().min(1).max(100).default(20),
    sort: Joi.string().valid('asc', 'desc').default('desc'),
    sortBy: Joi.string().default('createdAt'),
  },

  // Validation des filtres de date
  dateRange: {
    startDate: Joi.date().iso().optional(),
    endDate: Joi.date().iso().min(Joi.ref('startDate')).optional(),
  },
};

/**
 * Schémas de validation spécifiques aux fonctionnalités
 */
export const validationSchemas = {
  // Authentification
  auth: {
    register: Joi.object({
      email: commonSchemas.email,
      password: commonSchemas.password,
      name: commonSchemas.name,
      phone: commonSchemas.phone.optional(),
    }),

    login: Joi.object({
      email: commonSchemas.email,
      password: Joi.string().required().messages({
        'any.required': 'is required',
      }),
    }),

    refreshToken: Joi.object({
      refreshToken: Joi.string().required().messages({
        'any.required': 'is required',
      }),
    }),

    changePassword: Joi.object({
      currentPassword: Joi.string().required().messages({
        'any.required': 'is required',
      }),
      newPassword: commonSchemas.password,
      confirmPassword: Joi.string().valid(Joi.ref('newPassword')).required().messages({
        'any.only': 'must match new password',
        'any.required': 'is required',
      }),
    }),
  },

  // Réservations
  reservation: {
    create: Joi.object({
      date: commonSchemas.date,
      time: commonSchemas.time,
      partySize: commonSchemas.partySize,
      specialRequests: Joi.string().max(500).optional().messages({
        'string.max': 'must not exceed 500 characters',
      }),
      clientName: commonSchemas.name.optional(),
      clientEmail: commonSchemas.email.optional(),
      clientPhone: commonSchemas.phone.optional(),
    }),

    update: Joi.object({
      date: commonSchemas.date.optional(),
      time: commonSchemas.time.optional(),
      partySize: commonSchemas.partySize.optional(),
      status: commonSchemas.status.optional(),
      specialRequests: Joi.string().max(500).optional().messages({
        'string.max': 'must not exceed 500 characters',
      }),
      adminNotes: Joi.string().max(1000).optional().messages({
        'string.max': 'must not exceed 1000 characters',
      }),
      cancellationReason: Joi.string().max(200).optional().messages({
        'string.max': 'must not exceed 200 characters',
      }),
    }),

    list: Joi.object({
      page: commonSchemas.pagination.page,
      limit: commonSchemas.pagination.limit,
      sort: commonSchemas.pagination.sort,
      sortBy: commonSchemas.pagination.sortBy,
      status: commonSchemas.status.optional(),
      startDate: commonSchemas.dateRange.startDate,
      endDate: commonSchemas.dateRange.endDate,
    }),

    params: Joi.object({
      id: commonSchemas.mongoId,
    }),

    tokenParams: Joi.object({
      token: Joi.string().length(32).required().messages({
        'string.length': 'must be exactly 32 characters',
        'any.required': 'is required',
      }),
    }),
  },

  // Paiements
  payment: {
    createIntent: Joi.object({
      reservationId: commonSchemas.mongoId,
      amount: commonSchemas.amount,
      currency: Joi.string().valid('EUR', 'USD').default('EUR'),
    }),

    confirm: Joi.object({
      paymentIntentId: Joi.string().required().messages({
        'any.required': 'is required',
      }),
    }),

    refund: Joi.object({
      paymentIntentId: Joi.string().required().messages({
        'any.required': 'is required',
      }),
      amount: commonSchemas.amount.optional(),
      reason: Joi.string()
        .valid('duplicate', 'fraudulent', 'requested_by_customer', 'cancelled')
        .required()
        .messages({
          'any.only': 'must be one of: duplicate, fraudulent, requested_by_customer, cancelled',
          'any.required': 'is required',
        }),
    }),

    params: Joi.object({
      id: Joi.string().required().messages({
        'any.required': 'is required',
      }),
    }),
  },

  // Notifications
  notification: {
    send: Joi.object({
      reservationId: commonSchemas.mongoId,
      type: Joi.string()
        .valid(
          'RESERVATION_CONFIRMATION',
          'RESERVATION_REMINDER',
          'RESERVATION_CANCELLATION',
          'RESERVATION_MODIFICATION',
          'PAYMENT_CONFIRMATION',
          'PAYMENT_FAILED',
          'ADMIN_NOTIFICATION'
        )
        .required()
        .messages({
          'any.only': 'must be a valid notification type',
          'any.required': 'is required',
        }),
      recipientEmail: commonSchemas.email,
      data: Joi.object().optional(),
    }),

    customEmail: Joi.object({
      to: commonSchemas.email,
      subject: Joi.string().min(1).max(200).required().messages({
        'string.min': 'must not be empty',
        'string.max': 'must not exceed 200 characters',
        'any.required': 'is required',
      }),
      htmlContent: Joi.string().min(1).required().messages({
        'string.min': 'must not be empty',
        'any.required': 'is required',
      }),
      textContent: Joi.string().optional(),
      attachments: Joi.array().items(Joi.object()).optional(),
    }),

    history: Joi.object({
      page: commonSchemas.pagination.page,
      limit: commonSchemas.pagination.limit,
      type: Joi.string().optional(),
      status: Joi.string().valid('PENDING', 'SENT', 'FAILED', 'RETRYING').optional(),
      recipientEmail: commonSchemas.email.optional(),
      reservationId: commonSchemas.mongoId.optional(),
    }),
  },

  // Restaurant
  restaurant: {
    update: Joi.object({
      name: commonSchemas.name.optional(),
      description: Joi.string().max(1000).optional().messages({
        'string.max': 'must not exceed 1000 characters',
      }),
      address: Joi.string().max(200).optional().messages({
        'string.max': 'must not exceed 200 characters',
      }),
      phone: commonSchemas.phone.optional(),
      email: commonSchemas.email.optional(),
      website: Joi.string().uri().optional().messages({
        'string.uri': 'must be a valid URL',
      }),
      averagePricePerPerson: commonSchemas.amount.optional(),
      minimumDepositAmount: commonSchemas.amount.optional(),
      paymentThreshold: Joi.number().integer().min(1).max(20).optional().messages({
        'number.base': 'must be a number',
        'number.integer': 'must be an integer',
        'number.min': 'must be at least 1',
        'number.max': 'must not exceed 20',
      }),
      cancellationPolicy: Joi.string().max(500).optional().messages({
        'string.max': 'must not exceed 500 characters',
      }),
    }),
  },

  // Tables
  table: {
    create: Joi.object({
      number: Joi.number().integer().min(1).max(999).required().messages({
        'number.base': 'must be a number',
        'number.integer': 'must be an integer',
        'number.min': 'must be at least 1',
        'number.max': 'must not exceed 999',
        'any.required': 'is required',
      }),
      capacity: Joi.number().integer().min(1).max(20).required().messages({
        'number.base': 'must be a number',
        'number.integer': 'must be an integer',
        'number.min': 'must be at least 1',
        'number.max': 'must not exceed 20',
        'any.required': 'is required',
      }),
      position: Joi.string().max(100).optional().messages({
        'string.max': 'must not exceed 100 characters',
      }),
      isActive: Joi.boolean().default(true),
    }),

    update: Joi.object({
      number: Joi.number().integer().min(1).max(999).optional().messages({
        'number.base': 'must be a number',
        'number.integer': 'must be an integer',
        'number.min': 'must be at least 1',
        'number.max': 'must not exceed 999',
      }),
      capacity: Joi.number().integer().min(1).max(20).optional().messages({
        'number.base': 'must be a number',
        'number.integer': 'must be an integer',
        'number.min': 'must be at least 1',
        'number.max': 'must not exceed 20',
      }),
      position: Joi.string().max(100).optional().messages({
        'string.max': 'must not exceed 100 characters',
      }),
      isActive: Joi.boolean().optional(),
    }),

    params: Joi.object({
      id: commonSchemas.mongoId,
    }),
  },

  // Menu Items
  menuItem: {
    create: Joi.object({
      name: commonSchemas.name,
      description: Joi.string().max(500).optional().messages({
        'string.max': 'must not exceed 500 characters',
      }),
      price: commonSchemas.amount,
      category: Joi.string().min(2).max(50).required().messages({
        'string.min': 'must be at least 2 characters long',
        'string.max': 'must not exceed 50 characters',
        'any.required': 'is required',
      }),
      image: Joi.string().uri().optional().messages({
        'string.uri': 'must be a valid URL',
      }),
      isAvailable: Joi.boolean().default(true),
      allergens: Joi.array().items(Joi.string().max(50)).optional().messages({
        'array.base': 'must be an array',
        'string.max': 'each allergen must not exceed 50 characters',
      }),
    }),

    update: Joi.object({
      name: commonSchemas.name.optional(),
      description: Joi.string().max(500).optional().messages({
        'string.max': 'must not exceed 500 characters',
      }),
      price: commonSchemas.amount.optional(),
      category: Joi.string().min(2).max(50).optional().messages({
        'string.min': 'must be at least 2 characters long',
        'string.max': 'must not exceed 50 characters',
      }),
      image: Joi.string().uri().optional().messages({
        'string.uri': 'must be a valid URL',
      }),
      isAvailable: Joi.boolean().optional(),
      allergens: Joi.array().items(Joi.string().max(50)).optional().messages({
        'array.base': 'must be an array',
        'string.max': 'each allergen must not exceed 50 characters',
      }),
    }),

    params: Joi.object({
      id: commonSchemas.mongoId,
    }),
  },
};

/**
 * Middleware de validation personnalisée pour la logique métier
 */
export const customValidation = {
  // Validation des créneaux de réservation
  validateReservationSlot: (req: Request, res: Response, next: NextFunction): void => {
    const { date, time, partySize } = req.body;

    if (date && time) {
      const reservationDateTime = new Date(`${date}T${time}`);
      const now = new Date();

      // Vérifier que la réservation est dans le futur
      if (reservationDateTime <= now) {
        throw new CustomError('Reservation must be in the future', 400, {
          type: 'BUSINESS_VALIDATION_ERROR',
        });
      }

      // Vérifier que la réservation n'est pas trop loin dans le futur (6 mois)
      const sixMonthsFromNow = new Date();
      sixMonthsFromNow.setMonth(sixMonthsFromNow.getMonth() + 6);
      if (reservationDateTime > sixMonthsFromNow) {
        throw new CustomError('Reservation cannot be more than 6 months in advance', 400, {
          type: 'BUSINESS_VALIDATION_ERROR',
        });
      }

      // Vérifier les heures d'ouverture (11h-23h)
      const hour = reservationDateTime.getHours();
      if (hour < 11 || hour > 23) {
        throw new CustomError('Reservation time must be between 11:00 and 23:00', 400, {
          type: 'BUSINESS_VALIDATION_ERROR',
        });
      }
    }

    // Vérifier la taille du groupe
    if (partySize && partySize > 20) {
      throw new CustomError('Party size cannot exceed 20 people', 400, {
        type: 'BUSINESS_VALIDATION_ERROR',
      });
    }

    next();
  },

  // Validation des montants de paiement
  validatePaymentAmount: (req: Request, res: Response, next: NextFunction): void => {
    const { amount } = req.body;

    if (amount) {
      // Vérifier que le montant est raisonnable
      if (amount < 0.01) {
        throw new CustomError('Payment amount must be at least €0.01', 400, {
          type: 'BUSINESS_VALIDATION_ERROR',
        });
      }

      if (amount > 10000) {
        throw new CustomError('Payment amount cannot exceed €10,000', 400, {
          type: 'BUSINESS_VALIDATION_ERROR',
        });
      }
    }

    next();
  },

  // Validation des tokens de gestion
  validateManagementToken: (req: Request, res: Response, next: NextFunction): void => {
    const { token } = req.params;

    if (token) {
      // Vérifier le format du token (32 caractères alphanumériques)
      if (!/^[a-zA-Z0-9]{32}$/.test(token)) {
        throw new CustomError('Invalid management token format', 400, {
          type: 'BUSINESS_VALIDATION_ERROR',
        });
      }
    }

    next();
  },
};

/**
 * Middleware de validation des types TypeScript
 */
export const validateTypeScript = (req: Request, res: Response, next: NextFunction): void => {
  // Cette fonction peut être étendue pour des validations TypeScript spécifiques
  // Par exemple, vérifier que les types sont corrects après parsing JSON

  try {
    // Vérifier que les nombres sont bien des nombres
    if (req.body.partySize && typeof req.body.partySize !== 'number') {
      req.body.partySize = parseInt(req.body.partySize);
    }

    if (req.body.amount && typeof req.body.amount !== 'number') {
      req.body.amount = parseFloat(req.body.amount);
    }

    // Vérifier que les booléens sont bien des booléens
    if (req.body.isActive !== undefined && typeof req.body.isActive !== 'boolean') {
      req.body.isActive = req.body.isActive === 'true' || req.body.isActive === true;
    }

    next();
  } catch (error) {
    throw new CustomError('Type validation failed', 400, {
      type: 'TYPE_VALIDATION_ERROR',
      details: error instanceof Error ? error.message : 'Unknown type error',
    });
  }
};
