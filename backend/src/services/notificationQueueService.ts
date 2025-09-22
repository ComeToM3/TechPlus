import { PrismaClient } from '@prisma/client';
import {
  NotificationType,
  NotificationStatus,
  NotificationQueueItem,
} from '@/types/notification.types';
import { notificationService } from './notificationService';
import logger from '@/utils/logger';

const prisma = new PrismaClient();

/**
 * Service de queue pour les notifications
 */
export class NotificationQueueService {
  private isProcessing: boolean = false;
  private processingInterval: NodeJS.Timeout | null = null;
  private readonly PROCESSING_INTERVAL = 30000; // 30 secondes
  private readonly MAX_RETRY_ATTEMPTS = 3;
  private readonly RETRY_DELAY = 60000; // 1 minute

  constructor() {
    this.startProcessing();
  }

  /**
   * Ajoute une notification à la queue
   */
  async enqueueNotification(
    type: NotificationType,
    recipientEmail: string,
    data: any,
    priority: number = 1,
    scheduledAt?: Date
  ): Promise<string> {
    try {
      const queueItem = await prisma.notificationQueue.create({
        data: {
          type,
          recipientEmail,
          data: JSON.stringify(data),
          priority,
          scheduledAt: scheduledAt || new Date(),
          status: NotificationStatus.PENDING,
          attempts: 0,
          maxAttempts: this.MAX_RETRY_ATTEMPTS,
        },
      });

      logger.info(`Notification queued: ${queueItem.id} (${type})`);
      return queueItem.id;
    } catch (error) {
      logger.error('Failed to enqueue notification:', error);
      throw error;
    }
  }

  /**
   * Ajoute une notification de réservation à la queue
   */
  async enqueueReservationNotification(
    type: NotificationType,
    reservationId: string,
    recipientEmail: string,
    data: any,
    priority: number = 1,
    scheduledAt?: Date
  ): Promise<string> {
    try {
      const queueItem = await prisma.notificationQueue.create({
        data: {
          type,
          recipientEmail,
          data: JSON.stringify({ ...data, reservationId }),
          priority,
          scheduledAt: scheduledAt || new Date(),
          status: NotificationStatus.PENDING,
          attempts: 0,
          maxAttempts: this.MAX_RETRY_ATTEMPTS,
        },
      });

      logger.info(
        `Reservation notification queued: ${queueItem.id} (${type}) for reservation ${reservationId}`
      );
      return queueItem.id;
    } catch (error) {
      logger.error('Failed to enqueue reservation notification:', error);
      throw error;
    }
  }

  /**
   * Démarre le traitement de la queue
   */
  startProcessing(): void {
    if (this.processingInterval) {
      return;
    }

    this.processingInterval = setInterval(async () => {
      await this.processQueue();
    }, this.PROCESSING_INTERVAL);

    logger.info('Notification queue processing started');
  }

  /**
   * Arrête le traitement de la queue
   */
  stopProcessing(): void {
    if (this.processingInterval) {
      clearInterval(this.processingInterval);
      this.processingInterval = null;
    }

    logger.info('Notification queue processing stopped');
  }

  /**
   * Traite la queue des notifications
   */
  private async processQueue(): Promise<void> {
    if (this.isProcessing) {
      return;
    }

    this.isProcessing = true;

    try {
      // Récupérer les notifications en attente
      const pendingNotifications = await prisma.notificationQueue.findMany({
        where: {
          status: NotificationStatus.PENDING,
          scheduledAt: {
            lte: new Date(),
          },
        },
        orderBy: [{ priority: 'desc' }, { createdAt: 'asc' }],
        take: 10, // Traiter par lots de 10
      });

      if (pendingNotifications.length === 0) {
        return;
      }

      logger.info(`Processing ${pendingNotifications.length} notifications from queue`);

      // Traiter chaque notification
      for (const notification of pendingNotifications) {
        await this.processNotification(notification);
      }
    } catch (error) {
      logger.error('Error processing notification queue:', error);
    } finally {
      this.isProcessing = false;
    }
  }

  /**
   * Traite une notification individuelle
   */
  private async processNotification(notification: any): Promise<void> {
    try {
      // Marquer comme en cours de traitement
      await prisma.notificationQueue.update({
        where: { id: notification.id },
        data: {
          status: NotificationStatus.RETRYING,
          attempts: notification.attempts + 1,
        },
      });

      const data = JSON.parse(notification.data);
      let success = false;

      // Envoyer la notification selon le type
      if (data.reservationId) {
        success = await notificationService.sendReservationNotification(
          notification.type as NotificationType,
          data.reservationId,
          notification.recipientEmail,
          data
        );
      } else {
        // Notification personnalisée
        success = await notificationService.sendEmail(
          notification.recipientEmail,
          data.subject || 'Notification',
          data.htmlContent || '',
          data.textContent
        );
      }

      if (success) {
        // Marquer comme envoyée
        await prisma.notificationQueue.update({
          where: { id: notification.id },
          data: {
            status: NotificationStatus.SENT,
            sentAt: new Date(),
          },
        });

        logger.info(`Notification sent successfully: ${notification.id}`);
      } else {
        // Gérer l'échec
        await this.handleNotificationFailure(notification);
      }
    } catch (error) {
      logger.error(`Error processing notification ${notification.id}:`, error);
      await this.handleNotificationFailure(notification);
    }
  }

