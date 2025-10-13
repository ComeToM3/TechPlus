import { ReservationRepository } from '../../repositories/ReservationRepository';
import { Reservation } from '../../entities/Reservation';
import { ReservationStatus } from '@prisma/client';

export interface CancelReservationRequest {
  reservationId: string;
  userId?: string;
  reason?: string;
}

export interface CancelReservationResponse {
  reservation: Reservation;
}

export class CancelReservationUseCase {
  constructor(private reservationRepository: ReservationRepository) {}

  async execute(request: CancelReservationRequest): Promise<CancelReservationResponse> {
    this.validateRequest(request);

    const existingReservation = await this.reservationRepository.findById(request.reservationId);
    if (!existingReservation) {
      throw new Error('Reservation not found');
    }

    // Vérifier les permissions
    if (request.userId && existingReservation.userId !== request.userId) {
      throw new Error('Access denied');
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
    const reservation = await this.reservationRepository.update(request.reservationId, updateData);

    return { reservation };
  }

  private validateRequest(request: CancelReservationRequest): void {
    if (!request.reservationId) {
      throw new Error('Reservation ID is required');
    }
  }
}
