import { Router } from 'express';
import {
  checkSlotAvailability,
  getAvailability,
  getAvailableTables,
} from '@/controllers/availabilityController';
import { optionalAuth } from '@/middleware/auth';
import { generalLimiter } from '@/middleware/rateLimit';
import { validateAvailabilityQuery } from '@/middleware/validation';

const router = Router();

// Routes de disponibilité
router.get('/', generalLimiter, optionalAuth, validateAvailabilityQuery, getAvailability);
router.get('/tables', generalLimiter, optionalAuth, validateAvailabilityQuery, getAvailableTables);
router.get(
  '/check',
  generalLimiter,
  optionalAuth,
  validateAvailabilityQuery,
  checkSlotAvailability
);

export default router;
