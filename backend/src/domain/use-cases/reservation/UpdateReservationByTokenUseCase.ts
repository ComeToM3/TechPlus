import { ReservationRepository } from '../../repositories/ReservationRepository';
import { TableRepository } from '../../repositories/TableRepository';
import { Reservation } from '../../entities/Reservation';

export interface UpdateReservationByTokenRequest {
  token: string;
  date?: string | Date;
  time?: string;
  partySize?: number;
  duration?: number;
  notes?: string;
  specialRequests?: string;
  clientName?: string;
  clientEmail?: string;
  clientPhone?: string;
}

export interface UpdateReservationByTokenResponse {
  reservation: Reservation;
}

export class UpdateReservationByTokenUseCase {
  constructor(
    private reservationRepository: ReservationRepository,
    private tableRepository: TableRepository
  ) {}

  async execute(request: UpdateReservationByTokenRequest): Promise<UpdateReservationByTokenResponse> {
    this.validateRequest(request);

    const existingReservation = await this.reservationRepository.findByManagementToken(request.token);
    if (!existingReservation) {
      throw new Error('Reservation not found');
    }

    // Vérifier que le token n'est pas expiré
    if (existingReservation.isTokenExpired()) {
      throw new Error('Management token has expired');
    }

    // Vérifier que la réservation peut être modifiée
    if (!existingReservation.canBeModified()) {
      throw new Error('Reservation cannot be modified');
    }

    // Vérifier les disponibilités si nécessaire
    if (request.date || request.time || request.partySize) {
      const newDate = request.date ? new Date(request.date) : existingReservation.date;
      const newTime = request.time || existingReservation.time;
      const newPartySize = request.partySize || existingReservation.partySize;

      const isAvailable = await this.checkAvailability(
        newDate,
        newTime,
        newPartySize,
        existingReservation.restaurantId,
        existingReservation.id
      );

      if (!isAvailable) {
        throw new Error('No tables available for the selected time slot');
      }
    }

    // Préparer les données de mise à jour
    const updateData: any = {};
    if (request.date !== undefined) updateData.date = new Date(request.date);
    if (request.time !== undefined) updateData.time = request.time;
    if (request.partySize !== undefined) updateData.partySize = request.partySize;
    if (request.duration !== undefined) updateData.duration = request.duration;
    if (request.notes !== undefined) updateData.notes = request.notes;
    if (request.specialRequests !== undefined) updateData.specialRequests = request.specialRequests;
    if (request.clientName !== undefined) updateData.clientName = request.clientName;
    if (request.clientEmail !== undefined) updateData.clientEmail = request.clientEmail;
    if (request.clientPhone !== undefined) updateData.clientPhone = request.clientPhone;

    const reservation = await this.reservationRepository.update(existingReservation.id, updateData);

    return { reservation };
  }

  private validateRequest(request: UpdateReservationByTokenRequest): void {
    if (!request.token) {
      throw new Error('Management token is required');
    }

    if (request.date && new Date(request.date) < new Date()) {
      throw new Error('Cannot update reservation to past dates');
    }

    if (request.partySize && request.partySize <= 0) {
      throw new Error('Party size must be greater than 0');
    }
  }

  private async checkAvailability(
    date: Date,
    time: string,
    partySize: number,
    restaurantId: string,
    excludeReservationId: string
  ): Promise<boolean> {
    const availableTable = await this.tableRepository.findAvailableTable(
      date,
      time,
      partySize,
      restaurantId,
      excludeReservationId
    );
    return !!availableTable;
  }
}


