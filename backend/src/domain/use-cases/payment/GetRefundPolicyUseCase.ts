import { RefundPolicy } from '../../entities/RefundPolicy';
import { PaymentRepository } from '../../repositories/PaymentRepository';

export interface GetRefundPolicyResponse {
  success: boolean;
  data?: RefundPolicy;
  message?: string;
}

export class GetRefundPolicyUseCase {
  constructor(
    private paymentRepository: PaymentRepository
  ) {}

  async execute(): Promise<GetRefundPolicyResponse> {
    try {
      const policy = await this.paymentRepository.getRefundPolicy();

      return {
        success: true,
        data: policy,
      };
    } catch (error) {
      return {
        success: false,
        message: error instanceof Error ? error.message : 'Unknown error',
      };
    }
  }
}
