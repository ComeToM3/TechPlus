import { Request, Response } from 'express';
import { GetScheduleConfigUseCase } from '../domain/use-cases/schedule/GetScheduleConfigUseCase';
import { CreateOrUpdateScheduleConfigUseCase } from '../domain/use-cases/schedule/CreateOrUpdateScheduleConfigUseCase';
import { DeleteScheduleConfigUseCase } from '../domain/use-cases/schedule/DeleteScheduleConfigUseCase';
import { GetAvailableSlotsUseCase } from '../domain/use-cases/schedule/GetAvailableSlotsUseCase';
import { ValidateReservationUseCase } from '../domain/use-cases/schedule/ValidateReservationUseCase';
import logger from '../utils/logger';

export class ScheduleControllerNew {
  constructor(
    private getScheduleConfigUseCase: GetScheduleConfigUseCase,
    private createOrUpdateScheduleConfigUseCase: CreateOrUpdateScheduleConfigUseCase,
    private deleteScheduleConfigUseCase: DeleteScheduleConfigUseCase,
    private getAvailableSlotsUseCase: GetAvailableSlotsUseCase,
    private validateReservationUseCase: ValidateReservationUseCase
  ) {}

  async getScheduleConfig(req: Request, res: Response): Promise<void> {
    try {
      const user = (req as any).user;
      if (!user || (user.role !== 'ADMIN' && user.role !== 'SUPER_ADMIN')) {
        res.status(403).json({
          success: false,
          message: 'Access denied. Admin privileges required.',
        });
        return;
      }

      // Récupérer le restaurantId depuis la base de données
      const { PrismaClient } = await import('@prisma/client');
      const prisma = new PrismaClient();
      const restaurant = await prisma.restaurant.findFirst();
      const restaurantId = restaurant?.id;
      
      if (!restaurantId) {
        res.status(404).json({
          success: false,
          message: 'No restaurant found',
        });
        return;
      }

      const result = await this.getScheduleConfigUseCase.execute({
        restaurantId,
      });

      if (!result.success) {
        res.status(404).json({
          success: false,
          message: result.message,
        });
        return;
      }

      logger.info('Schedule config retrieved', {
        userId: user.id,
        restaurantId,
        ip: req.ip,
      });

      res.status(200).json({
        success: true,
        data: result.data,
      });
    } catch (error) {
      logger.error('Failed to get schedule config', {
        error: error instanceof Error ? error.message : 'Unknown error',
        stack: error instanceof Error ? error.stack : undefined,
      });

      res.status(500).json({
        success: false,
        message: 'Failed to get schedule configuration',
        error: error instanceof Error ? error.message : 'Unknown error',
      });
    }
  }

  async createOrUpdateScheduleConfig(req: Request, res: Response): Promise<void> {
    try {
      const user = (req as any).user;
      if (!user || (user.role !== 'ADMIN' && user.role !== 'SUPER_ADMIN')) {
        res.status(403).json({
          success: false,
          message: 'Access denied. Admin privileges required.',
        });
        return;
      }

      const {
        slotDurationMinutes,
        bufferTimeMinutes,
        maxAdvanceBookingDays,
        minAdvanceBookingHours,
        allowSameDayBooking,
        allowWeekendBooking,
        defaultCapacityPerSlot,
        daySchedules,
      } = req.body;

      // Validation des données
      if (!daySchedules || !Array.isArray(daySchedules)) {
        res.status(400).json({
          success: false,
          message: 'Day schedules are required',
        });
        return;
      }

      // Récupérer le restaurantId depuis la base de données
      const { PrismaClient } = await import('@prisma/client');
      const prisma = new PrismaClient();
      const restaurant = await prisma.restaurant.findFirst();
      const restaurantId = restaurant?.id;
      
      if (!restaurantId) {
        res.status(404).json({
          success: false,
          message: 'No restaurant found',
        });
        return;
      }

      const result = await this.createOrUpdateScheduleConfigUseCase.execute({
        restaurantId,
        slotDurationMinutes,
        bufferTimeMinutes,
        maxAdvanceBookingDays,
        minAdvanceBookingHours,
        allowSameDayBooking,
        allowWeekendBooking,
        defaultCapacityPerSlot,
        daySchedules,
      });

      if (!result.success) {
        res.status(400).json({
          success: false,
          message: result.message,
        });
        return;
      }

      logger.info('Schedule config updated', {
        userId: user.id,
        restaurantId,
        configId: result.data?.id,
        ip: req.ip,
      });

      res.status(200).json({
        success: true,
        data: result.data,
        message: result.message,
      });
    } catch (error) {
      logger.error('Failed to create/update schedule config', {
        error: error instanceof Error ? error.message : 'Unknown error',
        stack: error instanceof Error ? error.stack : undefined,
      });

      res.status(500).json({
        success: false,
        message: 'Failed to save schedule configuration',
        error: error instanceof Error ? error.message : 'Unknown error',
      });
    }
  }

