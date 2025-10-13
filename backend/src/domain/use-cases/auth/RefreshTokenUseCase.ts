/**
 * Use Case pour le rafraîchissement du token
 * Contient la logique métier pure pour le refresh token
 */

import { AuthTokens } from '../../entities/AuthTokens';
import { UserRepository } from '../../repositories/UserRepository';
import { JWTService } from './RegisterUserUseCase';

export interface RefreshTokenRequest {
  refreshToken: string;
}

export interface RefreshTokenResponse {
  tokens: AuthTokens;
}

export class RefreshTokenUseCase {
  constructor(
    private readonly userRepository: UserRepository,
    private readonly jwtService: JWTService
  ) {}

  async execute(request: RefreshTokenRequest): Promise<RefreshTokenResponse> {
    // Validation métier
    this.validateRequest(request);

    try {
      // Vérifier le refresh token
      const decoded = this.jwtService.verifyRefreshToken(request.refreshToken);

      // Vérifier que l'utilisateur existe toujours
      const user = await this.userRepository.findById(decoded.userId);
      if (!user) {
        throw new Error('User not found');
      }

      // Vérifier que l'utilisateur est toujours actif
      if (!user.isActive) {
        throw new Error('Account is deactivated');
      }

      // Générer une nouvelle paire de tokens
      const tokens = this.jwtService.generateTokenPair({
        userId: user.id,
        email: user.email,
        role: user.role
      });

      return { tokens };
    } catch (error) {
      if (error instanceof Error) {
        throw new Error('Invalid refresh token');
      }
      throw error;
    }
  }

  private validateRequest(request: RefreshTokenRequest): void {
    if (!request.refreshToken) {
      throw new Error('Refresh token is required');
    }
  }
}


