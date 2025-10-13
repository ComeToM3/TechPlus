/**
 * Use Case pour obtenir le profil de l'utilisateur connecté
 */

import { User } from '../../entities/User';
import { UserRepository } from '../../repositories/UserRepository';

export interface GetProfileRequest {
  userId: string;
}

export interface GetProfileResponse {
  user: User;
}

export class GetProfileUseCase {
  constructor(private readonly userRepository: UserRepository) {}

  async execute(request: GetProfileRequest): Promise<GetProfileResponse> {
    // Validation métier
    this.validateRequest(request);

    // Trouver l'utilisateur
    const user = await this.userRepository.findById(request.userId);
    if (!user) {
      throw new Error('User not found');
    }

    return { user };
  }

  private validateRequest(request: GetProfileRequest): void {
    if (!request.userId) {
      throw new Error('User ID is required');
    }
  }
}