  async deleteScheduleConfig(req: Request, res: Response): Promise<void> {
    try {
      const user = (req as any).user;
      if (!user || (user.role !== 'ADMIN' && user.role !== 'SUPER_ADMIN')) {
        res.status(403).json({
          success: false,
          message: 'Access denied. Admin privileges required.',
        });
        return;
      }

      // Récupérer le restaurantId depuis la base de données
      const { PrismaClient } = await import('@prisma/client');
      const prisma = new PrismaClient();
      const restaurant = await prisma.restaurant.findFirst();
      const restaurantId = restaurant?.id;
      
      if (!restaurantId) {
        res.status(404).json({
          success: false,
          message: 'No restaurant found',
        });
        return;
      }

      const result = await this.deleteScheduleConfigUseCase.execute({
        restaurantId,
      });

      if (!result.success) {
        res.status(404).json({
          success: false,
          message: result.message,
        });
        return;
      }

      logger.info('Schedule config deleted', {
        userId: user.id,
        restaurantId,
        ip: req.ip,
      });

      res.status(200).json({
        success: true,
        message: result.message,
      });
    } catch (error) {
      logger.error('Failed to delete schedule config', {
        error: error instanceof Error ? error.message : 'Unknown error',
        stack: error instanceof Error ? error.stack : undefined,
      });

      res.status(500).json({
        success: false,
        message: 'Failed to delete schedule configuration',
        error: error instanceof Error ? error.message : 'Unknown error',
      });
    }
  }

  async getAvailableSlots(req: Request, res: Response): Promise<void> {
    try {
      const user = (req as any).user;
      if (!user || (user.role !== 'ADMIN' && user.role !== 'SUPER_ADMIN')) {
        res.status(403).json({
          success: false,
          message: 'Access denied. Admin privileges required.',
        });
        return;
      }

      const { date, partySize = 1 } = req.query;

      if (!date) {
        res.status(400).json({
          success: false,
          message: 'Date parameter is required',
        });
        return;
      }

      // Récupérer le restaurantId depuis la base de données
      const { PrismaClient } = await import('@prisma/client');
      const prisma = new PrismaClient();
      const restaurant = await prisma.restaurant.findFirst();
      const restaurantId = restaurant?.id;
      
      if (!restaurantId) {
        res.status(404).json({
          success: false,
          message: 'No restaurant found',
        });
        return;
      }

      const result = await this.getAvailableSlotsUseCase.execute({
        restaurantId,
        date: date as string,
        partySize: parseInt(partySize as string),
      });

      if (!result.success) {
        res.status(404).json({
          success: false,
          message: result.message,
        });
        return;
      }

      logger.info('Available slots retrieved', {
        userId: user.id,
        restaurantId,
        date,
        partySize,
        slotsCount: result.data?.totalSlots,
        ip: req.ip,
      });

      res.status(200).json({
        success: true,
        data: result.data,
      });
    } catch (error) {
      logger.error('Failed to get available slots', {
        error: error instanceof Error ? error.message : 'Unknown error',
        ip: req.ip,
      });

      res.status(500).json({
        success: false,
        message: 'Failed to retrieve available slots',
        error: error instanceof Error ? error.message : 'Unknown error',
      });
    }
  }

  async validateReservation(req: Request, res: Response): Promise<void> {
    try {
      const user = (req as any).user;
      if (!user || (user.role !== 'ADMIN' && user.role !== 'SUPER_ADMIN')) {
        res.status(403).json({
          success: false,
          message: 'Access denied. Admin privileges required.',
        });
        return;
      }

      const { date, time, partySize = 1 } = req.body;

      if (!date || !time) {
        res.status(400).json({
          success: false,
          message: 'Date and time parameters are required',
        });
        return;
      }

      // Récupérer le restaurantId depuis la base de données
      const { PrismaClient } = await import('@prisma/client');
      const prisma = new PrismaClient();
      const restaurant = await prisma.restaurant.findFirst();
      const restaurantId = restaurant?.id;
      
      if (!restaurantId) {
        res.status(404).json({
          success: false,
          message: 'No restaurant found',
        });
        return;
      }

      const result = await this.validateReservationUseCase.execute({
        restaurantId,
        date,
        time,
        partySize: parseInt(partySize),
      });

      if (!result.success) {
        res.status(400).json({
          success: false,
          message: result.message,
        });
        return;
      }

      logger.info('Reservation validation completed', {
        userId: user.id,
        restaurantId,
        date,
        time,
        partySize,
        canReserve: result.data?.canReserve,
        ip: req.ip,
      });

      res.status(200).json({
        success: true,
        data: result.data,
      });
    } catch (error) {
      logger.error('Failed to validate reservation', {
        error: error instanceof Error ? error.message : 'Unknown error',
        ip: req.ip,
      });

      res.status(500).json({
        success: false,
        message: 'Failed to validate reservation',
        error: error instanceof Error ? error.message : 'Unknown error',
      });
    }
  }
}
