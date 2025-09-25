import { Request, Response } from 'express';
import { compare, hash } from 'bcryptjs';
import { v4 as uuidv4 } from 'uuid';
import prisma from '@/config/database';
import { jwtService } from '@/services/jwt';
import { OAuthService } from '@/services/oauthService';
import { CustomError, asyncHandler } from '@/middleware/error';
import logger from '@/utils/logger';

/**
 * Inscription d'un nouvel utilisateur
 */
export const register = asyncHandler(async (req: Request, res: Response) => {
  const { email, name, phone, password } = req.body;

  // Vérifier si l'utilisateur existe déjà
  const existingUser = await prisma.user.findUnique({
    where: { email },
  });

  if (existingUser) {
    throw new CustomError('User already exists with this email', 409);
  }

  // Hasher le mot de passe
  const hashedPassword = await hash(password, 12);

  // Créer l'utilisateur
  const user = await prisma.user.create({
    data: {
      email,
      password: hashedPassword,
      name,
      phone,
      isActive: true,
    },
    select: {
      id: true,
      email: true,
      name: true,
      phone: true,
      role: true,
      createdAt: true,
    },
  });

  // Générer les tokens JWT
  const tokenPair = jwtService.generateTokenPair({
    userId: user.id,
    email: user.email,
    role: user.role,
  });

  res.status(201).json({
    success: true,
    message: 'User registered successfully',
    data: {
      user,
      tokens: tokenPair,
    },
  });
});

/**
 * Connexion d'un utilisateur
 */
export const login = asyncHandler(async (req: Request, res: Response) => {
  const { email, password } = req.body;

  // Trouver l'utilisateur
  const user = await prisma.user.findUnique({
    where: { email },
  });

  if (!user) {
    throw new CustomError('Invalid email or password', 401);
  }

  // Vérifier le mot de passe
  if (!user.password) {
    throw new CustomError('Invalid email or password', 401);
  }

  const isValidPassword = await compare(password, user.password);
  if (!isValidPassword) {
    throw new CustomError('Invalid email or password', 401);
  }

  // Vérifier si l'utilisateur est actif
  if (!user.isActive) {
    throw new CustomError('Account is deactivated', 403);
  }

  // Mettre à jour la dernière connexion
  await prisma.user.update({
    where: { id: user.id },
    data: { lastLoginAt: new Date() },
  });

  // Générer les tokens JWT
  const tokenPair = jwtService.generateTokenPair({
    userId: user.id,
    email: user.email,
    role: user.role,
  });

  res.json({
    success: true,
    message: 'Login successful',
    data: {
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
        phone: user.phone,
        role: user.role,
      },
      tokens: tokenPair,
    },
  });
});

/**
 * Rafraîchissement du token
 */
export const refreshToken = asyncHandler(async (req: Request, res: Response) => {
  const { refreshToken } = req.body;

  if (!refreshToken) {
    throw new CustomError('Refresh token is required', 400);
  }

  try {
    // Vérifier le refresh token
    const decoded = jwtService.verifyRefreshToken(refreshToken);

    // Vérifier que l'utilisateur existe toujours
    const user = await prisma.user.findUnique({
      where: { id: decoded.userId },
      select: { id: true, email: true, role: true },
    });

    if (!user) {
      throw new CustomError('User not found', 404);
    }

    // Générer une nouvelle paire de tokens
    const tokenPair = jwtService.generateTokenPair({
      userId: user.id,
      email: user.email,
      role: user.role,
    });

    res.json({
      success: true,
      message: 'Token refreshed successfully',
      data: {
        tokens: tokenPair,
      },
    });
  } catch (error) {
    throw new CustomError('Invalid refresh token', 401);
  }
});

/**
 * Déconnexion (invalidation du token côté client)
 */
export const logout = asyncHandler(async (req: Request, res: Response) => {
  // Dans une implémentation complète, on pourrait ajouter le token à une blacklist
  // Pour l'instant, on se contente de confirmer la déconnexion

  res.json({
    success: true,
    message: 'Logout successful',
  });
});

/**
 * Obtenir le profil de l'utilisateur connecté
 */
export const getProfile = asyncHandler(async (req: Request, res: Response) => {
  const userId = req.user?.id;

  if (!userId) {
    throw new CustomError('User not authenticated', 401);
  }

  const user = await prisma.user.findUnique({
    where: { id: userId },
    select: {
      id: true,
      email: true,
      name: true,
      phone: true,
      avatar: true,
      role: true,
      createdAt: true,
      updatedAt: true,
    },
  });

  if (!user) {
    throw new CustomError('User not found', 404);
  }

  res.json({
    success: true,
    data: { user },
  });
});

/**
 * Mettre à jour le profil de l'utilisateur
 */
