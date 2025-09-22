import { NextFunction, Request, Response } from 'express';
import { body, param, query, validationResult } from 'express-validator';
import { CustomError } from './error';
import { validateRequest, validationSchemas } from './joiValidation';
import {
  sanitizeInput,
  validateContentType,
  validateRequestSize,
  validateHeaders,
  validateUrlParams,
  validateJsonData,
  validateFileUpload,
} from './sanitization';

/**
 * Middleware pour gérer les erreurs de validation express-validator
 */
export const handleValidationErrors = (req: Request, res: Response, next: NextFunction): void => {
  const errors = validationResult(req);

  if (!errors.isEmpty()) {
    const errorMessages = errors.array().map(error => ({
      field: error.type === 'field' ? (error as any).path : 'unknown',
      message: error.msg,
      value: error.type === 'field' ? (error as any).value : undefined,
    }));

    throw new CustomError('Validation failed', 400, {
      details: errorMessages,
      type: 'VALIDATION_ERROR',
    });
  }

  next();
};

/**
 * Validations pour l'authentification
 */
export const validateLogin = [
  body('email').isEmail().normalizeEmail().withMessage('Please provide a valid email address'),
  body('password').isLength({ min: 6 }).withMessage('Password must be at least 6 characters long'),
  handleValidationErrors,
];

export const validateRegister = [
  body('email').isEmail().normalizeEmail().withMessage('Please provide a valid email address'),
  body('name')
    .trim()
    .isLength({ min: 2, max: 50 })
    .withMessage('Name must be between 2 and 50 characters'),
  body('phone').optional().isMobilePhone('any').withMessage('Please provide a valid phone number'),
  body('password')
    .isLength({ min: 8 })
    .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/)
    .withMessage('Password must be at least 8 characters with uppercase, lowercase, and number'),
  handleValidationErrors,
];

/**
 * Validations pour les réservations
 */
export const validateReservation = [
  body('date').isISO8601().withMessage('Please provide a valid date in ISO format'),
  body('time')
    .matches(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/)
    .withMessage('Please provide a valid time in HH:MM format'),
  body('partySize')
    .isInt({ min: 1, max: 12 })
    .withMessage('Party size must be between 1 and 12 people'),
  body('duration')
    .optional()
    .isInt({ min: 30, max: 300 })
    .withMessage('Duration must be between 30 and 300 minutes'),
  body('notes')
    .optional()
    .isLength({ max: 500 })
    .withMessage('Notes must not exceed 500 characters'),
  body('specialRequests')
    .optional()
    .isLength({ max: 500 })
    .withMessage('Special requests must not exceed 500 characters'),
  handleValidationErrors,
];

export const validateGuestReservation = [
  body('date').isISO8601().withMessage('Please provide a valid date in ISO format'),
  body('time')
    .matches(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/)
    .withMessage('Please provide a valid time in HH:MM format'),
  body('partySize')
    .isInt({ min: 1, max: 12 })
    .withMessage('Party size must be between 1 and 12 people'),
  body('clientName')
    .trim()
    .isLength({ min: 2, max: 50 })
    .withMessage('Client name must be between 2 and 50 characters'),
  body('clientEmail')
    .isEmail()
    .normalizeEmail()
    .withMessage('Please provide a valid email address'),
  body('clientPhone').isMobilePhone('any').withMessage('Please provide a valid phone number'),
  body('notes')
    .optional()
    .isLength({ max: 500 })
    .withMessage('Notes must not exceed 500 characters'),
  body('specialRequests')
    .optional()
    .isLength({ max: 500 })
    .withMessage('Special requests must not exceed 500 characters'),
  handleValidationErrors,
];

/**
 * Validations pour les paramètres d'URL
 */
export const validateObjectId = [
  param('id').isLength({ min: 1 }).withMessage('ID parameter is required'),
  handleValidationErrors,
];

export const validateManagementToken = [
  param('token')
    .isLength({ min: 10, max: 50 })
    .withMessage('Management token must be between 10 and 50 characters'),
  handleValidationErrors,
];

/**
 * Validations pour les requêtes de disponibilité
 */
export const validateAvailabilityQuery = [
  query('date').optional().isISO8601().withMessage('Date must be in ISO format'),
  query('partySize')
    .optional()
    .isInt({ min: 1, max: 12 })
    .withMessage('Party size must be between 1 and 12'),
  handleValidationErrors,
];

