import { PrismaClient, NotificationType, NotificationStatus } from '@prisma/client';
import { NotificationRepository, CreateNotificationData, UpdateNotificationData, NotificationFilters, PaginationOptions, PaginatedResult, NotificationStats } from '@/domain/repositories/NotificationRepository';
import { Notification } from '@/domain/entities/Notification';

export class PrismaNotificationRepository implements NotificationRepository {
  private prisma: PrismaClient;

  constructor(prisma: PrismaClient) {
    this.prisma = prisma;
  }

  async findById(id: string): Promise<Notification | null> {
    const notification = await this.prisma.notification.findUnique({
      where: { id },
      include: {
        reservation: {
          include: {
            restaurant: true,
            table: true,
            user: true,
          },
        },
      },
    });
    return notification ? Notification.fromPrisma(notification) : null;
  }

  async findByReservationId(reservationId: string): Promise<Notification[]> {
    const notifications = await this.prisma.notification.findMany({
      where: { reservationId },
      orderBy: { createdAt: 'desc' },
    });
    return notifications.map(n => Notification.fromPrisma(n));
  }

  async findByRecipientEmail(email: string, filters?: NotificationFilters, pagination?: PaginationOptions): Promise<PaginatedResult<Notification>> {
    const where: any = { recipientEmail: email };
    
    if (filters) {
      if (filters.type) where.type = filters.type;
      if (filters.status) where.status = filters.status;
      if (filters.reservationId) where.reservationId = filters.reservationId;
      if (filters.dateFrom || filters.dateTo) {
        where.createdAt = {};
        if (filters.dateFrom) where.createdAt.gte = filters.dateFrom;
        if (filters.dateTo) where.createdAt.lte = filters.dateTo;
      }
    }

    const skip = pagination ? (pagination.page - 1) * pagination.limit : 0;
    const take = pagination?.limit || 10;

    const [notifications, total] = await Promise.all([
      this.prisma.notification.findMany({
        where,
        orderBy: { createdAt: 'desc' },
        skip,
        take,
      }),
      this.prisma.notification.count({ where }),
    ]);

    return {
      data: notifications.map(n => Notification.fromPrisma(n)),
      pagination: {
        page: pagination?.page || 1,
        limit: pagination?.limit || 10,
        total,
        pages: Math.ceil(total / (pagination?.limit || 10)),
      },
    };
  }

  async findByFilters(filters: NotificationFilters, pagination?: PaginationOptions): Promise<PaginatedResult<Notification>> {
    const where: any = {};
    
    if (filters.type) where.type = filters.type;
    if (filters.status) where.status = filters.status;
    if (filters.recipientEmail) where.recipientEmail = filters.recipientEmail;
    if (filters.reservationId) where.reservationId = filters.reservationId;
    if (filters.dateFrom || filters.dateTo) {
      where.createdAt = {};
      if (filters.dateFrom) where.createdAt.gte = filters.dateFrom;
      if (filters.dateTo) where.createdAt.lte = filters.dateTo;
    }

    const skip = pagination ? (pagination.page - 1) * pagination.limit : 0;
    const take = pagination?.limit || 10;

    const [notifications, total] = await Promise.all([
      this.prisma.notification.findMany({
        where,
        orderBy: { createdAt: 'desc' },
        skip,
        take,
      }),
      this.prisma.notification.count({ where }),
    ]);

    return {
      data: notifications.map(n => Notification.fromPrisma(n)),
      pagination: {
        page: pagination?.page || 1,
        limit: pagination?.limit || 10,
        total,
        pages: Math.ceil(total / (pagination?.limit || 10)),
      },
    };
  }

  async create(data: CreateNotificationData): Promise<Notification> {
    const notification = await this.prisma.notification.create({
      data: {
        type: data.type,
        recipientEmail: data.recipientEmail,
        subject: data.subject,
        status: data.status,
        reservationId: data.reservationId || null,
        data: data.data || null,
      },
    });
    return Notification.fromPrisma(notification);
  }

  async update(id: string, data: UpdateNotificationData): Promise<Notification> {
    const notification = await this.prisma.notification.update({
      where: { id },
      data: {
        ...(data.status && { status: data.status }),
        ...(data.subject && { subject: data.subject }),
        ...(data.data !== undefined && { data: data.data }),
      },
    });
    return Notification.fromPrisma(notification);
  }

  async delete(id: string): Promise<void> {
    await this.prisma.notification.delete({
      where: { id },
    });
  }

  async getStats(filters?: NotificationFilters): Promise<NotificationStats> {
    const where: any = {};
    
    if (filters) {
      if (filters.type) where.type = filters.type;
      if (filters.status) where.status = filters.status;
      if (filters.recipientEmail) where.recipientEmail = filters.recipientEmail;
      if (filters.reservationId) where.reservationId = filters.reservationId;
      if (filters.dateFrom || filters.dateTo) {
        where.createdAt = {};
        if (filters.dateFrom) where.createdAt.gte = filters.dateFrom;
        if (filters.dateTo) where.createdAt.lte = filters.dateTo;
      }
    }

    const [total, sent, failed, pending, retrying, byType, byStatus] = await Promise.all([
      this.prisma.notification.count({ where }),
      this.prisma.notification.count({ where: { ...where, status: NotificationStatus.SENT } }),
      this.prisma.notification.count({ where: { ...where, status: NotificationStatus.FAILED } }),
      this.prisma.notification.count({ where: { ...where, status: NotificationStatus.PENDING } }),
      this.prisma.notification.count({ where: { ...where, status: NotificationStatus.RETRYING } }),
      this.prisma.notification.groupBy({
        by: ['type'],
        where,
        _count: { type: true },
      }),
      this.prisma.notification.groupBy({
        by: ['status'],
        where,
        _count: { status: true },
      }),
    ]);

    const successRate = total > 0 ? Math.round((sent / total) * 100) : 0;

    return {
      total,
      sent,
      failed,
      pending,
      retrying,
      successRate,
      byType: byType.reduce((acc, item) => {
        acc[item.type] = item._count.type;
        return acc;
      }, {} as Record<string, number>),
      byStatus: byStatus.reduce((acc, item) => {
        acc[item.status] = item._count.status;
        return acc;
      }, {} as Record<string, number>),
    };
  }

  async findFailedNotifications(limit?: number): Promise<Notification[]> {
    const notifications = await this.prisma.notification.findMany({
      where: {
        status: NotificationStatus.FAILED,
        createdAt: {
          gte: new Date(Date.now() - 24 * 60 * 60 * 1000), // Dernières 24h
        },
      },
      orderBy: { createdAt: 'desc' },
      take: limit || 50,
    });
    return notifications.map(n => Notification.fromPrisma(n));
  }

  async updateStatus(id: string, status: NotificationStatus): Promise<Notification> {
    const notification = await this.prisma.notification.update({
      where: { id },
      data: { status },
    });
    return Notification.fromPrisma(notification);
  }
}
