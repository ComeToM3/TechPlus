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
} from '@/middleware/validation';

const router = Router();

// Routes pour utilisateurs authentifiés
router.post('/', authenticateToken, reservationLimiter, validateReservation, createReservation);
router.get('/', authenticateToken, validateReservationFilters, getUserReservations);
router.get('/:id', authenticateToken, validateObjectId, getReservationById);
router.put('/:id', authenticateToken, validateObjectId, updateReservation);
router.delete('/:id', authenticateToken, validateObjectId, cancelReservation);

// Routes pour les réservations guest (avec token de gestion)
router.get(
  '/manage/:token',
  managementTokenLimiter,
  validateManagementToken,
  authenticateManagementToken,
  getReservationByToken
);
router.put(
  '/manage/:token',
  managementTokenLimiter,
  validateManagementToken,
  authenticateManagementToken,
  updateReservationByToken
);
router.delete(
  '/manage/:token',
  managementTokenLimiter,
  validateManagementToken,
  authenticateManagementToken,
  cancelReservationByToken
);

// Route pour créer une réservation guest (sans authentification)
router.post('/guest', reservationLimiter, validateGuestReservation, createReservation);

export default router;
