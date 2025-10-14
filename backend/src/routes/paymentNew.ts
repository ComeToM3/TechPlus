import { Router } from 'express';
import { PaymentControllerNew } from '../controllers/paymentControllerNew';
import { Container } from '../infrastructure/container/Container';
import { authenticateToken } from '@/middleware/auth';
import { reservationLimiter } from '@/middleware/rateLimit';

const router = Router();

// Récupérer le controller depuis le container DI
const paymentController = Container.getInstance().getPaymentController();

/**
 * @route POST /api/payments/intent
 * @description Create a PaymentIntent for a reservation
 * @access Authenticated users only
 */
router.post('/intent', reservationLimiter, authenticateToken, (req, res) => {
  paymentController.createPaymentIntent(req, res);
});

/**
 * @route POST /api/payments/confirm
 * @description Confirm a payment
 * @access Authenticated users only
 */
router.post('/confirm', reservationLimiter, authenticateToken, (req, res) => {
  paymentController.confirmPayment(req, res);
});

/**
 * @route POST /api/payments/refund
 * @description Process a refund
 * @access Authenticated users only
 */
router.post('/refund', reservationLimiter, authenticateToken, (req, res) => {
  paymentController.processRefund(req, res);
});

/**
 * @route GET /api/payments/:id
 * @description Get payment details
 * @access Authenticated users only
 */
router.get('/:id', reservationLimiter, authenticateToken, (req, res) => {
  paymentController.getPaymentDetails(req, res);
});

/**
 * @route POST /api/payments/calculate-deposit
 * @description Calculate deposit for a reservation
 * @access Public
 */
router.post('/calculate-deposit', (req, res) => {
  paymentController.calculateDeposit(req, res);
});

/**
 * @route GET /api/payments/refund-policy
 * @description Get refund policy
 * @access Public
 */
router.get('/refund-policy', (req, res) => {
  paymentController.getRefundPolicy(req, res);
});

/**
 * @route POST /api/payments/test-refund
 * @description Test refund logic (without Stripe)
 * @access Public
 */
router.post('/test-refund', (req, res) => {
  paymentController.testRefundLogic(req, res);
});

/**
 * @route POST /api/payments/webhook
 * @description Handle Stripe webhook
 * @access Stripe only
 */
router.post('/webhook', (req, res) => {
  paymentController.handleWebhook(req, res);
});

export default router;
