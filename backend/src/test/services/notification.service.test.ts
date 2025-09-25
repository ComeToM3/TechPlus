import { NotificationService } from '../../services/notificationService';
import { NotificationType } from '../../types/notification.types';
import nodemailer from 'nodemailer';

// Mock nodemailer
jest.mock('nodemailer', () => ({
  createTransport: jest.fn(),
}));

// Mock Prisma
jest.mock('@prisma/client', () => ({
  PrismaClient: jest.fn().mockImplementation(() => ({
    reservation: {
      findUnique: jest.fn(),
    },
  })),
}));

describe('NotificationService', () => {
  let notificationService: NotificationService;
  let mockTransporter: any;
  let mockPrisma: any;

  beforeEach(() => {
    // Mock environment variables
    process.env.SMTP_HOST = 'smtp.test.com';
    process.env.SMTP_PORT = '587';
    process.env.SMTP_USER = 'test@test.com';
    process.env.SMTP_PASS = 'testpass';

    mockTransporter = {
      sendMail: jest.fn(),
      verify: jest.fn(),
    };

    // Get the mocked Prisma instance
    const { PrismaClient } = require('@prisma/client');
    mockPrisma = new PrismaClient();

    (nodemailer.createTransport as jest.Mock).mockReturnValue(mockTransporter);
    notificationService = new NotificationService();
    jest.clearAllMocks();
  });

  describe('sendEmail', () => {
    it('should send email successfully', async () => {
      mockTransporter.sendMail.mockResolvedValue({
        messageId: 'test-message-id',
        accepted: ['test@example.com'],
        rejected: [],
      });

      const result = await notificationService.sendEmail(
        'test@example.com',
        'Test Email',
        '<p>Test content</p>'
      );

      expect(result).toBe(true);
      expect(mockTransporter.sendMail).toHaveBeenCalledWith(
        expect.objectContaining({
          to: 'test@example.com',
          subject: 'Test Email',
          html: '<p>Test content</p>',
        })
      );
    });

    it('should handle email sending failure', async () => {
      const error = new Error('SMTP connection failed');
      mockTransporter.sendMail.mockRejectedValue(error);

      const result = await notificationService.sendEmail(
        'test@example.com',
        'Test Email',
        '<p>Test content</p>'
      );

      expect(result).toBe(false);
    });
  });

  // Note: sendReservationNotification test requires more complex Prisma mocking
  // This will be implemented in a separate test file with proper database mocking
});