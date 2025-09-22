import { Router } from 'express';
import {
  cancelReservation,
  cancelReservationByToken,
  createReservation,
  getReservationById,
  getReservationByToken,
  getUserReservations,
  updateReservation,
  updateReservationByToken,
} from '@/controllers/reservationController';
import { authenticateManagementToken, authenticateToken, optionalAuth } from '@/middleware/auth';
import { managementTokenLimiter, reservationLimiter } from '@/middleware/rateLimit';
import {
  validateGuestReservation,
  validateManagementToken,
  validateObjectId,
  validateReservation,
  validateReservationFilters,
  validateWithJoi,
  schemas,
} from '@/middleware/validation';

const router = Router();

// Routes pour utilisateurs authentifiés avec validation Joi
router.post(
  '/',
  authenticateToken,
  reservationLimiter,
  validateWithJoi({ body: schemas.reservation.create }),
  createReservation
);
router.get(
  '/',
  authenticateToken,
  validateWithJoi({ query: schemas.reservation.list }),
  getUserReservations
);
router.get(
  '/:id',
  authenticateToken,
  validateWithJoi({ params: schemas.reservation.params }),
  getReservationById
);
router.put(
  '/:id',
  authenticateToken,
  validateWithJoi({ params: schemas.reservation.params, body: schemas.reservation.update }),
  updateReservation
);
router.delete(
  '/:id',
  authenticateToken,
  validateWithJoi({ params: schemas.reservation.params }),
  cancelReservation
);

// Routes pour les réservations guest (avec token de gestion) avec validation Joi
router.get(
  '/manage/:token',
  managementTokenLimiter,
  validateWithJoi({ params: schemas.reservation.tokenParams }),
  authenticateManagementToken,
  getReservationByToken
);
router.put(
  '/manage/:token',
  managementTokenLimiter,
  validateWithJoi({ params: schemas.reservation.tokenParams, body: schemas.reservation.update }),
  authenticateManagementToken,
  updateReservationByToken
);
router.delete(
  '/manage/:token',
  managementTokenLimiter,
  validateWithJoi({ params: schemas.reservation.tokenParams }),
  authenticateManagementToken,
  cancelReservationByToken
);

// Route pour créer une réservation guest (sans authentification) avec validation Joi
router.post(
  '/guest',
  reservationLimiter,
  validateWithJoi({ body: schemas.reservation.create }),
  createReservation
);

export default router;
