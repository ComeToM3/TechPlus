import { Router } from 'express';
import {
  changePassword,
  facebookAuth,
  getProfile,
  googleAuth,
  login,
  logout,
  refreshToken,
  register,
  updateProfile,
} from '@/controllers/authController';
import { authenticateToken } from '@/middleware/auth';
import { authLimiter } from '@/middleware/rateLimit';
import { validateLogin, validateRegister, validateWithJoi, schemas } from '@/middleware/validation';

const router = Router();

// Routes d'authentification avec validation Joi
router.post('/register', authLimiter, validateWithJoi({ body: schemas.auth.register }), register);
router.post('/login', authLimiter, validateWithJoi({ body: schemas.auth.login }), login);
router.post('/refresh', validateWithJoi({ body: schemas.auth.refreshToken }), refreshToken);
router.post('/logout', authenticateToken, logout);

// Routes de profil
router.get('/profile', authenticateToken, getProfile);
router.put('/profile', authenticateToken, updateProfile);
router.put(
  '/change-password',
  authenticateToken,
  validateWithJoi({ body: schemas.auth.changePassword }),
  changePassword
);

// Routes OAuth2
router.post('/google', googleAuth);
router.post('/facebook', facebookAuth);

export default router;
