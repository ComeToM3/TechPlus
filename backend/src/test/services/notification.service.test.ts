import { NotificationService } from '../../services/notificationService';
import nodemailer from 'nodemailer';

// Mock nodemailer
jest.mock('nodemailer', () => ({
  createTransporter: jest.fn(),
}));

// Mock Prisma
jest.mock('../../config/database', () => ({
  notification: {
    create: jest.fn(),
    findMany: jest.fn(),
    update: jest.fn(),
  },
}));

describe('NotificationService', () => {
  let notificationService: NotificationService;
  let mockTransporter: any;

  beforeEach(() => {
    mockTransporter = {
      sendMail: jest.fn(),
      verify: jest.fn(),
    };

    (nodemailer.createTransporter as jest.Mock).mockReturnValue(mockTransporter);
    notificationService = new NotificationService();
    jest.clearAllMocks();
  });

  describe('sendEmail', () => {
    it('should send email successfully', async () => {
      const emailData = {
        to: 'test@example.com',
        subject: 'Test Email',
        html: '<p>Test content</p>',
      };

      mockTransporter.sendMail.mockResolvedValue({
        messageId: 'test-message-id',
        accepted: ['test@example.com'],
        rejected: [],
      });

      const result = await notificationService.sendEmail(emailData);

      expect(result.success).toBe(true);
      expect(result.messageId).toBe('test-message-id');
      expect(mockTransporter.sendMail).toHaveBeenCalledWith(emailData);
    });

    it('should handle email sending failure', async () => {
      const emailData = {
        to: 'test@example.com',
        subject: 'Test Email',
        html: '<p>Test content</p>',
      };

      const error = new Error('SMTP connection failed');
      mockTransporter.sendMail.mockRejectedValue(error);

      const result = await notificationService.sendEmail(emailData);

      expect(result.success).toBe(false);
      expect(result.error).toBe('SMTP connection failed');
    });
  });

  describe('sendReservationConfirmation', () => {
    it('should send reservation confirmation email', async () => {
      const reservationData = {
        id: 'reservation-1',
        clientName: 'John Doe',
        clientEmail: 'john@example.com',
        date: new Date('2024-12-25'),
        time: '19:00',
        partySize: 4,
        managementToken: 'token-123',
      };

      mockTransporter.sendMail.mockResolvedValue({
        messageId: 'test-message-id',
        accepted: ['john@example.com'],
        rejected: [],
      });

      const result = await notificationService.sendReservationConfirmation(reservationData);

      expect(result.success).toBe(true);
      expect(mockTransporter.sendMail).toHaveBeenCalledWith(
        expect.objectContaining({
          to: 'john@example.com',
          subject: expect.stringContaining('Confirmation'),
        })
      );
    });
  });

  describe('sendReservationReminder', () => {
    it('should send reservation reminder email', async () => {
      const reservationData = {
        id: 'reservation-1',
        clientName: 'John Doe',
        clientEmail: 'john@example.com',
        date: new Date('2024-12-25'),
        time: '19:00',
        partySize: 4,
        managementToken: 'token-123',
      };

      mockTransporter.sendMail.mockResolvedValue({
        messageId: 'test-message-id',
        accepted: ['john@example.com'],
        rejected: [],
      });

      const result = await notificationService.sendReservationReminder(reservationData);

      expect(result.success).toBe(true);
      expect(mockTransporter.sendMail).toHaveBeenCalledWith(
        expect.objectContaining({
          to: 'john@example.com',
          subject: expect.stringContaining('Rappel'),
        })
      );
    });
  });

  describe('sendReservationCancellation', () => {
    it('should send reservation cancellation email', async () => {
      const reservationData = {
        id: 'reservation-1',
        clientName: 'John Doe',
        clientEmail: 'john@example.com',
        date: new Date('2024-12-25'),
        time: '19:00',
        partySize: 4,
        cancellationReason: 'Customer request',
      };

      mockTransporter.sendMail.mockResolvedValue({
        messageId: 'test-message-id',
        accepted: ['john@example.com'],
        rejected: [],
      });

      const result = await notificationService.sendReservationCancellation(reservationData);

      expect(result.success).toBe(true);
      expect(mockTransporter.sendMail).toHaveBeenCalledWith(
        expect.objectContaining({
          to: 'john@example.com',
          subject: expect.stringContaining('Annulation'),
        })
      );
    });
  });

  describe('sendReservationModification', () => {
    it('should send reservation modification email', async () => {
      const reservationData = {
        id: 'reservation-1',
        clientName: 'John Doe',
        clientEmail: 'john@example.com',
        date: new Date('2024-12-25'),
        time: '19:00',
        partySize: 4,
        managementToken: 'token-123',
      };

      const changes = {
        time: '20:00',
        partySize: 6,
      };

      mockTransporter.sendMail.mockResolvedValue({
        messageId: 'test-message-id',
        accepted: ['john@example.com'],
        rejected: [],
      });

      const result = await notificationService.sendReservationModification(reservationData, changes);

      expect(result.success).toBe(true);
      expect(mockTransporter.sendMail).toHaveBeenCalledWith(
        expect.objectContaining({
          to: 'john@example.com',
          subject: expect.stringContaining('Modification'),
        })
      );
    });
  });

  describe('sendPaymentConfirmation', () => {
    it('should send payment confirmation email', async () => {
      const paymentData = {
        reservationId: 'reservation-1',
        clientName: 'John Doe',
        clientEmail: 'john@example.com',
        amount: 1000,
        currency: 'usd',
        paymentIntentId: 'pi_test_123',
      };

      mockTransporter.sendMail.mockResolvedValue({
        messageId: 'test-message-id',
        accepted: ['john@example.com'],
        rejected: [],
      });

      const result = await notificationService.sendPaymentConfirmation(paymentData);

      expect(result.success).toBe(true);
      expect(mockTransporter.sendMail).toHaveBeenCalledWith(
        expect.objectContaining({
          to: 'john@example.com',
          subject: expect.stringContaining('Paiement'),
        })
      );
    });
  });

  describe('sendPaymentFailed', () => {
    it('should send payment failed email', async () => {
      const paymentData = {
        reservationId: 'reservation-1',
        clientName: 'John Doe',
        clientEmail: 'john@example.com',
        amount: 1000,
        currency: 'usd',
        paymentIntentId: 'pi_test_123',
        errorMessage: 'Card declined',
      };

      mockTransporter.sendMail.mockResolvedValue({
        messageId: 'test-message-id',
        accepted: ['john@example.com'],
        rejected: [],
      });

      const result = await notificationService.sendPaymentFailed(paymentData);

      expect(result.success).toBe(true);
      expect(mockTransporter.sendMail).toHaveBeenCalledWith(
        expect.objectContaining({
          to: 'john@example.com',
          subject: expect.stringContaining('Échec'),
        })
      );
    });
  });

  describe('testEmailConnection', () => {
    it('should test email connection successfully', async () => {
      mockTransporter.verify.mockResolvedValue(true);

      const result = await notificationService.testEmailConnection();

      expect(result).toBe(true);
      expect(mockTransporter.verify).toHaveBeenCalled();
    });

    it('should handle email connection test failure', async () => {
      const error = new Error('SMTP connection failed');
      mockTransporter.verify.mockRejectedValue(error);

      const result = await notificationService.testEmailConnection();

      expect(result).toBe(false);
    });
  });
});

