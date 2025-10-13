import { PrismaClient } from '@prisma/client';
import { Table } from '../../domain/entities/Table';
import { TableMetadata } from '../../domain/entities/TableMetadata';
import { TableStatistics } from '../../domain/entities/TableStatistics';
import { 
  TableRepositoryExtended, 
  CreateTableData, 
  UpdateTableData, 
  TableFilters, 
  BatchUpdateData 
} from '../../domain/repositories/TableRepositoryExtended';

export class PrismaTableRepositoryExtended implements TableRepositoryExtended {
  constructor(private prisma: PrismaClient) {}

  async findById(id: string): Promise<Table | null> {
    const table = await this.prisma.table.findUnique({
      where: { id },
      include: {
        restaurant: true,
        reservations: {
          where: {
            date: { gte: new Date() },
          },
          select: {
            id: true,
            date: true,
            time: true,
            partySize: true,
            status: true,
            clientName: true,
            clientEmail: true,
          },
          orderBy: { date: 'asc' },
        },
      },
    });

    if (!table) return null;

    return new Table({
      id: table.id,
      number: table.number.toString(),
      capacity: table.capacity,
      position: table.position || undefined,
      isActive: table.isActive,
      restaurantId: table.restaurantId,
      createdAt: table.createdAt,
      updatedAt: table.updatedAt,
    });
  }

  async findByRestaurantId(restaurantId: string, filters?: TableFilters): Promise<Table[]> {
    const whereClause: any = { restaurantId };
    
    if (filters?.isActive !== undefined) {
      whereClause.isActive = filters.isActive;
    }
    
    if (filters?.minCapacity !== undefined) {
      whereClause.capacity = { gte: filters.minCapacity };
    }
    
    if (filters?.maxCapacity !== undefined) {
      whereClause.capacity = { ...whereClause.capacity, lte: filters.maxCapacity };
    }

    const tables = await this.prisma.table.findMany({
      where: whereClause,
      include: {
        reservations: {
          where: {
            date: { gte: new Date() },
            status: { in: ['PENDING', 'CONFIRMED'] },
          },
          select: {
            id: true,
            date: true,
            time: true,
            partySize: true,
            status: true,
          },
        },
      },
      orderBy: { number: 'asc' },
    });

    return tables.map(table => new Table({
      id: table.id,
      number: table.number.toString(),
      capacity: table.capacity,
      position: table.position || undefined,
      isActive: table.isActive,
      restaurantId: table.restaurantId,
      createdAt: table.createdAt,
      updatedAt: table.updatedAt,
    }));
  }

  async create(data: CreateTableData): Promise<Table> {
    const table = await this.prisma.table.create({
      data: {
        number: data.number,
        capacity: data.capacity,
        position: data.position || null,
        status: (data.status as any) || 'AVAILABLE',
        restaurantId: data.restaurantId,
      },
      include: {
        restaurant: true,
      },
    });

    return new Table({
      id: table.id,
      number: table.number.toString(),
      capacity: table.capacity,
      position: table.position || undefined,
      isActive: table.isActive,
      restaurantId: table.restaurantId,
      createdAt: table.createdAt,
      updatedAt: table.updatedAt,
    });
  }

  async update(id: string, data: UpdateTableData): Promise<Table> {
    const updateData: any = {};
    
    if (data.number !== undefined) updateData.number = data.number;
    if (data.capacity !== undefined) updateData.capacity = data.capacity;
    if (data.position !== undefined) updateData.position = data.position;
    if (data.isActive !== undefined) updateData.isActive = data.isActive;

    const table = await this.prisma.table.update({
      where: { id },
      data: updateData,
      include: {
        restaurant: true,
        reservations: {
          where: { date: { gte: new Date() } },
          select: {
            id: true,
            date: true,
            time: true,
            partySize: true,
            status: true,
          },
        },
      },
    });

    return new Table({
      id: table.id,
      number: table.number.toString(),
      capacity: table.capacity,
      position: table.position || undefined,
      isActive: table.isActive,
      restaurantId: table.restaurantId,
      createdAt: table.createdAt,
      updatedAt: table.updatedAt,
    });
  }

