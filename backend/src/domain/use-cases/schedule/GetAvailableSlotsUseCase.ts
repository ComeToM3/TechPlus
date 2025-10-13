import { ScheduleConfigRepository } from '../../repositories/ScheduleConfigRepository';
import { DayScheduleRepository } from '../../repositories/DayScheduleRepository';
import { ScheduleTimeSlotRepository } from '../../repositories/ScheduleTimeSlotRepository';

export interface GetAvailableSlotsRequest {
  restaurantId: string;
  date: string;
  partySize?: number;
}

export interface GetAvailableSlotsResponse {
  success: boolean;
  data?: {
    date: Date;
    partySize: number;
    slots: any[];
    totalSlots: number;
  };
  message?: string;
}

export class GetAvailableSlotsUseCase {
  constructor(
    private scheduleConfigRepository: ScheduleConfigRepository,
    private dayScheduleRepository: DayScheduleRepository,
    private scheduleTimeSlotRepository: ScheduleTimeSlotRepository
  ) {}

  async execute(request: GetAvailableSlotsRequest): Promise<GetAvailableSlotsResponse> {
    try {
      const { restaurantId, date, partySize = 1 } = request;

      const targetDate = new Date(date);
      const dayOfWeek = this.getDayOfWeek(targetDate);

      // Récupérer la configuration
      const scheduleConfig = await this.scheduleConfigRepository.findByRestaurantId(restaurantId);
      
      if (!scheduleConfig) {
        return {
          success: false,
          message: 'Schedule configuration not found',
        };
      }

      // Récupérer l'horaire du jour
      const daySchedule = await this.dayScheduleRepository.findByDayOfWeek(scheduleConfig.id, dayOfWeek);
      
      if (!daySchedule || !daySchedule.isOpen) {
        return {
          success: true,
          data: {
            date: targetDate,
            partySize,
            slots: [],
            totalSlots: 0,
          },
        };
      }

      // Récupérer les créneaux disponibles
      const availableSlots = await this.scheduleTimeSlotRepository.findAvailableSlots(daySchedule.id, partySize);

      // Si des créneaux spécifiques existent, les utiliser
      if (availableSlots.length > 0) {
        const slots = availableSlots.map(slot => ({
          id: slot.id,
          time: slot.time,
          isAvailable: slot.isAvailable,
          capacity: slot.capacity,
          isRecommended: slot.isRecommended,
        }));

        return {
          success: true,
          data: {
            date: targetDate,
            partySize,
            slots,
            totalSlots: slots.length,
          },
        };
      }

      // Sinon, générer des créneaux automatiquement
      const generatedSlots = this.generateTimeSlots(
        daySchedule.openingTime || '09:00',
        daySchedule.closingTime || '22:00',
        scheduleConfig.slotDurationMinutes,
        scheduleConfig.defaultCapacityPerSlot
      );

      const filteredSlots = generatedSlots.filter(slot => 
        slot.capacity >= partySize
      );

      return {
        success: true,
        data: {
          date: targetDate,
          partySize,
          slots: filteredSlots,
          totalSlots: filteredSlots.length,
        },
      };
    } catch (error) {
      return {
        success: false,
        message: error instanceof Error ? error.message : 'Unknown error',
      };
    }
  }

  private getDayOfWeek(date: Date): string {
    const days = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'];
    return days[date.getDay()] || 'sunday';
  }

  private generateTimeSlots(openTime: string, closeTime: string, slotDuration: number, capacity: number) {
    const slots: any[] = [];
    const openParts = openTime.split(':');
    const closeParts = closeTime.split(':');
    
    if (openParts.length !== 2 || closeParts.length !== 2) {
      return slots;
    }
    
    const openHour = parseInt(openParts[0] || '0');
    const openMinute = parseInt(openParts[1] || '0');
    const closeHour = parseInt(closeParts[0] || '0');
    const closeMinute = parseInt(closeParts[1] || '0');
    
    if (isNaN(openHour) || isNaN(openMinute) || isNaN(closeHour) || isNaN(closeMinute)) {
      return slots;
    }
    
    const openMinutes = openHour * 60 + openMinute;
    const closeMinutes = closeHour * 60 + closeMinute;
    
    for (let minutes = openMinutes; minutes < closeMinutes; minutes += slotDuration) {
      const hour = Math.floor(minutes / 60);
      const minute = minutes % 60;
      const time = `${hour.toString().padStart(2, '0')}:${minute.toString().padStart(2, '0')}`;
      
      slots.push({
        time,
        isAvailable: true,
        capacity,
        isRecommended: this.isRecommendedTime(time),
      });
    }
    
    return slots;
  }

  private isRecommendedTime(time: string): boolean {
    const timeParts = time.split(':');
    if (timeParts.length !== 2) return false;
    
    const hour = parseInt(timeParts[0] || '0');
    if (isNaN(hour)) return false;
    
    return (hour >= 12 && hour <= 13) || (hour >= 19 && hour <= 20);
  }
}
