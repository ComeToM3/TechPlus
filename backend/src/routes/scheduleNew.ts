import { Router } from 'express';
import { ScheduleControllerNew } from '../controllers/scheduleControllerNew';
import { Container } from '../infrastructure/container/Container';

const router = Router();

// Récupérer le controller depuis le container DI
const scheduleController = Container.getInstance().getScheduleController();

/**
 * @route GET /api/admin/schedule
 * @description Get restaurant schedule configuration
 * @access Admin only
 */
router.get('/', (req, res) => {
  scheduleController.getScheduleConfig(req, res);
});

/**
 * @route POST /api/admin/schedule
 * @description Create or update restaurant schedule configuration
 * @access Admin only
 */
router.post('/', (req, res) => {
  scheduleController.createOrUpdateScheduleConfig(req, res);
});

/**
 * @route DELETE /api/admin/schedule
 * @description Delete schedule configuration
 * @access Admin only
 */
router.delete('/', (req, res) => {
  scheduleController.deleteScheduleConfig(req, res);
});

/**
 * @route GET /api/admin/schedule/availability
 * @description Get available time slots for a specific date
 * @access Admin only
 */
router.get('/availability', (req, res) => {
  scheduleController.getAvailableSlots(req, res);
});

/**
 * @route POST /api/admin/schedule/validate
 * @description Validate if a reservation is possible
 * @access Admin only
 */
router.post('/validate', (req, res) => {
  scheduleController.validateReservation(req, res);
});

export default router;
