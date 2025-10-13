import { PrismaClient, ReservationStatus } from '@prisma/client';
import { ReservationRepository, CreateReservationData, UpdateReservationData, ReservationFilters, PaginationOptions, PaginatedResult } from '@/domain/repositories/ReservationRepository';
import { Reservation } from '@/domain/entities/Reservation';

export class PrismaReservationRepositoryNew implements ReservationRepository {
  private prisma: PrismaClient;

  constructor(prisma: PrismaClient) {
    this.prisma = prisma;
  }

  async findById(id: string): Promise<Reservation | null> {
    const reservation = await this.prisma.reservation.findUnique({
      where: { id },
      include: {
        user: { select: { id: true, email: true, name: true } },
        restaurant: { select: { id: true, name: true, address: true, phone: true } },
        table: { select: { id: true, number: true, capacity: true, position: true } },
      },
    });
    return reservation ? Reservation.fromPrisma(reservation) : null;
  }

  async findByManagementToken(token: string): Promise<Reservation | null> {
    const reservation = await this.prisma.reservation.findUnique({
      where: { managementToken: token },
      include: {
        restaurant: { select: { id: true, name: true, address: true, phone: true } },
        table: { select: { id: true, number: true, capacity: true, position: true } },
      },
    });
    return reservation ? Reservation.fromPrisma(reservation) : null;
  }

  async findByUserId(userId: string, filters?: ReservationFilters, pagination?: PaginationOptions): Promise<PaginatedResult<Reservation>> {
    const where: any = { userId };
    
    if (filters) {
      if (filters.status) where.status = filters.status;
      if (filters.date) where.date = filters.date;
      if (filters.dateFrom || filters.dateTo) {
        where.date = {};
        if (filters.dateFrom) where.date.gte = filters.dateFrom;
        if (filters.dateTo) where.date.lte = filters.dateTo;
      }
      if (filters.partySize) where.partySize = filters.partySize;
      if (filters.requiresPayment !== undefined) where.requiresPayment = filters.requiresPayment;
    }

    const skip = pagination ? (pagination.page - 1) * pagination.limit : 0;
    const take = pagination?.limit || 10;

    const [reservations, total] = await Promise.all([
      this.prisma.reservation.findMany({
        where,
        include: {
          restaurant: { select: { id: true, name: true, address: true } },
          table: { select: { id: true, number: true, capacity: true } },
        },
        orderBy: { date: 'desc' },
        skip,
        take,
      }),
      this.prisma.reservation.count({ where }),
    ]);

    return {
      data: reservations.map(r => Reservation.fromPrisma(r)),
      pagination: {
        page: pagination?.page || 1,
        limit: pagination?.limit || 10,
        total,
        pages: Math.ceil(total / (pagination?.limit || 10)),
      },
    };
  }

  async findByRestaurantId(restaurantId: string, filters?: ReservationFilters, pagination?: PaginationOptions): Promise<PaginatedResult<Reservation>> {
    const where: any = { restaurantId };
    
    if (filters) {
      if (filters.userId) where.userId = filters.userId;
      if (filters.status) where.status = filters.status;
      if (filters.date) where.date = filters.date;
      if (filters.dateFrom || filters.dateTo) {
        where.date = {};
        if (filters.dateFrom) where.date.gte = filters.dateFrom;
        if (filters.dateTo) where.date.lte = filters.dateTo;
      }
      if (filters.partySize) where.partySize = filters.partySize;
      if (filters.requiresPayment !== undefined) where.requiresPayment = filters.requiresPayment;
    }

    const skip = pagination ? (pagination.page - 1) * pagination.limit : 0;
    const take = pagination?.limit || 10;

    const [reservations, total] = await Promise.all([
      this.prisma.reservation.findMany({
        where,
        include: {
          user: { select: { id: true, email: true, name: true } },
          table: { select: { id: true, number: true, capacity: true } },
        },
        orderBy: { date: 'desc' },
        skip,
        take,
      }),
      this.prisma.reservation.count({ where }),
    ]);

    return {
      data: reservations.map(r => Reservation.fromPrisma(r)),
      pagination: {
        page: pagination?.page || 1,
        limit: pagination?.limit || 10,
        total,
        pages: Math.ceil(total / (pagination?.limit || 10)),
      },
    };
  }

