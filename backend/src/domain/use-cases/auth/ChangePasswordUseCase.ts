/**
 * Use Case pour changer le mot de passe
 */

import { UserRepository } from '../../repositories/UserRepository';
import { PasswordService } from './RegisterUserUseCase';

export interface ChangePasswordRequest {
  userId: string;
  currentPassword: string;
  newPassword: string;
}

export interface ChangePasswordResponse {
  success: boolean;
}

export class ChangePasswordUseCase {
  constructor(
    private readonly userRepository: UserRepository,
    private readonly passwordService: PasswordService
  ) {}

  async execute(request: ChangePasswordRequest): Promise<ChangePasswordResponse> {
    // Validation métier
    this.validateRequest(request);

    // Vérifier que l'utilisateur existe et récupérer son mot de passe
    const userWithPassword = await this.userRepository.findByEmailWithPassword(
      (await this.userRepository.findById(request.userId))?.email || ''
    );
    
    if (!userWithPassword) {
      throw new Error('User not found or no password set');
    }

    // Vérifier l'ancien mot de passe
    const isValidPassword = await this.passwordService.compare(
      request.currentPassword, 
      userWithPassword.password
    );
    
    if (!isValidPassword) {
      throw new Error('Current password is incorrect');
    }

    // Hasher le nouveau mot de passe
    const hashedNewPassword = await this.passwordService.hash(request.newPassword);

    // Mettre à jour le mot de passe
    await this.userRepository.update(request.userId, {
      password: hashedNewPassword
    });

    return { success: true };
  }

  private validateRequest(request: ChangePasswordRequest): void {
    if (!request.userId) {
      throw new Error('User ID is required');
    }

    if (!request.currentPassword) {
      throw new Error('Current password is required');
    }

    if (!request.newPassword || request.newPassword.length < 6) {
      throw new Error('New password must be at least 6 characters long');
    }

    if (request.currentPassword === request.newPassword) {
      throw new Error('New password must be different from current password');
    }
  }
}


