import { Request, Response } from 'express';
import { CreatePaymentIntentUseCase } from '../domain/use-cases/payment/CreatePaymentIntentUseCase';
import { ConfirmPaymentUseCase } from '../domain/use-cases/payment/ConfirmPaymentUseCase';
import { ProcessRefundUseCase } from '../domain/use-cases/payment/ProcessRefundUseCase';
import { GetPaymentDetailsUseCase } from '../domain/use-cases/payment/GetPaymentDetailsUseCase';
import { CalculateDepositUseCase } from '../domain/use-cases/payment/CalculateDepositUseCase';
import { GetRefundPolicyUseCase } from '../domain/use-cases/payment/GetRefundPolicyUseCase';
import { TestRefundLogicUseCase } from '../domain/use-cases/payment/TestRefundLogicUseCase';
import { HandleWebhookUseCase } from '../domain/use-cases/payment/HandleWebhookUseCase';
import logger from '../utils/logger';

export class PaymentControllerNew {
  constructor(
    private createPaymentIntentUseCase: CreatePaymentIntentUseCase,
    private confirmPaymentUseCase: ConfirmPaymentUseCase,
    private processRefundUseCase: ProcessRefundUseCase,
    private getPaymentDetailsUseCase: GetPaymentDetailsUseCase,
    private calculateDepositUseCase: CalculateDepositUseCase,
    private getRefundPolicyUseCase: GetRefundPolicyUseCase,
    private testRefundLogicUseCase: TestRefundLogicUseCase,
    private handleWebhookUseCase: HandleWebhookUseCase
  ) {}

  async createPaymentIntent(req: Request, res: Response): Promise<void> {
    try {
      const { reservationId, amount } = req.body;
      const userId = (req as any).user?.id;

      if (!userId) {
        res.status(401).json({
          success: false,
          message: 'Authentication required',
        });
        return;
      }

      const result = await this.createPaymentIntentUseCase.execute({
        reservationId,
        amount,
        userId,
      });

      if (!result.success) {
        res.status(400).json({
          success: false,
          message: result.message,
        });
        return;
      }

      logger.info('Payment intent created', {
        userId,
        reservationId,
        amount,
        paymentIntentId: result.data?.paymentIntentId,
        ip: req.ip,
      });

      res.status(200).json({
        success: true,
        data: result.data,
      });
    } catch (error) {
      logger.error('Failed to create payment intent', {
        error: error instanceof Error ? error.message : 'Unknown error',
        stack: error instanceof Error ? error.stack : undefined,
      });

      res.status(500).json({
        success: false,
        message: 'Failed to create payment intent',
        error: error instanceof Error ? error.message : 'Unknown error',
      });
    }
  }

  async confirmPayment(req: Request, res: Response): Promise<void> {
    try {
      const { paymentIntentId } = req.body;

      const result = await this.confirmPaymentUseCase.execute({
        paymentIntentId,
      });

      if (!result.success) {
        res.status(400).json({
          success: false,
          message: result.message,
        });
        return;
      }

      logger.info('Payment confirmed', {
        paymentIntentId,
        ip: req.ip,
      });

      res.status(200).json({
        success: true,
        message: result.message,
      });
    } catch (error) {
      logger.error('Failed to confirm payment', {
        error: error instanceof Error ? error.message : 'Unknown error',
        stack: error instanceof Error ? error.stack : undefined,
      });

      res.status(500).json({
        success: false,
        message: 'Failed to confirm payment',
        error: error instanceof Error ? error.message : 'Unknown error',
      });
    }
  }

  async processRefund(req: Request, res: Response): Promise<void> {
    try {
      const { reservationId, amount, reason } = req.body;
      const userId = (req as any).user?.id;

      if (!userId) {
        res.status(401).json({
          success: false,
          message: 'Authentication required',
        });
        return;
      }

      const result = await this.processRefundUseCase.execute({
        reservationId,
        amount,
        reason: reason || 'requested_by_customer',
        userId,
      });

      if (!result.success) {
        res.status(400).json({
          success: false,
          message: result.message,
        });
        return;
      }

      logger.info('Refund processed', {
        userId,
        reservationId,
        refundId: result.data?.refundId,
        refundAmount: result.data?.refundAmount,
        ip: req.ip,
      });

      res.status(200).json({
        success: true,
        data: result.data,
        message: result.message,
      });
    } catch (error) {
      logger.error('Failed to process refund', {
        error: error instanceof Error ? error.message : 'Unknown error',
        stack: error instanceof Error ? error.stack : undefined,
      });

      res.status(500).json({
        success: false,
        message: 'Failed to process refund',
        error: error instanceof Error ? error.message : 'Unknown error',
      });
    }
  }

