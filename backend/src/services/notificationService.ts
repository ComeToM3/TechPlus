import nodemailer from 'nodemailer';
import { PrismaClient } from '@prisma/client';
import logger from '@/utils/logger';
import {
  NotificationTemplate,
  NotificationType,
  NotificationStatus,
} from '@/types/notification.types';

const prisma = new PrismaClient();

/**
 * Service de notification pour l'envoi d'emails
 */
export class NotificationService {
  private transporter!: nodemailer.Transporter;
  private isConfigured: boolean = false;

  constructor() {
    this.initializeTransporter();
  }

  /**
   * Initialise le transporteur email
   */
  private initializeTransporter(): void {
    try {
      const smtpConfig = {
        host: process.env.SMTP_HOST || 'smtp.gmail.com',
        port: parseInt(process.env.SMTP_PORT || '587'),
        secure: process.env.SMTP_SECURE === 'true',
        auth: {
          user: process.env.SMTP_USER,
          pass: process.env.SMTP_PASS,
        },
        tls: {
          rejectUnauthorized: false,
        },
      };

      if (!smtpConfig.auth.user || !smtpConfig.auth.pass) {
        logger.warn('SMTP credentials not configured. Email notifications will be disabled.');
        return;
      }

      this.transporter = nodemailer.createTransport(smtpConfig);
      this.isConfigured = true;
      logger.info('Email transporter initialized successfully');
    } catch (error) {
      logger.error('Failed to initialize email transporter:', error);
      this.isConfigured = false;
    }
  }

  /**
   * Vérifie la configuration SMTP
   */
  async verifyConnection(): Promise<boolean> {
    if (!this.isConfigured) {
      logger.warn('SMTP not configured, skipping verification');
      return false;
    }

    try {
      await this.transporter.verify();
      logger.info('SMTP connection verified successfully');
      return true;
    } catch (error) {
      logger.error('SMTP connection verification failed:', error);
      return false;
    }
  }

  /**
   * Envoie un email de notification
   */
  async sendEmail(
    to: string,
    subject: string,
    htmlContent: string,
    textContent?: string,
    attachments?: any[]
  ): Promise<boolean> {
    if (!this.isConfigured) {
      logger.warn('SMTP not configured, email not sent');
      return false;
    }

    try {
      const mailOptions: nodemailer.SendMailOptions = {
        from: `"${process.env.SMTP_FROM_NAME || 'TechPlus'}" <${process.env.SMTP_FROM_EMAIL || process.env.SMTP_USER}>`,
        to,
        subject,
        html: htmlContent,
        text: textContent,
        attachments,
      };

      const result = await this.transporter.sendMail(mailOptions);
      logger.info(`Email sent successfully to ${to}. MessageId: ${result.messageId}`);
      return true;
    } catch (error) {
      logger.error(`Failed to send email to ${to}:`, error);
      return false;
    }
  }

  /**
   * Envoie une notification de réservation
   */
  async sendReservationNotification(
    type: NotificationType,
    reservationId: string,
    recipientEmail: string,
    data: any
  ): Promise<boolean> {
    try {
      // Récupérer la réservation avec les détails
      const reservation = await prisma.reservation.findUnique({
        where: { id: reservationId },
        include: {
          restaurant: true,
          table: true,
          user: true,
        },
      });

      if (!reservation) {
        logger.error(`Reservation ${reservationId} not found`);
        return false;
      }

      // Générer le template
      const template = this.generateReservationTemplate(type, reservation, data);

      // Envoyer l'email
      const success = await this.sendEmail(
        recipientEmail,
        template.subject,
        template.html,
        template.text
      );

      // Enregistrer la notification dans la base de données
      await this.logNotification({
        type,
        recipientEmail,
        subject: template.subject,
        status: success ? NotificationStatus.SENT : NotificationStatus.FAILED,
        reservationId,
        data: JSON.stringify(data),
      });

      return success;
    } catch (error: any) {
      logger.error(`Failed to send reservation notification:`, error);

      // Enregistrer l'échec
      await this.logNotification({
        type,
        recipientEmail,
        subject: 'Notification Failed',
        status: NotificationStatus.FAILED,
        reservationId,
        data: JSON.stringify({ error: error.message }),
      });

      return false;
    }
  }

