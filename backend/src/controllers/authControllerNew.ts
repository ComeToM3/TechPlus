/**
 * Nouveau AuthController utilisant l'architecture Clean
 * Ce controller utilise les use cases au lieu de la logique métier directe
 */

import { Request, Response } from 'express';
import { CustomError, asyncHandler } from '@/middleware/error';
import logger from '@/utils/logger';

// Use Cases
import { RegisterUserUseCase, RegisterUserRequest } from '../domain/use-cases/auth/RegisterUserUseCase';
import { LoginUserUseCase, LoginUserRequest } from '../domain/use-cases/auth/LoginUserUseCase';
import { RefreshTokenUseCase, RefreshTokenRequest } from '../domain/use-cases/auth/RefreshTokenUseCase';
import { GetProfileUseCase, GetProfileRequest } from '../domain/use-cases/auth/GetProfileUseCase';
import { UpdateProfileUseCase, UpdateProfileRequest } from '../domain/use-cases/auth/UpdateProfileUseCase';
import { ChangePasswordUseCase, ChangePasswordRequest } from '../domain/use-cases/auth/ChangePasswordUseCase';
import { LoginWithTokenUseCase, LoginWithTokenRequest } from '../domain/use-cases/auth/LoginWithTokenUseCase';
import { LogoutUseCase, LogoutRequest } from '../domain/use-cases/auth/LogoutUseCase';

export class AuthController {
  constructor(
    private readonly registerUserUseCase: RegisterUserUseCase,
    private readonly loginUserUseCase: LoginUserUseCase,
    private readonly refreshTokenUseCase: RefreshTokenUseCase,
    private readonly getProfileUseCase: GetProfileUseCase,
    private readonly updateProfileUseCase: UpdateProfileUseCase,
    private readonly changePasswordUseCase: ChangePasswordUseCase,
    private readonly loginWithTokenUseCase: LoginWithTokenUseCase,
    private readonly logoutUseCase: LogoutUseCase
  ) {}

  /**
   * Inscription d'un nouvel utilisateur
   */
  register = asyncHandler(async (req: Request, res: Response) => {
    const request: RegisterUserRequest = {
      email: req.body.email,
      name: req.body.name,
      phone: req.body.phone,
      password: req.body.password
    };

    try {
      const response = await this.registerUserUseCase.execute(request);

      res.status(201).json({
        success: true,
        message: 'User registered successfully',
        data: {
          user: response.user.toJSON(),
          tokens: response.tokens.toJSON()
        }
      });
    } catch (error) {
      this.handleError(error, res);
    }
  });

  /**
   * Connexion d'un utilisateur
   */
  login = asyncHandler(async (req: Request, res: Response) => {
    const request: LoginUserRequest = {
      email: req.body.email,
      password: req.body.password
    };

    try {
      const response = await this.loginUserUseCase.execute(request);

      res.json({
        success: true,
        message: 'Login successful',
        data: {
          user: response.user.toJSON(),
          tokens: response.tokens.toJSON()
        }
      });
    } catch (error) {
      this.handleError(error, res);
    }
  });

  /**
   * Rafraîchissement du token
   */
  refreshToken = asyncHandler(async (req: Request, res: Response) => {
    const request: RefreshTokenRequest = {
      refreshToken: req.body.refreshToken
    };

    try {
      const response = await this.refreshTokenUseCase.execute(request);

      res.json({
        success: true,
        message: 'Token refreshed successfully',
        data: {
          tokens: response.tokens.toJSON()
        }
      });
    } catch (error) {
      this.handleError(error, res);
    }
  });

  /**
   * Déconnexion
   */
  logout = asyncHandler(async (req: Request, res: Response) => {
    const accessToken = req.headers.authorization?.replace('Bearer ', '');
    const request: LogoutRequest = {
      userId: (req.user as any)?.id || '',
      ...(accessToken && { accessToken })
    };

    try {
      const response = await this.logoutUseCase.execute(request);

      res.json({
        success: true,
        message: 'Logout successful'
      });
    } catch (error) {
      this.handleError(error, res);
    }
  });

