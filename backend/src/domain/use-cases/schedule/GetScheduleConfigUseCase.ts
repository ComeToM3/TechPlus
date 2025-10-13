import { ScheduleConfig } from '../../entities/ScheduleConfig';
import { ScheduleConfigRepository } from '../../repositories/ScheduleConfigRepository';
import { DayScheduleRepository } from '../../repositories/DayScheduleRepository';
import { ScheduleTimeSlotRepository } from '../../repositories/ScheduleTimeSlotRepository';

export interface GetScheduleConfigRequest {
  restaurantId: string;
}

export interface GetScheduleConfigResponse {
  success: boolean;
  data?: any;
  message?: string;
}

export class GetScheduleConfigUseCase {
  constructor(
    private scheduleConfigRepository: ScheduleConfigRepository,
    private dayScheduleRepository: DayScheduleRepository,
    private scheduleTimeSlotRepository: ScheduleTimeSlotRepository
  ) {}

  async execute(request: GetScheduleConfigRequest): Promise<GetScheduleConfigResponse> {
    try {
      const { restaurantId } = request;

      // Récupérer la configuration
      const scheduleConfig = await this.scheduleConfigRepository.findByRestaurantId(restaurantId);
      
      if (!scheduleConfig) {
        return {
          success: false,
          message: 'Schedule configuration not found',
        };
      }

      // Récupérer les horaires des jours
      const daySchedules = await this.dayScheduleRepository.findByScheduleConfigId(scheduleConfig.id);
      
      // Récupérer les créneaux pour chaque jour
      const scheduleWithSlots = await Promise.all(
        daySchedules.map(async (daySchedule) => {
          const timeSlots = await this.scheduleTimeSlotRepository.findByDayScheduleId(daySchedule.id);
          
          return {
            id: daySchedule.id,
            dayOfWeek: daySchedule.dayOfWeek,
            isOpen: daySchedule.isOpen,
            openingTime: daySchedule.openingTime,
            closingTime: daySchedule.closingTime,
            notes: daySchedule.notes,
            timeSlots: timeSlots.map(slot => ({
              id: slot.id,
              time: slot.time,
              isAvailable: slot.isAvailable,
              capacity: slot.capacity,
              isRecommended: slot.isRecommended,
            })),
          };
        })
      );

      return {
        success: true,
        data: {
          id: scheduleConfig.id,
          restaurantId: scheduleConfig.restaurantId,
          slotDurationMinutes: scheduleConfig.slotDurationMinutes,
          bufferTimeMinutes: scheduleConfig.bufferTimeMinutes,
          maxAdvanceBookingDays: scheduleConfig.maxAdvanceBookingDays,
          minAdvanceBookingHours: scheduleConfig.minAdvanceBookingHours,
          allowSameDayBooking: scheduleConfig.allowSameDayBooking,
          allowWeekendBooking: scheduleConfig.allowWeekendBooking,
          defaultCapacityPerSlot: scheduleConfig.defaultCapacityPerSlot,
          daySchedules: scheduleWithSlots,
        },
      };
    } catch (error) {
      return {
        success: false,
        message: error instanceof Error ? error.message : 'Unknown error',
      };
    }
  }
}