  /**
   * Génère un template de réservation
   */
  private generateReservationTemplate(
    type: NotificationType,
    reservation: any,
    data: any
  ): NotificationTemplate {
    const restaurant = reservation.restaurant;
    const date = new Date(reservation.date).toLocaleDateString('fr-FR');
    const time = reservation.time;

    switch (type) {
      case NotificationType.RESERVATION_CONFIRMATION:
        return {
          subject: `Confirmation de réservation - ${restaurant.name}`,
          html: this.generateConfirmationHTML(reservation, restaurant, date, time),
          text: this.generateConfirmationText(reservation, restaurant, date, time),
        };

      case NotificationType.RESERVATION_REMINDER:
        return {
          subject: `Rappel de réservation - ${restaurant.name}`,
          html: this.generateReminderHTML(reservation, restaurant, date, time),
          text: this.generateReminderText(reservation, restaurant, date, time),
        };

      case NotificationType.RESERVATION_CANCELLATION:
        return {
          subject: `Annulation de réservation - ${restaurant.name}`,
          html: this.generateCancellationHTML(reservation, restaurant, date, time, data.reason),
          text: this.generateCancellationText(reservation, restaurant, date, time, data.reason),
        };

      case NotificationType.RESERVATION_MODIFICATION:
        return {
          subject: `Modification de réservation - ${restaurant.name}`,
          html: this.generateModificationHTML(reservation, restaurant, date, time, data.changes),
          text: this.generateModificationText(reservation, restaurant, date, time, data.changes),
        };

      default:
        throw new Error(`Unknown notification type: ${type}`);
    }
  }

  /**
   * Génère le HTML de confirmation
   */
  private generateConfirmationHTML(
    reservation: any,
    restaurant: any,
    date: string,
    time: string
  ): string {
    const managementToken = reservation.managementToken;
    const managementUrl = `${process.env.FRONTEND_URL}/manage-reservation?token=${managementToken}`;

    return `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Confirmation de réservation</title>
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: #2c3e50; color: white; padding: 20px; text-align: center; }
          .content { padding: 20px; background: #f9f9f9; }
          .reservation-details { background: white; padding: 20px; border-radius: 8px; margin: 20px 0; }
          .detail-row { display: flex; justify-content: space-between; margin: 10px 0; }
          .detail-label { font-weight: bold; }
          .management-link { background: #3498db; color: white; padding: 12px 24px; text-decoration: none; border-radius: 4px; display: inline-block; margin: 20px 0; }
          .footer { text-align: center; padding: 20px; color: #666; font-size: 14px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>🍽️ Confirmation de Réservation</h1>
            <h2>${restaurant.name}</h2>
          </div>
          
          <div class="content">
            <p>Bonjour ${reservation.clientName || reservation.user?.name || 'Cher client'},</p>
            
            <p>Votre réservation a été confirmée avec succès ! Voici les détails :</p>
            
            <div class="reservation-details">
              <div class="detail-row">
                <span class="detail-label">Date :</span>
                <span>${date}</span>
              </div>
              <div class="detail-row">
                <span class="detail-label">Heure :</span>
                <span>${time}</span>
              </div>
              <div class="detail-row">
                <span class="detail-label">Nombre de personnes :</span>
                <span>${reservation.partySize}</span>
              </div>
              ${
                reservation.table
                  ? `
              <div class="detail-row">
                <span class="detail-label">Table :</span>
                <span>Table ${reservation.table.number}</span>
              </div>
              `
                  : ''
              }
              ${
                reservation.specialRequests
                  ? `
              <div class="detail-row">
                <span class="detail-label">Demandes spéciales :</span>
                <span>${reservation.specialRequests}</span>
              </div>
              `
                  : ''
              }
            </div>

            ${
              managementToken
                ? `
            <p>Vous pouvez gérer votre réservation en cliquant sur le lien ci-dessous :</p>
            <a href="${managementUrl}" class="management-link">Gérer ma réservation</a>
            `
                : ''
            }

            <p>Nous avons hâte de vous accueillir !</p>
            
            <p>L'équipe de ${restaurant.name}</p>
          </div>
          
          <div class="footer">
            <p>${restaurant.name} | ${restaurant.address} | ${restaurant.phone}</p>
            <p>Cet email a été envoyé automatiquement, merci de ne pas y répondre.</p>
          </div>
        </div>
      </body>
      </html>
    `;
  }

  /**
   * Génère le texte de confirmation
   */
  private generateConfirmationText(
    reservation: any,
    restaurant: any,
    date: string,
    time: string
  ): string {
    const managementToken = reservation.managementToken;
    const managementUrl = `${process.env.FRONTEND_URL}/manage-reservation?token=${managementToken}`;

    return `
Confirmation de Réservation - ${restaurant.name}

Bonjour ${reservation.clientName || reservation.user?.name || 'Cher client'},

Votre réservation a été confirmée avec succès !

Détails de la réservation :
- Date : ${date}
- Heure : ${time}
- Nombre de personnes : ${reservation.partySize}
${reservation.table ? `- Table : Table ${reservation.table.number}` : ''}
${reservation.specialRequests ? `- Demandes spéciales : ${reservation.specialRequests}` : ''}

${managementToken ? `Gérer votre réservation : ${managementUrl}` : ''}

Nous avons hâte de vous accueillir !

L'équipe de ${restaurant.name}
${restaurant.address} | ${restaurant.phone}
    `.trim();
  }

