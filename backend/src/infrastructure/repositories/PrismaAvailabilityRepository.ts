import { PrismaClient, ReservationStatus } from '@prisma/client';
import { AvailabilityRepository, GetAvailabilityRequest, GetAvailableTablesRequest, CheckSlotAvailabilityRequest } from '@/domain/repositories/AvailabilityRepository';
import { DayAvailability } from '@/domain/entities/DayAvailability';
import { AvailabilitySlot } from '@/domain/entities/AvailabilitySlot';
import { TimeSlot } from '@/domain/entities/TimeSlot';

export class PrismaAvailabilityRepository implements AvailabilityRepository {
  private prisma: PrismaClient;

  constructor(prisma: PrismaClient) {
    this.prisma = prisma;
  }

  async getDayAvailability(request: GetAvailabilityRequest): Promise<DayAvailability> {
    const { date, partySize, restaurantId: requestedRestaurantId } = request;
    
    // Récupérer le restaurant
    const restaurant = await this.getRestaurant(requestedRestaurantId);
    if (!restaurant || !restaurant.id) {
      throw new Error('Restaurant not found');
    }

    const validRestaurantId = restaurant.id;

    // Récupérer les créneaux configurés pour ce jour
    const timeSlots = await this.getTimeSlotsForDay(
      this.getDayOfWeek(date),
      validRestaurantId
    );

    // Générer les slots de disponibilité
    const slots: AvailabilitySlot[] = [];
    
    for (const timeSlot of timeSlots) {
      if (!timeSlot.isAvailable) continue;

      // Vérifier la disponibilité pour ce créneau
      const availableTables = await this.getAvailableTablesForSlot(
        date,
        timeSlot.time,
        partySize,
        validRestaurantId
      );

      const slot = new AvailabilitySlot({
        time: timeSlot.time,
        available: availableTables.length > 0,
        availableTables: availableTables.length,
        tables: availableTables,
      });

      slots.push(slot);
    }

    return new DayAvailability({
      date: date.toISOString().split('T')[0]!,
      partySize,
      slots,
      restaurantId: validRestaurantId,
      openingHours: restaurant.openingHours || undefined,
    });
  }

  async getAvailableTables(request: GetAvailableTablesRequest): Promise<any[]> {
    const { date, time, partySize, restaurantId } = request;
    
    const restaurant = await this.getRestaurant(restaurantId);
    if (!restaurant) {
      throw new Error('Restaurant not found');
    }

    return this.getAvailableTablesForSlot(date, time, partySize, restaurant.id);
  }

  async checkSlotAvailability(request: CheckSlotAvailabilityRequest): Promise<boolean> {
    const { date, time, partySize, restaurantId } = request;
    
    const restaurant = await this.getRestaurant(restaurantId);
    if (!restaurant) {
      throw new Error('Restaurant not found');
    }

    const availableTables = await this.getAvailableTablesForSlot(
      date,
      time,
      partySize,
      restaurant.id
    );

    return availableTables.length > 0;
  }

  async getTimeSlotsForDay(dayOfWeek: string, restaurantId: string): Promise<TimeSlot[]> {
    const scheduleConfig = await this.prisma.scheduleConfig.findUnique({
      where: { restaurantId },
      include: {
        daySchedules: {
          where: { dayOfWeek },
          include: {
            timeSlots: {
              where: { isAvailable: true },
              orderBy: { time: 'asc' },
            },
          },
        },
      },
    });

    if (!scheduleConfig || scheduleConfig.daySchedules.length === 0) {
      return [];
    }

    const daySchedule = scheduleConfig.daySchedules[0];
    if (!daySchedule || !daySchedule.isOpen) {
      return [];
    }

    return daySchedule.timeSlots.map(slot => TimeSlot.fromPrisma(slot));
  }

  async getRestaurantOpeningHours(restaurantId: string): Promise<any> {
    const restaurant = await this.prisma.restaurant.findUnique({
      where: { id: restaurantId },
      select: { openingHours: true },
    });

    return restaurant?.openingHours;
  }

  private async getRestaurant(restaurantId?: string) {
    if (restaurantId) {
      return await this.prisma.restaurant.findUnique({
        where: { id: restaurantId, isActive: true },
      });
    } else {
      return await this.prisma.restaurant.findFirst({
        where: { isActive: true },
      });
    }
  }

  private async getAvailableTablesForSlot(
    date: Date,
    time: string,
    partySize: number,
    restaurantId: string
  ): Promise<any[]> {
    return await this.prisma.table.findMany({
      where: {
        restaurantId,
        isActive: true,
        capacity: { gte: partySize },
        reservations: {
          none: {
            AND: [
              { date },
              { time },
              { status: { not: ReservationStatus.CANCELLED } },
            ],
          },
        },
      },
      select: {
        id: true,
        number: true,
        capacity: true,
        position: true,
      },
      orderBy: [{ capacity: 'asc' }, { number: 'asc' }],
    });
  }

  private getDayOfWeek(date: Date): string {
    const days = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'];
    return days[date.getDay()] || 'sunday';
  }
}
