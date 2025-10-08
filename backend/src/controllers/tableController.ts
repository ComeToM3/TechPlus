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

    logger.info('🔍 [DEBUG] getTables - Tables récupérées:', {
      userId: user.id,
      restaurantId: restaurant.id,
      tableCount: tables.length,
      tables: tables.map(t => ({
        id: t.id,
        number: t.number,
        capacity: t.capacity,
        isActive: t.isActive,
        status: t.status,
        position: t.position,
      })),
      ip: req.ip,
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

    const { number, capacity, position, status } = req.body;

    // DEBUG: Log des données reçues
    logger.info('🔍 [DEBUG] createTable - Données reçues:', {
      body: req.body,
      user: user.id,
      ip: req.ip,
    });

    // Validation
    if (!number || !capacity) {
      logger.warn('❌ [DEBUG] createTable - Validation failed: missing number or capacity', {
        number,
        capacity,
        user: user.id,
      });
      res.status(400).json({
        success: false,
        message: 'Number and capacity are required',
      });
      return;
    }

    if (capacity < 1 || capacity > 20) {
      logger.warn('❌ [DEBUG] createTable - Validation failed: invalid capacity', {
        capacity,
        user: user.id,
      });
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
      logger.warn('❌ [DEBUG] createTable - Restaurant not found', {
        user: user.id,
      });
      res.status(404).json({
        success: false,
        message: 'Restaurant not found',
      });
      return;
    }

    logger.info('✅ [DEBUG] createTable - Restaurant trouvé:', {
      restaurantId: restaurant.id,
      restaurantName: restaurant.name,
    });

    // Vérifier si le numéro de table existe déjà
    const existingTable = await prisma.table.findFirst({
      where: {
        restaurantId: restaurant.id,
        number: parseInt(number),
      },
    });

    if (existingTable) {
      logger.warn('❌ [DEBUG] createTable - Table number already exists', {
        number: parseInt(number),
        existingTableId: existingTable.id,
        user: user.id,
      });
      res.status(400).json({
        success: false,
        message: 'Table number already exists',
      });
      return;
    }

    logger.info('🔍 [DEBUG] createTable - Création de la table en base:', {
      number: parseInt(number),
      capacity: parseInt(capacity),
      position: position || null,
      status: status || 'AVAILABLE',
      restaurantId: restaurant.id,
    });

    const table = await prisma.table.create({
      data: {
        number: parseInt(number),
        capacity: parseInt(capacity),
        position: position || null,
        status: status || 'AVAILABLE',
        restaurantId: restaurant.id,
      },
      include: {
        restaurant: true,
      },
    });

    logger.info('✅ [DEBUG] createTable - Table créée avec succès:', {
      tableId: table.id,
      tableNumber: table.number,
      tableCapacity: table.capacity,
      tablePosition: table.position,
      tableStatus: table.status,
      restaurantId: restaurant.id,
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

// ===== ENDPOINTS OPTIMISÉS POUR ÉVITER L'ENVOI DE TOUTES LES DONNÉES =====

/**
 * @route PATCH /api/admin/tables/:id/capacity
 * @description Update only table capacity
 * @access Admin only
 */
export const updateTableCapacity = async (req: Request, res: Response): Promise<void> => {
  try {
    const { id } = req.params;
    const { capacity } = req.body;

    if (!id) {
      res.status(400).json({
        success: false,
        message: 'Table ID is required',
      });
      return;
    }

    const updatedTable = await prisma.table.update({
      where: { id },
      data: { capacity },
      select: { id: true, capacity: true, number: true },
    });

    res.json({
      success: true,
      data: updatedTable,
    });
  } catch (error) {
    logger.error('Error updating table capacity:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update table capacity',
      error: error instanceof Error ? error.message : 'Unknown error',
    });
  }
};

/**
 * @route PATCH /api/admin/tables/:id/position
 * @description Update only table position
 * @access Admin only
 */
export const updateTablePosition = async (req: Request, res: Response): Promise<void> => {
  try {
    const { id } = req.params;
    const { position } = req.body;

    if (!id) {
      res.status(400).json({
        success: false,
        message: 'Table ID is required',
      });
      return;
    }

    const updatedTable = await prisma.table.update({
      where: { id },
      data: { position },
      select: { id: true, position: true, number: true },
    });

    res.json({
      success: true,
      data: updatedTable,
    });
  } catch (error) {
    logger.error('Error updating table position:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update table position',
      error: error instanceof Error ? error.message : 'Unknown error',
    });
  }
};

/**
 * @route PATCH /api/admin/tables/:id/number
 * @description Update only table number
 * @access Admin only
 */
export const updateTableNumber = async (req: Request, res: Response): Promise<void> => {
  try {
    const { id } = req.params;
    const { number } = req.body;

    if (!id) {
      res.status(400).json({
        success: false,
        message: 'Table ID is required',
      });
      return;
    }

    const updatedTable = await prisma.table.update({
      where: { id },
      data: { number },
      select: { id: true, number: true },
    });

    res.json({
      success: true,
      data: updatedTable,
    });
  } catch (error) {
    logger.error('Error updating table number:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update table number',
      error: error instanceof Error ? error.message : 'Unknown error',
    });
  }
};

/**
 * @route PATCH /api/admin/tables/:id/active
 * @description Update only table active status
 * @access Admin only
 */
export const updateTableActive = async (req: Request, res: Response): Promise<void> => {
  try {
    const { id } = req.params;
    const { isActive } = req.body;

    if (!id) {
      res.status(400).json({
        success: false,
        message: 'Table ID is required',
      });
      return;
    }

    const updatedTable = await prisma.table.update({
      where: { id },
      data: { isActive },
      select: { id: true, isActive: true, number: true },
    });

    res.json({
      success: true,
      data: updatedTable,
    });
  } catch (error) {
    logger.error('Error updating table active status:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update table active status',
      error: error instanceof Error ? error.message : 'Unknown error',
    });
  }
};

