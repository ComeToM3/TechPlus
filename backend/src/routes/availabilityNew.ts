import { Router } from 'express';
import { AvailabilityController } from '@/controllers/availabilityControllerNew';
import { optionalAuth } from '@/middleware/auth';
import { generalLimiter } from '@/middleware/rateLimit';
import { validateAvailabilityQuery } from '@/middleware/validation';
import { Container } from '@/infrastructure/container/Container';

const router = Router();
const container = Container.getInstance();
const availabilityController = container.getAvailabilityController();

// Routes de disponibilité
router.get('/', generalLimiter, optionalAuth, validateAvailabilityQuery, availabilityController.getAvailability);
router.get('/tables', generalLimiter, optionalAuth, validateAvailabilityQuery, availabilityController.getAvailableTables);
router.get(
  '/check',
  generalLimiter,
  optionalAuth,
  validateAvailabilityQuery,
  availabilityController.checkSlotAvailability
);

export default router;

