import { Request, Response } from 'express';
import { asyncHandler } from '@/middleware/error';
import logger from '@/utils/logger';

import { SendReservationNotificationUseCase, SendReservationNotificationRequest } from '../domain/use-cases/notification/SendReservationNotificationUseCase';
import { SendCustomEmailUseCase, SendCustomEmailRequest } from '../domain/use-cases/notification/SendCustomEmailUseCase';
import { GetNotificationHistoryUseCase, GetNotificationHistoryRequest } from '../domain/use-cases/notification/GetNotificationHistoryUseCase';
import { RetryFailedNotificationsUseCase, RetryFailedNotificationsRequest } from '../domain/use-cases/notification/RetryFailedNotificationsUseCase';
import { GetNotificationStatsUseCase, GetNotificationStatsRequest } from '../domain/use-cases/notification/GetNotificationStatsUseCase';
import { VerifySMTPConnectionUseCase, VerifySMTPConnectionRequest } from '../domain/use-cases/notification/VerifySMTPConnectionUseCase';
import { SendTestEmailUseCase, SendTestEmailRequest } from '../domain/use-cases/notification/SendTestEmailUseCase';

export class NotificationController {
  constructor(
    private readonly sendReservationNotificationUseCase: SendReservationNotificationUseCase,
    private readonly sendCustomEmailUseCase: SendCustomEmailUseCase,
    private readonly getNotificationHistoryUseCase: GetNotificationHistoryUseCase,
    private readonly retryFailedNotificationsUseCase: RetryFailedNotificationsUseCase,
    private readonly getNotificationStatsUseCase: GetNotificationStatsUseCase,
    private readonly verifySMTPConnectionUseCase: VerifySMTPConnectionUseCase,
    private readonly sendTestEmailUseCase: SendTestEmailUseCase
  ) {}

  /**
   * Envoyer une notification de réservation
   */
  sendReservationNotification = asyncHandler(async (req: Request, res: Response) => {
    const request: SendReservationNotificationRequest = {
      type: req.body.type || 'RESERVATION_CONFIRMATION',
      reservationId: req.body.reservationId,
      recipientEmail: req.body.recipientEmail || req.body.clientEmail,
      data: req.body.data,
    };

    try {
      const response = await this.sendReservationNotificationUseCase.execute(request);
      res.status(200).json({
        success: true,
        message: 'Notification sent successfully',
        data: {
          notification: response.notification.toJSON(),
          success: response.success,
        },
      });
    } catch (error) {
      this.handleError(error, res);
    }
  });

  /**
   * Envoyer un email personnalisé
   */
  sendCustomEmail = asyncHandler(async (req: Request, res: Response) => {
    const request: SendCustomEmailRequest = {
      to: req.body.to,
      subject: req.body.subject,
      htmlContent: req.body.htmlContent,
      textContent: req.body.textContent,
      attachments: req.body.attachments,
    };

    try {
      const response = await this.sendCustomEmailUseCase.execute(request);
      res.status(200).json({
        success: true,
        message: 'Email sent successfully',
        data: {
          notification: response.notification.toJSON(),
          success: response.success,
        },
      });
    } catch (error) {
      this.handleError(error, res);
    }
  });

  /**
   * Récupérer l'historique des notifications
   */
  getNotificationHistory = asyncHandler(async (req: Request, res: Response) => {
    const request: GetNotificationHistoryRequest = {
      limit: req.query.limit ? parseInt(req.query.limit as string) : undefined,
      offset: req.query.offset ? parseInt(req.query.offset as string) : undefined,
      type: req.query.type as any,
      status: req.query.status as any,
      recipientEmail: req.query.recipientEmail as string,
      reservationId: req.query.reservationId as string,
      dateFrom: req.query.dateFrom ? new Date(req.query.dateFrom as string) : undefined,
      dateTo: req.query.dateTo ? new Date(req.query.dateTo as string) : undefined,
    };

    try {
      const response = await this.getNotificationHistoryUseCase.execute(request);
      res.status(200).json({
        success: true,
        data: {
          notifications: response.notifications.map(n => n.toJSON()),
          pagination: response.pagination,
        },
      });
    } catch (error) {
      this.handleError(error, res);
    }
  });

  /**
   * Retry les notifications échouées
   */
  retryFailedNotifications = asyncHandler(async (req: Request, res: Response) => {
    const request: RetryFailedNotificationsRequest = {
      limit: req.body.limit,
    };

    try {
      const response = await this.retryFailedNotificationsUseCase.execute(request);
      res.status(200).json({
        success: true,
        message: `Retried ${response.retryCount} failed notifications`,
        data: {
          retryCount: response.retryCount,
          notifications: response.notifications.map(n => n.toJSON()),
        },
      });
    } catch (error) {
      this.handleError(error, res);
    }
  });

  /**
   * Vérifier la configuration SMTP
   */
  verifySMTPConnection = asyncHandler(async (req: Request, res: Response) => {
    const request: VerifySMTPConnectionRequest = {};

    try {
      const response = await this.verifySMTPConnectionUseCase.execute(request);
      res.status(200).json({
        success: true,
        data: {
          smtpConfigured: response.isConnected,
          message: response.message,
        },
      });
    } catch (error) {
      this.handleError(error, res);
    }
  });

  /**
   * Envoyer un email de test
   */
  sendTestEmail = asyncHandler(async (req: Request, res: Response) => {
    const request: SendTestEmailRequest = {
      to: req.body.to,
    };

    try {
      const response = await this.sendTestEmailUseCase.execute(request);
      res.status(200).json({
        success: true,
        message: 'Test email sent successfully',
        data: {
          notification: response.notification.toJSON(),
          success: response.success,
        },
      });
    } catch (error) {
      this.handleError(error, res);
    }
  });

  /**
   * Obtenir les statistiques des notifications
   */
  getNotificationStats = asyncHandler(async (req: Request, res: Response) => {
    const request: GetNotificationStatsRequest = {
      type: req.query.type as any,
      status: req.query.status as any,
      recipientEmail: req.query.recipientEmail as string,
      reservationId: req.query.reservationId as string,
      dateFrom: req.query.dateFrom ? new Date(req.query.dateFrom as string) : undefined,
      dateTo: req.query.dateTo ? new Date(req.query.dateTo as string) : undefined,
    };

    try {
      const response = await this.getNotificationStatsUseCase.execute(request);
      res.status(200).json({
        success: true,
        data: response,
      });
    } catch (error) {
      this.handleError(error, res);
    }
  });

  /**
   * Gestion centralisée des erreurs
   */
  private handleError(error: any, res: Response): void {
    logger.error('NotificationController error:', error);
    
    if (error.message.includes('Notification type is required') || 
        error.message.includes('Reservation ID is required') ||
        error.message.includes('Recipient email is required') ||
        error.message.includes('Subject is required') ||
        error.message.includes('HTML content is required')) {
      res.status(400).json({ success: false, message: error.message });
    } else if (error.message.includes('Invalid email format')) {
      res.status(400).json({ success: false, message: error.message });
    } else if (error.message.includes('No template found')) {
      res.status(404).json({ success: false, message: error.message });
    } else if (error.message.includes('Failed to send')) {
      res.status(500).json({ success: false, message: error.message });
    } else {
      res.status(500).json({ success: false, message: 'Internal Server Error' });
    }
  }
}

