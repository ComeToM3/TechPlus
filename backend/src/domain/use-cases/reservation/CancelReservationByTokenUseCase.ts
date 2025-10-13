import { ReservationRepository } from '../../repositories/ReservationRepository';
import { Reservation } from '../../entities/Reservation';
import { ReservationStatus } from '@prisma/client';

export interface CancelReservationByTokenRequest {
  token: string;
  reason?: string;
}

export interface CancelReservationByTokenResponse {
  reservation: Reservation;
}

export class CancelReservationByTokenUseCase {
  constructor(private reservationRepository: ReservationRepository) {}

  async execute(request: CancelReservationByTokenRequest): Promise<CancelReservationByTokenResponse> {
    this.validateRequest(request);

    const existingReservation = await this.reservationRepository.findByManagementToken(request.token);
    if (!existingReservation) {
      throw new Error('Reservation not found');
    }

    // Vérifier que le token n'est pas expiré
    if (existingReservation.isTokenExpired()) {
      throw new Error('Management token has expired');
    }

    // Vérifier que la réservation peut être annulée
    if (!existingReservation.canBeCancelled()) {
      throw new Error('Reservation cannot be cancelled');
    }

    const updateData: any = {
      status: ReservationStatus.CANCELLED,
    };
    if (request.reason) {
      updateData.cancellationReason = request.reason;
    }
    const reservation = await this.reservationRepository.update(existingReservation.id, updateData);

    return { reservation };
  }

  private validateRequest(request: CancelReservationByTokenRequest): void {
    if (!request.token) {
      throw new Error('Management token is required');
    }
  }
}