  async delete(id: string): Promise<void> {
    await this.prisma.table.delete({
      where: { id },
    });
  }

  async findByNumber(restaurantId: string, number: number): Promise<Table | null> {
    const table = await this.prisma.table.findFirst({
      where: {
        restaurantId,
        number,
      },
    });

    if (!table) return null;

    return new Table({
      id: table.id,
      number: table.number.toString(),
      capacity: table.capacity,
      position: table.position || undefined,
      isActive: table.isActive,
      restaurantId: table.restaurantId,
      createdAt: table.createdAt,
      updatedAt: table.updatedAt,
    });
  }

  async findAvailableTable(date: Date, time: string, partySize: number, restaurantId: string, excludeReservationId?: string): Promise<Table | null> {
    // Cette logique serait implémentée selon les besoins spécifiques
    // Pour l'instant, retournons null
    return null;
  }

  async countAvailableTables(date: Date, time: string, partySize: number, restaurantId: string, excludeReservationId?: string): Promise<number> {
    // Cette logique serait implémentée selon les besoins spécifiques
    // Pour l'instant, retournons 0
    return 0;
  }

  async getMetadata(restaurantId: string): Promise<TableMetadata[]> {
    const tables = await this.prisma.table.findMany({
      where: { restaurantId },
      select: {
        id: true,
        number: true,
        capacity: true,
        isActive: true,
        position: true,
        createdAt: true,
        updatedAt: true,
      },
    });

    return tables.map(table => new TableMetadata({
      id: table.id,
      number: table.number.toString(),
      capacity: table.capacity,
      isActive: table.isActive,
      position: table.position || undefined,
      createdAt: table.createdAt,
      updatedAt: table.updatedAt,
    }));
  }

  async getTableMetadata(id: string): Promise<TableMetadata | null> {
    const table = await this.prisma.table.findUnique({
      where: { id },
      select: {
        id: true,
        number: true,
        capacity: true,
        isActive: true,
        position: true,
        createdAt: true,
        updatedAt: true,
      },
    });

    if (!table) return null;

    return new TableMetadata({
      id: table.id,
      number: table.number.toString(),
      capacity: table.capacity,
      isActive: table.isActive,
      position: table.position || undefined,
      createdAt: table.createdAt,
      updatedAt: table.updatedAt,
    });
  }

  async getStatistics(restaurantId: string): Promise<TableStatistics> {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    const [
      totalTables,
      activeTables,
      inactiveTables,
      totalCapacity,
      todayReservations,
      upcomingReservations,
      capacityBySize,
    ] = await Promise.all([
      this.prisma.table.count({
        where: { restaurantId },
      }),
      this.prisma.table.count({
        where: { restaurantId, isActive: true },
      }),
      this.prisma.table.count({
        where: { restaurantId, isActive: false },
      }),
      this.prisma.table.aggregate({
        where: { restaurantId, isActive: true },
        _sum: { capacity: true },
      }),
      this.prisma.reservation.count({
        where: {
          restaurantId,
          date: { gte: today, lt: tomorrow },
          status: { in: ['PENDING', 'CONFIRMED'] },
        },
      }),
      this.prisma.reservation.count({
        where: {
          restaurantId,
          date: { gte: tomorrow },
          status: { in: ['PENDING', 'CONFIRMED'] },
        },
      }),
      this.prisma.table.groupBy({
        by: ['capacity'],
        where: { restaurantId, isActive: true },
        _count: { capacity: true },
        orderBy: { capacity: 'asc' },
      }),
    ]);

    return new TableStatistics({
      overview: {
        totalTables,
        activeTables,
        inactiveTables,
        totalCapacity: totalCapacity._sum.capacity || 0,
        averageCapacity: activeTables > 0 ? Math.round((totalCapacity._sum.capacity || 0) / activeTables) : 0,
      },
      reservations: {
        todayReservations,
        upcomingReservations,
        totalReservations: todayReservations + upcomingReservations,
      },
      capacityDistribution: capacityBySize.map(item => ({
        capacity: item.capacity,
        count: item._count.capacity,
      })),
      lastUpdated: new Date().toISOString(),
    });
  }

