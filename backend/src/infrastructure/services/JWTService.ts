/**
 * Service d'infrastructure pour JWT
 */

import jwt from 'jsonwebtoken';
import { config } from '@/config/environment';
import { JWTService as IJWTService } from '../../domain/use-cases/auth/RegisterUserUseCase';
import { AuthTokens } from '../../domain/entities/AuthTokens';

export class JWTService implements IJWTService {
  private readonly accessTokenSecret: string;
  private readonly refreshTokenSecret: string;
  private readonly accessTokenExpiry: string;
  private readonly refreshTokenExpiry: string;

  constructor() {
    this.accessTokenSecret = config.jwt.secret;
    this.refreshTokenSecret = `${config.jwt.secret}_refresh`;
    this.accessTokenExpiry = '15m';
    this.refreshTokenExpiry = '7d';
  }

  generateTokenPair(payload: { userId: string; email: string; role: string }): AuthTokens {
    const accessToken = this.generateAccessToken(payload);
    const refreshToken = this.generateRefreshToken(payload);

    return AuthTokens.fromJWT(accessToken, refreshToken, 900); // 15 minutes en secondes
  }

  private generateAccessToken(payload: { userId: string; email: string; role: string }): string {
    return jwt.sign(payload, this.accessTokenSecret, {
      expiresIn: this.accessTokenExpiry,
      issuer: 'techplus-api',
      audience: 'techplus-client',
    } as jwt.SignOptions);
  }

  private generateRefreshToken(payload: { userId: string; email: string; role: string }): string {
    return jwt.sign(payload, this.refreshTokenSecret, {
      expiresIn: this.refreshTokenExpiry,
      issuer: 'techplus-api',
      audience: 'techplus-client',
    } as jwt.SignOptions);
  }

  verifyAccessToken(token: string): { userId: string; email: string; role: string } {
    try {
      const decoded = jwt.verify(token, this.accessTokenSecret, {
        issuer: 'techplus-api',
        audience: 'techplus-client',
      }) as any;

      return {
        userId: decoded.userId,
        email: decoded.email,
        role: decoded.role
      };
    } catch (error) {
      if (error instanceof jwt.TokenExpiredError) {
        throw new Error('Token expired');
      } else if (error instanceof jwt.JsonWebTokenError) {
        throw new Error('Invalid token');
      } else {
        throw new Error('Token verification failed');
      }
    }
  }

  verifyRefreshToken(token: string): { userId: string; email: string; role: string } {
    try {
      const decoded = jwt.verify(token, this.refreshTokenSecret, {
        issuer: 'techplus-api',
        audience: 'techplus-client',
      }) as any;

      return {
        userId: decoded.userId,
        email: decoded.email,
        role: decoded.role
      };
    } catch (error) {
      if (error instanceof jwt.TokenExpiredError) {
        throw new Error('Refresh token expired');
      } else if (error instanceof jwt.JsonWebTokenError) {
        throw new Error('Invalid refresh token');
      } else {
        throw new Error('Refresh token verification failed');
      }
    }
  }
}