  /**
   * Génère le HTML de rappel
   */
  private generateReminderHTML(
    reservation: any,
    restaurant: any,
    date: string,
    time: string
  ): string {
    return `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Rappel de réservation</title>
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: #e74c3c; color: white; padding: 20px; text-align: center; }
          .content { padding: 20px; background: #f9f9f9; }
          .reminder-box { background: #fff3cd; border: 1px solid #ffeaa7; padding: 15px; border-radius: 8px; margin: 20px 0; }
          .footer { text-align: center; padding: 20px; color: #666; font-size: 14px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>⏰ Rappel de Réservation</h1>
            <h2>${restaurant.name}</h2>
          </div>
          
          <div class="content">
            <p>Bonjour ${reservation.clientName || reservation.user?.name || 'Cher client'},</p>
            
            <div class="reminder-box">
              <h3>📅 Votre réservation est prévue demain !</h3>
              <p><strong>Date :</strong> ${date}</p>
              <p><strong>Heure :</strong> ${time}</p>
              <p><strong>Nombre de personnes :</strong> ${reservation.partySize}</p>
            </div>

            <p>Nous vous attendons avec impatience !</p>
            
            <p>L'équipe de ${restaurant.name}</p>
          </div>
          
          <div class="footer">
            <p>${restaurant.name} | ${restaurant.address} | ${restaurant.phone}</p>
          </div>
        </div>
      </body>
      </html>
    `;
  }

  /**
   * Génère le texte de rappel
   */
  private generateReminderText(
    reservation: any,
    restaurant: any,
    date: string,
    time: string
  ): string {
    return `
Rappel de Réservation - ${restaurant.name}

Bonjour ${reservation.clientName || reservation.user?.name || 'Cher client'},

Votre réservation est prévue demain !

Détails :
- Date : ${date}
- Heure : ${time}
- Nombre de personnes : ${reservation.partySize}

Nous vous attendons avec impatience !

L'équipe de ${restaurant.name}
${restaurant.address} | ${restaurant.phone}
    `.trim();
  }

  /**
   * Génère le HTML d'annulation
   */
  private generateCancellationHTML(
    reservation: any,
    restaurant: any,
    date: string,
    time: string,
    reason?: string
  ): string {
    return `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Annulation de réservation</title>
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: #e74c3c; color: white; padding: 20px; text-align: center; }
          .content { padding: 20px; background: #f9f9f9; }
          .cancellation-box { background: #f8d7da; border: 1px solid #f5c6cb; padding: 15px; border-radius: 8px; margin: 20px 0; }
          .footer { text-align: center; padding: 20px; color: #666; font-size: 14px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>❌ Annulation de Réservation</h1>
            <h2>${restaurant.name}</h2>
          </div>
          
          <div class="content">
            <p>Bonjour ${reservation.clientName || reservation.user?.name || 'Cher client'},</p>
            
            <div class="cancellation-box">
              <h3>Votre réservation a été annulée</h3>
              <p><strong>Date :</strong> ${date}</p>
              <p><strong>Heure :</strong> ${time}</p>
              <p><strong>Nombre de personnes :</strong> ${reservation.partySize}</p>
              ${reason ? `<p><strong>Raison :</strong> ${reason}</p>` : ''}
            </div>

            <p>Nous espérons vous accueillir prochainement !</p>
            
            <p>L'équipe de ${restaurant.name}</p>
          </div>
          
          <div class="footer">
            <p>${restaurant.name} | ${restaurant.address} | ${restaurant.phone}</p>
          </div>
        </div>
      </body>
      </html>
    `;
  }

  /**
   * Génère le texte d'annulation
   */
  private generateCancellationText(
    reservation: any,
    restaurant: any,
    date: string,
    time: string,
    reason?: string
  ): string {
    return `
Annulation de Réservation - ${restaurant.name}

Bonjour ${reservation.clientName || reservation.user?.name || 'Cher client'},

Votre réservation a été annulée.

Détails :
- Date : ${date}
- Heure : ${time}
- Nombre de personnes : ${reservation.partySize}
${reason ? `- Raison : ${reason}` : ''}

Nous espérons vous accueillir prochainement !

L'équipe de ${restaurant.name}
${restaurant.address} | ${restaurant.phone}
    `.trim();
  }

