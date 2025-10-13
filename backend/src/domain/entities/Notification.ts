import { NotificationType, NotificationStatus } from '@prisma/client';

interface NotificationProps {
  id: string;
  type: NotificationType;
  recipientEmail: string;
  subject: string;
  status: NotificationStatus;
  reservationId?: string;
  data?: string;
  createdAt: Date;
  updatedAt: Date;
}

export class Notification {
  private props: NotificationProps;

  constructor(props: NotificationProps) {
    this.props = props;
  }

  // Getters
  get id(): string { return this.props.id; }
  get type(): NotificationType { return this.props.type; }
  get recipientEmail(): string { return this.props.recipientEmail; }
  get subject(): string { return this.props.subject; }
  get status(): NotificationStatus { return this.props.status; }
  get reservationId(): string | undefined { return this.props.reservationId; }
  get data(): string | undefined { return this.props.data; }
  get createdAt(): Date { return this.props.createdAt; }
  get updatedAt(): Date { return this.props.updatedAt; }

  // Business logic methods
  isSent(): boolean {
    return this.props.status === NotificationStatus.SENT;
  }

  isFailed(): boolean {
    return this.props.status === NotificationStatus.FAILED;
  }

  isPending(): boolean {
    return this.props.status === NotificationStatus.PENDING;
  }

  isRetrying(): boolean {
    return this.props.status === NotificationStatus.RETRYING;
  }

  canBeRetried(): boolean {
    return this.props.status === NotificationStatus.FAILED;
  }

  isReservationRelated(): boolean {
    return !!this.props.reservationId;
  }

  getParsedData(): any {
    if (!this.props.data) return null;
    try {
      return JSON.parse(this.props.data);
    } catch {
      return null;
    }
  }

  // Factory method to create Notification from Prisma model
  static fromPrisma(prismaNotification: any): Notification {
    return new Notification({
      id: prismaNotification.id,
      type: prismaNotification.type,
      recipientEmail: prismaNotification.recipientEmail,
      subject: prismaNotification.subject,
      status: prismaNotification.status,
      reservationId: prismaNotification.reservationId,
      data: prismaNotification.data,
      createdAt: prismaNotification.createdAt,
      updatedAt: prismaNotification.updatedAt,
    });
  }

  toJSON() {
    return {
      id: this.id,
      type: this.type,
      recipientEmail: this.recipientEmail,
      subject: this.subject,
      status: this.status,
      reservationId: this.reservationId,
      data: this.data,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt,
    };
  }
}

