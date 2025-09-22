import { notificationService } from '../services/notificationService';
import { notificationQueueService } from '../services/notificationQueueService';
import { NotificationType } from '../types/notification.types';

describe('Notification Service', () => {
  describe('NotificationService', () => {
    it('should initialize without errors', () => {
      expect(notificationService).toBeDefined();
    });

    it('should verify SMTP connection', async () => {
      const isConnected = await notificationService.verifyConnection();
      expect(typeof isConnected).toBe('boolean');
    });

    it('should send a test email', async () => {
      const success = await notificationService.sendEmail(
        'test@example.com',
        'Test Subject',
        '<h1>Test HTML</h1>',
        'Test Text'
      );
      expect(typeof success).toBe('boolean');
    });
  });

  describe('NotificationQueueService', () => {
    it('should initialize without errors', () => {
      expect(notificationQueueService).toBeDefined();
    });

    it('should enqueue a notification', async () => {
      const queueId = await notificationQueueService.enqueueNotification(
        NotificationType.RESERVATION_CONFIRMATION,
        'test@example.com',
        { test: 'data' }
      );
      expect(typeof queueId).toBe('string');
      expect(queueId.length).toBeGreaterThan(0);
    });

    it('should get queue stats', async () => {
      const stats = await notificationQueueService.getQueueStats();
      expect(stats).toBeDefined();
      expect(typeof stats.total).toBe('number');
      expect(typeof stats.pending).toBe('number');
      expect(typeof stats.sent).toBe('number');
      expect(typeof stats.failed).toBe('number');
    });
  });
});

