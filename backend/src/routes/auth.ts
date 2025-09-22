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
import { validateLogin, validateRegister } from '@/middleware/validation';

const router = Router();

// Routes d'authentification
router.post('/register', authLimiter, validateRegister, register);
router.post('/login', authLimiter, validateLogin, login);
router.post('/refresh', refreshToken);
router.post('/logout', authenticateToken, logout);

// Routes de profil
router.get('/profile', authenticateToken, getProfile);
router.put('/profile', authenticateToken, updateProfile);
router.put('/change-password', authenticateToken, changePassword);

// Routes OAuth2
router.post('/google', googleAuth);
router.post('/facebook', facebookAuth);

export default router;
