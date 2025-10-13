import { PrismaClient } from '@prisma/client';
import { DaySchedule } from '../../domain/entities/DaySchedule';
import { DayScheduleRepository, CreateDayScheduleData, UpdateDayScheduleData } from '../../domain/repositories/DayScheduleRepository';

export class PrismaDayScheduleRepository implements DayScheduleRepository {
  constructor(private prisma: PrismaClient) {}

  async findByScheduleConfigId(scheduleConfigId: string): Promise<DaySchedule[]> {
    const schedules = await this.prisma.daySchedule.findMany({
      where: { scheduleConfigId },
      orderBy: { dayOfWeek: 'asc' },
    });

    return schedules.map(schedule => new DaySchedule({
      id: schedule.id,
      scheduleConfigId: schedule.scheduleConfigId,
      dayOfWeek: schedule.dayOfWeek,
      isOpen: schedule.isOpen,
      openingTime: schedule.openingTime,
      closingTime: schedule.closingTime,
      notes: schedule.notes,
      createdAt: schedule.createdAt,
      updatedAt: schedule.updatedAt,
    }));
  }

  async findByDayOfWeek(scheduleConfigId: string, dayOfWeek: string): Promise<DaySchedule | null> {
    const schedule = await this.prisma.daySchedule.findFirst({
      where: {
        scheduleConfigId,
        dayOfWeek,
      },
    });

    if (!schedule) return null;

    return new DaySchedule({
      id: schedule.id,
      scheduleConfigId: schedule.scheduleConfigId,
      dayOfWeek: schedule.dayOfWeek,
      isOpen: schedule.isOpen,
      openingTime: schedule.openingTime,
      closingTime: schedule.closingTime,
      notes: schedule.notes,
      createdAt: schedule.createdAt,
      updatedAt: schedule.updatedAt,
    });
  }

  async create(data: CreateDayScheduleData): Promise<DaySchedule> {
    const schedule = await this.prisma.daySchedule.create({
      data: {
        scheduleConfigId: data.scheduleConfigId,
        dayOfWeek: data.dayOfWeek,
        isOpen: data.isOpen,
        openingTime: data.openingTime || null,
        closingTime: data.closingTime || null,
        notes: data.notes || null,
      },
    });

    return new DaySchedule({
      id: schedule.id,
      scheduleConfigId: schedule.scheduleConfigId,
      dayOfWeek: schedule.dayOfWeek,
      isOpen: schedule.isOpen,
      openingTime: schedule.openingTime,
      closingTime: schedule.closingTime,
      notes: schedule.notes,
      createdAt: schedule.createdAt,
      updatedAt: schedule.updatedAt,
    });
  }

  async update(id: string, data: UpdateDayScheduleData): Promise<DaySchedule> {
    // Construire l'objet de données dynamiquement pour éviter les propriétés undefined
    const updateData: any = {};
    
    if (data.isOpen !== undefined) {
      updateData.isOpen = data.isOpen;
    }
    if (data.openingTime !== undefined) {
      updateData.openingTime = data.openingTime;
    }
    if (data.closingTime !== undefined) {
      updateData.closingTime = data.closingTime;
    }
    if (data.notes !== undefined) {
      updateData.notes = data.notes;
    }

    const schedule = await this.prisma.daySchedule.update({
      where: { id },
      data: updateData,
    });

    return new DaySchedule({
      id: schedule.id,
      scheduleConfigId: schedule.scheduleConfigId,
      dayOfWeek: schedule.dayOfWeek,
      isOpen: schedule.isOpen,
      openingTime: schedule.openingTime,
      closingTime: schedule.closingTime,
      notes: schedule.notes,
      createdAt: schedule.createdAt,
      updatedAt: schedule.updatedAt,
    });
  }

  async delete(id: string): Promise<void> {
    await this.prisma.daySchedule.delete({
      where: { id },
    });
  }

  async deleteByScheduleConfigId(scheduleConfigId: string): Promise<void> {
    await this.prisma.daySchedule.deleteMany({
      where: { scheduleConfigId },
    });
  }
}
