import { NotificationRepository } from '../../repositories/NotificationRepository';
import { EmailService } from '../../../infrastructure/services/EmailService';
import { Notification } from '../../entities/Notification';
import { NotificationType, NotificationStatus } from '@prisma/client';

export interface SendReservationNotificationRequest {
  type: NotificationType;
  reservationId: string;
  recipientEmail: string;
  data?: any;
}

export interface SendReservationNotificationResponse {
  notification: Notification;
  success: boolean;
}

export class SendReservationNotificationUseCase {
  constructor(
    private notificationRepository: NotificationRepository,
    private emailService: EmailService
  ) {}

  async execute(request: SendReservationNotificationRequest): Promise<SendReservationNotificationResponse> {
    this.validateRequest(request);

    // 1. Créer la notification en base
    const notification = await this.notificationRepository.create({
      type: request.type,
      recipientEmail: request.recipientEmail,
      subject: `Notification ${request.type}`,
      status: NotificationStatus.PENDING,
      reservationId: request.reservationId,
      data: request.data ? JSON.stringify(request.data) : null,
    });

    try {
      // 2. Envoyer l'email
      const emailSuccess = await this.emailService.sendEmail(
        request.recipientEmail,
        `Notification ${request.type}`,
        `<h1>Notification ${request.type}</h1><p>Réservation: ${request.reservationId}</p>`,
        `Notification ${request.type}\nRéservation: ${request.reservationId}`
      );

      // 4. Mettre à jour le statut
      const updatedNotification = await this.notificationRepository.updateStatus(
        notification.id,
        emailSuccess ? NotificationStatus.SENT : NotificationStatus.FAILED
      );

      return {
        notification: updatedNotification,
        success: emailSuccess,
      };
    } catch (error) {
      // 5. Marquer comme échoué en cas d'erreur
      const failedNotification = await this.notificationRepository.updateStatus(
        notification.id,
        NotificationStatus.FAILED
      );

      throw new Error(`Failed to send notification: ${error}`);
    }
  }

  private validateRequest(request: SendReservationNotificationRequest): void {
    if (!request.type) {
      throw new Error('Notification type is required');
    }

    if (!request.reservationId) {
      throw new Error('Reservation ID is required');
    }

    if (!request.recipientEmail) {
      throw new Error('Recipient email is required');
    }

    if (!this.isValidEmail(request.recipientEmail)) {
      throw new Error('Invalid email format');
    }
  }

  private isValidEmail(email: string): boolean {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  }
}
