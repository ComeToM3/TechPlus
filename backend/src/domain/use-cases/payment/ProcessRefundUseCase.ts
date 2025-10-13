import { Refund } from '../../entities/Refund';
import { PaymentRepository } from '../../repositories/PaymentRepository';

export interface ProcessRefundRequest {
  reservationId: string;
  amount: number;
  reason: string;
  userId: string;
}

export interface ProcessRefundResponse {
  success: boolean;
  data?: {
    refundId: string;
    refundAmount: number;
    reason: string;
  };
  message?: string;
}

export class ProcessRefundUseCase {
  constructor(
    private paymentRepository: PaymentRepository
  ) {}

  async execute(request: ProcessRefundRequest): Promise<ProcessRefundResponse> {
    try {
      const { reservationId, amount, reason, userId } = request;

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
          message: 'Refund amount must be greater than 0',
        };
      }

      // Récupérer le PaymentIntent pour cette réservation
      const paymentIntent = await this.paymentRepository.findPaymentIntentByReservationId(reservationId);
      if (!paymentIntent) {
        return {
          success: false,
          message: 'No payment found for this reservation',
        };
      }

      if (!paymentIntent.canBeRefunded()) {
        return {
          success: false,
          message: 'Payment cannot be refunded',
        };
      }

      // Vérifier si un remboursement existe déjà
      const existingRefunds = await this.paymentRepository.findRefundsByReservationId(reservationId);
      if (existingRefunds.length > 0) {
        return {
          success: false,
          message: 'Refund already processed for this reservation',
        };
      }

      // Créer le remboursement
      const refund = await this.paymentRepository.createRefund({
        amount,
        currency: 'eur',
        reason,
        reservationId,
        paymentIntentId: paymentIntent.id,
      });

      return {
        success: true,
        data: {
          refundId: refund.id,
          refundAmount: refund.getAmountInEuros(),
          reason: refund.reason,
        },
        message: 'Refund processed successfully',
      };
    } catch (error) {
      return {
        success: false,
        message: error instanceof Error ? error.message : 'Unknown error',
      };
    }
  }
}