export const updateProfile = asyncHandler(async (req: Request, res: Response) => {
  const userId = req.user?.id;
  const { name, phone, avatar } = req.body;

  if (!userId) {
    throw new CustomError('User not authenticated', 401);
  }

  const user = await prisma.user.update({
    where: { id: userId },
    data: {
      ...(name && { name }),
      ...(phone && { phone }),
      ...(avatar && { avatar }),
    },
    select: {
      id: true,
      email: true,
      name: true,
      phone: true,
      avatar: true,
      role: true,
      updatedAt: true,
    },
  });

  res.json({
    success: true,
    message: 'Profile updated successfully',
    data: { user },
  });
});

/**
 * Changer le mot de passe
 */
export const changePassword = asyncHandler(async (req: Request, res: Response) => {
  const userId = req.user?.id;
  const { currentPassword, newPassword } = req.body;

  if (!userId) {
    throw new CustomError('User not authenticated', 401);
  }

  // Vérifier l'ancien mot de passe
  const user = await prisma.user.findUnique({ where: { id: userId } });
  if (!user?.password) {
    throw new CustomError('User not found or no password set', 404);
  }

  const isValidPassword = await compare(currentPassword, user.password);
  if (!isValidPassword) {
    throw new CustomError('Current password is incorrect', 400);
  }

  // Hasher le nouveau mot de passe
  const hashedNewPassword = await hash(newPassword, 12);

  // Mettre à jour le mot de passe
  await prisma.user.update({
    where: { id: userId },
    data: { password: hashedNewPassword },
  });

  res.json({
    success: true,
    message: 'Password changed successfully',
  });
});

/**
 * OAuth2 - Google
 */
export const googleAuth = asyncHandler(async (req: Request, res: Response) => {
  try {
    const { accessToken } = req.body;

    if (!accessToken) {
      res.status(400).json({
        success: false,
        message: 'Access token is required',
      });
      return;
    }

    // Vérifier le token Google
    const response = await fetch(
      `https://www.googleapis.com/oauth2/v2/userinfo?access_token=${accessToken}`
    );

    if (!response.ok) {
      res.status(401).json({
        success: false,
        message: 'Invalid Google access token',
      });
      return;
    }

    const googleUser = await response.json() as any;

    // Créer le profil OAuth
    const oauthProfile = {
      id: googleUser.id,
      email: googleUser.email,
      name: googleUser.name,
      picture: googleUser.picture,
      provider: 'google' as const,
    };

    // Trouver ou créer l'utilisateur
    const { user, isNewUser } = await OAuthService.findOrCreateUser(oauthProfile);

    // Générer le token JWT
    const tokenPair = jwtService.generateTokenPair({
      userId: user.id,
      email: user.email,
      role: user.role,
    });

    logger.info(`Google OAuth login successful for user: ${user.email}`);

    res.json({
      success: true,
      message: isNewUser ? 'Account created successfully' : 'Login successful',
      data: {
        user: {
          id: user.id,
          email: user.email,
          name: user.name,
          avatar: user.avatar,
          role: user.role,
        },
        token: tokenPair.accessToken,
        refreshToken: tokenPair.refreshToken,
        isNewUser,
      },
    });
  } catch (error) {
    logger.error('Google OAuth error:', error);
    res.status(500).json({
      success: false,
      message: 'Google authentication failed',
    });
  }
});

/**
 * OAuth2 - Facebook
 */
export const facebookAuth = asyncHandler(async (req: Request, res: Response) => {
  try {
    const { accessToken } = req.body;

    if (!accessToken) {
      res.status(400).json({
        success: false,
        message: 'Access token is required',
      });
      return;
    }

    // Vérifier le token Facebook
    const response = await fetch(
      `https://graph.facebook.com/me?fields=id,name,email,picture&access_token=${accessToken}`
    );

    if (!response.ok) {
      res.status(401).json({
        success: false,
        message: 'Invalid Facebook access token',
      });
      return;
    }

    const facebookUser = await response.json() as any;

    // Créer le profil OAuth
    const oauthProfile = {
      id: facebookUser.id,
      email: facebookUser.email,
      name: facebookUser.name,
      picture: facebookUser.picture?.data?.url,
      provider: 'facebook' as const,
    };

    // Trouver ou créer l'utilisateur
    const { user, isNewUser } = await OAuthService.findOrCreateUser(oauthProfile);

    // Générer le token JWT
    const tokenPair = jwtService.generateTokenPair({
      userId: user.id,
      email: user.email,
      role: user.role,
    });

    logger.info(`Facebook OAuth login successful for user: ${user.email}`);

    res.json({
      success: true,
      message: isNewUser ? 'Account created successfully' : 'Login successful',
      data: {
        user: {
          id: user.id,
          email: user.email,
          name: user.name,
          avatar: user.avatar,
          role: user.role,
        },
        token: tokenPair.accessToken,
        refreshToken: tokenPair.refreshToken,
        isNewUser,
      },
    });
  } catch (error) {
    logger.error('Facebook OAuth error:', error);
    res.status(500).json({
      success: false,
      message: 'Facebook authentication failed',
    });
  }
});
