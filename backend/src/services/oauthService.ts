import { PrismaClient } from '@prisma/client';
import logger from '@/utils/logger';
import { config } from '@/config/environment';

const prisma = new PrismaClient();

export interface OAuthProfile {
  id: string;
  email: string;
  name: string;
  picture?: string;
  provider: 'google' | 'facebook';
}

export class OAuthService {
  /**
   * Trouve ou crée un utilisateur OAuth2
   */
  static async findOrCreateUser(profile: OAuthProfile): Promise<{ user: any; isNewUser: boolean }> {
    try {
      // Chercher un compte OAuth existant
      const existingOAuthAccount = await prisma.oAuthAccount.findUnique({
        where: {
          provider_providerId: {
            provider: profile.provider,
            providerId: profile.id,
          },
        },
        include: {
          user: true,
        },
      });

      if (existingOAuthAccount) {
        // Mettre à jour les informations de l'utilisateur
        const updatedUser = await prisma.user.update({
          where: { id: existingOAuthAccount.user.id },
          data: {
            name: profile.name,
            avatar: profile.picture || null,
            lastLoginAt: new Date(),
          },
        });

        logger.info(`OAuth login successful for existing user: ${updatedUser.email}`);
        return { user: updatedUser, isNewUser: false };
      }

      // Chercher un utilisateur existant avec le même email
      const existingUser = await prisma.user.findUnique({
        where: { email: profile.email },
      });

      if (existingUser) {
        // Lier le compte OAuth à l'utilisateur existant
        await prisma.oAuthAccount.create({
          data: {
            provider: profile.provider,
            providerId: profile.id,
            userId: existingUser.id,
          },
        });

        // Mettre à jour les informations
        const updatedUser = await prisma.user.update({
          where: { id: existingUser.id },
          data: {
            name: profile.name,
            avatar: profile.picture || null,
            lastLoginAt: new Date(),
          },
        });

        logger.info(`OAuth account linked to existing user: ${updatedUser.email}`);
        return { user: updatedUser, isNewUser: false };
      }

      // Créer un nouvel utilisateur
      const newUser = await prisma.user.create({
        data: {
          email: profile.email,
          name: profile.name,
          avatar: profile.picture || null,
          password: null, // Pas de mot de passe pour OAuth
          lastLoginAt: new Date(),
        },
      });

      // Créer le compte OAuth
      await prisma.oAuthAccount.create({
        data: {
          provider: profile.provider,
          providerId: profile.id,
          userId: newUser.id,
        },
      });

      logger.info(`New OAuth user created: ${newUser.email}`);
      return { user: newUser, isNewUser: true };
    } catch (error) {
      logger.error('Error in OAuth user creation:', error);
      throw error;
    }
  }

  /**
   * Valide la configuration OAuth
   */
  static validateOAuthConfig(): { google: boolean; facebook: boolean } {
    const googleConfigured = !!(config.oauth.google.clientId && config.oauth.google.clientSecret);
    const facebookConfigured = !!(
      config.oauth.facebook.clientId && config.oauth.facebook.clientSecret
    );

    return {
      google: googleConfigured,
      facebook: facebookConfigured,
    };
  }

  /**
   * Obtient l'URL de redirection OAuth
   */
  static getRedirectUrl(provider: 'google' | 'facebook'): string {
    const baseUrl = process.env.FRONTEND_URL || 'http://localhost:3000';
    return `${baseUrl}/api/auth/${provider}/callback`;
  }
}
