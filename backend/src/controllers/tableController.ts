import { Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';
import logger from '@/utils/logger';

const prisma = new PrismaClient();

/**
 * @route GET /api/admin/tables
 * @description Get all tables for the restaurant
 * @access Admin only
 */
export const getTables = async (req: Request, res: Response): Promise<void> => {
  try {
    const user = (req as any).user;
    if (!user || (user.role !== 'ADMIN' && user.role !== 'SUPER_ADMIN')) {
      res.status(403).json({
        success: false,
        message: 'Access denied. Admin privileges required.',
      });
      return;
    }

    // Récupérer le restaurant
    const restaurant = await prisma.restaurant.findFirst({
      where: { isActive: true },
    });

    if (!restaurant) {
      res.status(404).json({
        success: false,
        message: 'Restaurant not found',
      });
      return;
    }

    const tables = await prisma.table.findMany({
      where: { restaurantId: restaurant.id },
      include: {
        reservations: {
          where: {
            date: {
              gte: new Date(),
            },
            status: {
              in: ['PENDING', 'CONFIRMED'],
            },
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

    logger.info('Tables retrieved', {
      userId: user.id,
      restaurantId: restaurant.id,
      tableCount: tables.length,
      ip: req.ip,
    });

    res.status(200).json({
      success: true,
      data: tables,
    });
  } catch (error) {
    logger.error('Failed to get tables', {
      error: error instanceof Error ? error.message : 'Unknown error',
      stack: error instanceof Error ? error.stack : undefined,
    });

    res.status(500).json({
      success: false,
      message: 'Failed to get tables',
      error: error instanceof Error ? error.message : 'Unknown error',
    });
  }
};

/**
 * @route GET /api/admin/tables/:id
 * @description Get a specific table by ID
 * @access Admin only
 */
export const getTableById = async (req: Request, res: Response): Promise<void> => {
  try {
    const user = (req as any).user;
    if (!user || (user.role !== 'ADMIN' && user.role !== 'SUPER_ADMIN')) {
      res.status(403).json({
        success: false,
        message: 'Access denied. Admin privileges required.',
      });
      return;
    }

    const { id } = req.params;

    const table = await prisma.table.findUnique({
      where: { id: id! },
      include: {
        restaurant: true,
        reservations: {
          where: {
            date: {
              gte: new Date(),
            },
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

    if (!table) {
      res.status(404).json({
        success: false,
        message: 'Table not found',
      });
      return;
    }

    logger.info('Table retrieved', {
      userId: user.id,
      tableId: id,
      ip: req.ip,
    });

    res.status(200).json({
      success: true,
      data: table,
    });
  } catch (error) {
    logger.error('Failed to get table', {
      error: error instanceof Error ? error.message : 'Unknown error',
      stack: error instanceof Error ? error.stack : undefined,
    });

    res.status(500).json({
      success: false,
      message: 'Failed to get table',
      error: error instanceof Error ? error.message : 'Unknown error',
    });
  }
};

/**
 * @route POST /api/admin/tables
 * @description Create a new table
 * @access Admin only
 */
export const createTable = async (req: Request, res: Response): Promise<void> => {
  try {
    const user = (req as any).user;
    if (!user || (user.role !== 'ADMIN' && user.role !== 'SUPER_ADMIN')) {
      res.status(403).json({
        success: false,
        message: 'Access denied. Admin privileges required.',
      });
      return;
    }

    const { number, capacity, position } = req.body;

    // Validation
    if (!number || !capacity) {
      res.status(400).json({
        success: false,
        message: 'Number and capacity are required',
      });
      return;
    }

    if (capacity < 1 || capacity > 20) {
      res.status(400).json({
        success: false,
        message: 'Capacity must be between 1 and 20',
      });
      return;
    }

    // Récupérer le restaurant
    const restaurant = await prisma.restaurant.findFirst({
      where: { isActive: true },
    });

    if (!restaurant) {
      res.status(404).json({
        success: false,
        message: 'Restaurant not found',
      });
      return;
    }

    // Vérifier si le numéro de table existe déjà
    const existingTable = await prisma.table.findFirst({
      where: {
        restaurantId: restaurant.id,
        number: parseInt(number),
      },
    });

    if (existingTable) {
      res.status(400).json({
        success: false,
        message: 'Table number already exists',
      });
      return;
    }

    const table = await prisma.table.create({
      data: {
        number: parseInt(number),
        capacity: parseInt(capacity),
        position: position || null,
        restaurantId: restaurant.id,
      },
      include: {
        restaurant: true,
      },
    });

    logger.info('Table created', {
      userId: user.id,
      restaurantId: restaurant.id,
      tableId: table.id,
      tableNumber: table.number,
      ip: req.ip,
    });

    res.status(201).json({
      success: true,
      data: table,
      message: 'Table created successfully',
    });
  } catch (error) {
    logger.error('Failed to create table', {
      error: error instanceof Error ? error.message : 'Unknown error',
      stack: error instanceof Error ? error.stack : undefined,
    });

    res.status(500).json({
      success: false,
      message: 'Failed to create table',
      error: error instanceof Error ? error.message : 'Unknown error',
    });
  }
};

/**
 * @route PUT /api/admin/tables/:id
 * @description Update a table
 * @access Admin only
 */
export const updateTable = async (req: Request, res: Response): Promise<void> => {
  try {
    const user = (req as any).user;
    if (!user || (user.role !== 'ADMIN' && user.role !== 'SUPER_ADMIN')) {
      res.status(403).json({
        success: false,
        message: 'Access denied. Admin privileges required.',
      });
      return;
    }

    const { id } = req.params;
    const { number, capacity, position, isActive } = req.body;

    // Vérifier si la table existe
    const existingTable = await prisma.table.findUnique({
      where: { id: id! },
    });

    if (!existingTable) {
      res.status(404).json({
        success: false,
        message: 'Table not found',
      });
      return;
    }

    // Validation
    if (capacity && (capacity < 1 || capacity > 20)) {
      res.status(400).json({
        success: false,
        message: 'Capacity must be between 1 and 20',
      });
      return;
    }

    // Vérifier si le nouveau numéro existe déjà (si changé)
    if (number && number !== existingTable.number) {
      const duplicateTable = await prisma.table.findFirst({
        where: {
          restaurantId: existingTable.restaurantId,
          number: parseInt(number),
          id: { not: id! },
        },
      });

      if (duplicateTable) {
        res.status(400).json({
          success: false,
          message: 'Table number already exists',
        });
        return;
      }
    }

    const updateData: any = {};
    if (number !== undefined) updateData.number = parseInt(number);
    if (capacity !== undefined) updateData.capacity = parseInt(capacity);
    if (position !== undefined) updateData.position = position;
    if (isActive !== undefined) updateData.isActive = isActive;

    const table = await prisma.table.update({
      where: { id: id! },
      data: updateData,
      include: {
        restaurant: true,
        reservations: {
          where: {
            date: {
              gte: new Date(),
            },
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
    });

    logger.info('Table updated', {
      userId: user.id,
      tableId: id,
      tableNumber: table.number,
      ip: req.ip,
    });

    res.status(200).json({
      success: true,
      data: table,
      message: 'Table updated successfully',
    });
  } catch (error) {
    logger.error('Failed to update table', {
      error: error instanceof Error ? error.message : 'Unknown error',
      stack: error instanceof Error ? error.stack : undefined,
    });

    res.status(500).json({
      success: false,
      message: 'Failed to update table',
      error: error instanceof Error ? error.message : 'Unknown error',
    });
  }
};

/**
 * @route DELETE /api/admin/tables/:id
 * @description Delete a table
 * @access Admin only
 */
export const deleteTable = async (req: Request, res: Response): Promise<void> => {
  try {
    const user = (req as any).user;
    if (!user || (user.role !== 'ADMIN' && user.role !== 'SUPER_ADMIN')) {
      res.status(403).json({
        success: false,
        message: 'Access denied. Admin privileges required.',
      });
      return;
    }

    const { id } = req.params;

    // Vérifier si la table existe
    const existingTable = await prisma.table.findUnique({
      where: { id: id! },
      include: {
        reservations: {
          where: {
            date: {
              gte: new Date(),
            },
            status: {
              in: ['PENDING', 'CONFIRMED'],
            },
          },
        },
      },
    });

    if (!existingTable) {
      res.status(404).json({
        success: false,
        message: 'Table not found',
      });
      return;
    }

    // Vérifier s'il y a des réservations futures
    if (existingTable.reservations.length > 0) {
      res.status(400).json({
        success: false,
        message: 'Cannot delete table with future reservations',
      });
      return;
    }

    await prisma.table.delete({
      where: { id: id! },
    });

    logger.info('Table deleted', {
      userId: user.id,
      tableId: id,
      tableNumber: existingTable.number,
      ip: req.ip,
    });

    res.status(200).json({
      success: true,
      message: 'Table deleted successfully',
    });
  } catch (error) {
    logger.error('Failed to delete table', {
      error: error instanceof Error ? error.message : 'Unknown error',
      stack: error instanceof Error ? error.stack : undefined,
    });

    res.status(500).json({
      success: false,
      message: 'Failed to delete table',
      error: error instanceof Error ? error.message : 'Unknown error',
    });
  }
};

/**
 * @route PUT /api/admin/tables/:id/status
 * @description Update table status (active/inactive)
 * @access Admin only
 */
export const updateTableStatus = async (req: Request, res: Response): Promise<void> => {
  try {
    const user = (req as any).user;
    if (!user || (user.role !== 'ADMIN' && user.role !== 'SUPER_ADMIN')) {
      res.status(403).json({
        success: false,
        message: 'Access denied. Admin privileges required.',
      });
      return;
    }

    const { id } = req.params;
    const { isActive } = req.body;

    if (typeof isActive !== 'boolean') {
      res.status(400).json({
        success: false,
        message: 'isActive must be a boolean value',
      });
      return;
    }

    // Vérifier si la table existe
    const existingTable = await prisma.table.findUnique({
      where: { id: id! },
    });

    if (!existingTable) {
      res.status(404).json({
        success: false,
        message: 'Table not found',
      });
      return;
    }

    const table = await prisma.table.update({
      where: { id: id! },
      data: { isActive },
      include: {
        restaurant: true,
      },
    });

    logger.info('Table status updated', {
      userId: user.id,
      tableId: id,
      tableNumber: table.number,
      isActive,
      ip: req.ip,
    });

    res.status(200).json({
      success: true,
      data: table,
      message: `Table ${isActive ? 'activated' : 'deactivated'} successfully`,
    });
  } catch (error) {
    logger.error('Failed to update table status', {
      error: error instanceof Error ? error.message : 'Unknown error',
      stack: error instanceof Error ? error.stack : undefined,
    });

    res.status(500).json({
      success: false,
      message: 'Failed to update table status',
      error: error instanceof Error ? error.message : 'Unknown error',
    });
  }
};

/**
 * @route GET /api/admin/tables/statistics
 * @description Get table statistics
 * @access Admin only
 */
export const getTableStatistics = async (req: Request, res: Response): Promise<void> => {
  try {
    const user = (req as any).user;
    if (!user || (user.role !== 'ADMIN' && user.role !== 'SUPER_ADMIN')) {
      res.status(403).json({
        success: false,
        message: 'Access denied. Admin privileges required.',
      });
      return;
    }

    // Récupérer le restaurant
    const restaurant = await prisma.restaurant.findFirst({
      where: { isActive: true },
    });

    if (!restaurant) {
      res.status(404).json({
        success: false,
        message: 'Restaurant not found',
      });
      return;
    }

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
      // Total des tables
      prisma.table.count({
        where: { restaurantId: restaurant.id },
      }),

      // Tables actives
      prisma.table.count({
        where: { restaurantId: restaurant.id, isActive: true },
      }),

      // Tables inactives
      prisma.table.count({
        where: { restaurantId: restaurant.id, isActive: false },
      }),

      // Capacité totale
      prisma.table.aggregate({
        where: { restaurantId: restaurant.id, isActive: true },
        _sum: { capacity: true },
      }),

      // Réservations d'aujourd'hui
      prisma.reservation.count({
        where: {
          restaurantId: restaurant.id,
          date: {
            gte: today,
            lt: tomorrow,
          },
          status: {
            in: ['PENDING', 'CONFIRMED'],
          },
        },
      }),

      // Réservations à venir
      prisma.reservation.count({
        where: {
          restaurantId: restaurant.id,
          date: {
            gte: tomorrow,
          },
          status: {
            in: ['PENDING', 'CONFIRMED'],
          },
        },
      }),

      // Répartition par taille
      prisma.table.groupBy({
        by: ['capacity'],
        where: { restaurantId: restaurant.id, isActive: true },
        _count: { capacity: true },
        orderBy: { capacity: 'asc' },
      }),
    ]);

    const statistics = {
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
    };

    logger.info('Table statistics retrieved', {
      userId: user.id,
      restaurantId: restaurant.id,
      ip: req.ip,
    });

    res.status(200).json({
      success: true,
      data: statistics,
    });
  } catch (error) {
    logger.error('Failed to get table statistics', {
      error: error instanceof Error ? error.message : 'Unknown error',
      stack: error instanceof Error ? error.stack : undefined,
    });

    res.status(500).json({
      success: false,
      message: 'Failed to get table statistics',
      error: error instanceof Error ? error.message : 'Unknown error',
    });
  }
};