/**
 * Validations pour les filtres de réservations
 */
export const validateReservationFilters = [
  query('status')
    .optional()
    .isIn(['PENDING', 'CONFIRMED', 'CANCELLED', 'COMPLETED', 'NO_SHOW'])
    .withMessage('Invalid status filter'),
  query('dateFrom').optional().isISO8601().withMessage('Date from must be in ISO format'),
  query('dateTo').optional().isISO8601().withMessage('Date to must be in ISO format'),
  query('page').optional().isInt({ min: 1 }).withMessage('Page must be a positive integer'),
  query('limit')
    .optional()
    .isInt({ min: 1, max: 100 })
    .withMessage('Limit must be between 1 and 100'),
  handleValidationErrors,
];

/**
 * Validations pour les paiements
 */
export const validatePaymentIntent = [
  body('reservationId').isLength({ min: 1 }).withMessage('Reservation ID is required'),
  body('amount')
    .isDecimal({ decimal_digits: '0,2' })
    .isFloat({ min: 0.01 })
    .withMessage('Amount must be a positive decimal'),
  handleValidationErrors,
];

/**
 * Validations pour les restaurants
 */
export const validateRestaurant = [
  body('name')
    .trim()
    .isLength({ min: 2, max: 100 })
    .withMessage('Restaurant name must be between 2 and 100 characters'),
  body('description')
    .optional()
    .isLength({ max: 1000 })
    .withMessage('Description must not exceed 1000 characters'),
  body('address')
    .trim()
    .isLength({ min: 10, max: 200 })
    .withMessage('Address must be between 10 and 200 characters'),
  body('phone').isMobilePhone('any').withMessage('Please provide a valid phone number'),
  body('email').isEmail().normalizeEmail().withMessage('Please provide a valid email address'),
  body('website').optional().isURL().withMessage('Please provide a valid website URL'),
  handleValidationErrors,
];

/**
 * Validations pour les tables
 */
export const validateTable = [
  body('number').isInt({ min: 1 }).withMessage('Table number must be a positive integer'),
  body('capacity')
    .isInt({ min: 1, max: 12 })
    .withMessage('Table capacity must be between 1 and 12'),
  body('position')
    .optional()
    .isLength({ max: 50 })
    .withMessage('Position must not exceed 50 characters'),
  body('isActive').optional().isBoolean().withMessage('isActive must be a boolean'),
  handleValidationErrors,
];

/**
 * Validations pour les éléments de menu
 */
export const validateMenuItem = [
  body('name')
    .trim()
    .isLength({ min: 2, max: 100 })
    .withMessage('Menu item name must be between 2 and 100 characters'),
  body('description')
    .optional()
    .isLength({ max: 500 })
    .withMessage('Description must not exceed 500 characters'),
  body('price')
    .isDecimal({ decimal_digits: '0,2' })
    .isFloat({ min: 0.01 })
    .withMessage('Price must be a positive decimal'),
  body('category')
    .trim()
    .isLength({ min: 2, max: 50 })
    .withMessage('Category must be between 2 and 50 characters'),
  body('allergens').optional().isArray().withMessage('Allergens must be an array'),
  body('isAvailable').optional().isBoolean().withMessage('isAvailable must be a boolean'),
  handleValidationErrors,
];

/**
 * Validation pour les emails
 */
export const validateEmail = (field: string = 'email') => {
  return body(field).isEmail().withMessage(`${field} must be a valid email address`);
};

/**
 * Middleware de validation complet avec Joi
 */
export const validateWithJoi = (schema: {
  body?: any;
  query?: any;
  params?: any;
  headers?: any;
}) => {
  return validateRequest(schema);
};

/**
 * Middleware de sanitization et validation complet
 */
export const fullValidation = (schema?: {
  body?: any;
  query?: any;
  params?: any;
  headers?: any;
}) => {
  const middlewares = [
    validateContentType,
    validateRequestSize(),
    validateHeaders,
    validateUrlParams,
    sanitizeInput,
    validateJsonData,
    validateFileUpload,
  ];

  if (schema) {
    middlewares.push(validateRequest(schema));
  }

  return middlewares;
};

/**
 * Schémas de validation prêts à l'emploi
 */
export const schemas = validationSchemas;
