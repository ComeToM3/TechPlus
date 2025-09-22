import { Request, Response } from 'express';
import { v4 as uuidv4 } from 'uuid';
import prisma from '@/config/database';
import { CustomError, asyncHandler } from '@/middleware/error';
import { PaymentStatus, ReservationStatus } from '@prisma/client';
import ReservationService from '@/services/reservationService';

/**
 * Créer une nouvelle réservation
 */
export const createReservation = asyncHandler(async (req: Request, res: Response) => {
  const {
    date,
    time,
    partySize,
    duration,
    notes,
    specialRequests,
    clientName,
    clientEmail,
    clientPhone,
  } = req.body;

  const userId = req.user?.id;

  // Utiliser le service de réservation pour créer la réservation
  const reservation = await ReservationService.createReservation({
    date,
    time,
    partySize,
    duration,
    notes,
    specialRequests,
    clientName,
    clientEmail,
    clientPhone,
    userId: userId || undefined,
  });

  res.status(201).json({
    success: true,
    message: 'Reservation created successfully',
    data: { reservation },
  });
});

/**
 * Obtenir les réservations de l'utilisateur connecté
 */
export const getUserReservations = asyncHandler(async (req: Request, res: Response) => {
  const userId = req.user?.id;
  const { page = 1, limit = 10, status } = req.query;

  if (!userId) {
    throw new CustomError('User not authenticated', 401);
  }

  const where: any = { userId };
  if (status) {
    where.status = status;
  }

  const reservations = await prisma.reservation.findMany({
    where,
    include: {
      restaurant: {
        select: { id: true, name: true, address: true },
      },
      table: {
        select: { id: true, number: true, capacity: true },
      },
    },
    orderBy: { date: 'desc' },
    skip: (Number(page) - 1) * Number(limit),
    take: Number(limit),
  });

  const total = await prisma.reservation.count({ where });

  res.json({
    success: true,
    data: {
      reservations,
      pagination: {
        page: Number(page),
        limit: Number(limit),
        total,
        pages: Math.ceil(total / Number(limit)),
      },
    },
  });
});

/**
 * Obtenir une réservation par ID
 */
export const getReservationById = asyncHandler(async (req: Request, res: Response) => {
  const { id } = req.params;
  const userId = req.user?.id;

  if (!id) {
    throw new CustomError('Reservation ID is required', 400);
  }

  const reservation = await prisma.reservation.findUnique({
    where: { id },
    include: {
      user: {
        select: { id: true, email: true, name: true },
      },
      restaurant: {
        select: { id: true, name: true, address: true, phone: true },
      },
      table: {
        select: { id: true, number: true, capacity: true, position: true },
      },
    },
  });

  if (!reservation) {
    throw new CustomError('Reservation not found', 404);
  }

  // Vérifier que l'utilisateur peut accéder à cette réservation
  if (userId && reservation.userId !== userId) {
    throw new CustomError('Access denied', 403);
  }

  res.json({
    success: true,
    data: { reservation },
  });
});

/**
 * Modifier une réservation
 */
export const updateReservation = asyncHandler(async (req: Request, res: Response) => {
  const { id } = req.params;
  const userId = req.user?.id;
  const updateData = req.body;

  if (!id) {
    throw new CustomError('Reservation ID is required', 400);
  }

  const existingReservation = await prisma.reservation.findUnique({
    where: { id },
  });

  if (!existingReservation) {
    throw new CustomError('Reservation not found', 404);
  }

  // Vérifier les permissions
  if (userId && existingReservation.userId !== userId) {
    throw new CustomError('Access denied', 403);
  }

  // Vérifier les disponibilités si la date/heure change
  if (updateData.date || updateData.time || updateData.partySize) {
    const newDate = updateData.date || existingReservation.date;
    const newTime = updateData.time || existingReservation.time;
    const newPartySize = updateData.partySize || existingReservation.partySize;

    const isAvailable = await checkAvailability(
      newDate,
      newTime,
      newPartySize,
      existingReservation.restaurantId,
      id // Exclure la réservation actuelle
    );

    if (!isAvailable) {
      throw new CustomError('No tables available for the selected time slot', 409);
    }
  }

  const reservation = await prisma.reservation.update({
    where: { id },
    data: {
      ...updateData,
      ...(updateData.date && { date: new Date(updateData.date) }),
    },
    include: {
      user: {
        select: { id: true, email: true, name: true },
      },
      restaurant: {
        select: { id: true, name: true },
      },
      table: {
        select: { id: true, number: true, capacity: true },
      },
    },
  });

  res.json({
    success: true,
    message: 'Reservation updated successfully',
    data: { reservation },
  });
});

