import { AvailabilityRepository } from '../../repositories/AvailabilityRepository';

export interface CheckSlotAvailabilityRequest {
  date: Date;
  time: string;
  partySize: number;
  restaurantId?: string;
}

export interface CheckSlotAvailabilityResponse {
  isAvailable: boolean;
  date: string;
  time: string;
  partySize: number;
  availableTable?: any;
}

export class CheckSlotAvailabilityUseCase {
  constructor(private availabilityRepository: AvailabilityRepository) {}

  async execute(request: CheckSlotAvailabilityRequest): Promise<CheckSlotAvailabilityResponse> {
    this.validateRequest(request);

    const isAvailable = await this.availabilityRepository.checkSlotAvailability(request);

    let availableTable = null;
    if (isAvailable) {
      const tables = await this.availabilityRepository.getAvailableTables(request);
      availableTable = tables.length > 0 ? {
        id: tables[0].id,
        number: tables[0].number,
        capacity: tables[0].capacity,
      } : null;
    }

    return {
      isAvailable,
      date: request.date.toISOString(),
      time: request.time,
      partySize: request.partySize,
      availableTable,
    };
  }

  private validateRequest(request: CheckSlotAvailabilityRequest): void {
    if (!request.date) {
      throw new Error('Date is required');
    }

    if (!request.time) {
      throw new Error('Time is required');
    }

    if (!request.partySize || request.partySize < 1) {
      throw new Error('Party size must be at least 1');
    }

    if (request.partySize > 20) {
      throw new Error('Party size cannot exceed 20');
    }

    // Valider le format de l'heure (HH:MM)
    const timeRegex = /^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/;
    if (!timeRegex.test(request.time)) {
      throw new Error('Time must be in HH:MM format');
    }

    // Vérifier que la date n'est pas dans le passé
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    
    if (request.date < today) {
      throw new Error('Date cannot be in the past');
    }
  }
}

