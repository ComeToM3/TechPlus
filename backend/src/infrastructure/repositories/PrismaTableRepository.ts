import { PrismaClient, ReservationStatus } from '@prisma/client';
import { TableRepository, TableFilters } from '@/domain/repositories/TableRepository';
import { Table } from '@/domain/entities/Table';

export class PrismaTableRepository implements TableRepository {
  private prisma: PrismaClient;

  constructor(prisma: PrismaClient) {
    this.prisma = prisma;
  }

  async findById(id: string): Promise<Table | null> {
    const table = await this.prisma.table.findUnique({
      where: { id },
    });
    return table ? Table.fromPrisma(table) : null;
  }

  async findByRestaurantId(restaurantId: string, filters?: TableFilters): Promise<Table[]> {
    const where: any = { restaurantId };
    
    if (filters) {
      if (filters.isActive !== undefined) where.isActive = filters.isActive;
      if (filters.minCapacity) where.capacity = { gte: filters.minCapacity };
      if (filters.maxCapacity) where.capacity = { ...where.capacity, lte: filters.maxCapacity };
    }

    const tables = await this.prisma.table.findMany({
      where,
      orderBy: [
        { capacity: 'asc' },
        { number: 'asc' },
      ],
    });

    return tables.map(t => Table.fromPrisma(t));
  }

  async findAvailableTable(date: Date, time: string, partySize: number, restaurantId: string, excludeReservationId?: string): Promise<Table | null> {
    const reservationFilter: any = {
      date,
      time,
      status: { not: ReservationStatus.CANCELLED },
    };

    if (excludeReservationId) {
      reservationFilter.id = { not: excludeReservationId };
    }

    const table = await this.prisma.table.findFirst({
      where: {
        restaurantId,
        isActive: true,
        capacity: { gte: partySize },
        reservations: {
          none: reservationFilter,
        },
      },
      orderBy: [
        { capacity: 'asc' },
        { number: 'asc' },
      ],
    });

    return table ? Table.fromPrisma(table) : null;
  }

  async countAvailableTables(date: Date, time: string, partySize: number, restaurantId: string, excludeReservationId?: string): Promise<number> {
    const reservationFilter: any = {
      date,
      time,
      status: { not: ReservationStatus.CANCELLED },
    };

    if (excludeReservationId) {
      reservationFilter.id = { not: excludeReservationId };
    }

    const count = await this.prisma.table.count({
      where: {
        restaurantId,
        isActive: true,
        capacity: { gte: partySize },
        reservations: {
          none: reservationFilter,
        },
      },
    });

    return count;
  }
}


