import { Prisma, ReservationStatus, PaymentStatus } from '@prisma/client';
import prisma from '@/config/database';
import { CustomError } from '@/middleware/error';

export interface CreateReservationData {
  date: string | Date;
  time: string;
  partySize: number;
  duration?: number;
  notes?: string;
  specialRequests?: string;
  clientName?: string;
  clientEmail?: string;
  clientPhone?: string;
  userId?: string | undefined;
}

export interface AvailabilityCheck {
  date: string | Date;
  time: string;
  partySize: number;
  restaurantId: string;
  excludeReservationId?: string | undefined;
}

export interface TimeSlot {
  time: string;
  available: boolean;
  availableTables: number;
}

export interface DayAvailability {
  date: string;
  slots: TimeSlot[];
}

/**
 * Service de gestion des réservations
 */
export class ReservationService {
  /**
   * Créer une nouvelle réservation avec validation complète
   */
  static async createReservation(data: CreateReservationData): Promise<any> {
    try {
      // 1. Récupérer le restaurant actif
      const restaurant = await prisma.restaurant.findFirst({
        where: { isActive: true },
      });

      if (!restaurant) {
        throw new CustomError('No active restaurant found', 404);
      }

      // 2. Valider les créneaux disponibles
      const isAvailable = await this.checkAvailability({
        date: data.date,
        time: data.time,
        partySize: data.partySize,
        restaurantId: restaurant.id,
      });

      if (!isAvailable) {
        throw new CustomError('No tables available for the selected time slot', 409);
      }

      // 3. Calculer la durée automatiquement si non fournie
      const calculatedDuration = data.duration || this.calculateDuration(data.partySize);

      // 4. Déterminer si un paiement est requis
      const requiresPayment = data.partySize >= restaurant.paymentThreshold;
      const depositAmount = requiresPayment ? Number(restaurant.minimumDepositAmount) : 0;

      // 5. Générer un token de gestion pour les réservations guest
      const managementToken = !data.userId ? this.generateManagementToken() : undefined;
      const tokenExpiresAt = !data.userId ? this.calculateTokenExpiry() : undefined;

      // 6. Trouver une table disponible et l'assigner
      const availableTable = await this.findAvailableTable({
        date: data.date,
        time: data.time,
        partySize: data.partySize,
        restaurantId: restaurant.id,
      });

      // 7. Créer la réservation
      const reservationData: Prisma.ReservationCreateInput = {
        date: new Date(data.date),
        time: data.time,
        duration: calculatedDuration,
        partySize: data.partySize,
        status: ReservationStatus.PENDING,
        requiresPayment,
        depositAmount,
        paymentStatus: requiresPayment ? PaymentStatus.PENDING : PaymentStatus.NONE,
        notes: data.notes,
        specialRequests: data.specialRequests,
        managementToken,
        tokenExpiresAt,
        restaurant: { connect: { id: restaurant.id } },
        ...(availableTable && { table: { connect: { id: availableTable.id } } }),
        ...(data.userId && { user: { connect: { id: data.userId } } }),
        ...(data.clientName && { clientName: data.clientName }),
        ...(data.clientEmail && { clientEmail: data.clientEmail }),
        ...(data.clientPhone && { clientPhone: data.clientPhone }),
      };

      const reservation = await prisma.reservation.create({
        data: reservationData,
        include: {
          user: {
            select: {
              id: true,
              email: true,
              name: true,
            },
          },
          restaurant: {
            select: {
              id: true,
              name: true,
              address: true,
              phone: true,
            },
          },
          table: {
            select: {
              id: true,
              number: true,
              capacity: true,
              position: true,
            },
          },
        },
      });

      return reservation;
    } catch (error) {
      if (error instanceof CustomError) {
        throw error;
      }
      console.error('Error creating reservation:', error);
      throw new CustomError('Failed to create reservation', 500);
    }
  }

  /**
   * Vérifier la disponibilité pour un créneau donné
   */
  static async checkAvailability(check: AvailabilityCheck): Promise<boolean> {
    try {
      const availableTable = await this.findAvailableTable(check);
      return !!availableTable;
    } catch (error) {
      console.error('Error checking availability:', error);
      return false;
    }
  }

