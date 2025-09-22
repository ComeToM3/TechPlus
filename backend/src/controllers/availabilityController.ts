import { Request, Response } from 'express';
import prisma from '@/config/database';
import { CustomError, asyncHandler } from '@/middleware/error';
import { ReservationStatus } from '@prisma/client';
import ReservationService from '@/services/reservationService';

/**
 * Obtenir les créneaux disponibles pour une date donnée
 */
export const getAvailability = asyncHandler(async (req: Request, res: Response) => {
  const { date, partySize = 2 } = req.query;

  if (!date) {
    throw new CustomError('Date parameter is required', 400);
  }

  const targetDate = new Date(date as string);
  const partySizeNum = Number(partySize);

  // Récupérer le restaurant actif
  const restaurant = await prisma.restaurant.findFirst({
    where: { isActive: true },
    select: { id: true, openingHours: true },
  });

  if (!restaurant) {
    throw new CustomError('Restaurant not found', 404);
  }

  // Utiliser le service de réservation pour obtenir les disponibilités
  const dayAvailability = await ReservationService.getDayAvailability(
    targetDate,
    restaurant.id,
    partySizeNum
  );

  res.json({
    success: true,
    data: {
      date: dayAvailability.date,
      partySize: partySizeNum,
      availableSlots: dayAvailability.slots.filter(slot => slot.available).map(slot => slot.time),
      allSlots: dayAvailability.slots,
      restaurant: {
        openingHours: restaurant.openingHours,
      },
    },
  });
});

/**
 * Obtenir les tables disponibles pour une date/heure donnée
 */
export const getAvailableTables = asyncHandler(async (req: Request, res: Response) => {
  const { date, time, partySize = 2 } = req.query;

  if (!date || !time) {
    throw new CustomError('Date and time parameters are required', 400);
  }

  const targetDate = new Date(date as string);
  const targetTime = time as string;
  const partySizeNum = Number(partySize);

  // Trouver les tables disponibles
  const availableTables = await prisma.table.findMany({
    where: {
      isActive: true,
      capacity: { gte: partySizeNum },
      reservations: {
        none: {
          AND: [
            { date: targetDate },
            { time: targetTime },
            { status: { not: ReservationStatus.CANCELLED } },
          ],
        },
      },
    },
    select: {
      id: true,
      number: true,
      capacity: true,
      position: true,
    },
    orderBy: [{ capacity: 'asc' }, { number: 'asc' }],
  });

  res.json({
    success: true,
    data: {
      date: targetDate.toISOString(),
      time: targetTime,
      partySize: partySizeNum,
      availableTables,
      count: availableTables.length,
    },
  });
});

/**
 * Vérifier la disponibilité d'un créneau spécifique
 */
export const checkSlotAvailability = asyncHandler(async (req: Request, res: Response) => {
  const { date, time, partySize = 2 } = req.query;

  if (!date || !time) {
    throw new CustomError('Date and time parameters are required', 400);
  }

  const targetDate = new Date(date as string);
  const targetTime = time as string;
  const partySizeNum = Number(partySize);

  // Vérifier s'il y a des tables disponibles
  const availableTable = await prisma.table.findFirst({
    where: {
      isActive: true,
      capacity: { gte: partySizeNum },
      reservations: {
        none: {
          AND: [
            { date: targetDate },
            { time: targetTime },
            { status: { not: ReservationStatus.CANCELLED } },
          ],
        },
      },
    },
  });

  const isAvailable = !!availableTable;

  res.json({
    success: true,
    data: {
      date: targetDate.toISOString(),
      time: targetTime,
      partySize: partySizeNum,
      isAvailable,
      availableTable: isAvailable
        ? {
            id: availableTable.id,
            number: availableTable.number,
            capacity: availableTable.capacity,
          }
        : null,
    },
  });
});

/**
 * Fonction utilitaire pour générer les créneaux disponibles
 */
async function generateAvailableSlots(
  date: Date,
  daySchedule: any,
  partySize: number
): Promise<string[]> {
  const slots: string[] = [];
  const bufferTime = 30; // 30 minutes entre les réservations
  const slotDuration = partySize <= 4 ? 90 : 120; // 1h30 ou 2h selon le nombre de personnes

  // Heures d'ouverture du midi
  if (daySchedule.open && daySchedule.close) {
    const lunchSlots = generateTimeSlots(
      daySchedule.open,
      daySchedule.close,
      slotDuration,
      bufferTime
    );
    slots.push(...lunchSlots);
  }

  // Heures d'ouverture du soir
  if (daySchedule.evening?.open && daySchedule.evening?.close) {
    const eveningSlots = generateTimeSlots(
      daySchedule.evening.open,
      daySchedule.evening.close,
      slotDuration,
      bufferTime
    );
    slots.push(...eveningSlots);
  }

  // Vérifier la disponibilité réelle de chaque créneau
  const availableSlots: string[] = [];

  for (const slot of slots) {
    const isAvailable = await checkSlotAvailabilityInDB(date, slot, partySize);
    if (isAvailable) {
      availableSlots.push(slot);
    }
  }

  return availableSlots;
}

/**
 * Générer les créneaux horaires entre deux heures
 */
function generateTimeSlots(
  startTime: string,
  endTime: string,
  duration: number,
  bufferTime: number
): string[] {
  const slots: string[] = [];

  const start = parseTime(startTime);
  const end = parseTime(endTime);
  const slotDurationMinutes = duration + bufferTime;

  let current = start;

  while (current + slotDurationMinutes <= end) {
    slots.push(formatTime(current));
    current += slotDurationMinutes;
  }

  return slots;
}

/**
 * Parser une heure au format HH:MM en minutes
 */
function parseTime(time: string): number {
  const parts = time.split(':');
  const hours = parts[0] ? parseInt(parts[0], 10) : 0;
  const minutes = parts[1] ? parseInt(parts[1], 10) : 0;
  return hours * 60 + minutes;
}

/**
 * Formater des minutes en format HH:MM
 */
function formatTime(minutes: number): string {
  const hours = Math.floor(minutes / 60);
  const mins = minutes % 60;
  return `${hours.toString().padStart(2, '0')}:${mins.toString().padStart(2, '0')}`;
}

/**
 * Vérifier la disponibilité d'un créneau en base de données
 */
async function checkSlotAvailabilityInDB(
  date: Date,
  time: string,
  partySize: number
): Promise<boolean> {
  const availableTable = await prisma.table.findFirst({
    where: {
      isActive: true,
      capacity: { gte: partySize },
      reservations: {
        none: {
          AND: [{ date }, { time }, { status: { not: ReservationStatus.CANCELLED } }],
        },
      },
    },
  });

  return !!availableTable;
}
