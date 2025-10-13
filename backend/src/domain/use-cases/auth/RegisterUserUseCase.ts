/**
 * Use Case pour l'inscription d'un utilisateur
 * Contient la logique métier pure pour l'inscription
 */

import { User } from '../../entities/User';
import { AuthTokens } from '../../entities/AuthTokens';
import { UserRepository } from '../../repositories/UserRepository';

export interface RegisterUserRequest {
  email: string;
  name?: string;
  phone?: string;
  password: string;
}

export interface RegisterUserResponse {
  user: User;
  tokens: AuthTokens;
}

export class RegisterUserUseCase {
  constructor(
    private readonly userRepository: UserRepository,
    private readonly passwordService: PasswordService,
    private readonly jwtService: JWTService
  ) {}

  async execute(request: RegisterUserRequest): Promise<RegisterUserResponse> {
    // Validation métier
    this.validateRequest(request);

    // Vérifier si l'utilisateur existe déjà
    const existingUser = await this.userRepository.findByEmail(request.email);
    if (existingUser) {
      throw new Error('User already exists with this email');
    }

    // Hasher le mot de passe
    const hashedPassword = await this.passwordService.hash(request.password);

    // Créer l'utilisateur
    const userData: any = {
      email: request.email,
      password: hashedPassword,
      role: 'CLIENT',
      isActive: true
    };

    if (request.name) {
      userData.name = request.name;
    }
    if (request.phone) {
      userData.phone = request.phone;
    }

    const user = await this.userRepository.create(userData);

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

  private validateRequest(request: RegisterUserRequest): void {
    if (!request.email || !request.email.includes('@')) {
      throw new Error('Valid email is required');
    }

    if (!request.password || request.password.length < 6) {
      throw new Error('Password must be at least 6 characters long');
    }

    if (request.phone && !/^\+?[\d\s-()]+$/.test(request.phone)) {
      throw new Error('Invalid phone number format');
    }
  }
}

// Interfaces pour les services (seront injectés)
export interface PasswordService {
  hash(password: string): Promise<string>;
  compare(password: string, hashedPassword: string): Promise<boolean>;
}

export interface JWTService {
  generateTokenPair(payload: { userId: string; email: string; role: string }): AuthTokens;
  verifyAccessToken(token: string): { userId: string; email: string; role: string };
  verifyRefreshToken(token: string): { userId: string; email: string; role: string };
}
