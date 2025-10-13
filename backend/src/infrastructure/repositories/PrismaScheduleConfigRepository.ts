import { PrismaClient } from '@prisma/client';
import { ScheduleConfig } from '../../domain/entities/ScheduleConfig';
import { ScheduleConfigRepository, CreateScheduleConfigData, UpdateScheduleConfigData } from '../../domain/repositories/ScheduleConfigRepository';

export class PrismaScheduleConfigRepository implements ScheduleConfigRepository {
  constructor(private prisma: PrismaClient) {}

  async findByRestaurantId(restaurantId: string): Promise<ScheduleConfig | null> {
    const config = await this.prisma.scheduleConfig.findUnique({
      where: { restaurantId },
    });

    if (!config) return null;

    return new ScheduleConfig({
      id: config.id,
      restaurantId: config.restaurantId,
      slotDurationMinutes: config.slotDurationMinutes,
      bufferTimeMinutes: config.bufferTimeMinutes,
      maxAdvanceBookingDays: config.maxAdvanceBookingDays,
      minAdvanceBookingHours: config.minAdvanceBookingHours,
      allowSameDayBooking: config.allowSameDayBooking,
      allowWeekendBooking: config.allowWeekendBooking,
      defaultCapacityPerSlot: config.defaultCapacityPerSlot,
      createdAt: config.createdAt,
      updatedAt: config.updatedAt,
    });
  }

  async create(data: CreateScheduleConfigData): Promise<ScheduleConfig> {
    const config = await this.prisma.scheduleConfig.create({
      data: {
        restaurantId: data.restaurantId,
        slotDurationMinutes: data.slotDurationMinutes,
        bufferTimeMinutes: data.bufferTimeMinutes,
        maxAdvanceBookingDays: data.maxAdvanceBookingDays,
        minAdvanceBookingHours: data.minAdvanceBookingHours,
        allowSameDayBooking: data.allowSameDayBooking,
        allowWeekendBooking: data.allowWeekendBooking,
        defaultCapacityPerSlot: data.defaultCapacityPerSlot,
      },
    });

    return new ScheduleConfig({
      id: config.id,
      restaurantId: config.restaurantId,
      slotDurationMinutes: config.slotDurationMinutes,
      bufferTimeMinutes: config.bufferTimeMinutes,
      maxAdvanceBookingDays: config.maxAdvanceBookingDays,
      minAdvanceBookingHours: config.minAdvanceBookingHours,
      allowSameDayBooking: config.allowSameDayBooking,
      allowWeekendBooking: config.allowWeekendBooking,
      defaultCapacityPerSlot: config.defaultCapacityPerSlot,
      createdAt: config.createdAt,
      updatedAt: config.updatedAt,
    });
  }

  async update(id: string, data: UpdateScheduleConfigData): Promise<ScheduleConfig> {
    // Construire l'objet de données dynamiquement pour éviter les propriétés undefined
    const updateData: any = {};
    
    if (data.slotDurationMinutes !== undefined) {
      updateData.slotDurationMinutes = data.slotDurationMinutes;
    }
    if (data.bufferTimeMinutes !== undefined) {
      updateData.bufferTimeMinutes = data.bufferTimeMinutes;
    }
    if (data.maxAdvanceBookingDays !== undefined) {
      updateData.maxAdvanceBookingDays = data.maxAdvanceBookingDays;
    }
    if (data.minAdvanceBookingHours !== undefined) {
      updateData.minAdvanceBookingHours = data.minAdvanceBookingHours;
    }
    if (data.allowSameDayBooking !== undefined) {
      updateData.allowSameDayBooking = data.allowSameDayBooking;
    }
    if (data.allowWeekendBooking !== undefined) {
      updateData.allowWeekendBooking = data.allowWeekendBooking;
    }
    if (data.defaultCapacityPerSlot !== undefined) {
      updateData.defaultCapacityPerSlot = data.defaultCapacityPerSlot;
    }

    const config = await this.prisma.scheduleConfig.update({
      where: { id },
      data: updateData,
    });

    return new ScheduleConfig({
      id: config.id,
      restaurantId: config.restaurantId,
      slotDurationMinutes: config.slotDurationMinutes,
      bufferTimeMinutes: config.bufferTimeMinutes,
      maxAdvanceBookingDays: config.maxAdvanceBookingDays,
      minAdvanceBookingHours: config.minAdvanceBookingHours,
      allowSameDayBooking: config.allowSameDayBooking,
      allowWeekendBooking: config.allowWeekendBooking,
      defaultCapacityPerSlot: config.defaultCapacityPerSlot,
      createdAt: config.createdAt,
      updatedAt: config.updatedAt,
    });
  }

  async delete(id: string): Promise<void> {
    await this.prisma.scheduleConfig.delete({
      where: { id },
    });
  }

  async exists(restaurantId: string): Promise<boolean> {
    const config = await this.prisma.scheduleConfig.findUnique({
      where: { restaurantId },
      select: { id: true },
    });

    return config !== null;
  }
}