  async getTableStats(id: string): Promise<{
    totalReservations: number;
    todayReservations: number;
    tableId: string;
  }> {
    const stats = await this.prisma.reservation.aggregate({
      where: { tableId: id },
      _count: { id: true },
    });

    const todayReservations = await this.prisma.reservation.count({
      where: {
        tableId: id,
        date: {
          gte: new Date(new Date().setHours(0, 0, 0, 0)),
          lt: new Date(new Date().setHours(23, 59, 59, 999)),
        },
      },
    });

    return {
      totalReservations: stats._count?.id || 0,
      todayReservations,
      tableId: id,
    };
  }

  async batchUpdate(updates: BatchUpdateData[]): Promise<{
    successful: number;
    failed: number;
    total: number;
  }> {
    const results = await Promise.allSettled(
      updates.map(async (update) => {
        const { id, data } = update;
        return await this.prisma.table.update({
          where: { id },
          data,
          select: { id: true, number: true },
        });
      })
    );

    const successful = results.filter(r => r.status === 'fulfilled').length;
    const failed = results.filter(r => r.status === 'rejected').length;

    return {
      successful,
      failed,
      total: updates.length,
    };
  }

  async updateStatus(id: string, isActive: boolean): Promise<Table> {
    const table = await this.prisma.table.update({
      where: { id },
      data: { isActive },
      include: {
        restaurant: true,
      },
    });

    return new Table({
      id: table.id,
      number: table.number.toString(),
      capacity: table.capacity,
      position: table.position || undefined,
      isActive: table.isActive,
      restaurantId: table.restaurantId,
      createdAt: table.createdAt,
      updatedAt: table.updatedAt,
    });
  }

  async updateCapacity(id: string, capacity: number): Promise<Table> {
    const table = await this.prisma.table.update({
      where: { id },
      data: { capacity },
    });

    return new Table({
      id: table.id,
      number: table.number.toString(),
      capacity: table.capacity,
      position: table.position || undefined,
      isActive: table.isActive,
      restaurantId: table.restaurantId,
      createdAt: table.createdAt,
      updatedAt: table.updatedAt,
    });
  }

  async updatePosition(id: string, position: string | null): Promise<Table> {
    const table = await this.prisma.table.update({
      where: { id },
      data: { position },
    });

    return new Table({
      id: table.id,
      number: table.number.toString(),
      capacity: table.capacity,
      position: table.position || undefined,
      isActive: table.isActive,
      restaurantId: table.restaurantId,
      createdAt: table.createdAt,
      updatedAt: table.updatedAt,
    });
  }

  async updateNumber(id: string, number: number): Promise<Table> {
    const table = await this.prisma.table.update({
      where: { id },
      data: { number },
    });

    return new Table({
      id: table.id,
      number: table.number.toString(),
      capacity: table.capacity,
      position: table.position || undefined,
      isActive: table.isActive,
      restaurantId: table.restaurantId,
      createdAt: table.createdAt,
      updatedAt: table.updatedAt,
    });
  }

  async canDeleteTable(id: string): Promise<boolean> {
    const reservations = await this.prisma.reservation.count({
      where: {
        tableId: id,
        date: { gte: new Date() },
        status: { in: ['PENDING', 'CONFIRMED'] },
      },
    });

    return reservations === 0;
  }

  async hasFutureReservations(id: string): Promise<boolean> {
    const count = await this.prisma.reservation.count({
      where: {
        tableId: id,
        date: { gte: new Date() },
      },
    });

    return count > 0;
  }
}
