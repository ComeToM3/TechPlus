import { DepositCalculation } from '../../entities/DepositCalculation';

export interface CalculateDepositRequest {
  partySize: number;
  averagePricePerPerson: number;
}

export interface CalculateDepositResponse {
  success: boolean;
  data?: {
    depositAmount: number;
    isRequired: boolean;
    partySize: number;
    averagePricePerPerson: number;
    totalReservationValue: number;
    depositPercentage: number;
    remainingAmount: number;
  };
  message?: string;
}

export class CalculateDepositUseCase {
  async execute(request: CalculateDepositRequest): Promise<CalculateDepositResponse> {
    try {
      const { partySize, averagePricePerPerson } = request;

      // Validation
      if (!partySize || partySize <= 0) {
        return {
          success: false,
          message: 'Party size must be greater than 0',
        };
      }

      if (!averagePricePerPerson || averagePricePerPerson <= 0) {
        return {
          success: false,
          message: 'Average price per person must be greater than 0',
        };
      }

      // Calculer l'acompte
      const depositCalculation = DepositCalculation.calculate(partySize, averagePricePerPerson);

      return {
        success: true,
        data: depositCalculation.toJSON(),
      };
    } catch (error) {
      return {
        success: false,
        message: error instanceof Error ? error.message : 'Unknown error',
      };
    }
  }
}
