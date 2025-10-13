import { PrismaClient } from '@prisma/client';
import { ScheduleTimeSlot } from '../../domain/entities/ScheduleTimeSlot';
import { ScheduleTimeSlotRepository, CreateScheduleTimeSlotData, UpdateScheduleTimeSlotData } from '../../domain/repositories/ScheduleTimeSlotRepository';

export class PrismaScheduleTimeSlotRepository implements ScheduleTimeSlotRepository {
  constructor(private prisma: PrismaClient) {}

  async findByDayScheduleId(dayScheduleId: string): Promise<ScheduleTimeSlot[]> {
    const slots = await this.prisma.timeSlot.findMany({
      where: { dayScheduleId },
      orderBy: { time: 'asc' },
    });

    return slots.map(slot => new ScheduleTimeSlot({
      id: slot.id,
      dayScheduleId: slot.dayScheduleId,
      time: slot.time,
      isAvailable: slot.isAvailable,
      capacity: slot.capacity,
      isRecommended: slot.isRecommended,
      createdAt: slot.createdAt,
      updatedAt: slot.updatedAt,
    }));
  }

  async findByTime(dayScheduleId: string, time: string): Promise<ScheduleTimeSlot | null> {
    const slot = await this.prisma.timeSlot.findFirst({
      where: {
        dayScheduleId,
        time,
      },
    });

    if (!slot) return null;

    return new ScheduleTimeSlot({
      id: slot.id,
      dayScheduleId: slot.dayScheduleId,
      time: slot.time,
      isAvailable: slot.isAvailable,
      capacity: slot.capacity,
      isRecommended: slot.isRecommended,
      createdAt: slot.createdAt,
      updatedAt: slot.updatedAt,
    });
  }

  async create(data: CreateScheduleTimeSlotData): Promise<ScheduleTimeSlot> {
    const slot = await this.prisma.timeSlot.create({
      data: {
        dayScheduleId: data.dayScheduleId,
        time: data.time,
        isAvailable: data.isAvailable,
        capacity: data.capacity,
        isRecommended: data.isRecommended || false,
      },
    });

    return new ScheduleTimeSlot({
      id: slot.id,
      dayScheduleId: slot.dayScheduleId,
      time: slot.time,
      isAvailable: slot.isAvailable,
      capacity: slot.capacity,
      isRecommended: slot.isRecommended,
      createdAt: slot.createdAt,
      updatedAt: slot.updatedAt,
    });
  }

  async update(id: string, data: UpdateScheduleTimeSlotData): Promise<ScheduleTimeSlot> {
    // Construire l'objet de données dynamiquement pour éviter les propriétés undefined
    const updateData: any = {};
    
    if (data.isAvailable !== undefined) {
      updateData.isAvailable = data.isAvailable;
    }
    if (data.capacity !== undefined) {
      updateData.capacity = data.capacity;
    }
    if (data.isRecommended !== undefined) {
      updateData.isRecommended = data.isRecommended;
    }

    const slot = await this.prisma.timeSlot.update({
      where: { id },
      data: updateData,
    });

    return new ScheduleTimeSlot({
      id: slot.id,
      dayScheduleId: slot.dayScheduleId,
      time: slot.time,
      isAvailable: slot.isAvailable,
      capacity: slot.capacity,
      isRecommended: slot.isRecommended,
      createdAt: slot.createdAt,
      updatedAt: slot.updatedAt,
    });
  }

  async delete(id: string): Promise<void> {
    await this.prisma.timeSlot.delete({
      where: { id },
    });
  }

  async deleteByDayScheduleId(dayScheduleId: string): Promise<void> {
    await this.prisma.timeSlot.deleteMany({
      where: { dayScheduleId },
    });
  }

  async findAvailableSlots(dayScheduleId: string, partySize?: number): Promise<ScheduleTimeSlot[]> {
    const whereClause: any = {
      dayScheduleId,
      isAvailable: true,
    };

    if (partySize !== undefined) {
      whereClause.capacity = {
        gte: partySize,
      };
    }

    const slots = await this.prisma.timeSlot.findMany({
      where: whereClause,
      orderBy: { time: 'asc' },
    });

    return slots.map(slot => new ScheduleTimeSlot({
      id: slot.id,
      dayScheduleId: slot.dayScheduleId,
      time: slot.time,
      isAvailable: slot.isAvailable,
      capacity: slot.capacity,
      isRecommended: slot.isRecommended,
      createdAt: slot.createdAt,
      updatedAt: slot.updatedAt,
    }));
  }
}
