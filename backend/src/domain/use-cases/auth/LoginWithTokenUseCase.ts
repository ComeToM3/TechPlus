/**
 * Use Case pour la connexion par token (guests)
 */

import { User } from '../../entities/User';
import { AuthTokens } from '../../entities/AuthTokens';
import { JWTService } from './RegisterUserUseCase';

export interface LoginWithTokenRequest {
  token: string;
}

export interface LoginWithTokenResponse {
  user: User;
  tokens: AuthTokens;
  reservation: {
    id: string;
    restaurant: { id: string; name: string };
    date: Date;
    time: string;
    partySize: number;
  };
}

export class LoginWithTokenUseCase {
  constructor(
    private readonly jwtService: JWTService,
    private readonly reservationRepository: ReservationRepository
  ) {}

  async execute(request: LoginWithTokenRequest): Promise<LoginWithTokenResponse> {
    // Validation métier
    this.validateRequest(request);

    // Vérifier que le token existe et n'est pas expiré
    const reservation = await this.reservationRepository.findByManagementToken(request.token);
    if (!reservation) {
      throw new Error('Invalid token');
    }

    if (reservation.tokenExpiresAt && reservation.tokenExpiresAt < new Date()) {
      throw new Error('Token has expired');
    }

    // Vérifier que la réservation n'est pas annulée
    if (reservation.status === 'CANCELLED') {
      throw new Error('This reservation has been cancelled');
    }

    // Créer un utilisateur temporaire pour le guest
    const guestUser = new User({
      id: `guest_${reservation.id}`,
      email: reservation.clientEmail || 'guest@example.com',
      name: reservation.clientName || 'Guest',
      role: 'GUEST' as any,
      isActive: true,
      createdAt: new Date(),
      updatedAt: new Date()
    });

    // Générer les tokens JWT pour le guest
    const tokens = this.jwtService.generateTokenPair({
      userId: guestUser.id,
      email: guestUser.email,
      role: guestUser.role
    });

    return {
      user: guestUser,
      tokens,
      reservation: {
        id: reservation.id,
        restaurant: reservation.restaurant,
        date: reservation.date,
        time: reservation.time,
        partySize: reservation.partySize
      }
    };
  }

  private validateRequest(request: LoginWithTokenRequest): void {
    if (!request.token) {
      throw new Error('Token is required');
    }
  }
}

// Interface pour le repository des réservations
export interface ReservationRepository {
  findByManagementToken(token: string): Promise<{
    id: string;
    clientEmail?: string;
    clientName?: string;
    tokenExpiresAt?: Date;
    status: string;
    restaurant: { id: string; name: string };
    date: Date;
    time: string;
    partySize: number;
  } | null>;
}
