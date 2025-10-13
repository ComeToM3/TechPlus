import { RefundPolicy } from '../../entities/RefundPolicy';
import { PaymentRepository } from '../../repositories/PaymentRepository';

export interface TestRefundLogicRequest {
  reservationDate: string;
  depositAmount: number;
  cancellationReason?: string;
}

export interface TestRefundLogicResponse {
  success: boolean;
  data?: {
    refundAmount: number;
    reason: string;
    reservationDate: string;
    depositAmount: number;
    cancellationReason: string;
  };
  message?: string;
}

export class TestRefundLogicUseCase {
  constructor(
    private paymentRepository: PaymentRepository
  ) {}

  async execute(request: TestRefundLogicRequest): Promise<TestRefundLogicResponse> {
    try {
      const { reservationDate, depositAmount, cancellationReason } = request;

      // Validation
      if (!reservationDate || depositAmount === undefined) {
        return {
          success: false,
          message: 'Reservation date and deposit amount are required',
        };
      }

      if (depositAmount < 0) {
        return {
          success: false,
          message: 'Deposit amount must be greater than or equal to 0',
        };
      }

      // Récupérer la politique de remboursement
      const policy = await this.paymentRepository.getRefundPolicy();

      // Calculer le montant de remboursement
      const refundInfo = policy.calculateRefundAmount(
        new Date(reservationDate),
        depositAmount,
        cancellationReason
      );

      return {
        success: true,
        data: {
          refundAmount: refundInfo.amount,
          reason: refundInfo.reason,
          reservationDate: new Date(reservationDate).toISOString(),
          depositAmount,
          cancellationReason: cancellationReason || 'not_specified',
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
