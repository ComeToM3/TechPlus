import { PrismaClient } from '@prisma/client';
import { notificationQueueService } from './notificationQueueService';
import { NotificationType } from '@/types/notification.types';
import logger from '@/utils/logger';

const prisma = new PrismaClient();

/**
 * Service de gestion des rappels automatiques
 */
export class ReminderService {
  /**
   * Envoie les rappels pour les réservations du jour
   */
  static async sendDailyReminders(): Promise<void> {
    try {
      const today = new Date();
      today.setHours(0, 0, 0, 0);
      
      const tomorrow = new Date(today);
      tomorrow.setDate(tomorrow.getDate() + 1);

      // Trouver les réservations pour demain
      const reservations = await prisma.reservation.findMany({
        where: {
          date: {
            gte: today,
            lt: tomorrow,
          },
          status: 'CONFIRMED', // Seulement les réservations confirmées
        },
        include: {
          restaurant: true,
          table: true,
          user: true,
        },
      });

      logger.info(`Found ${reservations.length} reservations for reminders`);

      for (const reservation of reservations) {
        await this.sendReminderForReservation(reservation);
      }

      logger.info('Daily reminders processing completed');
    } catch (error) {
      logger.error('Error sending daily reminders:', error);
    }
  }

  /**
   * Envoie un rappel pour une réservation spécifique
   */
  private static async sendReminderForReservation(reservation: any): Promise<void> {
    try {
      const clientEmail = reservation.clientEmail || reservation.user?.email;
      
      if (!clientEmail) {
        logger.warn(`No email found for reservation ${reservation.id}`);
        return;
      }

      // Vérifier si un rappel a déjà été envoyé
      const existingReminder = await prisma.notificationQueue.findFirst({
        where: {
          type: NotificationType.RESERVATION_REMINDER,
          status: 'SENT',
          data: {
            contains: reservation.id, // Chercher l'ID de réservation dans les données JSON
          },
        },
      });

      if (existingReminder) {
        logger.info(`Reminder already sent for reservation ${reservation.id}`);
        return;
      }

      // Programmer le rappel pour 24h avant la réservation
      const reminderTime = new Date(reservation.date);
      reminderTime.setHours(reminderTime.getHours() - 24);

      // Si c'est déjà le moment d'envoyer le rappel
      if (reminderTime <= new Date()) {
        await notificationQueueService.enqueueReservationNotification(
          NotificationType.RESERVATION_REMINDER,
          reservation.id,
          clientEmail,
          {},
          2, // Priorité moyenne
          new Date() // Envoyer immédiatement
        );

        logger.info(`Reminder queued for reservation ${reservation.id}`);
      } else {
        // Programmer le rappel pour plus tard
        await notificationQueueService.enqueueReservationNotification(
          NotificationType.RESERVATION_REMINDER,
          reservation.id,
          clientEmail,
          {},
          2, // Priorité moyenne
          reminderTime // Envoyer à l'heure programmée
        );

        logger.info(`Reminder scheduled for ${reminderTime} for reservation ${reservation.id}`);
      }
    } catch (error) {
      logger.error(`Error sending reminder for reservation ${reservation.id}:`, error);
    }
  }

  /**
   * Envoie les rappels pour les réservations dans les 24h
   */
  static async sendUpcomingReminders(): Promise<void> {
    try {
      const now = new Date();
      const in24Hours = new Date(now.getTime() + 24 * 60 * 60 * 1000);

      // Trouver les réservations dans les 24h
      const reservations = await prisma.reservation.findMany({
        where: {
          date: {
            gte: now,
            lte: in24Hours,
          },
          status: 'CONFIRMED',
        },
        include: {
          restaurant: true,
          table: true,
          user: true,
        },
      });

      logger.info(`Found ${reservations.length} upcoming reservations for reminders`);

      for (const reservation of reservations) {
        await this.sendReminderForReservation(reservation);
      }

      logger.info('Upcoming reminders processing completed');
    } catch (error) {
      logger.error('Error sending upcoming reminders:', error);
    }
  }

  /**
   * Démarre le service de rappels automatiques
   */
  static startReminderService(): void {
    // Démarrer avec un délai pour laisser le serveur s'initialiser
    setTimeout(() => {
      // Envoyer les rappels toutes les heures
      setInterval(async () => {
        try {
          await this.sendDailyReminders();
          await this.sendUpcomingReminders();
        } catch (error) {
          logger.error('Error in reminder service interval:', error);
        }
      }, 60 * 60 * 1000); // Toutes les heures

      logger.info('Reminder service started - checking every hour');
    }, 10000); // Délai de 10 secondes
  }
}
