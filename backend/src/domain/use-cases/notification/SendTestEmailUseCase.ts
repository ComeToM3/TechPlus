import { NotificationRepository } from '../../repositories/NotificationRepository';
import { EmailService } from '../../../infrastructure/services/EmailService';
import { Notification } from '../../entities/Notification';
import { NotificationType, NotificationStatus } from '@prisma/client';

export interface SendTestEmailRequest {
  to: string;
}

export interface SendTestEmailResponse {
  notification: Notification;
  success: boolean;
}

export class SendTestEmailUseCase {
  constructor(
    private notificationRepository: NotificationRepository,
    private emailService: EmailService
  ) {}

  async execute(request: SendTestEmailRequest): Promise<SendTestEmailResponse> {
    this.validateRequest(request);

    const testSubject = 'Test Email - TechPlus Notification Service';
    const testHtml = this.generateTestHtml(request.to);
    const testText = this.generateTestText(request.to);

    // 1. Créer la notification en base
    const notification = await this.notificationRepository.create({
      type: NotificationType.ADMIN_NOTIFICATION,
      recipientEmail: request.to,
      subject: testSubject,
      status: NotificationStatus.PENDING,
    });

    try {
      // 2. Envoyer l'email de test
      const emailSuccess = await this.emailService.sendEmail(
        request.to,
        testSubject,
        testHtml,
        testText
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

      throw new Error(`Failed to send test email: ${error}`);
    }
  }

  private validateRequest(request: SendTestEmailRequest): void {
    if (!request.to) {
      throw new Error('Recipient email is required');
    }

    if (!this.isValidEmail(request.to)) {
      throw new Error('Invalid email format');
    }
  }

  private isValidEmail(email: string): boolean {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  }

  private generateTestHtml(recipient: string): string {
    return `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <title>Test Email</title>
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: #2c3e50; color: white; padding: 20px; text-align: center; }
          .content { padding: 20px; background: #f9f9f9; }
          .success { background: #d4edda; border: 1px solid #c3e6cb; padding: 15px; border-radius: 8px; margin: 20px 0; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>✅ Test Email</h1>
            <h2>TechPlus Notification Service</h2>
          </div>
          
          <div class="content">
            <div class="success">
              <h3>🎉 Email Configuration Working!</h3>
              <p>This is a test email to verify that the notification service is properly configured.</p>
              <p><strong>Timestamp:</strong> ${new Date().toISOString()}</p>
              <p><strong>Recipient:</strong> ${recipient}</p>
            </div>
            
            <p>If you received this email, the notification service is working correctly!</p>
          </div>
        </div>
      </body>
      </html>
    `;
  }

  private generateTestText(recipient: string): string {
    return `
Test Email - TechPlus Notification Service

Email Configuration Working!

This is a test email to verify that the notification service is properly configured.

Timestamp: ${new Date().toISOString()}
Recipient: ${recipient}

If you received this email, the notification service is working correctly!
    `.trim();
  }
}

