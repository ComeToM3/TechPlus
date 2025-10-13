import { PaymentRepository } from '../../repositories/PaymentRepository';

export interface ConfirmPaymentRequest {
  paymentIntentId: string;
}

export interface ConfirmPaymentResponse {
  success: boolean;
  message?: string;
}

export class ConfirmPaymentUseCase {
  constructor(
    private paymentRepository: PaymentRepository
  ) {}

  async execute(request: ConfirmPaymentRequest): Promise<ConfirmPaymentResponse> {
    try {
      const { paymentIntentId } = request;

      // Validation
      if (!paymentIntentId) {
        return {
          success: false,
          message: 'Payment Intent ID is required',
        };
      }

      // Récupérer le PaymentIntent
      const paymentIntent = await this.paymentRepository.findPaymentIntentById(paymentIntentId);
      if (!paymentIntent) {
        return {
          success: false,
          message: 'Payment intent not found',
        };
      }

      // Vérifier si le paiement peut être confirmé
      if (paymentIntent.isCompleted()) {
        return {
          success: true,
          message: 'Payment already confirmed',
        };
      }

      if (paymentIntent.isFailed()) {
        return {
          success: false,
          message: 'Payment has failed and cannot be confirmed',
        };
      }

      // Confirmer le paiement
      await this.paymentRepository.updatePaymentIntentStatus(paymentIntentId, 'succeeded');

      return {
        success: true,
        message: 'Payment confirmed successfully',
      };
    } catch (error) {
      return {
        success: false,
        message: error instanceof Error ? error.message : 'Unknown error',
      };
    }
  }
}
