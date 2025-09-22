import Joi from 'joi';
import { body, param, query } from 'express-validator';

/**
 * Schémas de validation Joi pour les entités principales
 */

// Schéma de validation pour l'authentification
export const authValidationSchema = Joi.object({
  email: Joi.string()
    .email()
    .required()
    .messages({
      'string.email': 'Email must be a valid email address',
      'any.required': 'Email is required',
    }),
  password: Joi.string()
    .min(8)
    .max(128)
    .pattern(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/)
    .required()
    .messages({
      'string.min': 'Password must be at least 8 characters long',
      'string.max': 'Password must not exceed 128 characters',
      'string.pattern.base': 'Password must contain at least one lowercase letter, one uppercase letter, one number, and one special character',
      'any.required': 'Password is required',
    }),
  name: Joi.string()
    .min(2)
    .max(50)
    .pattern(/^[a-zA-ZÀ-ÿ\s'-]+$/)
    .optional()
    .messages({
      'string.min': 'Name must be at least 2 characters long',
      'string.max': 'Name must not exceed 50 characters',
      'string.pattern.base': 'Name can only contain letters, spaces, hyphens, and apostrophes',
    }),
  phone: Joi.string()
    .pattern(/^\+?[1-9]\d{1,14}$/)
    .optional()
    .messages({
      'string.pattern.base': 'Phone number must be a valid international format',
    }),
});

// Schéma de validation pour les réservations
export const reservationValidationSchema = Joi.object({
  date: Joi.date()
    .min('now')
    .required()
    .messages({
      'date.min': 'Reservation date must be in the future',
      'any.required': 'Reservation date is required',
    }),
  time: Joi.string()
    .pattern(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/)
    .required()
    .messages({
      'string.pattern.base': 'Time must be in HH:MM format',
      'any.required': 'Reservation time is required',
    }),
  partySize: Joi.number()
    .integer()
    .min(1)
    .max(12)
    .required()
    .messages({
      'number.min': 'Party size must be at least 1',
      'number.max': 'Party size cannot exceed 12',
      'any.required': 'Party size is required',
    }),
  specialRequests: Joi.string()
    .max(500)
    .optional()
    .messages({
      'string.max': 'Special requests cannot exceed 500 characters',
    }),
  clientName: Joi.string()
    .min(2)
    .max(50)
    .pattern(/^[a-zA-ZÀ-ÿ\s'-]+$/)
    .optional()
    .messages({
      'string.min': 'Client name must be at least 2 characters long',
      'string.max': 'Client name must not exceed 50 characters',
      'string.pattern.base': 'Client name can only contain letters, spaces, hyphens, and apostrophes',
    }),
  clientEmail: Joi.string()
    .email()
    .optional()
    .messages({
      'string.email': 'Client email must be a valid email address',
    }),
  clientPhone: Joi.string()
    .pattern(/^\+?[1-9]\d{1,14}$/)
    .optional()
    .messages({
      'string.pattern.base': 'Client phone must be a valid international format',
    }),
});

// Schéma de validation pour les paiements
export const paymentValidationSchema = Joi.object({
  amount: Joi.number()
    .positive()
    .precision(2)
    .required()
    .messages({
      'number.positive': 'Payment amount must be positive',
      'any.required': 'Payment amount is required',
    }),
  currency: Joi.string()
    .length(3)
    .uppercase()
    .valid('USD', 'EUR', 'CAD')
    .default('CAD')
    .messages({
      'string.length': 'Currency must be a 3-letter code',
      'any.only': 'Currency must be USD, EUR, or CAD',
    }),
  paymentMethodId: Joi.string()
    .required()
    .messages({
      'any.required': 'Payment method ID is required',
    }),
  reservationId: Joi.string()
    .required()
    .messages({
      'any.required': 'Reservation ID is required',
    }),
});

// Schéma de validation pour les éléments de menu
export const menuItemValidationSchema = Joi.object({
  name: Joi.string()
    .min(2)
    .max(100)
    .required()
    .messages({
      'string.min': 'Menu item name must be at least 2 characters long',
      'string.max': 'Menu item name must not exceed 100 characters',
      'any.required': 'Menu item name is required',
    }),
  description: Joi.string()
    .max(500)
    .optional()
    .messages({
      'string.max': 'Description cannot exceed 500 characters',
    }),
  price: Joi.number()
    .positive()
    .precision(2)
    .required()
    .messages({
      'number.positive': 'Price must be positive',
      'any.required': 'Price is required',
    }),
  category: Joi.string()
    .min(2)
    .max(50)
    .required()
    .messages({
      'string.min': 'Category must be at least 2 characters long',
      'string.max': 'Category must not exceed 50 characters',
      'any.required': 'Category is required',
    }),
  allergens: Joi.array()
    .items(Joi.string().max(50))
    .max(10)
    .optional()
    .messages({
      'array.max': 'Cannot have more than 10 allergens',
    }),
  isAvailable: Joi.boolean()
    .default(true)
    .messages({
      'boolean.base': 'Availability must be a boolean value',
    }),
});

// Schéma de validation pour les tables
export const tableValidationSchema = Joi.object({
  number: Joi.number()
    .integer()
    .positive()
    .required()
    .messages({
      'number.positive': 'Table number must be positive',
      'any.required': 'Table number is required',
    }),
  capacity: Joi.number()
    .integer()
    .min(1)
    .max(12)
    .required()
    .messages({
      'number.min': 'Table capacity must be at least 1',
      'number.max': 'Table capacity cannot exceed 12',
      'any.required': 'Table capacity is required',
    }),
  position: Joi.string()
    .max(100)
    .optional()
    .messages({
      'string.max': 'Position description cannot exceed 100 characters',
    }),
  isActive: Joi.boolean()
    .default(true)
    .messages({
      'boolean.base': 'Active status must be a boolean value',
    }),
});

// Schéma de validation pour les restaurants
export const restaurantValidationSchema = Joi.object({
  name: Joi.string()
    .min(2)
    .max(100)
    .required()
    .messages({
      'string.min': 'Restaurant name must be at least 2 characters long',
      'string.max': 'Restaurant name must not exceed 100 characters',
      'any.required': 'Restaurant name is required',
    }),
  description: Joi.string()
    .max(1000)
    .optional()
    .messages({
      'string.max': 'Description cannot exceed 1000 characters',
    }),
  address: Joi.string()
    .min(10)
    .max(200)
    .required()
    .messages({
      'string.min': 'Address must be at least 10 characters long',
      'string.max': 'Address must not exceed 200 characters',
      'any.required': 'Address is required',
    }),
  phone: Joi.string()
    .pattern(/^\+?[1-9]\d{1,14}$/)
    .required()
    .messages({
      'string.pattern.base': 'Phone number must be a valid international format',
      'any.required': 'Phone number is required',
    }),
  email: Joi.string()
    .email()
    .required()
    .messages({
      'string.email': 'Email must be a valid email address',
      'any.required': 'Email is required',
    }),
  website: Joi.string()
    .uri()
    .optional()
    .messages({
      'string.uri': 'Website must be a valid URL',
    }),
  averagePricePerPerson: Joi.number()
    .positive()
    .precision(2)
    .default(25.00)
    .messages({
      'number.positive': 'Average price per person must be positive',
    }),
  minimumDepositAmount: Joi.number()
    .positive()
    .precision(2)
    .default(10.00)
    .messages({
      'number.positive': 'Minimum deposit amount must be positive',
    }),
  paymentThreshold: Joi.number()
    .integer()
    .min(1)
    .max(20)
    .default(6)
    .messages({
      'number.min': 'Payment threshold must be at least 1',
      'number.max': 'Payment threshold cannot exceed 20',
    }),
});

/**
 * Validateurs express-validator pour les routes
 */

// Validateurs pour l'authentification
export const authValidators = {
  login: [
    body('email')
      .isEmail()
      .normalizeEmail()
      .withMessage('Email must be a valid email address'),
    body('password')
      .isLength({ min: 8, max: 128 })
      .withMessage('Password must be between 8 and 128 characters'),
  ],
  register: [
    body('email')
      .isEmail()
      .normalizeEmail()
      .withMessage('Email must be a valid email address'),
    body('password')
      .isLength({ min: 8, max: 128 })
      .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/)
      .withMessage('Password must contain at least one lowercase letter, one uppercase letter, one number, and one special character'),
    body('name')
      .optional()
      .isLength({ min: 2, max: 50 })
      .matches(/^[a-zA-ZÀ-ÿ\s'-]+$/)
      .withMessage('Name can only contain letters, spaces, hyphens, and apostrophes'),
    body('phone')
      .optional()
      .matches(/^\+?[1-9]\d{1,14}$/)
      .withMessage('Phone number must be a valid international format'),
  ],
};

// Validateurs pour les réservations
export const reservationValidators = {
  create: [
    body('date')
      .isISO8601()
      .withMessage('Date must be a valid ISO 8601 date')
      .custom((value) => {
        const date = new Date(value);
        const now = new Date();
        if (date <= now) {
          throw new Error('Reservation date must be in the future');
        }
        return true;
      }),
    body('time')
      .matches(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/)
      .withMessage('Time must be in HH:MM format'),
    body('partySize')
      .isInt({ min: 1, max: 12 })
      .withMessage('Party size must be between 1 and 12'),
    body('specialRequests')
      .optional()
      .isLength({ max: 500 })
      .withMessage('Special requests cannot exceed 500 characters'),
    body('clientName')
      .optional()
      .isLength({ min: 2, max: 50 })
      .matches(/^[a-zA-ZÀ-ÿ\s'-]+$/)
      .withMessage('Client name can only contain letters, spaces, hyphens, and apostrophes'),
    body('clientEmail')
      .optional()
      .isEmail()
      .normalizeEmail()
      .withMessage('Client email must be a valid email address'),
    body('clientPhone')
      .optional()
      .matches(/^\+?[1-9]\d{1,14}$/)
      .withMessage('Client phone must be a valid international format'),
  ],
  update: [
    param('id')
      .isUUID()
      .withMessage('Reservation ID must be a valid UUID'),
    body('date')
      .optional()
      .isISO8601()
      .withMessage('Date must be a valid ISO 8601 date'),
    body('time')
      .optional()
      .matches(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/)
      .withMessage('Time must be in HH:MM format'),
    body('partySize')
      .optional()
      .isInt({ min: 1, max: 12 })
      .withMessage('Party size must be between 1 and 12'),
    body('specialRequests')
      .optional()
      .isLength({ max: 500 })
      .withMessage('Special requests cannot exceed 500 characters'),
  ],
  getById: [
    param('id')
      .isUUID()
      .withMessage('Reservation ID must be a valid UUID'),
  ],
  delete: [
    param('id')
      .isUUID()
      .withMessage('Reservation ID must be a valid UUID'),
  ],
};

// Validateurs pour les paiements
export const paymentValidators = {
  create: [
    body('amount')
      .isFloat({ min: 0.01 })
      .withMessage('Payment amount must be a positive number'),
    body('currency')
      .optional()
      .isIn(['USD', 'EUR', 'CAD'])
      .withMessage('Currency must be USD, EUR, or CAD'),
    body('paymentMethodId')
      .notEmpty()
      .withMessage('Payment method ID is required'),
    body('reservationId')
      .isUUID()
      .withMessage('Reservation ID must be a valid UUID'),
  ],
  getById: [
    param('id')
      .isUUID()
      .withMessage('Payment ID must be a valid UUID'),
  ],
};

// Validateurs pour les éléments de menu
export const menuItemValidators = {
  create: [
    body('name')
      .isLength({ min: 2, max: 100 })
      .withMessage('Menu item name must be between 2 and 100 characters'),
    body('description')
      .optional()
      .isLength({ max: 500 })
      .withMessage('Description cannot exceed 500 characters'),
    body('price')
      .isFloat({ min: 0.01 })
      .withMessage('Price must be a positive number'),
    body('category')
      .isLength({ min: 2, max: 50 })
      .withMessage('Category must be between 2 and 50 characters'),
    body('allergens')
      .optional()
      .isArray({ max: 10 })
      .withMessage('Cannot have more than 10 allergens'),
    body('isAvailable')
      .optional()
      .isBoolean()
      .withMessage('Availability must be a boolean value'),
  ],
  update: [
    param('id')
      .isUUID()
      .withMessage('Menu item ID must be a valid UUID'),
    body('name')
      .optional()
      .isLength({ min: 2, max: 100 })
      .withMessage('Menu item name must be between 2 and 100 characters'),
    body('description')
      .optional()
      .isLength({ max: 500 })
      .withMessage('Description cannot exceed 500 characters'),
    body('price')
      .optional()
      .isFloat({ min: 0.01 })
      .withMessage('Price must be a positive number'),
    body('category')
      .optional()
      .isLength({ min: 2, max: 50 })
      .withMessage('Category must be between 2 and 50 characters'),
    body('allergens')
      .optional()
      .isArray({ max: 10 })
      .withMessage('Cannot have more than 10 allergens'),
    body('isAvailable')
      .optional()
      .isBoolean()
      .withMessage('Availability must be a boolean value'),
  ],
  getById: [
    param('id')
      .isUUID()
      .withMessage('Menu item ID must be a valid UUID'),
  ],
  delete: [
    param('id')
      .isUUID()
      .withMessage('Menu item ID must be a valid UUID'),
  ],
};

// Validateurs pour les tables
export const tableValidators = {
  create: [
    body('number')
      .isInt({ min: 1 })
      .withMessage('Table number must be a positive integer'),
    body('capacity')
      .isInt({ min: 1, max: 12 })
      .withMessage('Table capacity must be between 1 and 12'),
    body('position')
      .optional()
      .isLength({ max: 100 })
      .withMessage('Position description cannot exceed 100 characters'),
    body('isActive')
      .optional()
      .isBoolean()
      .withMessage('Active status must be a boolean value'),
  ],
  update: [
    param('id')
      .isUUID()
      .withMessage('Table ID must be a valid UUID'),
    body('number')
      .optional()
      .isInt({ min: 1 })
      .withMessage('Table number must be a positive integer'),
    body('capacity')
      .optional()
      .isInt({ min: 1, max: 12 })
      .withMessage('Table capacity must be between 1 and 12'),
    body('position')
      .optional()
      .isLength({ max: 100 })
      .withMessage('Position description cannot exceed 100 characters'),
    body('isActive')
      .optional()
      .isBoolean()
      .withMessage('Active status must be a boolean value'),
  ],
  getById: [
    param('id')
      .isUUID()
      .withMessage('Table ID must be a valid UUID'),
  ],
  delete: [
    param('id')
      .isUUID()
      .withMessage('Table ID must be a valid UUID'),
  ],
};

// Validateurs pour les paramètres de requête
export const queryValidators = {
  pagination: [
    query('page')
      .optional()
      .isInt({ min: 1 })
      .withMessage('Page must be a positive integer'),
    query('limit')
      .optional()
      .isInt({ min: 1, max: 100 })
      .withMessage('Limit must be between 1 and 100'),
    query('sort')
      .optional()
      .isIn(['asc', 'desc'])
      .withMessage('Sort must be either asc or desc'),
    query('orderBy')
      .optional()
      .isLength({ min: 1, max: 50 })
      .withMessage('Order by field must be between 1 and 50 characters'),
  ],
  dateRange: [
    query('startDate')
      .optional()
      .isISO8601()
      .withMessage('Start date must be a valid ISO 8601 date'),
    query('endDate')
      .optional()
      .isISO8601()
      .withMessage('End date must be a valid ISO 8601 date'),
  ],
  search: [
    query('search')
      .optional()
      .isLength({ min: 1, max: 100 })
      .withMessage('Search term must be between 1 and 100 characters'),
  ],
};

/**
 * Fonctions utilitaires de validation
 */

// Fonction pour valider un email
export const isValidEmail = (email: string): boolean => {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
};

// Fonction pour valider un numéro de téléphone
export const isValidPhone = (phone: string): boolean => {
  const phoneRegex = /^\+?[1-9]\d{1,14}$/;
  return phoneRegex.test(phone);
};

// Fonction pour valider un mot de passe
export const isValidPassword = (password: string): boolean => {
  const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,128}$/;
  return passwordRegex.test(password);
};

// Fonction pour valider un UUID
export const isValidUUID = (uuid: string): boolean => {
  const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
  return uuidRegex.test(uuid);
};

// Fonction pour valider une date
export const isValidDate = (date: string): boolean => {
  const dateObj = new Date(date);
  return dateObj instanceof Date && !isNaN(dateObj.getTime());
};

// Fonction pour valider une heure
export const isValidTime = (time: string): boolean => {
  const timeRegex = /^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/;
  return timeRegex.test(time);
};
