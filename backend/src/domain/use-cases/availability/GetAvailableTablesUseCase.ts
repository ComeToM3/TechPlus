import { AvailabilityRepository } from '../../repositories/AvailabilityRepository';

export interface GetAvailableTablesRequest {
  date: Date;
  time: string;
  partySize: number;
  restaurantId?: string;
}

export interface GetAvailableTablesResponse {
  availableTables: any[];
  count: number;
  date: string;
  time: string;
  partySize: number;
}

export class GetAvailableTablesUseCase {
  constructor(private availabilityRepository: AvailabilityRepository) {}

  async execute(request: GetAvailableTablesRequest): Promise<GetAvailableTablesResponse> {
    this.validateRequest(request);

    const availableTables = await this.availabilityRepository.getAvailableTables(request);

    return {
      availableTables,
      count: availableTables.length,
      date: request.date.toISOString(),
      time: request.time,
      partySize: request.partySize,
    };
  }

  private validateRequest(request: GetAvailableTablesRequest): void {
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

