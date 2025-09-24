import { ReservationService } from '../../services/reservationService';
import prisma from '../../config/database';
import { CreateReservationData } from '../../types/reservation.types';

// Mock Prisma
jest.mock('../../config/database', () => ({
  reservation: {
    create: jest.fn(),
    findMany: jest.fn(),
    findUnique: jest.fn(),
    update: jest.fn(),
    delete: jest.fn(),
  },
  table: {
    findMany: jest.fn(),
  },
  restaurant: {
    findFirst: jest.fn(),
  },
}));

const mockPrisma = prisma as jest.Mocked<typeof prisma>;

describe('ReservationService', () => {
  let reservationService: ReservationService;

  beforeEach(() => {
    reservationService = new ReservationService();
    jest.clearAllMocks();
  });

  describe('createReservation', () => {
    it('should create a reservation successfully', async () => {
      const reservationData: CreateReservationData = {
        date: new Date('2024-12-25'),
        time: '19:00',
        partySize: 4,
        clientName: 'John Doe',
        clientEmail: 'john@example.com',
        clientPhone: '+1234567890',
        specialRequests: 'Table near window',
      };

      const mockRestaurant = { id: 'restaurant-1', name: 'Test Restaurant' };
      const mockTable = { id: 'table-1', number: 1, capacity: 4 };
      const mockReservation = {
        id: 'reservation-1',
        ...reservationData,
        status: 'PENDING',
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      mockPrisma.restaurant.findFirst.mockResolvedValue(mockRestaurant as any);
      mockPrisma.table.findMany.mockResolvedValue([mockTable as any]);
      mockPrisma.reservation.create.mockResolvedValue(mockReservation as any);

      const result = await reservationService.createReservation(reservationData);

      expect(result).toEqual(mockReservation);
      expect(mockPrisma.restaurant.findFirst).toHaveBeenCalled();
      expect(mockPrisma.table.findMany).toHaveBeenCalled();
      expect(mockPrisma.reservation.create).toHaveBeenCalled();
    });

    it('should throw error when no restaurant found', async () => {
      const reservationData: CreateReservationData = {
        date: new Date('2024-12-25'),
        time: '19:00',
        partySize: 4,
        clientName: 'John Doe',
        clientEmail: 'john@example.com',
        clientPhone: '+1234567890',
      };

      mockPrisma.restaurant.findFirst.mockResolvedValue(null);

      await expect(reservationService.createReservation(reservationData))
        .rejects
        .toThrow('Restaurant not found');
    });

    it('should throw error when no available tables', async () => {
      const reservationData: CreateReservationData = {
        date: new Date('2024-12-25'),
        time: '19:00',
        partySize: 4,
        clientName: 'John Doe',
        clientEmail: 'john@example.com',
        clientPhone: '+1234567890',
      };

      const mockRestaurant = { id: 'restaurant-1', name: 'Test Restaurant' };

      mockPrisma.restaurant.findFirst.mockResolvedValue(mockRestaurant as any);
      mockPrisma.table.findMany.mockResolvedValue([]);

      await expect(reservationService.createReservation(reservationData))
        .rejects
        .toThrow('No tables available for the selected time slot');
    });
  });

  describe('getReservations', () => {
    it('should return reservations with filters', async () => {
      const mockReservations = [
        {
          id: 'reservation-1',
          date: new Date('2024-12-25'),
          time: '19:00',
          partySize: 4,
          status: 'PENDING',
          clientName: 'John Doe',
          clientEmail: 'john@example.com',
          clientPhone: '+1234567890',
        },
      ];

      mockPrisma.reservation.findMany.mockResolvedValue(mockReservations as any);

      const result = await reservationService.getReservations({
        date: new Date('2024-12-25'),
        status: 'PENDING',
      });

      expect(result).toEqual(mockReservations);
      expect(mockPrisma.reservation.findMany).toHaveBeenCalled();
    });
  });

  describe('getReservationById', () => {
    it('should return reservation by id', async () => {
      const mockReservation = {
        id: 'reservation-1',
        date: new Date('2024-12-25'),
        time: '19:00',
        partySize: 4,
        status: 'PENDING',
        clientName: 'John Doe',
        clientEmail: 'john@example.com',
        clientPhone: '+1234567890',
      };

      mockPrisma.reservation.findUnique.mockResolvedValue(mockReservation as any);

      const result = await reservationService.getReservationById('reservation-1');

      expect(result).toEqual(mockReservation);
      expect(mockPrisma.reservation.findUnique).toHaveBeenCalledWith({
        where: { id: 'reservation-1' },
      });
    });

    it('should return null when reservation not found', async () => {
      mockPrisma.reservation.findUnique.mockResolvedValue(null);

      const result = await reservationService.getReservationById('non-existent');

      expect(result).toBeNull();
    });
  });

  describe('updateReservation', () => {
    it('should update reservation successfully', async () => {
      const updateData = {
        partySize: 6,
        specialRequests: 'Updated request',
      };

      const mockUpdatedReservation = {
        id: 'reservation-1',
        date: new Date('2024-12-25'),
        time: '19:00',
        partySize: 6,
        status: 'PENDING',
        clientName: 'John Doe',
        clientEmail: 'john@example.com',
        clientPhone: '+1234567890',
        specialRequests: 'Updated request',
      };

      mockPrisma.reservation.update.mockResolvedValue(mockUpdatedReservation as any);

      const result = await reservationService.updateReservation('reservation-1', updateData);

      expect(result).toEqual(mockUpdatedReservation);
      expect(mockPrisma.reservation.update).toHaveBeenCalledWith({
        where: { id: 'reservation-1' },
        data: updateData,
      });
    });
  });

  describe('deleteReservation', () => {
    it('should delete reservation successfully', async () => {
      const mockDeletedReservation = {
        id: 'reservation-1',
        date: new Date('2024-12-25'),
        time: '19:00',
        partySize: 4,
        status: 'CANCELLED',
        clientName: 'John Doe',
        clientEmail: 'john@example.com',
        clientPhone: '+1234567890',
      };

      mockPrisma.reservation.update.mockResolvedValue(mockDeletedReservation as any);

      const result = await reservationService.deleteReservation('reservation-1', 'Customer request');

      expect(result).toEqual(mockDeletedReservation);
      expect(mockPrisma.reservation.update).toHaveBeenCalledWith({
        where: { id: 'reservation-1' },
        data: {
          status: 'CANCELLED',
          cancellationReason: 'Customer request',
        },
      });
    });
  });
});