  /**
   * Trouver une table disponible pour un créneau donné
   */
  static async findAvailableTable(check: AvailabilityCheck): Promise<any> {
    const reservationDate = new Date(check.date);
    const reservationTime = check.time;

    // Construire la condition de filtrage pour les réservations existantes
    const reservationFilter: any = {
      date: reservationDate,
      time: reservationTime,
      status: { not: ReservationStatus.CANCELLED },
    };

    // Ajouter l'exclusion de la réservation actuelle si fournie
    if (check.excludeReservationId) {
      reservationFilter.id = { not: check.excludeReservationId };
    }

    // Trouver une table disponible
    const availableTable = await prisma.table.findFirst({
      where: {
        restaurantId: check.restaurantId,
        isActive: true,
        capacity: { gte: check.partySize },
        reservations: {
          none: reservationFilter,
        },
      },
      orderBy: [
        { capacity: 'asc' }, // Préférer les tables les plus petites
        { number: 'asc' }, // Puis par numéro
      ],
    });

    return availableTable;
  }

  /**
   * Obtenir les disponibilités pour une date donnée
   */
  static async getDayAvailability(
    date: string | Date,
    restaurantId: string,
    partySize: number = 1
  ): Promise<DayAvailability> {
    try {
      const restaurant = await prisma.restaurant.findUnique({
        where: { id: restaurantId },
        select: { openingHours: true },
      });

      if (!restaurant) {
        throw new CustomError('Restaurant not found', 404);
      }

      // Récupérer les heures d'ouverture (par défaut si non configurées)
      const openingHours = (restaurant.openingHours as any) || this.getDefaultOpeningHours();
      const dayNames = [
        'sunday',
        'monday',
        'tuesday',
        'wednesday',
        'thursday',
        'friday',
        'saturday',
      ];
      const dayOfWeek = dayNames[new Date(date).getDay()] as string;

      const dateStr = new Date(date).toISOString().split('T')[0] as string;

      if (!dayOfWeek) {
        return {
          date: dateStr,
          slots: [],
        };
      }

      const dayHours = openingHours[dayOfWeek];
      if (!dayHours || dayHours.closed) {
        return {
          date: dateStr,
          slots: [],
        };
      }

      // Générer les créneaux horaires
      const slots = await this.generateTimeSlots(date, restaurantId, dayHours, partySize);

      return {
        date: dateStr,
        slots,
      };
    } catch (error) {
      console.error('Error getting day availability:', error);
      throw new CustomError('Failed to get availability', 500);
    }
  }

  /**
   * Générer les créneaux horaires pour une journée
   */
  private static async generateTimeSlots(
    date: string | Date,
    restaurantId: string,
    dayHours: any,
    partySize: number
  ): Promise<TimeSlot[]> {
    const slots: TimeSlot[] = [];
    const reservationDate = new Date(date);

    // Créneaux de 30 minutes
    const timeSlots = this.generateTimeIntervals(dayHours);

    for (const time of timeSlots) {
      const isAvailable = await this.checkAvailability({
        date: reservationDate,
        time,
        partySize,
        restaurantId,
      });

      const availableTables = await this.countAvailableTables({
        date: reservationDate,
        time,
        partySize,
        restaurantId,
      });

      slots.push({
        time,
        available: isAvailable,
        availableTables,
      });
    }

    return slots;
  }

  /**
   * Générer les intervalles de temps pour une journée
   */
  private static generateTimeIntervals(dayHours: any): string[] {
    const intervals: string[] = [];

    // Service du midi
    if (dayHours.open && dayHours.close) {
      const startTime = this.parseTime(dayHours.open);
      const endTime = this.parseTime(dayHours.close);
      intervals.push(...this.generateIntervals(startTime, endTime));
    }

    // Service du soir
    if (dayHours.evening?.open && dayHours.evening?.close) {
      const startTime = this.parseTime(dayHours.evening.open);
      const endTime = this.parseTime(dayHours.evening.close);
      intervals.push(...this.generateIntervals(startTime, endTime));
    }

    return intervals;
  }

  /**
   * Parser une heure au format HH:MM
   */
  private static parseTime(timeStr: string): number {
    const parts = timeStr.split(':');
    const hours = parts[0] ? parseInt(parts[0], 10) : 0;
    const minutes = parts[1] ? parseInt(parts[1], 10) : 0;
    return hours * 60 + minutes;
  }

