import { Notification } from '../entities/Notification';
import { NotificationType, NotificationStatus } from '@prisma/client';

export interface CreateNotificationData {
  type: NotificationType;
  recipientEmail: string;
  subject: string;
  status: NotificationStatus;
  reservationId?: string | null;
  data?: string | null;
}

export interface UpdateNotificationData {
  status?: NotificationStatus;
  subject?: string;
  data?: string;
}

export interface NotificationFilters {
  type?: NotificationType | undefined;
  status?: NotificationStatus | undefined;
  recipientEmail?: string | undefined;
  reservationId?: string | undefined;
  dateFrom?: Date | undefined;
  dateTo?: Date | undefined;
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

export interface NotificationStats {
  total: number;
  sent: number;
  failed: number;
  pending: number;
  retrying: number;
  successRate: number;
  byType: Record<string, number>;
  byStatus: Record<string, number>;
}

export interface NotificationRepository {
  findById(id: string): Promise<Notification | null>;
  findByReservationId(reservationId: string): Promise<Notification[]>;
  findByRecipientEmail(email: string, filters?: NotificationFilters, pagination?: PaginationOptions): Promise<PaginatedResult<Notification>>;
  findByFilters(filters: NotificationFilters, pagination?: PaginationOptions): Promise<PaginatedResult<Notification>>;
  create(data: CreateNotificationData): Promise<Notification>;
  update(id: string, data: UpdateNotificationData): Promise<Notification>;
  delete(id: string): Promise<void>;
  getStats(filters?: NotificationFilters): Promise<NotificationStats>;
  findFailedNotifications(limit?: number): Promise<Notification[]>;
  updateStatus(id: string, status: NotificationStatus): Promise<Notification>;
}
