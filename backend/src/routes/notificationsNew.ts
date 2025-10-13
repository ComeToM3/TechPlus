import { Router } from 'express';
import { NotificationController } from '@/controllers/notificationControllerNew';
import { authenticateToken } from '@/middleware/auth';
import { notificationLimiter } from '@/middleware/rateLimit';
import { validateEmail, handleValidationErrors } from '@/middleware/validation';
import { body } from 'express-validator';
import { Container } from '@/infrastructure/container/Container';

const router = Router();
const container = Container.getInstance();
const notificationController = container.getNotificationController();

// Middleware d'authentification pour toutes les routes
router.use(authenticateToken);

// Routes pour les notifications
router.post(
  '/send-reservation',
  notificationLimiter,
  [
    body('reservationId').isMongoId().withMessage('reservationId must be a valid MongoDB ObjectId'),
    validateEmail('recipientEmail'),
    handleValidationErrors,
  ],
  notificationController.sendReservationNotification
);

// Endpoint générique pour les notifications (compatible avec le frontend)
router.post(
  '/send',
  notificationLimiter,
  [
    body('reservationId').optional().isMongoId().withMessage('reservationId must be a valid MongoDB ObjectId'),
    validateEmail('clientEmail'),
    handleValidationErrors,
  ],
  notificationController.sendReservationNotification
);

router.post(
  '/send-custom',
  notificationLimiter,
  [validateEmail('to'), handleValidationErrors],
  notificationController.sendCustomEmail
);

router.post(
  '/send-test',
  notificationLimiter,
  [validateEmail('to'), handleValidationErrors],
  notificationController.sendTestEmail
);

router.get('/history', notificationController.getNotificationHistory);

router.post('/retry-failed', notificationController.retryFailedNotifications);

router.get('/verify-smtp', notificationController.verifySMTPConnection);

router.get('/stats', notificationController.getNotificationStats);

export default router;