/**
 * @route GET /api/admin/tables/metadata
 * @description Get tables metadata only (without reservations)
 * @access Admin only
 */
export const getTablesMetadata = async (req: Request, res: Response): Promise<void> => {
  try {
    const user = (req as any).user;
    if (!user || (user.role !== 'ADMIN' && user.role !== 'SUPER_ADMIN')) {
      res.status(403).json({
        success: false,
        message: 'Access denied. Admin privileges required.',
      });
      return;
    }

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

    res.json({
      success: true,
      data: tables,
    });
  } catch (error) {
    logger.error('Error fetching tables metadata:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch tables metadata',
      error: error instanceof Error ? error.message : 'Unknown error',
    });
  }
};

/**
 * @route GET /api/admin/tables/:id/stats-only
 * @description Get only table statistics
 * @access Admin only
 */
export const getTableStatsOnly = async (req: Request, res: Response): Promise<void> => {
  try {
    const { id } = req.params;

    if (!id) {
      res.status(400).json({
        success: false,
        message: 'Table ID is required',
      });
      return;
    }

    const stats = await prisma.reservation.aggregate({
      where: { tableId: id },
      _count: { id: true },
    });

    const todayReservations = await prisma.reservation.count({
      where: {
        tableId: id,
        date: {
          gte: new Date(new Date().setHours(0, 0, 0, 0)),
          lt: new Date(new Date().setHours(23, 59, 59, 999)),
        },
      },
    });

    res.json({
      success: true,
      data: {
        totalReservations: stats._count?.id || 0,
        todayReservations,
        tableId: id,
      },
    });
  } catch (error) {
    logger.error('Error fetching table stats only:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch table stats',
      error: error instanceof Error ? error.message : 'Unknown error',
    });
  }
};

/**
 * @route PATCH /api/admin/tables/batch
 * @description Batch update multiple tables
 * @access Admin only
 */
export const batchUpdateTables = async (req: Request, res: Response): Promise<void> => {
  try {
    const user = (req as any).user;
    if (!user || (user.role !== 'ADMIN' && user.role !== 'SUPER_ADMIN')) {
      res.status(403).json({
        success: false,
        message: 'Access denied. Admin privileges required.',
      });
      return;
    }

    const { updates } = req.body;

    if (!Array.isArray(updates) || updates.length === 0) {
      res.status(400).json({
        success: false,
        message: 'Updates array is required and must not be empty',
      });
      return;
    }

    const results = await Promise.allSettled(
      updates.map(async (update: any) => {
        const { id, ...data } = update;
        return await prisma.table.update({
          where: { id },
          data,
          select: { id: true, number: true },
        });
      })
    );

    const successful = results.filter(r => r.status === 'fulfilled').length;
    const failed = results.filter(r => r.status === 'rejected').length;

    res.json({
      success: true,
      data: {
        successful,
        failed,
        total: updates.length,
      },
    });
  } catch (error) {
    logger.error('Error batch updating tables:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to batch update tables',
      error: error instanceof Error ? error.message : 'Unknown error',
    });
  }
};
