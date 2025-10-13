import { Request, Response } from 'express';
import { asyncHandler } from '@/middleware/error';
import logger from '@/utils/logger';

import { CreateReservationUseCase, CreateReservationRequest } from '../domain/use-cases/reservation/CreateReservationUseCase';
import { GetReservationUseCase, GetReservationRequest } from '../domain/use-cases/reservation/GetReservationUseCase';
import { GetUserReservationsUseCase, GetUserReservationsRequest } from '../domain/use-cases/reservation/GetUserReservationsUseCase';
import { UpdateReservationUseCase, UpdateReservationRequest } from '../domain/use-cases/reservation/UpdateReservationUseCase';
import { CancelReservationUseCase, CancelReservationRequest } from '../domain/use-cases/reservation/CancelReservationUseCase';
import { GetReservationByTokenUseCase, GetReservationByTokenRequest } from '../domain/use-cases/reservation/GetReservationByTokenUseCase';
import { UpdateReservationByTokenUseCase, UpdateReservationByTokenRequest } from '../domain/use-cases/reservation/UpdateReservationByTokenUseCase';
import { CancelReservationByTokenUseCase, CancelReservationByTokenRequest } from '../domain/use-cases/reservation/CancelReservationByTokenUseCase';

export class ReservationController {
  constructor(
    private readonly createReservationUseCase: CreateReservationUseCase,
    private readonly getReservationUseCase: GetReservationUseCase,
    private readonly getUserReservationsUseCase: GetUserReservationsUseCase,
    private readonly updateReservationUseCase: UpdateReservationUseCase,
    private readonly cancelReservationUseCase: CancelReservationUseCase,
    private readonly getReservationByTokenUseCase: GetReservationByTokenUseCase,
    private readonly updateReservationByTokenUseCase: UpdateReservationByTokenUseCase,
    private readonly cancelReservationByTokenUseCase: CancelReservationByTokenUseCase
  ) {}

  /**
   * Créer une nouvelle réservation
   */
  createReservation = asyncHandler(async (req: Request, res: Response) => {
    const request: CreateReservationRequest = {
      date: req.body.date,
      time: req.body.time,
      partySize: req.body.partySize,
      duration: req.body.duration,
      notes: req.body.notes,
      specialRequests: req.body.specialRequests,
      clientName: req.body.clientName,
      clientEmail: req.body.clientEmail,
      clientPhone: req.body.clientPhone,
      userId: (req.user as any)?.id,
    };

    try {
      const response = await this.createReservationUseCase.execute(request);
      res.status(201).json({
        success: true,
        message: 'Reservation created successfully',
        data: response.reservation.toJSON(),
      });
    } catch (error) {
      this.handleError(error, res);
    }
  });

  /**
   * Obtenir les réservations de l'utilisateur connecté
   */
  getUserReservations = asyncHandler(async (req: Request, res: Response) => {
    const request: GetUserReservationsRequest = {
      userId: (req.user as any)?.id || '',
      ...(req.query.status && { status: req.query.status as any }),
      ...(req.query.date && { date: new Date(req.query.date as string) }),
      ...(req.query.dateFrom && { dateFrom: new Date(req.query.dateFrom as string) }),
      ...(req.query.dateTo && { dateTo: new Date(req.query.dateTo as string) }),
      ...(req.query.partySize && { partySize: parseInt(req.query.partySize as string) }),
      ...(req.query.requiresPayment && { requiresPayment: req.query.requiresPayment === 'true' }),
      ...(req.query.page && { page: parseInt(req.query.page as string) }),
      ...(req.query.limit && { limit: parseInt(req.query.limit as string) }),
    };

    try {
      const response = await this.getUserReservationsUseCase.execute(request);
      res.json({
        success: true,
        data: {
          reservations: response.reservations.map(r => r.toJSON()),
          pagination: response.pagination,
        },
      });
    } catch (error) {
      this.handleError(error, res);
    }
  });

  /**
   * Obtenir une réservation par ID
   */
  getReservationById = asyncHandler(async (req: Request, res: Response) => {
    const request: GetReservationRequest = {
      reservationId: req.params.id || '',
      userId: (req.user as any)?.id,
    };

    try {
      const response = await this.getReservationUseCase.execute(request);
      res.json({
        success: true,
        data: { reservation: response.reservation.toJSON() },
      });
    } catch (error) {
      this.handleError(error, res);
    }
  });