  /**
   * Générer les intervalles de 30 minutes entre deux heures
   */
  private static generateIntervals(startMinutes: number, endMinutes: number): string[] {
    const intervals: string[] = [];

    for (let minutes = startMinutes; minutes < endMinutes; minutes += 30) {
      const hours = Math.floor(minutes / 60);
      const mins = minutes % 60;
      intervals.push(`${hours.toString().padStart(2, '0')}:${mins.toString().padStart(2, '0')}`);
    }

    return intervals;
  }

  /**
   * Compter le nombre de tables disponibles pour un créneau
   */
  private static async countAvailableTables(check: AvailabilityCheck): Promise<number> {
    const reservationDate = new Date(check.date);
    const reservationTime = check.time;

    const reservationFilter: any = {
      date: reservationDate,
      time: reservationTime,
      status: { not: ReservationStatus.CANCELLED },
    };

    if (check.excludeReservationId) {
      reservationFilter.id = { not: check.excludeReservationId };
    }

    const count = await prisma.table.count({
      where: {
        restaurantId: check.restaurantId,
        isActive: true,
        capacity: { gte: check.partySize },
        reservations: {
          none: reservationFilter,
        },
      },
    });

    return count;
  }

  /**
   * Calculer la durée automatique selon le nombre de personnes
   */
  private static calculateDuration(partySize: number): number {
    // 1h30 pour 1-4 personnes, 2h00 pour 5+ personnes
    return partySize <= 4 ? 90 : 120;
  }

  /**
   * Générer un token de gestion unique
   */
  private static generateManagementToken(): string {
    const uuid = require('uuid').v4();
    return `guest_${uuid}`;
  }

  /**
   * Calculer la date d'expiration du token (7 jours)
   */
  private static calculateTokenExpiry(): Date {
    return new Date(Date.now() + 7 * 24 * 60 * 60 * 1000);
  }

  /**
   * Obtenir les heures d'ouverture par défaut
   */
  private static getDefaultOpeningHours(): any {
    return {
      monday: { open: '12:00', close: '14:30', evening: { open: '19:00', close: '22:30' } },
      tuesday: { open: '12:00', close: '14:30', evening: { open: '19:00', close: '22:30' } },
      wednesday: { open: '12:00', close: '14:30', evening: { open: '19:00', close: '22:30' } },
      thursday: { open: '12:00', close: '14:30', evening: { open: '19:00', close: '22:30' } },
      friday: { open: '12:00', close: '14:30', evening: { open: '19:00', close: '22:30' } },
      saturday: { open: '12:00', close: '14:30', evening: { open: '19:00', close: '22:30' } },
      sunday: { closed: true },
    };
  }

  /**
   * Valider les conflits de réservation
   */
  static async validateReservationConflicts(
    date: string | Date,
    time: string,
    duration: number,
    restaurantId: string,
    excludeReservationId?: string
  ): Promise<{ hasConflicts: boolean; conflicts: any[] }> {
    try {
      const reservationDate = new Date(date);
      const startTime = this.parseTime(time);
      const endTime = startTime + duration;

      // Trouver toutes les réservations qui se chevauchent
      const conflictingReservations = await prisma.reservation.findMany({
        where: {
          restaurantId,
          date: reservationDate,
          status: { not: ReservationStatus.CANCELLED },
          ...(excludeReservationId && { id: { not: excludeReservationId } }),
          OR: [
            // Réservation qui commence pendant notre créneau
            {
              time: {
                gte: time,
                lt: this.formatTime(endTime),
              },
            },
            // Réservation qui se termine pendant notre créneau
            {
              time: {
                lte: time,
                gte: this.formatTime(startTime - duration),
              },
            },
          ],
        },
        include: {
          user: { select: { name: true, email: true } },
          table: { select: { number: true, capacity: true } },
        },
      });

      return {
        hasConflicts: conflictingReservations.length > 0,
        conflicts: conflictingReservations,
      };
    } catch (error) {
      console.error('Error validating conflicts:', error);
      throw new CustomError('Failed to validate conflicts', 500);
    }
  }

  /**
   * Formater les minutes en format HH:MM
   */
  private static formatTime(minutes: number): string {
    const hours = Math.floor(minutes / 60);
    const mins = minutes % 60;
    return `${hours.toString().padStart(2, '0')}:${mins.toString().padStart(2, '0')}`;
  }
}

export default ReservationService;
