import { Router } from 'express';
import { ReservationController } from '@/controllers/reservationControllerNew';
import { authenticateToken, authenticateManagementToken, optionalAuth } from '@/middleware/auth';
import { managementTokenLimiter, reservationLimiter } from '@/middleware/rateLimit';
import {
  validateWithJoi,
  schemas,
} from '@/middleware/validation';
import { Container } from '@/infrastructure/container/Container';

const router = Router();
const container = Container.getInstance();
const reservationController = container.getReservationController();

// Routes pour utilisateurs authentifiés avec validation Joi
router.post(
  '/',
  authenticateToken,
  reservationLimiter,
  validateWithJoi({ body: schemas.reservation.create }),
  reservationController.createReservation
);

router.get(
  '/',
  authenticateToken,
  validateWithJoi({ query: schemas.reservation.list }),
  reservationController.getUserReservations
);

router.get(
  '/:id',
  authenticateToken,
  validateWithJoi({ params: schemas.reservation.params }),
  reservationController.getReservationById
);

router.put(
  '/:id',
  authenticateToken,
  validateWithJoi({ params: schemas.reservation.params, body: schemas.reservation.update }),
  reservationController.updateReservation
);

router.delete(
  '/:id',
  authenticateToken,
  validateWithJoi({ params: schemas.reservation.params }),
  reservationController.cancelReservation
);

// Routes pour les réservations guest (avec token de gestion) avec validation Joi
router.get(
  '/manage/:token',
  managementTokenLimiter,
  validateWithJoi({ params: schemas.reservation.tokenParams }),
  authenticateManagementToken,
  reservationController.getReservationByToken
);

router.put(
  '/manage/:token',
  managementTokenLimiter,
  validateWithJoi({ params: schemas.reservation.tokenParams, body: schemas.reservation.update }),
  authenticateManagementToken,
  reservationController.updateReservationByToken
);

router.delete(
  '/manage/:token',
  managementTokenLimiter,
  validateWithJoi({ params: schemas.reservation.tokenParams }),
  authenticateManagementToken,
  reservationController.cancelReservationByToken
);

// Route pour créer une réservation guest (sans authentification) avec validation Joi
router.post(
  '/guest',
  reservationLimiter,
  validateWithJoi({ body: schemas.reservation.create }),
  reservationController.createReservation
);

export default router;


