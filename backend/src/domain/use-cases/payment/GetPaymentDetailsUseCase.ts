import { PaymentIntent } from '../../entities/PaymentIntent';
import { PaymentRepository } from '../../repositories/PaymentRepository';

export interface GetPaymentDetailsRequest {
  paymentIntentId: string;
}

export interface GetPaymentDetailsResponse {
  success: boolean;
  data?: {
    id: string;
    amount: number;
    currency: string;
    status: string;
    created: Date;
    metadata?: Record<string, any> | undefined;
  };
  message?: string;
}

export class GetPaymentDetailsUseCase {
  constructor(
    private paymentRepository: PaymentRepository
  ) {}

  async execute(request: GetPaymentDetailsRequest): Promise<GetPaymentDetailsResponse> {
    try {
      const { paymentIntentId } = request;

      // Validation
      if (!paymentIntentId) {
        return {
          success: false,
          message: 'Payment Intent ID is required',
        };
      }

      // Récupérer les détails du paiement
      const paymentIntent = await this.paymentRepository.findPaymentIntentById(paymentIntentId);
      if (!paymentIntent) {
        return {
          success: false,
          message: 'Payment not found',
        };
      }

      return {
        success: true,
        data: {
          id: paymentIntent.id,
          amount: paymentIntent.amount,
          currency: paymentIntent.currency,
          status: paymentIntent.status,
          created: paymentIntent.createdAt,
          metadata: paymentIntent.metadata,
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