/**
 * Annuler une réservation
 */
export const cancelReservation = asyncHandler(async (req: Request, res: Response) => {
  const { id } = req.params;
  const userId = req.user?.id;
  const { reason } = req.body;

  if (!id) {
    throw new CustomError('Reservation ID is required', 400);
  }

  const reservation = await prisma.reservation.findUnique({
    where: { id },
  });

  if (!reservation) {
    throw new CustomError('Reservation not found', 404);
  }

  // Vérifier les permissions
  if (userId && reservation.userId !== userId) {
    throw new CustomError('Access denied', 403);
  }

  // Vérifier que la réservation peut être annulée
  if (reservation.status === ReservationStatus.CANCELLED) {
    throw new CustomError('Reservation is already cancelled', 400);
  }

  const updatedReservation = await prisma.reservation.update({
    where: { id },
    data: {
      status: ReservationStatus.CANCELLED,
      cancellationReason: reason,
    },
    include: {
      user: {
        select: { id: true, email: true, name: true },
      },
      restaurant: {
        select: { id: true, name: true },
      },
    },
  });

  res.json({
    success: true,
    message: 'Reservation cancelled successfully',
    data: { reservation: updatedReservation },
  });
});

/**
 * Gestion des réservations par token (Guest)
 */
export const getReservationByToken = asyncHandler(async (req: Request, res: Response) => {
  const reservation = (req as any).reservation;

  res.json({
    success: true,
    data: { reservation },
  });
});

export const updateReservationByToken = asyncHandler(async (req: Request, res: Response) => {
  const { token } = req.params;
  const updateData = req.body;

  if (!token) {
    throw new CustomError('Management token is required', 400);
  }

  const existingReservation = await prisma.reservation.findUnique({
    where: { managementToken: token },
  });

  if (!existingReservation) {
    throw new CustomError('Reservation not found', 404);
  }

  // Vérifier que le token n'est pas expiré
  if (existingReservation.tokenExpiresAt && existingReservation.tokenExpiresAt < new Date()) {
    throw new CustomError('Management token has expired', 410);
  }

  // Vérifier les disponibilités si nécessaire
  if (updateData.date || updateData.time || updateData.partySize) {
    const newDate = updateData.date || existingReservation.date;
    const newTime = updateData.time || existingReservation.time;
    const newPartySize = updateData.partySize || existingReservation.partySize;

    const isAvailable = await checkAvailability(
      newDate,
      newTime,
      newPartySize,
      existingReservation.restaurantId,
      existingReservation.id
    );

    if (!isAvailable) {
      throw new CustomError('No tables available for the selected time slot', 409);
    }
  }

  const reservation = await prisma.reservation.update({
    where: { managementToken: token },
    data: {
      ...updateData,
      ...(updateData.date && { date: new Date(updateData.date) }),
    },
    include: {
      restaurant: {
        select: { id: true, name: true, address: true, phone: true },
      },
      table: {
        select: { id: true, number: true, capacity: true, position: true },
      },
    },
  });

  res.json({
    success: true,
    message: 'Reservation updated successfully',
    data: { reservation },
  });
});

export const cancelReservationByToken = asyncHandler(async (req: Request, res: Response) => {
  const { token } = req.params;
  const { reason } = req.body;

  if (!token) {
    throw new CustomError('Management token is required', 400);
  }

  const reservation = await prisma.reservation.findUnique({
    where: { managementToken: token },
  });

  if (!reservation) {
    throw new CustomError('Reservation not found', 404);
  }

  if (reservation.tokenExpiresAt && reservation.tokenExpiresAt < new Date()) {
    throw new CustomError('Management token has expired', 410);
  }

  const updatedReservation = await prisma.reservation.update({
    where: { managementToken: token },
    data: {
      status: ReservationStatus.CANCELLED,
      cancellationReason: reason,
    },
    include: {
      restaurant: {
        select: { id: true, name: true },
      },
    },
  });

  res.json({
    success: true,
    message: 'Reservation cancelled successfully',
    data: { reservation: updatedReservation },
  });
});

/**
 * Fonction utilitaire pour vérifier les disponibilités
 * @deprecated Utiliser ReservationService.checkAvailability à la place
 */
async function checkAvailability(
  date: string | Date,
  time: string,
  partySize: number,
  restaurantId: string,
  excludeReservationId?: string
): Promise<boolean> {
  return ReservationService.checkAvailability({
    date,
    time,
    partySize,
    restaurantId,
    excludeReservationId: excludeReservationId || undefined,
  });
}
