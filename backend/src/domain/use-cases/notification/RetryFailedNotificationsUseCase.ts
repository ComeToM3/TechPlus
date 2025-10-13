import { NotificationRepository } from '../../repositories/NotificationRepository';
import { EmailService } from '../../../infrastructure/services/EmailService';
import { Notification } from '../../entities/Notification';
import { NotificationStatus } from '@prisma/client';

export interface RetryFailedNotificationsRequest {
  limit?: number;
}

export interface RetryFailedNotificationsResponse {
  retryCount: number;
  notifications: Notification[];
}

export class RetryFailedNotificationsUseCase {
  constructor(
    private notificationRepository: NotificationRepository,
    private emailService: EmailService
  ) {}

  async execute(request: RetryFailedNotificationsRequest): Promise<RetryFailedNotificationsResponse> {
    // 1. Récupérer les notifications échouées
    const failedNotifications = await this.notificationRepository.findFailedNotifications(
      request.limit || 50
    );

    if (failedNotifications.length === 0) {
      return {
        retryCount: 0,
        notifications: [],
      };
    }

    let retryCount = 0;
    const retriedNotifications: Notification[] = [];

    // 2. Retry chaque notification échouée
    for (const notification of failedNotifications) {
      try {
        // Marquer comme en cours de retry
        await this.notificationRepository.updateStatus(
          notification.id,
          NotificationStatus.RETRYING
        );

        // Retry l'envoi (simplifié - dans un vrai cas, il faudrait reconstruire l'email)
        const success = await this.emailService.sendEmail(
          notification.recipientEmail,
          notification.subject,
          'Retry email content', // Dans un vrai cas, il faudrait récupérer le contenu original
          'Retry email content'
        );

        // Mettre à jour le statut selon le résultat
        const updatedNotification = await this.notificationRepository.updateStatus(
          notification.id,
          success ? NotificationStatus.SENT : NotificationStatus.FAILED
        );

        if (success) {
          retryCount++;
          retriedNotifications.push(updatedNotification);
        }
      } catch (error) {
        // En cas d'erreur, marquer comme échoué
        await this.notificationRepository.updateStatus(
          notification.id,
          NotificationStatus.FAILED
        );
      }
    }

    return {
      retryCount,
      notifications: retriedNotifications,
    };
  }
}

