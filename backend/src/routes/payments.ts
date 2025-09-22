import { Router } from 'express';
import {
  calculateDeposit,
  confirmPayment,
  createPaymentIntent,
  getPaymentDetails,
  getRefundPolicy,
  handleStripeWebhook,
  processRefund,
  testRefundLogic,
} from '@/controllers/paymentController';
import { authenticateToken } from '@/middleware/auth';
import { paymentLimiter, webhookLimiter } from '@/middleware/rateLimit';
import { validateObjectId, validatePaymentIntent } from '@/middleware/validation';

const router = Router();

// Routes pour les paiements
router.post(
  '/create-intent',
  authenticateToken,
  paymentLimiter,
  validatePaymentIntent,
  createPaymentIntent
);
router.post('/confirm', authenticateToken, paymentLimiter, confirmPayment);
router.post('/refund', authenticateToken, paymentLimiter, processRefund);
router.post('/calculate', calculateDeposit);
router.get('/refund-policy', getRefundPolicy);
router.post('/test-refund-logic', testRefundLogic);
router.get('/:id', authenticateToken, validateObjectId, getPaymentDetails);

// Webhook Stripe (sans authentification, vérification par signature)
router.post('/webhook', webhookLimiter, handleStripeWebhook);

export default router;
