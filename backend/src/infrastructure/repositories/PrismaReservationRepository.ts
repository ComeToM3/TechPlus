/**
 * Implémentation Prisma du ReservationRepository pour les tokens de gestion
 */

import { PrismaClient } from '@prisma/client';
import { ReservationRepository } from '../../domain/use-cases/auth/LoginWithTokenUseCase';

export class PrismaReservationRepository implements ReservationRepository {
  constructor(private readonly prisma: PrismaClient) {}

  async findByManagementToken(token: string): Promise<{
    id: string;
    clientEmail?: string;
    clientName?: string;
    tokenExpiresAt?: Date;
    status: string;
    restaurant: { id: string; name: string };
    date: Date;
    time: string;
    partySize: number;
  } | null> {
    const reservation = await this.prisma.reservation.findUnique({
      where: { managementToken: token },
      include: {
        restaurant: { select: { id: true, name: true } }
      }
    });

    if (!reservation) {
      return null;
    }

    const result: any = {
      id: reservation.id,
      status: reservation.status as string,
      restaurant: reservation.restaurant,
      date: reservation.date,
      time: reservation.time,
      partySize: reservation.partySize
    };

    if (reservation.clientEmail) {
      result.clientEmail = reservation.clientEmail;
    }
    if (reservation.clientName) {
      result.clientName = reservation.clientName;
    }
    if (reservation.tokenExpiresAt) {
      result.tokenExpiresAt = reservation.tokenExpiresAt;
    }

    return result;
  }
}
