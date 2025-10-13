import { NotificationRepository } from '../../repositories/NotificationRepository';
import { Notification } from '../../entities/Notification';
import { NotificationType, NotificationStatus } from '@prisma/client';

export interface GetNotificationHistoryRequest {
  limit?: number | undefined;
  offset?: number | undefined;
  type?: NotificationType | undefined;
  status?: NotificationStatus | undefined;
  recipientEmail?: string | undefined;
  reservationId?: string | undefined;
  dateFrom?: Date | undefined;
  dateTo?: Date | undefined;
}

export interface GetNotificationHistoryResponse {
  notifications: Notification[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    pages: number;
  };
}

export class GetNotificationHistoryUseCase {
  constructor(private notificationRepository: NotificationRepository) {}

  async execute(request: GetNotificationHistoryRequest): Promise<GetNotificationHistoryResponse> {
    this.validateRequest(request);

    const filters = {
      type: request.type,
      status: request.status,
      recipientEmail: request.recipientEmail,
      reservationId: request.reservationId,
      dateFrom: request.dateFrom,
      dateTo: request.dateTo,
    };

    const pagination = {
      page: Math.floor((request.offset || 0) / (request.limit || 10)) + 1,
      limit: request.limit || 10,
    };

    const result = await this.notificationRepository.findByFilters(filters, pagination);

    return {
      notifications: result.data,
      pagination: result.pagination,
    };
  }

  private validateRequest(request: GetNotificationHistoryRequest): void {
    if (request.limit && (request.limit < 1 || request.limit > 100)) {
      throw new Error('Limit must be between 1 and 100');
    }

    if (request.offset && request.offset < 0) {
      throw new Error('Offset must be non-negative');
    }

    if (request.dateFrom && request.dateTo && request.dateFrom > request.dateTo) {
      throw new Error('Date from must be before date to');
    }
  }
}
