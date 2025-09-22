/**
 * Types pour le service de notification
 */

export enum NotificationType {
  RESERVATION_CONFIRMATION = 'RESERVATION_CONFIRMATION',
  RESERVATION_REMINDER = 'RESERVATION_REMINDER',
  RESERVATION_CANCELLATION = 'RESERVATION_CANCELLATION',
  RESERVATION_MODIFICATION = 'RESERVATION_MODIFICATION',
  PAYMENT_CONFIRMATION = 'PAYMENT_CONFIRMATION',
  PAYMENT_FAILED = 'PAYMENT_FAILED',
  ADMIN_NOTIFICATION = 'ADMIN_NOTIFICATION',
}

export enum NotificationStatus {
  PENDING = 'PENDING',
  SENT = 'SENT',
  FAILED = 'FAILED',
  RETRYING = 'RETRYING',
}

export interface NotificationTemplate {
  subject: string;
  html: string;
  text: string;
}

export interface NotificationData {
  type: NotificationType;
  recipientEmail: string;
  subject: string;
  status: NotificationStatus;
  reservationId?: string;
  data?: string;
  createdAt?: Date;
  updatedAt?: Date;
}

export interface ReservationNotificationData {
  reason?: string;
  changes?: {
    date?: string;
    time?: string;
    partySize?: number;
    table?: string;
  };
  refundAmount?: number;
  refundStatus?: string;
}

export interface EmailConfig {
  host: string;
  port: number;
  secure: boolean;
  auth: {
    user: string;
    pass: string;
  };
  from: {
    name: string;
    email: string;
  };
}

export interface NotificationQueueItem {
  id: string;
  type: NotificationType;
  recipientEmail: string;
  data: any;
  priority: number;
  scheduledAt: Date;
  attempts: number;
  maxAttempts: number;
  status: NotificationStatus;
}

export interface NotificationStats {
  total: number;
  sent: number;
  failed: number;
  pending: number;
  byType: Record<NotificationType, number>;
  byStatus: Record<NotificationStatus, number>;
}

