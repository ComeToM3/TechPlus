import { ReservationRepository } from '../../repositories/ReservationRepository';
import { Reservation } from '../../entities/Reservation';

export interface GetReservationByTokenRequest {
  token: string;
}

export interface GetReservationByTokenResponse {
  reservation: Reservation;
}

export class GetReservationByTokenUseCase {
  constructor(private reservationRepository: ReservationRepository) {}

  async execute(request: GetReservationByTokenRequest): Promise<GetReservationByTokenResponse> {
    this.validateRequest(request);

    const reservation = await this.reservationRepository.findByManagementToken(request.token);
    if (!reservation) {
      throw new Error('Reservation not found');
    }

    // Vérifier que le token n'est pas expiré
    if (reservation.isTokenExpired()) {
      throw new Error('Management token has expired');
    }

    return { reservation };
  }

  private validateRequest(request: GetReservationByTokenRequest): void {
    if (!request.token) {
      throw new Error('Management token is required');
    }
  }
}


