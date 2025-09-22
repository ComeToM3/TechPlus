import { NextFunction, Request, Response } from 'express';
import { jwtService } from '@/services/jwt';
import prisma from '@/config/database';

// Interface pour étendre Request avec les données utilisateur
declare global {
  namespace Express {
    interface Request {
      user?: {
        id: string;
        email: string;
        role: string;
      };
    }
  }
}

/**
 * Middleware d'authentification JWT
 */
export const authenticateToken = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const authHeader = req.headers.authorization;
    const token = jwtService.extractTokenFromHeader(authHeader);

    if (!token) {
      res.status(401).json({
        error: 'Access token required',
        message: 'Please provide a valid access token',
      });
      return;
    }

    // Vérifier le token
    const decoded = jwtService.verifyAccessToken(token);

    // Vérifier que l'utilisateur existe toujours
    const user = await prisma.user.findUnique({
      where: { id: decoded.userId },
      select: { id: true, email: true, role: true },
    });

    if (!user) {
      res.status(401).json({
        error: 'User not found',
        message: 'The user associated with this token no longer exists',
      });
      return;
    }

    // Ajouter les données utilisateur à la requête
    req.user = {
      id: user.id,
      email: user.email,
      role: user.role,
    };

    next();
  } catch (error) {
    console.error('Authentication error:', error);

    if (error instanceof Error) {
      if (error.message === 'Token expired') {
        res.status(401).json({
          error: 'Token expired',
          message: 'Please refresh your token',
        });
        return;
      }

      if (error.message === 'Invalid token') {
        res.status(401).json({
          error: 'Invalid token',
          message: 'The provided token is invalid',
        });
        return;
      }
    }

    res.status(401).json({
      error: 'Authentication failed',
      message: 'Unable to authenticate the request',
    });
  }
};

/**
 * Middleware pour vérifier les rôles
 */
export const requireRole = (allowedRoles: string[]) => {
  return (req: Request, res: Response, next: NextFunction): void => {
    if (!req.user) {
      res.status(401).json({
        error: 'Authentication required',
        message: 'Please authenticate first',
      });
      return;
    }

    if (!allowedRoles.includes(req.user.role)) {
      res.status(403).json({
        error: 'Insufficient permissions',
        message: `Access denied. Required roles: ${allowedRoles.join(', ')}`,
      });
      return;
    }

    next();
  };
};

/**
 * Middleware pour vérifier le rôle admin
 */
export const requireAdmin = (req: Request, res: Response, next: NextFunction): void => {
  requireRole(['ADMIN', 'SUPER_ADMIN'])(req, res, next);
};

/**
 * Middleware pour vérifier le rôle super admin
 */
export const requireSuperAdmin = (req: Request, res: Response, next: NextFunction): void => {
  requireRole(['SUPER_ADMIN'])(req, res, next);
};

/**
 * Middleware optionnel d'authentification (ne bloque pas si pas de token)
 */
export const optionalAuth = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const authHeader = req.headers.authorization;
    const token = jwtService.extractTokenFromHeader(authHeader);

    if (token) {
      const decoded = jwtService.verifyAccessToken(token);
      const user = await prisma.user.findUnique({
        where: { id: decoded.userId },
        select: { id: true, email: true, role: true },
      });

      if (user) {
        req.user = {
          id: user.id,
          email: user.email,
          role: user.role,
        };
      }
    }
  } catch (error) {
    // Ignorer les erreurs d'authentification pour ce middleware optionnel
    console.warn('Optional auth failed:', error);
  }

  next();
};

/**
 * Middleware pour vérifier l'accès aux réservations par token de gestion
 */
export const authenticateManagementToken = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { token } = req.params;

    if (!token) {
      res.status(400).json({
        error: 'Management token required',
        message: 'Please provide a valid management token',
      });
      return;
    }

    // Vérifier que le token existe et n'est pas expiré
    const reservation = await prisma.reservation.findUnique({
      where: { managementToken: token },
      include: {
        user: { select: { id: true, email: true, role: true } },
        restaurant: { select: { id: true, name: true } },
      },
    });

    if (!reservation) {
      res.status(404).json({
        error: 'Invalid management token',
        message: 'The provided management token is invalid',
      });
      return;
    }

    if (reservation.tokenExpiresAt && reservation.tokenExpiresAt < new Date()) {
      res.status(410).json({
        error: 'Management token expired',
        message: 'This management token has expired',
      });
      return;
    }

    // Ajouter les données de réservation à la requête
    (req as any).reservation = reservation;
    (req as any).managementToken = token;

    next();
  } catch (error) {
    console.error('Management token authentication error:', error);
    res.status(500).json({
      error: 'Authentication failed',
      message: 'Unable to verify management token',
    });
  }
};
