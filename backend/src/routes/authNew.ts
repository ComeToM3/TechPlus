/**
 * Nouvelles routes d'authentification utilisant l'architecture Clean
 * Ces routes utilisent le nouveau controller avec les use cases
 */

import { Router } from 'express';
import { Container } from '../infrastructure/container/Container';
import { authLimiter } from '@/middleware/rateLimit';
import { validateWithJoi, schemas } from '@/middleware/validation';
import { authenticateToken } from '@/middleware/auth';

const router = Router();
const container = Container.getInstance();
const authController = container.getAuthController();

// Routes d'authentification avec validation Joi
router.post('/register', authLimiter, validateWithJoi({ body: schemas.auth.register }), authController.register);
router.post('/login', authLimiter, validateWithJoi({ body: schemas.auth.login }), authController.login);
router.post('/token', authLimiter, authController.loginWithToken);
router.post('/refresh', validateWithJoi({ body: schemas.auth.refreshToken }), authController.refreshToken);
router.post('/logout', authenticateToken, authController.logout);

// Routes de profil
router.get('/profile', authenticateToken, authController.getProfile);
router.put('/profile', authenticateToken, authController.updateProfile);
router.put(
  '/change-password',
  authenticateToken,
  validateWithJoi({ body: schemas.auth.changePassword }),
  authController.changePassword
);

// OAuth supprimé - utilisation du système d'authentification interne uniquement

export default router;
