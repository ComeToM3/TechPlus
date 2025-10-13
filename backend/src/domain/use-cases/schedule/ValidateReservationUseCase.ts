import { ScheduleConfigRepository } from '../../repositories/ScheduleConfigRepository';
import { DayScheduleRepository } from '../../repositories/DayScheduleRepository';

export interface ValidateReservationRequest {
  restaurantId: string;
  date: string;
  time: string;
  partySize?: number;
}

export interface ValidateReservationResponse {
  success: boolean;
  data?: {
    canReserve: boolean;
    date: Date;
    time: string;
    partySize: number;
    message: string;
  };
  message?: string;
}

export class ValidateReservationUseCase {
  constructor(
    private scheduleConfigRepository: ScheduleConfigRepository,
    private dayScheduleRepository: DayScheduleRepository
  ) {}

  async execute(request: ValidateReservationRequest): Promise<ValidateReservationResponse> {
    try {
      const { restaurantId, date, time, partySize = 1 } = request;

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
            canReserve: false,
            date: targetDate,
            time,
            partySize,
            message: 'Restaurant is closed on this day',
          },
        };
      }

      // Vérifier les heures d'ouverture
      const openTime = daySchedule.openingTime || '09:00';
      const closeTime = daySchedule.closingTime || '22:00';
      
      if (time < openTime || time >= closeTime) {
        return {
          success: true,
          data: {
            canReserve: false,
            date: targetDate,
            time,
            partySize,
            message: 'Time is outside opening hours',
          },
        };
      }

      // Vérifier les règles de réservation
      const now = new Date();
      const reservationDateTime = new Date(targetDate);
      const [hours, minutes] = time.split(':').map(Number);
      reservationDateTime.setHours(hours || 0, minutes || 0, 0, 0);

      // Vérifier le délai minimum
      const minAdvanceHours = scheduleConfig.minAdvanceBookingHours;
      const minDateTime = new Date(now.getTime() + minAdvanceHours * 60 * 60 * 1000);
      
      if (reservationDateTime < minDateTime) {
        return {
          success: true,
          data: {
            canReserve: false,
            date: targetDate,
            time,
            partySize,
            message: `Reservation must be made at least ${minAdvanceHours} hours in advance`,
          },
        };
      }

      // Vérifier le délai maximum
      const maxAdvanceDays = scheduleConfig.maxAdvanceBookingDays;
      const maxDateTime = new Date(now.getTime() + maxAdvanceDays * 24 * 60 * 60 * 1000);
      
      if (reservationDateTime > maxDateTime) {
        return {
          success: true,
          data: {
            canReserve: false,
            date: targetDate,
            time,
            partySize,
            message: `Reservation cannot be made more than ${maxAdvanceDays} days in advance`,
          },
        };
      }

      // Vérifier les règles spéciales
      if (!scheduleConfig.allowSameDayBooking && this.isSameDay(targetDate, now)) {
        return {
          success: true,
          data: {
            canReserve: false,
            date: targetDate,
            time,
            partySize,
            message: 'Same day booking is not allowed',
          },
        };
      }

      if (!scheduleConfig.allowWeekendBooking && this.isWeekend(targetDate)) {
        return {
          success: true,
          data: {
            canReserve: false,
            date: targetDate,
            time,
            partySize,
            message: 'Weekend booking is not allowed',
          },
        };
      }

      return {
        success: true,
        data: {
          canReserve: true,
          date: targetDate,
          time,
          partySize,
          message: 'Reservation is possible',
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

  private isSameDay(date1: Date, date2: Date): boolean {
    return date1.toDateString() === date2.toDateString();
  }

  private isWeekend(date: Date): boolean {
    const day = date.getDay();
    return day === 0 || day === 6; // Dimanche ou Samedi
  }
}
