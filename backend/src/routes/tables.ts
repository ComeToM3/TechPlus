import { Router } from 'express';
import { authenticateToken } from '@/middleware/auth';
import { adminLimiter } from '@/middleware/rateLimit';
import {
  getTables,
  getTableById,
  createTable,
  updateTable,
  deleteTable,
  updateTableStatus,
  getTableStatistics,
  // Nouveaux endpoints optimisés
  updateTableCapacity,
  updateTablePosition,
  updateTableNumber,
  updateTableActive,
  getTablesMetadata,
  getTableStatsOnly,
  batchUpdateTables,
} from '@/controllers/tableController';

const router = Router();

/**
 * @route GET /api/admin/tables
 * @description Get all tables for the restaurant
 * @access Admin only
 */
router.get(
  '/',
  adminLimiter,
  authenticateToken,
  getTables
);

/**
 * @route GET /api/admin/tables/statistics
 * @description Get table statistics
 * @access Admin only
 */
router.get(
  '/statistics',
  adminLimiter,
  authenticateToken,
  getTableStatistics
);

/**
 * @route GET /api/admin/tables/:id
 * @description Get a specific table by ID
 * @access Admin only
 */
router.get(
  '/:id',
  adminLimiter,
  authenticateToken,
  getTableById
);

/**
 * @route POST /api/admin/tables
 * @description Create a new table
 * @access Admin only
 */
router.post(
  '/',
  adminLimiter,
  authenticateToken,
  createTable
);

/**
 * @route PUT /api/admin/tables/:id
 * @description Update a table
 * @access Admin only
 */
router.put(
  '/:id',
  adminLimiter,
  authenticateToken,
  updateTable
);

/**
 * @route PUT /api/admin/tables/:id/status
 * @description Update table status (active/inactive)
 * @access Admin only
 */
router.put(
  '/:id/status',
  adminLimiter,
  authenticateToken,
  updateTableStatus
);

/**
 * @route DELETE /api/admin/tables/:id
 * @description Delete a table
 * @access Admin only
 */
router.delete(
  '/:id',
  adminLimiter,
  authenticateToken,
  deleteTable
);

// ===== ENDPOINTS OPTIMISÉS POUR ÉVITER L'ENVOI DE TOUTES LES DONNÉES =====

/**
 * @route PATCH /api/admin/tables/:id/status
 * @description Update only table status
 * @access Admin only
 */
router.patch(
  '/:id/status',
  adminLimiter,
  authenticateToken,
  updateTableStatus
);

/**
 * @route PATCH /api/admin/tables/:id/capacity
 * @description Update only table capacity
 * @access Admin only
 */
router.patch(
  '/:id/capacity',
  adminLimiter,
  authenticateToken,
  updateTableCapacity
);

/**
 * @route PATCH /api/admin/tables/:id/position
 * @description Update only table position
 * @access Admin only
 */
router.patch(
  '/:id/position',
  adminLimiter,
  authenticateToken,
  updateTablePosition
);

/**
 * @route PATCH /api/admin/tables/:id/number
 * @description Update only table number
 * @access Admin only
 */
router.patch(
  '/:id/number',
  adminLimiter,
  authenticateToken,
  updateTableNumber
);

/**
 * @route PATCH /api/admin/tables/:id/active
 * @description Update only table active status
 * @access Admin only
 */
router.patch(
  '/:id/active',
  adminLimiter,
  authenticateToken,
  updateTableActive
);

/**
 * @route GET /api/admin/tables/metadata
 * @description Get tables metadata only (without reservations)
 * @access Admin only
 */
router.get(
  '/metadata',
  adminLimiter,
  authenticateToken,
  getTablesMetadata
);

/**
 * @route GET /api/admin/tables/:id/stats-only
 * @description Get only table statistics
 * @access Admin only
 */
router.get(
  '/:id/stats-only',
  adminLimiter,
  authenticateToken,
  getTableStatsOnly
);

/**
 * @route PATCH /api/admin/tables/batch
 * @description Batch update multiple tables
 * @access Admin only
 */
router.patch(
  '/batch',
  adminLimiter,
  authenticateToken,
  batchUpdateTables
);

export default router;
