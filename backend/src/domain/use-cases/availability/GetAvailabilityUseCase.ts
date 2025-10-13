import { AvailabilityRepository } from '../../repositories/AvailabilityRepository';
import { DayAvailability } from '../../entities/DayAvailability';

export interface GetAvailabilityRequest {
  date: Date;
  partySize: number;
  restaurantId?: string;
}

export interface GetAvailabilityResponse {
  dayAvailability: DayAvailability;
}

export class GetAvailabilityUseCase {
  constructor(private availabilityRepository: AvailabilityRepository) {}

  async execute(request: GetAvailabilityRequest): Promise<GetAvailabilityResponse> {
    this.validateRequest(request);

    const dayAvailability = await this.availabilityRepository.getDayAvailability(request);

    return {
      dayAvailability,
    };
  }

  private validateRequest(request: GetAvailabilityRequest): void {
    if (!request.date) {
      throw new Error('Date is required');
    }

    if (!request.partySize || request.partySize < 1) {
      throw new Error('Party size must be at least 1');
    }

    if (request.partySize > 20) {
      throw new Error('Party size cannot exceed 20');
    }

    // Vérifier que la date n'est pas dans le passé
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    
    if (request.date < today) {
      throw new Error('Date cannot be in the past');
    }

    // Vérifier que la date n'est pas trop loin dans le futur (max 1 an)
    const maxDate = new Date();
    maxDate.setFullYear(maxDate.getFullYear() + 1);
    
    if (request.date > maxDate) {
      throw new Error('Date cannot be more than 1 year in the future');
    }
  }
}

