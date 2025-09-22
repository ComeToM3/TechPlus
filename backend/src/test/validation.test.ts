import request from 'supertest';
import app from '../app';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

describe('Validation Middleware Tests', () => {
  beforeAll(async () => {
    // Nettoyer les données de test
    await prisma.reservation.deleteMany({});
    await prisma.user.deleteMany({});
  });

  afterAll(async () => {
    await prisma.$disconnect();
  });

  describe('Joi Validation', () => {
    it('should validate registration data correctly', async () => {
      const validData = {
        email: 'test@example.com',
        password: 'Password123!',
        name: 'John Doe',
        phone: '+33123456789',
      };

      const response = await request(app).post('/api/auth/register').send(validData).expect(201);

      expect(response.body).toHaveProperty('user');
      expect(response.body.user.email).toBe(validData.email);
    });

    it('should reject invalid email format', async () => {
      const invalidData = {
        email: 'invalid-email',
        password: 'Password123!',
        name: 'John Doe',
      };

      const response = await request(app).post('/api/auth/register').send(invalidData).expect(400);

      expect(response.body.error).toBe('Validation failed');
      expect(response.body.details).toContainEqual(
        expect.objectContaining({
          message: expect.stringContaining('email'),
        })
      );
    });

    it('should reject weak password', async () => {
      const invalidData = {
        email: 'test2@example.com',
        password: 'weak',
        name: 'John Doe',
      };

      const response = await request(app).post('/api/auth/register').send(invalidData).expect(400);

      expect(response.body.error).toBe('Validation failed');
      expect(response.body.details).toContainEqual(
        expect.objectContaining({
          message: expect.stringContaining('password'),
        })
      );
    });

    it('should reject invalid phone number', async () => {
      const invalidData = {
        email: 'test3@example.com',
        password: 'Password123!',
        name: 'John Doe',
        phone: 'invalid-phone',
      };

      const response = await request(app).post('/api/auth/register').send(invalidData).expect(400);

      expect(response.body.error).toBe('Validation failed');
      expect(response.body.details).toContainEqual(
        expect.objectContaining({
          message: expect.stringContaining('phone'),
        })
      );
    });
  });

  describe('Reservation Validation', () => {
    it('should validate reservation creation correctly', async () => {
      const validData = {
        date: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString().split('T')[0], // Demain
        time: '19:00',
        partySize: 4,
        specialRequests: 'Table near the window',
      };

      const response = await request(app)
        .post('/api/reservations/guest')
        .send(validData)
        .expect(201);

      expect(response.body).toHaveProperty('reservation');
      expect(response.body.reservation.partySize).toBe(validData.partySize);
    });

    it('should reject past date', async () => {
      const invalidData = {
        date: '2020-01-01', // Date passée
        time: '19:00',
        partySize: 4,
      };

      const response = await request(app)
        .post('/api/reservations/guest')
        .send(invalidData)
        .expect(400);

      expect(response.body.error).toBe('Validation failed');
      expect(response.body.details).toContainEqual(
        expect.objectContaining({
          message: expect.stringContaining('future'),
        })
      );
    });

    it('should reject invalid party size', async () => {
      const invalidData = {
        date: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString().split('T')[0],
        time: '19:00',
        partySize: 25, // Trop de personnes
      };

      const response = await request(app)
        .post('/api/reservations/guest')
        .send(invalidData)
        .expect(400);

      expect(response.body.error).toBe('Validation failed');
      expect(response.body.details).toContainEqual(
        expect.objectContaining({
          message: expect.stringContaining('partySize'),
        })
      );
    });

    it('should reject invalid time format', async () => {
      const invalidData = {
        date: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString().split('T')[0],
        time: '25:00', // Heure invalide
        partySize: 4,
      };

      const response = await request(app)
        .post('/api/reservations/guest')
        .send(invalidData)
        .expect(400);

      expect(response.body.error).toBe('Validation failed');
      expect(response.body.details).toContainEqual(
        expect.objectContaining({
          message: expect.stringContaining('time'),
        })
      );
    });
  });

  describe('Sanitization', () => {
    it('should sanitize HTML tags in input', async () => {
      const dataWithHtml = {
        email: 'test4@example.com',
        password: 'Password123!',
        name: '<script>alert("xss")</script>John Doe',
      };

      const response = await request(app).post('/api/auth/register').send(dataWithHtml).expect(201);

      // Le nom devrait être sanitizé
      expect(response.body.user.name).not.toContain('<script>');
      expect(response.body.user.name).toContain('John Doe');
    });

    it('should sanitize special characters', async () => {
      const dataWithSpecialChars = {
        email: 'test5@example.com',
        password: 'Password123!',
        name: 'John & "Doe" <test>',
      };

      const response = await request(app)
        .post('/api/auth/register')
        .send(dataWithSpecialChars)
        .expect(201);

      // Les caractères spéciaux devraient être échappés
      expect(response.body.user.name).not.toContain('<');
      expect(response.body.user.name).not.toContain('>');
      expect(response.body.user.name).not.toContain('&');
    });
  });

  describe('Content Type Validation', () => {
    it('should reject requests without JSON content type', async () => {
      const response = await request(app)
        .post('/api/auth/register')
        .set('Content-Type', 'text/plain')
        .send('invalid data')
        .expect(400);

      expect(response.body.error).toBe('Content-Type must be application/json');
    });
  });

  describe('Request Size Validation', () => {
    it('should reject oversized requests', async () => {
      const largeData = {
        email: 'test6@example.com',
        password: 'Password123!',
        name: 'A'.repeat(1024 * 1024), // 1MB de données
      };

      const response = await request(app).post('/api/auth/register').send(largeData).expect(413);

      expect(response.body.error).toBe('Request size exceeds maximum allowed size');
    });
  });

  describe('Header Validation', () => {
    it('should reject requests without User-Agent', async () => {
      const response = await request(app)
        .post('/api/auth/register')
        .unset('User-Agent')
        .send({
          email: 'test7@example.com',
          password: 'Password123!',
          name: 'John Doe',
        })
        .expect(400);

      expect(response.body.error).toBe('User-Agent header is required');
    });
  });

  describe('URL Validation', () => {
    it('should reject URLs with suspicious characters', async () => {
      const response = await request(app).get('/api/reservations/../admin').expect(400);

      expect(response.body.error).toBe('Path traversal attempt detected');
    });
  });

  describe('Business Logic Validation', () => {
    it('should validate reservation time is within business hours', async () => {
      const invalidData = {
        date: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString().split('T')[0],
        time: '08:00', // Trop tôt
        partySize: 4,
      };

      const response = await request(app)
        .post('/api/reservations/guest')
        .send(invalidData)
        .expect(400);

      expect(response.body.error).toBe('Reservation time must be between 11:00 and 23:00');
    });

    it('should validate reservation is not too far in the future', async () => {
      const farFutureDate = new Date();
      farFutureDate.setMonth(farFutureDate.getMonth() + 7); // 7 mois dans le futur

      const invalidData = {
        date: farFutureDate.toISOString().split('T')[0],
        time: '19:00',
        partySize: 4,
      };

      const response = await request(app)
        .post('/api/reservations/guest')
        .send(invalidData)
        .expect(400);

      expect(response.body.error).toBe('Reservation cannot be more than 6 months in advance');
    });
  });
});
