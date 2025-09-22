import { Request, Response } from 'express';
import { paymentService } from '@/services/paymentService';
import { CustomError, asyncHandler } from '@/middleware/error';
import prisma from '@/config/database';

/**
 * Créer un PaymentIntent pour une réservation
 */
export const createPaymentIntent = asyncHandler(async (req: Request, res: Response) => {
  const { reservationId, amount } = req.body;
  const userId = req.user?.id;

  if (!userId) {
    throw new CustomError('Authentication required', 401);
  }

  // Vérifier que la réservation appartient à l'utilisateur
  const reservation = await prisma.reservation.findFirst({
    where: {
      id: reservationId,
      userId,
    },
  });

  if (!reservation) {
    throw new CustomError('Reservation not found or access denied', 404);
  }

  // Créer le PaymentIntent
  const paymentIntent = await paymentService.createPaymentIntent(reservationId, amount);

  res.json({
    success: true,
    data: {
      clientSecret: paymentIntent.client_secret,
      paymentIntentId: paymentIntent.id,
      amount: paymentIntent.amount,
      currency: paymentIntent.currency,
    },
  });
});

/**
 * Confirmer un paiement
 */
export const confirmPayment = asyncHandler(async (req: Request, res: Response) => {
  const { paymentIntentId } = req.body;

  const success = await paymentService.confirmPayment(paymentIntentId);

  if (success) {
    res.json({
      success: true,
      message: 'Payment confirmed successfully',
    });
  } else {
    throw new CustomError('Payment confirmation failed', 400);
  }
});

/**
 * Effectuer un remboursement
 */
export const processRefund = asyncHandler(async (req: Request, res: Response) => {
  const { reservationId, amount } = req.body;
  const userId = req.user?.id;

  if (!userId) {
    throw new CustomError('Authentication required', 401);
  }

  // Vérifier que la réservation appartient à l'utilisateur
  const reservation = await prisma.reservation.findFirst({
    where: {
      id: reservationId,
      userId,
    },
  });

  if (!reservation) {
    throw new CustomError('Reservation not found or access denied', 404);
  }

  // Calculer le montant de remboursement selon la politique
  const refundInfo = paymentService.calculateRefundAmount(
    reservation.date,
    Number(reservation.depositAmount),
    req.body.cancellationReason
  );

  if (refundInfo.amount === 0) {
    res.json({
      success: true,
      message: 'No refund applicable',
      data: {
        refundAmount: 0,
        reason: refundInfo.reason,
      },
    });
    return;
  }

  // Effectuer le remboursement
  const refund = await paymentService.processRefund(reservationId, refundInfo.amount);

  res.json({
    success: true,
    message: 'Refund processed successfully',
    data: {
      refundId: refund.id,
      refundAmount: refund.amount / 100, // Convertir de centimes en euros
      reason: refundInfo.reason,
    },
  });
});

/**
 * Obtenir les détails d'un paiement
 */
export const getPaymentDetails = asyncHandler(async (req: Request, res: Response) => {
  const { id: paymentIntentId } = req.params;

  if (!paymentIntentId) {
    throw new CustomError('Payment Intent ID is required', 400);
  }

  const paymentDetails = await paymentService.getPaymentDetails(paymentIntentId);

  if (!paymentDetails) {
    throw new CustomError('Payment not found', 404);
  }

  res.json({
    success: true,
    data: {
      id: paymentDetails.id,
      amount: paymentDetails.amount,
      currency: paymentDetails.currency,
      status: paymentDetails.status,
      created: paymentDetails.created,
      metadata: paymentDetails.metadata,
    },
  });
});

/**
 * Calculer l'acompte pour une réservation
 */
export const calculateDeposit = asyncHandler(async (req: Request, res: Response) => {
  const { partySize, averagePricePerPerson } = req.body;

  const depositAmount = paymentService.calculateDepositAmount(partySize, averagePricePerPerson);
  const isRequired = paymentService.isPaymentRequired(partySize);

  res.json({
    success: true,
    data: {
      depositAmount,
      isRequired,
      partySize,
      averagePricePerPerson: averagePricePerPerson || 25,
    },
  });
});

/**
 * Obtenir la politique de remboursement
 */
export const getRefundPolicy = asyncHandler(async (req: Request, res: Response) => {
  const policy = paymentService.getRefundPolicy();

  res.json({
    success: true,
    data: policy,
  });
});

/**
 * Tester la logique de remboursement (sans Stripe)
 */
export const testRefundLogic = asyncHandler(async (req: Request, res: Response) => {
  const { reservationDate, depositAmount, cancellationReason } = req.body;

  if (!reservationDate || depositAmount === undefined) {
    throw new CustomError('reservationDate and depositAmount are required', 400);
  }

  const refundInfo = paymentService.calculateRefundAmount(
    new Date(reservationDate),
    Number(depositAmount),
    cancellationReason
  );

  res.json({
    success: true,
    data: {
      refundAmount: refundInfo.amount,
      reason: refundInfo.reason,
      reservationDate: new Date(reservationDate).toISOString(),
      depositAmount: Number(depositAmount),
      cancellationReason: cancellationReason || 'not_specified',
    },
  });
});

/**
 * Webhook Stripe
 */
export const handleStripeWebhook = asyncHandler(async (req: Request, res: Response) => {
  const sig = req.headers['stripe-signature'] as string;
  const endpointSecret = process.env.STRIPE_WEBHOOK_SECRET;

  if (!endpointSecret) {
    throw new CustomError('Webhook secret not configured', 500);
  }

  let event;

  try {
    // Vérifier la signature du webhook
    const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
    event = stripe.webhooks.constructEvent(req.body, sig, endpointSecret);
  } catch (err) {
    console.error('Webhook signature verification failed:', err);
    throw new CustomError('Invalid webhook signature', 400);
  }

  // Traiter l'événement
  await paymentService.handleWebhook(event);

  res.json({ received: true });
});
