import { Router } from 'express';
import {
  sendReservationNotification,
  sendCustomEmail,
  getNotificationHistory,
  retryFailedNotifications,
  verifySMTPConnection,
  sendTestEmail,
  getNotificationStats,
} from '@/controllers/notificationController';
import { authenticateToken } from '@/middleware/auth';
import { notificationLimiter } from '@/middleware/rateLimit';
import { validateEmail, handleValidationErrors } from '@/middleware/validation';
import { body } from 'express-validator';

const router = Router();

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
  sendReservationNotification
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
  sendReservationNotification
);

router.post(
  '/send-custom',
  notificationLimiter,
  [validateEmail('to'), handleValidationErrors],
  sendCustomEmail
);

router.post(
  '/send-test',
  notificationLimiter,
  [validateEmail('to'), handleValidationErrors],
  sendTestEmail
);

router.get('/history', getNotificationHistory);

router.post('/retry-failed', retryFailedNotifications);

router.get('/verify-smtp', verifySMTPConnection);

router.get('/stats', getNotificationStats);

export default router;
