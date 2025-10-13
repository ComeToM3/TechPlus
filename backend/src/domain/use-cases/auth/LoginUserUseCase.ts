/**
 * Use Case pour la connexion d'un utilisateur
 * Contient la logique métier pure pour la connexion
 */

import { User } from '../../entities/User';
import { AuthTokens } from '../../entities/AuthTokens';
import { UserRepository } from '../../repositories/UserRepository';
import { PasswordService, JWTService } from './RegisterUserUseCase';

export interface LoginUserRequest {
  email: string;
  password: string;
}

export interface LoginUserResponse {
  user: User;
  tokens: AuthTokens;
}

export class LoginUserUseCase {
  constructor(
    private readonly userRepository: UserRepository,
    private readonly passwordService: PasswordService,
    private readonly jwtService: JWTService
  ) {}

  async execute(request: LoginUserRequest): Promise<LoginUserResponse> {
    // Validation métier
    this.validateRequest(request);

    // Trouver l'utilisateur avec son mot de passe
    const userWithPassword = await this.userRepository.findByEmailWithPassword(request.email);
    if (!userWithPassword) {
      throw new Error('Invalid email or password');
    }

    const { user, password } = userWithPassword;

    // Vérifier le mot de passe
    const isValidPassword = await this.passwordService.compare(request.password, password);
    if (!isValidPassword) {
      throw new Error('Invalid email or password');
    }

    // Vérifier si l'utilisateur est actif
    if (!user.isActive) {
      throw new Error('Account is deactivated');
    }

    // Mettre à jour la dernière connexion
    await this.userRepository.updateLastLogin(user.id);

    // Générer les tokens JWT
    const tokens = this.jwtService.generateTokenPair({
      userId: user.id,
      email: user.email,
      role: user.role
    });

    return {
      user,
      tokens
    };
  }

  private validateRequest(request: LoginUserRequest): void {
    if (!request.email || !request.email.includes('@')) {
      throw new Error('Valid email is required');
    }

    if (!request.password) {
      throw new Error('Password is required');
    }
  }
}


