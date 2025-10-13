import { ReservationRepository } from '../../repositories/ReservationRepository';
import { Reservation } from '../../entities/Reservation';

export interface GetReservationRequest {
  reservationId: string;
  userId?: string;
}

export interface GetReservationResponse {
  reservation: Reservation;
}

export class GetReservationUseCase {
  constructor(private reservationRepository: ReservationRepository) {}

  async execute(request: GetReservationRequest): Promise<GetReservationResponse> {
    this.validateRequest(request);

    const reservation = await this.reservationRepository.findById(request.reservationId);
    if (!reservation) {
      throw new Error('Reservation not found');
    }

    // Vérifier les permissions d'accès
    if (request.userId && reservation.userId !== request.userId) {
      throw new Error('Access denied');
    }

    return { reservation };
  }

  private validateRequest(request: GetReservationRequest): void {
    if (!request.reservationId) {
      throw new Error('Reservation ID is required');
    }
  }
}


