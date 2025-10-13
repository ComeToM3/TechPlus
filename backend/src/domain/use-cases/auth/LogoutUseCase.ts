/**
 * Use Case pour la déconnexion
 * Pour l'instant, c'est une opération simple côté client
 * Dans une implémentation complète, on pourrait ajouter le token à une blacklist
 */

export interface LogoutRequest {
  userId: string;
  accessToken?: string;
}

export interface LogoutResponse {
  success: boolean;
}

export class LogoutUseCase {
  constructor(
    private readonly tokenBlacklistService?: TokenBlacklistService
  ) {}

  async execute(request: LogoutRequest): Promise<LogoutResponse> {
    // Validation métier
    this.validateRequest(request);

    // Dans une implémentation complète, on pourrait :
    // 1. Ajouter le token à une blacklist Redis
    // 2. Invalider le refresh token
    // 3. Logger l'événement de déconnexion
    
    if (this.tokenBlacklistService && request.accessToken) {
      await this.tokenBlacklistService.addToBlacklist(request.accessToken);
    }

    return { success: true };
  }

  private validateRequest(request: LogoutRequest): void {
    if (!request.userId) {
      throw new Error('User ID is required');
    }
  }
}

// Interface pour le service de blacklist des tokens
export interface TokenBlacklistService {
  addToBlacklist(token: string): Promise<void>;
  isBlacklisted(token: string): Promise<boolean>;
}


