import { Router } from 'express';
import { authenticateToken } from '@/middleware/auth';
import { adminLimiter } from '@/middleware/rateLimit';
import {
  getScheduleConfig,
  createOrUpdateScheduleConfig,
  deleteScheduleConfig,
} from '@/controllers/scheduleController';

const router = Router();

/**
 * @route GET /api/admin/schedule
 * @description Get restaurant schedule configuration
 * @access Admin only
 */
router.get(
  '/',
  adminLimiter,
  authenticateToken,
  getScheduleConfig
);

/**
 * @route POST /api/admin/schedule
 * @description Create or update restaurant schedule configuration
 * @access Admin only
 */
router.post(
  '/',
  adminLimiter,
  authenticateToken,
  createOrUpdateScheduleConfig
);

/**
 * @route PUT /api/admin/schedule
 * @description Update restaurant schedule configuration
 * @access Admin only
 */
router.put(
  '/',
  adminLimiter,
  authenticateToken,
  createOrUpdateScheduleConfig
);

/**
 * @route DELETE /api/admin/schedule
 * @description Delete restaurant schedule configuration
 * @access Admin only
 */
router.delete(
  '/',
  adminLimiter,
  authenticateToken,
  deleteScheduleConfig
);

export default router;
