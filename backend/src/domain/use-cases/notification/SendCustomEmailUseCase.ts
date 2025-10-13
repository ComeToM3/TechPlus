import { NotificationRepository } from '../../repositories/NotificationRepository';
import { EmailService } from '../../../infrastructure/services/EmailService';
import { Notification } from '../../entities/Notification';
import { NotificationType, NotificationStatus } from '@prisma/client';

export interface SendCustomEmailRequest {
  to: string;
  subject: string;
  htmlContent: string;
  textContent?: string;
  attachments?: any[];
}

export interface SendCustomEmailResponse {
  notification: Notification;
  success: boolean;
}

export class SendCustomEmailUseCase {
  constructor(
    private notificationRepository: NotificationRepository,
    private emailService: EmailService
  ) {}

  async execute(request: SendCustomEmailRequest): Promise<SendCustomEmailResponse> {
    this.validateRequest(request);

    // 1. Créer la notification en base
    const notification = await this.notificationRepository.create({
      type: NotificationType.ADMIN_NOTIFICATION,
      recipientEmail: request.to,
      subject: request.subject,
      status: NotificationStatus.PENDING,
    });

    try {
      // 2. Envoyer l'email
      const emailSuccess = await this.emailService.sendEmail(
        request.to,
        request.subject,
        request.htmlContent,
        request.textContent,
        request.attachments
      );

      // 3. Mettre à jour le statut
      const updatedNotification = await this.notificationRepository.updateStatus(
        notification.id,
        emailSuccess ? NotificationStatus.SENT : NotificationStatus.FAILED
      );

      return {
        notification: updatedNotification,
        success: emailSuccess,
      };
    } catch (error) {
      // 4. Marquer comme échoué en cas d'erreur
      const failedNotification = await this.notificationRepository.updateStatus(
        notification.id,
        NotificationStatus.FAILED
      );

      throw new Error(`Failed to send custom email: ${error}`);
    }
  }

  private validateRequest(request: SendCustomEmailRequest): void {
    if (!request.to) {
      throw new Error('Recipient email is required');
    }

    if (!request.subject) {
      throw new Error('Subject is required');
    }

    if (!request.htmlContent) {
      throw new Error('HTML content is required');
    }

    if (!this.isValidEmail(request.to)) {
      throw new Error('Invalid email format');
    }
  }

  private isValidEmail(email: string): boolean {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  }
}