  /**
   * Modifier une réservation
   */
  updateReservation = asyncHandler(async (req: Request, res: Response) => {
    const request: UpdateReservationRequest = {
      reservationId: req.params.id || '',
      userId: (req.user as any)?.id,
      date: req.body.date,
      time: req.body.time,
      partySize: req.body.partySize,
      duration: req.body.duration,
      notes: req.body.notes,
      specialRequests: req.body.specialRequests,
      clientName: req.body.clientName,
      clientEmail: req.body.clientEmail,
      clientPhone: req.body.clientPhone,
    };

    try {
      const response = await this.updateReservationUseCase.execute(request);
      res.json({
        success: true,
        message: 'Reservation updated successfully',
        data: { reservation: response.reservation.toJSON() },
      });
    } catch (error) {
      this.handleError(error, res);
    }
  });

  /**
   * Annuler une réservation
   */
  cancelReservation = asyncHandler(async (req: Request, res: Response) => {
    const request: CancelReservationRequest = {
      reservationId: req.params.id || '',
      userId: (req.user as any)?.id,
      reason: req.body.reason,
    };

    try {
      const response = await this.cancelReservationUseCase.execute(request);
      res.json({
        success: true,
        message: 'Reservation cancelled successfully',
        data: { reservation: response.reservation.toJSON() },
      });
    } catch (error) {
      this.handleError(error, res);
    }
  });

  /**
   * Obtenir une réservation par token (Guest)
   */
  getReservationByToken = asyncHandler(async (req: Request, res: Response) => {
    const request: GetReservationByTokenRequest = {
      token: req.params.token || '',
    };

    try {
      const response = await this.getReservationByTokenUseCase.execute(request);
      res.json({
        success: true,
        data: { reservation: response.reservation.toJSON() },
      });
    } catch (error) {
      this.handleError(error, res);
    }
  });

  /**
   * Modifier une réservation par token (Guest)
   */
  updateReservationByToken = asyncHandler(async (req: Request, res: Response) => {
    const request: UpdateReservationByTokenRequest = {
      token: req.params.token || '',
      date: req.body.date,
      time: req.body.time,
      partySize: req.body.partySize,
      duration: req.body.duration,
      notes: req.body.notes,
      specialRequests: req.body.specialRequests,
      clientName: req.body.clientName,
      clientEmail: req.body.clientEmail,
      clientPhone: req.body.clientPhone,
    };

    try {
      const response = await this.updateReservationByTokenUseCase.execute(request);
      res.json({
        success: true,
        message: 'Reservation updated successfully',
        data: { reservation: response.reservation.toJSON() },
      });
    } catch (error) {
      this.handleError(error, res);
    }
  });

  /**
   * Annuler une réservation par token (Guest)
   */
  cancelReservationByToken = asyncHandler(async (req: Request, res: Response) => {
    const request: CancelReservationByTokenRequest = {
      token: req.params.token || '',
      reason: req.body.reason,
    };

    try {
      const response = await this.cancelReservationByTokenUseCase.execute(request);
      res.json({
        success: true,
        message: 'Reservation cancelled successfully',
        data: { reservation: response.reservation.toJSON() },
      });
    } catch (error) {
      this.handleError(error, res);
    }
  });

  /**
   * Gestion centralisée des erreurs
   */
  private handleError(error: any, res: Response): void {
    logger.error('ReservationController error:', error);
    
    if (error.message.includes('Reservation not found')) {
      res.status(404).json({ success: false, message: error.message });
    } else if (error.message.includes('Access denied')) {
      res.status(403).json({ success: false, message: error.message });
    } else if (error.message.includes('No tables available')) {
      res.status(409).json({ success: false, message: error.message });
    } else if (error.message.includes('Management token has expired')) {
      res.status(410).json({ success: false, message: error.message });
    } else if (error.message.includes('Reservation cannot be') || 
               error.message.includes('Cannot create reservation') ||
               error.message.includes('Cannot update reservation')) {
      res.status(400).json({ success: false, message: error.message });
    } else if (error.message.includes('is required') || 
               error.message.includes('must be')) {
      res.status(400).json({ success: false, message: error.message });
    } else {
      res.status(500).json({ success: false, message: 'Internal Server Error' });
    }
  }
}
