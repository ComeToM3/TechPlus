import { PaymentIntent } from '../../entities/PaymentIntent';
import { PaymentRepository } from '../../repositories/PaymentRepository';

export interface CreatePaymentIntentRequest {
  reservationId: string;
  amount: number;
  userId: string;
  metadata?: Record<string, any>;
}

export interface CreatePaymentIntentResponse {
  success: boolean;
  data?: {
    clientSecret: string;
    paymentIntentId: string;
    amount: number;
    currency: string;
  };
  message?: string;
}

export class CreatePaymentIntentUseCase {
  constructor(
    private paymentRepository: PaymentRepository
  ) {}

  async execute(request: CreatePaymentIntentRequest): Promise<CreatePaymentIntentResponse> {
    try {
      const { reservationId, amount, userId, metadata } = request;

      // Validation
      if (!reservationId || !amount || !userId) {
        return {
          success: false,
          message: 'Reservation ID, amount, and user ID are required',
        };
      }

      if (amount <= 0) {
        return {
          success: false,
          message: 'Amount must be greater than 0',
        };
      }

      // Vérifier si un PaymentIntent existe déjà pour cette réservation
      const existingPaymentIntent = await this.paymentRepository.findPaymentIntentByReservationId(reservationId);
      if (existingPaymentIntent && !existingPaymentIntent.isFailed()) {
        return {
          success: false,
          message: 'Payment intent already exists for this reservation',
        };
      }

      // Créer le PaymentIntent
      const paymentIntent = await this.paymentRepository.createPaymentIntent({
        amount,
        currency: 'eur',
        reservationId,
        userId,
        metadata,
      });

      return {
        success: true,
        data: {
          clientSecret: paymentIntent.clientSecret,
          paymentIntentId: paymentIntent.id,
          amount: paymentIntent.amount,
          currency: paymentIntent.currency,
        },
      };
    } catch (error) {
      return {
        success: false,
        message: error instanceof Error ? error.message : 'Unknown error',
      };
    }
  }
}
