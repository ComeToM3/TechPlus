import { Request, Response } from 'express';
import { notificationService } from '@/services/notificationService';
import { NotificationType, NotificationStatus } from '@/types/notification.types';
import { asyncHandler } from '@/middleware/error';
import { CustomError } from '@/middleware/error';
import logger from '@/utils/logger';

/**
 * Envoyer une notification de réservation
 */
export const sendReservationNotification = asyncHandler(async (req: Request, res: Response) => {
  const { reservationId, type, recipientEmail, data } = req.body;

  if (!reservationId || !type || !recipientEmail) {
    throw new CustomError('Missing required fields: reservationId, type, recipientEmail', 400);
  }

  // Valider le type de notification
  if (!Object.values(NotificationType).includes(type)) {
    throw new CustomError('Invalid notification type', 400);
  }

  const success = await notificationService.sendReservationNotification(
    type,
    reservationId,
    recipientEmail,
    data || {}
  );

  if (!success) {
    throw new CustomError('Failed to send notification', 500);
  }

  res.status(200).json({
    success: true,
    message: 'Notification sent successfully',
    data: {
      reservationId,
      type,
      recipientEmail,
    },
  });
});

/**
 * Envoyer un email personnalisé
 */
export const sendCustomEmail = asyncHandler(async (req: Request, res: Response) => {
  const { to, subject, htmlContent, textContent, attachments } = req.body;

  if (!to || !subject || !htmlContent) {
    throw new CustomError('Missing required fields: to, subject, htmlContent', 400);
  }

  const success = await notificationService.sendEmail(
    to,
    subject,
    htmlContent,
    textContent,
    attachments
  );

  if (!success) {
    throw new CustomError('Failed to send email', 500);
  }

  res.status(200).json({
    success: true,
    message: 'Email sent successfully',
    data: {
      to,
      subject,
    },
  });
});

/**
 * Récupérer l'historique des notifications
 */
export const getNotificationHistory = asyncHandler(async (req: Request, res: Response) => {
  const {
    limit = 50,
    offset = 0,
    type,
    status,
    recipientEmail,
    reservationId,
  } = req.query;

  const filters: any = {};
  if (type) filters.type = type;
  if (status) filters.status = status;
  if (recipientEmail) filters.recipientEmail = recipientEmail;
  if (reservationId) filters.reservationId = reservationId;

  const notifications = await notificationService.getNotificationHistory(
    parseInt(limit as string),
    parseInt(offset as string),
    filters
  );

  res.status(200).json({
    success: true,
    data: notifications,
    pagination: {
      limit: parseInt(limit as string),
      offset: parseInt(offset as string),
      total: notifications.length,
    },
  });
});

/**
 * Retry les notifications échouées
 */
export const retryFailedNotifications = asyncHandler(async (req: Request, res: Response) => {
  const retryCount = await notificationService.retryFailedNotifications();

  res.status(200).json({
    success: true,
    message: `Retried ${retryCount} failed notifications`,
    data: {
      retryCount,
    },
  });
});

/**
 * Vérifier la configuration SMTP
 */
export const verifySMTPConnection = asyncHandler(async (req: Request, res: Response) => {
  const isConnected = await notificationService.verifyConnection();

  res.status(200).json({
    success: true,
    data: {
      smtpConfigured: isConnected,
      message: isConnected ? 'SMTP connection verified' : 'SMTP not configured or connection failed',
    },
  });
});

/**
 * Envoyer un email de test
 */
export const sendTestEmail = asyncHandler(async (req: Request, res: Response) => {
  const { to } = req.body;

  if (!to) {
    throw new CustomError('Email address is required', 400);
  }

  const testSubject = 'Test Email - TechPlus Notification Service';
  const testHtml = `
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
            <p><strong>Recipient:</strong> ${to}</p>
          </div>
          
          <p>If you received this email, the notification service is working correctly!</p>
        </div>
      </div>
    </body>
    </html>
  `;

  const testText = `
Test Email - TechPlus Notification Service

Email Configuration Working!

This is a test email to verify that the notification service is properly configured.

Timestamp: ${new Date().toISOString()}
Recipient: ${to}

If you received this email, the notification service is working correctly!
  `.trim();

  const success = await notificationService.sendEmail(
    to,
    testSubject,
    testHtml,
    testText
  );

  if (!success) {
    throw new CustomError('Failed to send test email', 500);
  }

  res.status(200).json({
    success: true,
    message: 'Test email sent successfully',
    data: {
      to,
      subject: testSubject,
    },
  });
});

/**
 * Obtenir les statistiques des notifications
 */
export const getNotificationStats = asyncHandler(async (req: Request, res: Response) => {
  const { period = '7d' } = req.query;

  // Calculer la date de début selon la période
  let startDate: Date;
  const now = new Date();
  
  switch (period) {
    case '1d':
      startDate = new Date(now.getTime() - 24 * 60 * 60 * 1000);
      break;
    case '7d':
      startDate = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
      break;
    case '30d':
      startDate = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);
      break;
    default:
      startDate = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
  }

  // Récupérer les statistiques depuis la base de données
  const { PrismaClient } = await import('@prisma/client');
  const prisma = new PrismaClient();

  try {
    const [
      total,
      sent,
      failed,
      pending,
      byType,
      byStatus,
    ] = await Promise.all([
      prisma.notification.count({
        where: { createdAt: { gte: startDate } },
      }),
      prisma.notification.count({
        where: { 
          createdAt: { gte: startDate },
          status: NotificationStatus.SENT,
        },
      }),
      prisma.notification.count({
        where: { 
          createdAt: { gte: startDate },
          status: NotificationStatus.FAILED,
        },
      }),
      prisma.notification.count({
        where: { 
          createdAt: { gte: startDate },
          status: NotificationStatus.PENDING,
        },
      }),
      prisma.notification.groupBy({
        by: ['type'],
        where: { createdAt: { gte: startDate } },
        _count: { type: true },
      }),
      prisma.notification.groupBy({
        by: ['status'],
        where: { createdAt: { gte: startDate } },
        _count: { status: true },
      }),
    ]);

    const stats = {
      total,
      sent,
      failed,
      pending,
      successRate: total > 0 ? Math.round((sent / total) * 100) : 0,
      byType: byType.reduce((acc, item) => {
        acc[item.type] = item._count.type;
        return acc;
      }, {} as Record<string, number>),
      byStatus: byStatus.reduce((acc, item) => {
        acc[item.status] = item._count.status;
        return acc;
      }, {} as Record<string, number>),
      period,
      startDate,
      endDate: now,
    };

    res.status(200).json({
      success: true,
      data: stats,
    });
  } catch (error) {
    logger.error('Failed to get notification stats:', error);
    throw new CustomError('Failed to get notification statistics', 500);
  } finally {
    await prisma.$disconnect();
  }
});
