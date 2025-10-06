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

export default router;
