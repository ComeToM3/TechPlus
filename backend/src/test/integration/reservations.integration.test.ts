import request from 'supertest';
import app from '../../app';
import prisma from '../../config/database';

// Mock Prisma
jest.mock('../../config/database', () => ({
  reservation: {
    findMany: jest.fn(),
    findUnique: jest.fn(),
    create: jest.fn(),
    update: jest.fn(),
  },
  restaurant: {
    findFirst: jest.fn(),
  },
  table: {
    findMany: jest.fn(),
  },
  user: {
    findUnique: jest.fn(),
  },
}));

const mockPrisma = prisma as jest.Mocked<typeof prisma>;

describe('Reservations Integration Tests', () => {
  let authToken: string;

  beforeEach(async () => {
    jest.clearAllMocks();

    // Setup mock user for authentication
    const mockUser = {
      id: 'user-1',
      email: 'test@example.com',
      name: 'Test User',
      role: 'CLIENT',
    };

    mockPrisma.user.findUnique.mockResolvedValue(mockUser as any);

    // Get auth token
    const loginResponse = await request(app)
      .post('/api/auth/login')
      .send({
        email: 'test@example.com',
        password: 'password123',
      });

    authToken = loginResponse.body.token;
  });

  describe('GET /api/reservations', () => {
    it('should return user reservations', async () => {
      const mockReservations = [
        {
          id: 'reservation-1',
          date: new Date('2024-12-25'),
          time: '19:00',
          partySize: 4,
          status: 'PENDING',
          clientName: 'Test User',
          clientEmail: 'test@example.com',
          clientPhone: '+1234567890',
        },
      ];

      mockPrisma.reservation.findMany.mockResolvedValue(mockReservations as any);

      const response = await request(app)
        .get('/api/reservations')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.reservations).toHaveLength(1);
      expect(response.body.reservations[0].id).toBe('reservation-1');
    });

    it('should return error without authentication', async () => {
      const response = await request(app)
        .get('/api/reservations')
        .expect(401);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain('Access token required');
    });
  });

  describe('POST /api/reservations', () => {
    it('should create a new reservation', async () => {
      const reservationData = {
        date: '2024-12-25',
        time: '19:00',
        partySize: 4,
        clientName: 'Test User',
        clientEmail: 'test@example.com',
        clientPhone: '+1234567890',
        specialRequests: 'Table near window',
      };

      const mockRestaurant = { id: 'restaurant-1', name: 'Test Restaurant' };
      const mockTable = { id: 'table-1', number: 1, capacity: 4 };
      const mockReservation = {
        id: 'reservation-1',
        ...reservationData,
        date: new Date(reservationData.date),
        status: 'PENDING',
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      mockPrisma.restaurant.findFirst.mockResolvedValue(mockRestaurant as any);
      mockPrisma.table.findMany.mockResolvedValue([mockTable as any]);
      mockPrisma.reservation.create.mockResolvedValue(mockReservation as any);

      const response = await request(app)
        .post('/api/reservations')
        .set('Authorization', `Bearer ${authToken}`)
        .send(reservationData)
        .expect(201);

      expect(response.body.success).toBe(true);
      expect(response.body.reservation.id).toBe('reservation-1');
      expect(response.body.reservation.clientName).toBe('Test User');
    });

    it('should return error for invalid reservation data', async () => {
      const invalidData = {
        date: 'invalid-date',
        time: 'invalid-time',
        partySize: -1,
      };

      const response = await request(app)
        .post('/api/reservations')
        .set('Authorization', `Bearer ${authToken}`)
        .send(invalidData)
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain('validation');
    });

    it('should return error when no tables available', async () => {
      const reservationData = {
        date: '2024-12-25',
        time: '19:00',
        partySize: 4,
        clientName: 'Test User',
        clientEmail: 'test@example.com',
        clientPhone: '+1234567890',
      };

      const mockRestaurant = { id: 'restaurant-1', name: 'Test Restaurant' };

      mockPrisma.restaurant.findFirst.mockResolvedValue(mockRestaurant as any);
      mockPrisma.table.findMany.mockResolvedValue([]);

      const response = await request(app)
        .post('/api/reservations')
        .set('Authorization', `Bearer ${authToken}`)
        .send(reservationData)
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain('No tables available');
    });
  });

  describe('GET /api/reservations/:id', () => {
    it('should return reservation by id', async () => {
      const mockReservation = {
        id: 'reservation-1',
        date: new Date('2024-12-25'),
        time: '19:00',
        partySize: 4,
        status: 'PENDING',
        clientName: 'Test User',
        clientEmail: 'test@example.com',
        clientPhone: '+1234567890',
      };

      mockPrisma.reservation.findUnique.mockResolvedValue(mockReservation as any);

      const response = await request(app)
        .get('/api/reservations/reservation-1')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.reservation.id).toBe('reservation-1');
    });

    it('should return error for non-existent reservation', async () => {
      mockPrisma.reservation.findUnique.mockResolvedValue(null);

      const response = await request(app)
        .get('/api/reservations/non-existent')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(404);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain('Reservation not found');
    });
  });

  describe('PUT /api/reservations/:id', () => {
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
        clientName: 'Test User',
        clientEmail: 'test@example.com',
        clientPhone: '+1234567890',
        specialRequests: 'Updated request',
      };

      mockPrisma.reservation.findUnique.mockResolvedValue({
        id: 'reservation-1',
        userId: 'user-1',
      } as any);
      mockPrisma.reservation.update.mockResolvedValue(mockUpdatedReservation as any);

      const response = await request(app)
        .put('/api/reservations/reservation-1')
        .set('Authorization', `Bearer ${authToken}`)
        .send(updateData)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.reservation.partySize).toBe(6);
      expect(response.body.reservation.specialRequests).toBe('Updated request');
    });

    it('should return error when trying to update another user\'s reservation', async () => {
      const updateData = {
        partySize: 6,
      };

      mockPrisma.reservation.findUnique.mockResolvedValue({
        id: 'reservation-1',
        userId: 'other-user',
      } as any);

      const response = await request(app)
        .put('/api/reservations/reservation-1')
        .set('Authorization', `Bearer ${authToken}`)
        .send(updateData)
        .expect(403);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain('not authorized');
    });
  });

  describe('DELETE /api/reservations/:id', () => {
    it('should cancel reservation successfully', async () => {
      const mockCancelledReservation = {
        id: 'reservation-1',
        date: new Date('2024-12-25'),
        time: '19:00',
        partySize: 4,
        status: 'CANCELLED',
        clientName: 'Test User',
        clientEmail: 'test@example.com',
        clientPhone: '+1234567890',
        cancellationReason: 'Customer request',
      };

      mockPrisma.reservation.findUnique.mockResolvedValue({
        id: 'reservation-1',
        userId: 'user-1',
      } as any);
      mockPrisma.reservation.update.mockResolvedValue(mockCancelledReservation as any);

      const response = await request(app)
        .delete('/api/reservations/reservation-1')
        .set('Authorization', `Bearer ${authToken}`)
        .send({ reason: 'Customer request' })
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.reservation.status).toBe('CANCELLED');
      expect(response.body.reservation.cancellationReason).toBe('Customer request');
    });

    it('should return error when trying to cancel another user\'s reservation', async () => {
      mockPrisma.reservation.findUnique.mockResolvedValue({
        id: 'reservation-1',
        userId: 'other-user',
      } as any);

      const response = await request(app)
        .delete('/api/reservations/reservation-1')
        .set('Authorization', `Bearer ${authToken}`)
        .send({ reason: 'Customer request' })
        .expect(403);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain('not authorized');
    });
  });

  describe('GET /api/reservations/manage/:token', () => {
    it('should return reservation by management token', async () => {
      const mockReservation = {
        id: 'reservation-1',
        date: new Date('2024-12-25'),
        time: '19:00',
        partySize: 4,
        status: 'PENDING',
        clientName: 'Test User',
        clientEmail: 'test@example.com',
        clientPhone: '+1234567890',
        managementToken: 'valid-token',
        tokenExpiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000), // 24h from now
      };

      mockPrisma.reservation.findUnique.mockResolvedValue(mockReservation as any);

      const response = await request(app)
        .get('/api/reservations/manage/valid-token')
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.reservation.id).toBe('reservation-1');
      expect(response.body.reservation.managementToken).toBe('valid-token');
    });

    it('should return error for invalid management token', async () => {
      mockPrisma.reservation.findUnique.mockResolvedValue(null);

      const response = await request(app)
        .get('/api/reservations/manage/invalid-token')
        .expect(404);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain('Reservation not found');
    });

    it('should return error for expired management token', async () => {
      const mockExpiredReservation = {
        id: 'reservation-1',
        managementToken: 'expired-token',
        tokenExpiresAt: new Date(Date.now() - 24 * 60 * 60 * 1000), // 24h ago
      };

      mockPrisma.reservation.findUnique.mockResolvedValue(mockExpiredReservation as any);

      const response = await request(app)
        .get('/api/reservations/manage/expired-token')
        .expect(410);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain('Management token has expired');
    });
  });
});

