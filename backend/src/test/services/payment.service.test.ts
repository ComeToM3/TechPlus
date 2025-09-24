import { PaymentService } from '../../services/paymentService';
import Stripe from 'stripe';

// Mock Stripe
jest.mock('stripe', () => {
  return jest.fn().mockImplementation(() => ({
    paymentIntents: {
      create: jest.fn(),
      retrieve: jest.fn(),
      cancel: jest.fn(),
    },
    refunds: {
      create: jest.fn(),
    },
  }));
});

describe('PaymentService', () => {
  let paymentService: PaymentService;
  let mockStripe: jest.Mocked<Stripe>;

  beforeEach(() => {
    paymentService = new PaymentService();
    mockStripe = new Stripe('test-key') as jest.Mocked<Stripe>;
    jest.clearAllMocks();
  });

  describe('createPaymentIntent', () => {
    it('should create payment intent successfully', async () => {
      const mockPaymentIntent = {
        id: 'pi_test_123',
        amount: 1000,
        currency: 'usd',
        status: 'requires_payment_method',
        client_secret: 'pi_test_123_secret',
      };

      (mockStripe.paymentIntents.create as jest.Mock).mockResolvedValue(mockPaymentIntent);

      const result = await paymentService.createPaymentIntent({
        amount: 1000,
        currency: 'usd',
        metadata: { reservationId: 'reservation-1' },
      });

      expect(result).toEqual(mockPaymentIntent);
      expect(mockStripe.paymentIntents.create).toHaveBeenCalledWith({
        amount: 1000,
        currency: 'usd',
        metadata: { reservationId: 'reservation-1' },
      });
    });

    it('should throw error when Stripe fails', async () => {
      const error = new Error('Stripe API error');
      (mockStripe.paymentIntents.create as jest.Mock).mockRejectedValue(error);

      await expect(paymentService.createPaymentIntent({
        amount: 1000,
        currency: 'usd',
      })).rejects.toThrow('Stripe API error');
    });
  });

  describe('getPaymentIntent', () => {
    it('should retrieve payment intent successfully', async () => {
      const mockPaymentIntent = {
        id: 'pi_test_123',
        amount: 1000,
        currency: 'usd',
        status: 'succeeded',
        metadata: { reservationId: 'reservation-1' },
      };

      (mockStripe.paymentIntents.retrieve as jest.Mock).mockResolvedValue(mockPaymentIntent);

      const result = await paymentService.getPaymentIntent('pi_test_123');

      expect(result).toEqual(mockPaymentIntent);
      expect(mockStripe.paymentIntents.retrieve).toHaveBeenCalledWith('pi_test_123');
    });

    it('should throw error when payment intent not found', async () => {
      const error = new Error('No such payment_intent: pi_invalid');
      (mockStripe.paymentIntents.retrieve as jest.Mock).mockRejectedValue(error);

      await expect(paymentService.getPaymentIntent('pi_invalid'))
        .rejects
        .toThrow('No such payment_intent: pi_invalid');
    });
  });

  describe('cancelPaymentIntent', () => {
    it('should cancel payment intent successfully', async () => {
      const mockCancelledPaymentIntent = {
        id: 'pi_test_123',
        amount: 1000,
        currency: 'usd',
        status: 'canceled',
      };

      (mockStripe.paymentIntents.cancel as jest.Mock).mockResolvedValue(mockCancelledPaymentIntent);

      const result = await paymentService.cancelPaymentIntent('pi_test_123');

      expect(result).toEqual(mockCancelledPaymentIntent);
      expect(mockStripe.paymentIntents.cancel).toHaveBeenCalledWith('pi_test_123');
    });
  });

  describe('createRefund', () => {
    it('should create refund successfully', async () => {
      const mockRefund = {
        id: 're_test_123',
        amount: 1000,
        currency: 'usd',
        status: 'succeeded',
        payment_intent: 'pi_test_123',
      };

      (mockStripe.refunds.create as jest.Mock).mockResolvedValue(mockRefund);

      const result = await paymentService.createRefund({
        paymentIntentId: 'pi_test_123',
        amount: 1000,
        reason: 'requested_by_customer',
      });

      expect(result).toEqual(mockRefund);
      expect(mockStripe.refunds.create).toHaveBeenCalledWith({
        payment_intent: 'pi_test_123',
        amount: 1000,
        reason: 'requested_by_customer',
      });
    });

    it('should create full refund when amount not specified', async () => {
      const mockRefund = {
        id: 're_test_123',
        amount: 1000,
        currency: 'usd',
        status: 'succeeded',
        payment_intent: 'pi_test_123',
      };

      (mockStripe.refunds.create as jest.Mock).mockResolvedValue(mockRefund);

      const result = await paymentService.createRefund({
        paymentIntentId: 'pi_test_123',
        reason: 'requested_by_customer',
      });

      expect(result).toEqual(mockRefund);
      expect(mockStripe.refunds.create).toHaveBeenCalledWith({
        payment_intent: 'pi_test_123',
        reason: 'requested_by_customer',
      });
    });
  });

  describe('calculateDepositAmount', () => {
    it('should calculate deposit amount correctly', () => {
      const result = paymentService.calculateDepositAmount(4, 25);
      expect(result).toBe(10); // 10$ fixed deposit
    });

    it('should return 0 for parties smaller than threshold', () => {
      const result = paymentService.calculateDepositAmount(2, 25);
      expect(result).toBe(0);
    });
  });

  describe('isRefundEligible', () => {
    it('should return true for cancellations more than 24h in advance', () => {
      const reservationDate = new Date();
      reservationDate.setHours(reservationDate.getHours() + 25); // 25h in advance

      const result = paymentService.isRefundEligible(reservationDate);
      expect(result).toBe(true);
    });

    it('should return false for cancellations less than 24h in advance', () => {
      const reservationDate = new Date();
      reservationDate.setHours(reservationDate.getHours() + 12); // 12h in advance

      const result = paymentService.isRefundEligible(reservationDate);
      expect(result).toBe(false);
    });

    it('should return false for past reservations', () => {
      const reservationDate = new Date();
      reservationDate.setHours(reservationDate.getHours() - 1); // 1h ago

      const result = paymentService.isRefundEligible(reservationDate);
      expect(result).toBe(false);
    });
  });
});

