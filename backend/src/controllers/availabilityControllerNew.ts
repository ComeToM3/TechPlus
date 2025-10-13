import { Request, Response } from 'express';
import { asyncHandler } from '@/middleware/error';
import logger from '@/utils/logger';

import { GetAvailabilityUseCase, GetAvailabilityRequest } from '../domain/use-cases/availability/GetAvailabilityUseCase';
import { GetAvailableTablesUseCase, GetAvailableTablesRequest } from '../domain/use-cases/availability/GetAvailableTablesUseCase';
import { CheckSlotAvailabilityUseCase, CheckSlotAvailabilityRequest } from '../domain/use-cases/availability/CheckSlotAvailabilityUseCase';

export class AvailabilityController {
  constructor(
    private readonly getAvailabilityUseCase: GetAvailabilityUseCase,
    private readonly getAvailableTablesUseCase: GetAvailableTablesUseCase,
    private readonly checkSlotAvailabilityUseCase: CheckSlotAvailabilityUseCase
  ) {}

  /**
   * Obtenir les créneaux disponibles pour une date donnée
   */
  getAvailability = asyncHandler(async (req: Request, res: Response) => {
    const request: GetAvailabilityRequest = {
      date: new Date(req.query.date as string),
      partySize: parseInt(req.query.partySize as string) || 2,
      restaurantId: req.query.restaurantId as string,
    };

    try {
      const response = await this.getAvailabilityUseCase.execute(request);
      
      res.json({
        success: true,
        data: {
          date: response.dayAvailability.date,
          partySize: response.dayAvailability.partySize,
          availableSlots: response.dayAvailability.getAvailableTimes(),
          allSlots: response.dayAvailability.slots.map(slot => slot.toJSON()),
          restaurant: {
            openingHours: response.dayAvailability.openingHours,
          },
          totalSlots: response.dayAvailability.getTotalSlots(),
          totalAvailableSlots: response.dayAvailability.getTotalAvailableSlots(),
          availabilityPercentage: response.dayAvailability.getAvailabilityPercentage(),
        },
      });
    } catch (error) {
      this.handleError(error, res);
    }
  });

  /**
   * Obtenir les tables disponibles pour une date/heure donnée
   */
  getAvailableTables = asyncHandler(async (req: Request, res: Response) => {
    const request: GetAvailableTablesRequest = {
      date: new Date(req.query.date as string),
      time: req.query.time as string,
      partySize: parseInt(req.query.partySize as string) || 2,
      restaurantId: req.query.restaurantId as string,
    };

    try {
      const response = await this.getAvailableTablesUseCase.execute(request);
      
      res.json({
        success: true,
        data: {
          date: response.date,
          time: response.time,
          partySize: response.partySize,
          availableTables: response.availableTables,
          count: response.count,
        },
      });
    } catch (error) {
      this.handleError(error, res);
    }
  });

  /**
   * Vérifier la disponibilité d'un créneau spécifique
   */
  checkSlotAvailability = asyncHandler(async (req: Request, res: Response) => {
    const request: CheckSlotAvailabilityRequest = {
      date: new Date(req.query.date as string),
      time: req.query.time as string,
      partySize: parseInt(req.query.partySize as string) || 2,
      restaurantId: req.query.restaurantId as string,
    };

    try {
      const response = await this.checkSlotAvailabilityUseCase.execute(request);
      
      res.json({
        success: true,
        data: {
          date: response.date,
          time: response.time,
          partySize: response.partySize,
          isAvailable: response.isAvailable,
          availableTable: response.availableTable,
        },
      });
    } catch (error) {
      this.handleError(error, res);
    }
  });

  /**
   * Gestion centralisée des erreurs
   */
  private handleError(error: any, res: Response): void {
    logger.error('AvailabilityController error:', error);
    
    if (error.message.includes('Date is required') || 
        error.message.includes('Time is required') ||
        error.message.includes('Party size must be at least 1') ||
        error.message.includes('Party size cannot exceed 20') ||
        error.message.includes('Time must be in HH:MM format') ||
        error.message.includes('Date cannot be in the past') ||
        error.message.includes('Date cannot be more than 1 year in the future')) {
      res.status(400).json({ success: false, message: error.message });
    } else if (error.message.includes('Restaurant not found')) {
      res.status(404).json({ success: false, message: error.message });
    } else {
      res.status(500).json({ success: false, message: 'Internal Server Error' });
    }
  }
}