  /**
   * Obtenir le profil de l'utilisateur connecté
   */
  getProfile = asyncHandler(async (req: Request, res: Response) => {
    const request: GetProfileRequest = {
      userId: (req.user as any)?.id || ''
    };

    try {
      const response = await this.getProfileUseCase.execute(request);

      res.json({
        success: true,
        data: { user: response.user.toJSON() }
      });
    } catch (error) {
      this.handleError(error, res);
    }
  });

  /**
   * Mettre à jour le profil de l'utilisateur
   */
  updateProfile = asyncHandler(async (req: Request, res: Response) => {
    const request: UpdateProfileRequest = {
      userId: (req.user as any)?.id || '',
      name: req.body.name,
      phone: req.body.phone,
      avatar: req.body.avatar
    };

    try {
      const response = await this.updateProfileUseCase.execute(request);

      res.json({
        success: true,
        message: 'Profile updated successfully',
        data: { user: response.user.toJSON() }
      });
    } catch (error) {
      this.handleError(error, res);
    }
  });

  /**
   * Changer le mot de passe
   */
  changePassword = asyncHandler(async (req: Request, res: Response) => {
    const request: ChangePasswordRequest = {
      userId: (req.user as any)?.id || '',
      currentPassword: req.body.currentPassword,
      newPassword: req.body.newPassword
    };

    try {
      const response = await this.changePasswordUseCase.execute(request);

      res.json({
        success: true,
        message: 'Password changed successfully'
      });
    } catch (error) {
      this.handleError(error, res);
    }
  });

  /**
   * Connexion par token (pour les guests)
   */
  loginWithToken = asyncHandler(async (req: Request, res: Response) => {
    const request: LoginWithTokenRequest = {
      token: req.body.token
    };

    try {
      const response = await this.loginWithTokenUseCase.execute(request);

      logger.info(`Token login successful for guest: ${response.user.email} with reservation: ${response.reservation.id}`);

      res.json({
        success: true,
        message: 'Token login successful',
        data: {
          user: response.user.toJSON(),
          tokens: response.tokens.toJSON(),
          reservation: response.reservation
        }
      });
    } catch (error) {
      this.handleError(error, res);
    }
  });


  /**
   * Gestion centralisée des erreurs
   */
  private handleError(error: any, res: Response): void {
    logger.error('AuthController error:', error);

    if (error.message === 'User already exists with this email') {
      res.status(409).json({
        success: false,
        message: error.message
      });
    } else if (error.message === 'Invalid email or password') {
      res.status(401).json({
        success: false,
        message: error.message
      });
    } else if (error.message === 'Account is deactivated') {
      res.status(403).json({
        success: false,
        message: error.message
      });
    } else if (error.message === 'User not found') {
      res.status(404).json({
        success: false,
        message: error.message
      });
    } else if (error.message === 'Invalid refresh token') {
      res.status(401).json({
        success: false,
        message: error.message
      });
    } else if (error.message === 'Token is required') {
      res.status(400).json({
        success: false,
        message: error.message
      });
    } else if (error.message === 'Invalid token') {
      res.status(401).json({
        success: false,
        message: error.message
      });
    } else if (error.message === 'Token has expired') {
      res.status(401).json({
        success: false,
        message: error.message
      });
    } else if (error.message === 'This reservation has been cancelled') {
      res.status(410).json({
        success: false,
        message: error.message
      });
    } else if (error.message === 'Access token is required') {
      res.status(400).json({
        success: false,
        message: error.message
      });
    } else if (error.message === 'Invalid Google access token' || error.message === 'Invalid Facebook access token') {
      res.status(401).json({
        success: false,
        message: error.message
      });
    } else if (error.message === 'Google authentication failed' || error.message === 'Facebook authentication failed') {
      res.status(500).json({
        success: false,
        message: error.message
      });
    } else {
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }
}