  /**
   * Gère l'échec d'une notification
   */
  private async handleNotificationFailure(notification: any): Promise<void> {
    const newAttempts = notification.attempts + 1;

    if (newAttempts >= notification.maxAttempts) {
      // Marquer comme définitivement échouée
      await prisma.notificationQueue.update({
        where: { id: notification.id },
        data: {
          status: NotificationStatus.FAILED,
          failedAt: new Date(),
        },
      });

      logger.error(
        `Notification failed permanently: ${notification.id} after ${newAttempts} attempts`
      );
    } else {
      // Programmer un nouvel essai
      const retryAt = new Date(Date.now() + this.RETRY_DELAY * newAttempts);

      await prisma.notificationQueue.update({
        where: { id: notification.id },
        data: {
          status: NotificationStatus.PENDING,
          scheduledAt: retryAt,
        },
      });

      logger.warn(
        `Notification scheduled for retry: ${notification.id} (attempt ${newAttempts}/${notification.maxAttempts}) at ${retryAt.toISOString()}`
      );
    }
  }

  /**
   * Récupère les statistiques de la queue
   */
  async getQueueStats(): Promise<any> {
    try {
      const [total, pending, processing, sent, failed, byType, byStatus] = await Promise.all([
        prisma.notificationQueue.count(),
        prisma.notificationQueue.count({
          where: { status: NotificationStatus.PENDING },
        }),
        prisma.notificationQueue.count({
          where: { status: NotificationStatus.RETRYING },
        }),
        prisma.notificationQueue.count({
          where: { status: NotificationStatus.SENT },
        }),
        prisma.notificationQueue.count({
          where: { status: NotificationStatus.FAILED },
        }),
        prisma.notificationQueue.groupBy({
          by: ['type'],
          _count: { type: true },
        }),
        prisma.notificationQueue.groupBy({
          by: ['status'],
          _count: { status: true },
        }),
      ]);

      return {
        total,
        pending,
        processing,
        sent,
        failed,
        byType: byType.reduce(
          (acc, item) => {
            acc[item.type] = item._count.type;
            return acc;
          },
          {} as Record<string, number>
        ),
        byStatus: byStatus.reduce(
          (acc, item) => {
            acc[item.status] = item._count.status;
            return acc;
          },
          {} as Record<string, number>
        ),
        processingInterval: this.PROCESSING_INTERVAL,
        maxRetryAttempts: this.MAX_RETRY_ATTEMPTS,
        retryDelay: this.RETRY_DELAY,
      };
    } catch (error) {
      logger.error('Failed to get queue stats:', error);
      throw error;
    }
  }

  /**
   * Nettoie les anciennes notifications
   */
  async cleanupOldNotifications(daysOld: number = 30): Promise<number> {
    try {
      const cutoffDate = new Date(Date.now() - daysOld * 24 * 60 * 60 * 1000);

      const result = await prisma.notificationQueue.deleteMany({
        where: {
          status: {
            in: [NotificationStatus.SENT, NotificationStatus.FAILED],
          },
          updatedAt: {
            lt: cutoffDate,
          },
        },
      });

      logger.info(`Cleaned up ${result.count} old notifications`);
      return result.count;
    } catch (error) {
      logger.error('Failed to cleanup old notifications:', error);
      throw error;
    }
  }

  /**
   * Retry les notifications échouées
   */
  async retryFailedNotifications(): Promise<number> {
    try {
      const failedNotifications = await prisma.notificationQueue.findMany({
        where: {
          status: NotificationStatus.FAILED,
          attempts: {
            lt: this.MAX_RETRY_ATTEMPTS,
          },
        },
      });

      let retryCount = 0;

      for (const notification of failedNotifications) {
        await prisma.notificationQueue.update({
          where: { id: notification.id },
          data: {
            status: NotificationStatus.PENDING,
            scheduledAt: new Date(),
            attempts: 0,
          },
        });
        retryCount++;
      }

      logger.info(`Retried ${retryCount} failed notifications`);
      return retryCount;
    } catch (error) {
      logger.error('Failed to retry failed notifications:', error);
      throw error;
    }
  }
}

// Instance singleton
export const notificationQueueService = new NotificationQueueService();
