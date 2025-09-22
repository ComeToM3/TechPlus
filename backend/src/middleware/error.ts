import { NextFunction, Request, Response } from 'express';
import { config } from '@/config/environment';

export interface AppError extends Error {
  statusCode?: number;
  isOperational?: boolean;
  details?: any;
  type?: string | undefined;
}

/**
 * Classe d'erreur personnalisée
 */
export class CustomError extends Error implements AppError {
  public statusCode: number;
  public isOperational: boolean;
  public details?: any;
  public type?: string | undefined;

  constructor(
    message: string,
    statusCode: number = 500,
    options: { isOperational?: boolean; details?: any; type?: string } = {}
  ) {
    super(message);
    this.statusCode = statusCode;
    this.isOperational = options.isOperational ?? true;
    this.details = options.details;
    this.type = options.type;

    Error.captureStackTrace(this, this.constructor);
  }
}

/**
 * Middleware de gestion d'erreurs global
 */
export const errorHandler = (
  error: AppError,
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  let statusCode = error.statusCode || 500;
  let message = error.message || 'Internal Server Error';

  // Log de l'erreur
  console.error('Error:', {
    message: error.message,
    stack: error.stack,
    url: req.url,
    method: req.method,
    ip: req.ip,
    userAgent: req.get('User-Agent'),
    timestamp: new Date().toISOString(),
  });

  // Gestion des erreurs Prisma
  if (error.name === 'PrismaClientKnownRequestError') {
    statusCode = 400;
    message = 'Database operation failed';
  }

  // Gestion des erreurs de validation
  if (error.name === 'ValidationError') {
    statusCode = 400;
    message = 'Validation failed';
  }

  // Gestion des erreurs JWT
  if (error.name === 'JsonWebTokenError') {
    statusCode = 401;
    message = 'Invalid token';
  }

  if (error.name === 'TokenExpiredError') {
    statusCode = 401;
    message = 'Token expired';
  }

  // Réponse d'erreur
  const errorResponse: any = {
    error: true,
    message,
    timestamp: new Date().toISOString(),
    path: req.url,
    method: req.method,
  };

  // Ajouter les détails en développement
  if (config.nodeEnv === 'development') {
    errorResponse.stack = error.stack;
    errorResponse.details = error;
  }

  res.status(statusCode).json(errorResponse);
};

/**
 * Middleware pour les routes non trouvées
 */
export const notFoundHandler = (req: Request, res: Response): void => {
  res.status(404).json({
    error: true,
    message: 'Route not found',
    path: req.url,
    method: req.method,
    timestamp: new Date().toISOString(),
  });
};

/**
 * Wrapper pour les fonctions async
 */
export const asyncHandler = (fn: Function) => {
  return (req: Request, res: Response, next: NextFunction) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
};
