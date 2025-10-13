/**
 * Use Case pour mettre à jour le profil de l'utilisateur
 */

import { User } from '../../entities/User';
import { UserRepository } from '../../repositories/UserRepository';

export interface UpdateProfileRequest {
  userId: string;
  name?: string;
  phone?: string;
  avatar?: string;
}

export interface UpdateProfileResponse {
  user: User;
}

export class UpdateProfileUseCase {
  constructor(private readonly userRepository: UserRepository) {}

  async execute(request: UpdateProfileRequest): Promise<UpdateProfileResponse> {
    // Validation métier
    this.validateRequest(request);

    // Vérifier que l'utilisateur existe
    const existingUser = await this.userRepository.findById(request.userId);
    if (!existingUser) {
      throw new Error('User not found');
    }

    // Mettre à jour l'utilisateur
    const updateData: any = {};
    
    if (request.name !== undefined) {
      updateData.name = request.name;
    }
    if (request.phone !== undefined) {
      updateData.phone = request.phone;
    }
    if (request.avatar !== undefined) {
      updateData.avatar = request.avatar;
    }

    const user = await this.userRepository.update(request.userId, updateData);

    return { user };
  }

  private validateRequest(request: UpdateProfileRequest): void {
    if (!request.userId) {
      throw new Error('User ID is required');
    }

    if (request.phone && !/^\+?[\d\s-()]+$/.test(request.phone)) {
      throw new Error('Invalid phone number format');
    }
  }
}