  /**
   * Génère le HTML de modification
   */
  private generateModificationHTML(
    reservation: any,
    restaurant: any,
    date: string,
    time: string,
    changes: any
  ): string {
    return `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Modification de réservation</title>
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: #f39c12; color: white; padding: 20px; text-align: center; }
          .content { padding: 20px; background: #f9f9f9; }
          .modification-box { background: #fff3cd; border: 1px solid #ffeaa7; padding: 15px; border-radius: 8px; margin: 20px 0; }
          .footer { text-align: center; padding: 20px; color: #666; font-size: 14px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>✏️ Modification de Réservation</h1>
            <h2>${restaurant.name}</h2>
          </div>
          
          <div class="content">
            <p>Bonjour ${reservation.clientName || reservation.user?.name || 'Cher client'},</p>
            
            <div class="modification-box">
              <h3>Votre réservation a été modifiée</h3>
              <p><strong>Nouvelle date :</strong> ${date}</p>
              <p><strong>Nouvelle heure :</strong> ${time}</p>
              <p><strong>Nombre de personnes :</strong> ${reservation.partySize}</p>
            </div>

            <p>Nous vous remercions de votre compréhension.</p>
            
            <p>L'équipe de ${restaurant.name}</p>
          </div>
          
          <div class="footer">
            <p>${restaurant.name} | ${restaurant.address} | ${restaurant.phone}</p>
          </div>
        </div>
      </body>
      </html>
    `;
  }

  /**
   * Génère le texte de modification
   */
  private generateModificationText(
    reservation: any,
    restaurant: any,
    date: string,
    time: string,
    changes: any
  ): string {
    return `
Modification de Réservation - ${restaurant.name}

Bonjour ${reservation.clientName || reservation.user?.name || 'Cher client'},

Votre réservation a été modifiée.

Nouveaux détails :
- Date : ${date}
- Heure : ${time}
- Nombre de personnes : ${reservation.partySize}

Nous vous remercions de votre compréhension.

L'équipe de ${restaurant.name}
${restaurant.address} | ${restaurant.phone}
    `.trim();
  }

  /**
   * Enregistre une notification dans la base de données
   */
  private async logNotification(data: {
    type: NotificationType;
    recipientEmail: string;
    subject: string;
    status: NotificationStatus;
    reservationId?: string;
    data?: string;
  }): Promise<void> {
    try {
      const notificationData: any = {
        type: data.type,
        recipientEmail: data.recipientEmail,
        subject: data.subject,
        status: data.status,
      };

      if (data.reservationId) {
        notificationData.reservationId = data.reservationId;
      }

      if (data.data) {
        notificationData.data = data.data;
      }

      await prisma.notification.create({
        data: notificationData,
      });
    } catch (error) {
      logger.error('Failed to log notification:', error);
    }
  }

  /**
   * Récupère l'historique des notifications
   */
  async getNotificationHistory(
    limit: number = 50,
    offset: number = 0,
    filters?: {
      type?: NotificationType;
      status?: NotificationStatus;
      recipientEmail?: string;
      reservationId?: string;
    }
  ): Promise<any[]> {
    try {
      const where: any = {};

      if (filters?.type) where.type = filters.type;
      if (filters?.status) where.status = filters.status;
      if (filters?.recipientEmail) where.recipientEmail = filters.recipientEmail;
      if (filters?.reservationId) where.reservationId = filters.reservationId;

      const notifications = await prisma.notification.findMany({
        where,
        orderBy: { createdAt: 'desc' },
        take: limit,
        skip: offset,
        include: {
          reservation: {
            include: {
              restaurant: true,
            },
          },
        },
      });

      return notifications;
    } catch (error) {
      logger.error('Failed to get notification history:', error);
      return [];
    }
  }

  /**
   * Retry les notifications échouées
   */
  async retryFailedNotifications(): Promise<number> {
    try {
      const failedNotifications = await prisma.notification.findMany({
        where: {
          status: NotificationStatus.FAILED,
          createdAt: {
            gte: new Date(Date.now() - 24 * 60 * 60 * 1000), // Dernières 24h
          },
        },
        include: {
          reservation: {
            include: {
              restaurant: true,
              table: true,
              user: true,
            },
          },
        },
      });

      let retryCount = 0;

      for (const notification of failedNotifications) {
        try {
          if (notification.reservation) {
            const success = await this.sendReservationNotification(
              notification.type as NotificationType,
              notification.reservationId!,
              notification.recipientEmail,
              notification.data ? JSON.parse(notification.data) : {}
            );

            if (success) {
              await prisma.notification.update({
                where: { id: notification.id },
                data: { status: NotificationStatus.SENT },
              });
              retryCount++;
            }
          }
        } catch (error) {
          logger.error(`Failed to retry notification ${notification.id}:`, error);
        }
      }

      logger.info(`Retried ${retryCount} failed notifications`);
      return retryCount;
    } catch (error) {
      logger.error('Failed to retry failed notifications:', error);
      return 0;
    }
  }
}

// Instance singleton
export const notificationService = new NotificationService();
