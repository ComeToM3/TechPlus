import { ReservationRepository } from '../../repositories/ReservationRepository';
import { TableRepository } from '../../repositories/TableRepository';
import { RestaurantRepository } from '../../repositories/RestaurantRepository';
import { Reservation } from '../../entities/Reservation';
import { ReservationStatus, PaymentStatus } from '@prisma/client';
import { v4 as uuidv4 } from 'uuid';

export interface CreateReservationRequest {
  date: string | Date;
  time: string;
  partySize: number;
  duration?: number;
  notes?: string;
  specialRequests?: string;
  clientName?: string;
  clientEmail?: string;
  clientPhone?: string;
  userId?: string;
}

export interface CreateReservationResponse {
  reservation: Reservation;
}

export class CreateReservationUseCase {
  constructor(
    private reservationRepository: ReservationRepository,
    private tableRepository: TableRepository,
    private restaurantRepository: RestaurantRepository
  ) {}

  async execute(request: CreateReservationRequest): Promise<CreateReservationResponse> {
    this.validateRequest(request);

    // 1. Récupérer le restaurant actif
    const restaurant = await this.restaurantRepository.findActiveRestaurant();
    if (!restaurant) {
      throw new Error('No active restaurant found');
    }

    // 2. Vérifier les disponibilités
    const reservationDate = new Date(request.date);
    const isAvailable = await this.checkAvailability(
      reservationDate,
      request.time,
      request.partySize,
      restaurant.id
    );

    if (!isAvailable) {
      throw new Error('No tables available for the selected time slot');
    }

    // 3. Calculer la durée automatiquement si non fournie
    const duration = request.duration || this.calculateDuration(request.partySize);

    // 4. Déterminer si un paiement est requis
    const requiresPayment = restaurant.requiresPayment(request.partySize);
    const depositAmount = restaurant.calculateDepositAmount(request.partySize);

    // 5. Générer un token de gestion pour les réservations guest
    const managementToken = !request.userId ? this.generateManagementToken() : undefined;
    const tokenExpiresAt = !request.userId ? this.calculateTokenExpiry() : undefined;

    // 6. Trouver une table disponible
    const availableTable = await this.tableRepository.findAvailableTable(
      reservationDate,
      request.time,
      request.partySize,
      restaurant.id
    );

    // 7. Créer la réservation
    const reservationData: any = {
      date: reservationDate,
      time: request.time,
      duration,
      partySize: request.partySize,
      status: ReservationStatus.PENDING,
      requiresPayment,
      depositAmount,
      restaurantId: restaurant.id,
    };

    if (request.notes) reservationData.notes = request.notes;
    if (request.specialRequests) reservationData.specialRequests = request.specialRequests;
    if (request.clientName) reservationData.clientName = request.clientName;
    if (request.clientEmail) reservationData.clientEmail = request.clientEmail;
    if (request.clientPhone) reservationData.clientPhone = request.clientPhone;
    if (managementToken) reservationData.managementToken = managementToken;
    if (tokenExpiresAt) reservationData.tokenExpiresAt = tokenExpiresAt;
    if (request.userId) reservationData.userId = request.userId;
    if (availableTable?.id) reservationData.tableId = availableTable.id;

    const reservation = await this.reservationRepository.create(reservationData);

    return { reservation };
  }

  private validateRequest(request: CreateReservationRequest): void {
    if (!request.date || !request.time || !request.partySize) {
      throw new Error('Date, time, and party size are required');
    }

    if (request.partySize <= 0) {
      throw new Error('Party size must be greater than 0');
    }

    const reservationDate = new Date(request.date);
    if (reservationDate < new Date()) {
      throw new Error('Cannot create reservation for past dates');
    }
  }

  private async checkAvailability(
    date: Date,
    time: string,
    partySize: number,
    restaurantId: string
  ): Promise<boolean> {
    const availableTable = await this.tableRepository.findAvailableTable(
      date,
      time,
      partySize,
      restaurantId
    );
    return !!availableTable;
  }

  private calculateDuration(partySize: number): number {
    return partySize <= 4 ? 90 : 120; // 1h30 pour 1-4 personnes, 2h00 pour 5+ personnes
  }

  private generateManagementToken(): string {
    return `guest_${uuidv4()}`;
  }

  private calculateTokenExpiry(): Date {
    return new Date(Date.now() + 7 * 24 * 60 * 60 * 1000); // 7 jours
  }
}
