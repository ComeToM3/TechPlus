import { Reservation } from '../entities/Reservation';
import { ReservationStatus } from '@prisma/client';

export interface CreateReservationData {
  date: Date;
  time: string;
  duration: number;
  partySize: number;
  status: ReservationStatus;
  requiresPayment: boolean;
  depositAmount: number;
  notes?: string;
  specialRequests?: string;
  clientName?: string;
  clientEmail?: string;
  clientPhone?: string;
  managementToken?: string;
  tokenExpiresAt?: Date;
  userId?: string;
  restaurantId: string;
  tableId?: string;
}

export interface UpdateReservationData {
  date?: Date;
  time?: string;
  duration?: number;
  partySize?: number;
  status?: ReservationStatus;
  requiresPayment?: boolean;
  depositAmount?: number;
  notes?: string;
  specialRequests?: string;
  clientName?: string;
  clientEmail?: string;
  clientPhone?: string;
  cancellationReason?: string;
  tableId?: string;
}

export interface ReservationFilters {
  userId?: string;
  restaurantId?: string;
  status?: ReservationStatus;
  date?: Date;
  dateFrom?: Date;
  dateTo?: Date;
  partySize?: number;
  requiresPayment?: boolean;
}

export interface PaginationOptions {
  page: number;
  limit: number;
}

export interface PaginatedResult<T> {
  data: T[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    pages: number;
  };
}

export interface ReservationRepository {
  findById(id: string): Promise<Reservation | null>;
  findByManagementToken(token: string): Promise<Reservation | null>;
  findByUserId(userId: string, filters?: ReservationFilters, pagination?: PaginationOptions): Promise<PaginatedResult<Reservation>>;
  findByRestaurantId(restaurantId: string, filters?: ReservationFilters, pagination?: PaginationOptions): Promise<PaginatedResult<Reservation>>;
  create(data: CreateReservationData): Promise<Reservation>;
  update(id: string, data: UpdateReservationData): Promise<Reservation>;
  delete(id: string): Promise<void>;
  findConflictingReservations(date: Date, time: string, duration: number, restaurantId: string, excludeReservationId?: string): Promise<Reservation[]>;
}