  async create(data: CreateReservationData): Promise<Reservation> {
    const reservation = await this.prisma.reservation.create({
      data: {
        date: data.date,
        time: data.time,
        duration: data.duration,
        partySize: data.partySize,
        status: data.status,
        requiresPayment: data.requiresPayment,
        depositAmount: data.depositAmount,
        notes: data.notes || null,
        specialRequests: data.specialRequests || null,
        clientName: data.clientName || null,
        clientEmail: data.clientEmail || null,
        clientPhone: data.clientPhone || null,
        managementToken: data.managementToken || null,
        tokenExpiresAt: data.tokenExpiresAt || null,
        restaurantId: data.restaurantId,
        tableId: data.tableId || null,
        ...(data.userId && { userId: data.userId }),
      },
      include: {
        user: { select: { id: true, email: true, name: true } },
        restaurant: { select: { id: true, name: true, address: true, phone: true } },
        table: { select: { id: true, number: true, capacity: true, position: true } },
      },
    });

    return Reservation.fromPrisma(reservation);
  }

  async update(id: string, data: UpdateReservationData): Promise<Reservation> {
    const reservation = await this.prisma.reservation.update({
      where: { id },
      data: {
        ...(data.date && { date: data.date }),
        ...(data.time && { time: data.time }),
        ...(data.duration && { duration: data.duration }),
        ...(data.partySize && { partySize: data.partySize }),
        ...(data.status && { status: data.status }),
        ...(data.requiresPayment !== undefined && { requiresPayment: data.requiresPayment }),
        ...(data.depositAmount && { depositAmount: data.depositAmount }),
        ...(data.notes !== undefined && { notes: data.notes }),
        ...(data.specialRequests !== undefined && { specialRequests: data.specialRequests }),
        ...(data.clientName !== undefined && { clientName: data.clientName }),
        ...(data.clientEmail !== undefined && { clientEmail: data.clientEmail }),
        ...(data.clientPhone !== undefined && { clientPhone: data.clientPhone }),
        ...(data.cancellationReason !== undefined && { cancellationReason: data.cancellationReason }),
        ...(data.tableId !== undefined && { tableId: data.tableId }),
      },
      include: {
        user: { select: { id: true, email: true, name: true } },
        restaurant: { select: { id: true, name: true, address: true, phone: true } },
        table: { select: { id: true, number: true, capacity: true, position: true } },
      },
    });

    return Reservation.fromPrisma(reservation);
  }

  async delete(id: string): Promise<void> {
    await this.prisma.reservation.delete({
      where: { id },
    });
  }

  async findConflictingReservations(date: Date, time: string, duration: number, restaurantId: string, excludeReservationId?: string): Promise<Reservation[]> {
    const startTime = this.parseTime(time);
    const endTime = startTime + duration;

    const where: any = {
      restaurantId,
      date,
      status: { not: ReservationStatus.CANCELLED },
      ...(excludeReservationId && { id: { not: excludeReservationId } }),
      OR: [
        {
          time: {
            gte: time,
            lt: this.formatTime(endTime),
          },
        },
        {
          time: {
            lte: time,
            gte: this.formatTime(startTime - duration),
          },
        },
      ],
    };

    const reservations = await this.prisma.reservation.findMany({
      where,
      include: {
        user: { select: { name: true, email: true } },
        table: { select: { number: true, capacity: true } },
      },
    });

    return reservations.map(r => Reservation.fromPrisma(r));
  }

  private parseTime(timeStr: string): number {
    const parts = timeStr.split(':');
    const hours = parts[0] ? parseInt(parts[0], 10) : 0;
    const minutes = parts[1] ? parseInt(parts[1], 10) : 0;
    return hours * 60 + minutes;
  }

  private formatTime(minutes: number): string {
    const hours = Math.floor(minutes / 60);
    const mins = minutes % 60;
    return `${hours.toString().padStart(2, '0')}:${mins.toString().padStart(2, '0')}`;
  }
}