  async getPaymentDetails(req: Request, res: Response): Promise<void> {
    try {
      const { id: paymentIntentId } = req.params;

      const result = await this.getPaymentDetailsUseCase.execute({
        paymentIntentId: paymentIntentId!,
      });

      if (!result.success) {
        res.status(404).json({
          success: false,
          message: result.message,
        });
        return;
      }

      logger.info('Payment details retrieved', {
        paymentIntentId,
        ip: req.ip,
      });

      res.status(200).json({
        success: true,
        data: result.data,
      });
    } catch (error) {
      logger.error('Failed to get payment details', {
        error: error instanceof Error ? error.message : 'Unknown error',
        stack: error instanceof Error ? error.stack : undefined,
      });

      res.status(500).json({
        success: false,
        message: 'Failed to get payment details',
        error: error instanceof Error ? error.message : 'Unknown error',
      });
    }
  }

  async calculateDeposit(req: Request, res: Response): Promise<void> {
    try {
      const { partySize, averagePricePerPerson } = req.body;

      const result = await this.calculateDepositUseCase.execute({
        partySize,
        averagePricePerPerson: averagePricePerPerson || 25,
      });

      if (!result.success) {
        res.status(400).json({
          success: false,
          message: result.message,
        });
        return;
      }

      logger.info('Deposit calculated', {
        partySize,
        averagePricePerPerson,
        depositAmount: result.data?.depositAmount,
        ip: req.ip,
      });

      res.status(200).json({
        success: true,
        data: result.data,
      });
    } catch (error) {
      logger.error('Failed to calculate deposit', {
        error: error instanceof Error ? error.message : 'Unknown error',
        stack: error instanceof Error ? error.stack : undefined,
      });

      res.status(500).json({
        success: false,
        message: 'Failed to calculate deposit',
        error: error instanceof Error ? error.message : 'Unknown error',
      });
    }
  }

  async getRefundPolicy(req: Request, res: Response): Promise<void> {
    try {
      const result = await this.getRefundPolicyUseCase.execute();

      if (!result.success) {
        res.status(500).json({
          success: false,
          message: result.message,
        });
        return;
      }

      logger.info('Refund policy retrieved', {
        ip: req.ip,
      });

      res.status(200).json({
        success: true,
        data: result.data,
      });
    } catch (error) {
      logger.error('Failed to get refund policy', {
        error: error instanceof Error ? error.message : 'Unknown error',
        stack: error instanceof Error ? error.stack : undefined,
      });

      res.status(500).json({
        success: false,
        message: 'Failed to get refund policy',
        error: error instanceof Error ? error.message : 'Unknown error',
      });
    }
  }

  async testRefundLogic(req: Request, res: Response): Promise<void> {
    try {
      const { reservationDate, depositAmount, cancellationReason } = req.body;

      const result = await this.testRefundLogicUseCase.execute({
        reservationDate,
        depositAmount,
        cancellationReason,
      });

      if (!result.success) {
        res.status(400).json({
          success: false,
          message: result.message,
        });
        return;
      }

      logger.info('Refund logic tested', {
        reservationDate,
        depositAmount,
        refundAmount: result.data?.refundAmount,
        ip: req.ip,
      });

      res.status(200).json({
        success: true,
        data: result.data,
      });
    } catch (error) {
      logger.error('Failed to test refund logic', {
        error: error instanceof Error ? error.message : 'Unknown error',
        stack: error instanceof Error ? error.stack : undefined,
      });

      res.status(500).json({
        success: false,
        message: 'Failed to test refund logic',
        error: error instanceof Error ? error.message : 'Unknown error',
      });
    }
  }

  async handleWebhook(req: Request, res: Response): Promise<void> {
    try {
      const sig = req.headers['stripe-signature'] as string;
      const endpointSecret = process.env.STRIPE_WEBHOOK_SECRET;

      if (!endpointSecret) {
        res.status(500).json({
          success: false,
          message: 'Webhook secret not configured',
        });
        return;
      }

      let event;

      try {
        // Vérifier la signature du webhook
        const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
        event = stripe.webhooks.constructEvent(req.body, sig, endpointSecret);
      } catch (err) {
        logger.error('Webhook signature verification failed', {
          error: err instanceof Error ? err.message : 'Unknown error',
        });
        res.status(400).json({
          success: false,
          message: 'Invalid webhook signature',
        });
        return;
      }

      // Traiter l'événement
      const result = await this.handleWebhookUseCase.execute({
        eventType: event.type,
        eventData: event,
      });

      if (!result.success) {
        logger.error('Failed to handle webhook', {
          eventType: event.type,
          error: result.message,
        });
        res.status(500).json({
          success: false,
          message: result.message,
        });
        return;
      }

      logger.info('Webhook handled successfully', {
        eventType: event.type,
        ip: req.ip,
      });

      res.status(200).json({
        success: true,
        message: 'Webhook event processed successfully',
      });
    } catch (error) {
      logger.error('Failed to handle webhook', {
        error: error instanceof Error ? error.message : 'Unknown error',
        stack: error instanceof Error ? error.stack : undefined,
      });

      res.status(500).json({
        success: false,
        message: 'Failed to handle webhook',
        error: error instanceof Error ? error.message : 'Unknown error',
      });
    }
  }
}
