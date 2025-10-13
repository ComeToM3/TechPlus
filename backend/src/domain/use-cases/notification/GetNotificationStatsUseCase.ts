import { NotificationRepository } from '../../repositories/NotificationRepository';
import { NotificationType, NotificationStatus } from '@prisma/client';

export interface GetNotificationStatsRequest {
  type?: NotificationType | undefined;
  status?: NotificationStatus | undefined;
  recipientEmail?: string | undefined;
  reservationId?: string | undefined;
  dateFrom?: Date | undefined;
  dateTo?: Date | undefined;
}

export interface GetNotificationStatsResponse {
  total: number;
  sent: number;
  failed: number;
  pending: number;
  retrying: number;
  successRate: number;
  byType: Record<string, number>;
  byStatus: Record<string, number>;
}

export class GetNotificationStatsUseCase {
  constructor(private notificationRepository: NotificationRepository) {}

  async execute(request: GetNotificationStatsRequest): Promise<GetNotificationStatsResponse> {
    const filters = {
      type: request.type,
      status: request.status,
      recipientEmail: request.recipientEmail,
      reservationId: request.reservationId,
      dateFrom: request.dateFrom,
      dateTo: request.dateTo,
    };

    const stats = await this.notificationRepository.getStats(filters);

    return {
      total: stats.total,
      sent: stats.sent,
      failed: stats.failed,
      pending: stats.pending,
      retrying: stats.retrying,
      successRate: stats.successRate,
      byType: stats.byType,
      byStatus: stats.byStatus,
    };
  }
}
