import { ReservationRepository } from '../../repositories/ReservationRepository';
import { Reservation } from '../../entities/Reservation';
import { ReservationStatus } from '@prisma/client';

export interface GetUserReservationsRequest {
  userId: string;
  status?: ReservationStatus;
  date?: Date;
  dateFrom?: Date;
  dateTo?: Date;
  partySize?: number;
  requiresPayment?: boolean;
  page?: number;
  limit?: number;
}

export interface GetUserReservationsResponse {
  reservations: Reservation[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    pages: number;
  };
}

export class GetUserReservationsUseCase {
  constructor(private reservationRepository: ReservationRepository) {}

  async execute(request: GetUserReservationsRequest): Promise<GetUserReservationsResponse> {
    this.validateRequest(request);

    const filters: any = {};
    if (request.status) filters.status = request.status;
    if (request.date) filters.date = request.date;
    if (request.dateFrom) filters.dateFrom = request.dateFrom;
    if (request.dateTo) filters.dateTo = request.dateTo;
    if (request.partySize) filters.partySize = request.partySize;
    if (request.requiresPayment !== undefined) filters.requiresPayment = request.requiresPayment;

    const pagination = {
      page: request.page || 1,
      limit: request.limit || 10,
    };

    const result = await this.reservationRepository.findByUserId(
      request.userId,
      filters,
      pagination
    );

    return {
      reservations: result.data,
      pagination: result.pagination,
    };
  }

  private validateRequest(request: GetUserReservationsRequest): void {
    if (!request.userId) {
      throw new Error('User ID is required');
    }

    if (request.page && request.page < 1) {
      throw new Error('Page must be greater than 0');
    }

    if (request.limit && (request.limit < 1 || request.limit > 100)) {
      throw new Error('Limit must be between 1 and 100');
    }
  }
}
