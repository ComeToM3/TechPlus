import { ScheduleConfig } from '../../entities/ScheduleConfig';
import { ScheduleConfigRepository, CreateScheduleConfigData } from '../../repositories/ScheduleConfigRepository';
import { DayScheduleRepository, CreateDayScheduleData } from '../../repositories/DayScheduleRepository';
import { ScheduleTimeSlotRepository, CreateScheduleTimeSlotData } from '../../repositories/ScheduleTimeSlotRepository';

export interface CreateOrUpdateScheduleConfigRequest {
  restaurantId: string;
  slotDurationMinutes: number;
  bufferTimeMinutes: number;
  maxAdvanceBookingDays: number;
  minAdvanceBookingHours: number;
  allowSameDayBooking: boolean;
  allowWeekendBooking: boolean;
  defaultCapacityPerSlot: number;
  daySchedules: Array<{
    dayOfWeek: string;
    isOpen: boolean;
    openingTime?: string | null;
    closingTime?: string | null;
    notes?: string | null;
    timeSlots?: Array<{
      time: string;
      isAvailable: boolean;
      capacity: number;
      isRecommended?: boolean;
    }>;
  }>;
}

export interface CreateOrUpdateScheduleConfigResponse {
  success: boolean;
  data?: any;
  message?: string;
}

export class CreateOrUpdateScheduleConfigUseCase {
  constructor(
    private scheduleConfigRepository: ScheduleConfigRepository,
    private dayScheduleRepository: DayScheduleRepository,
    private scheduleTimeSlotRepository: ScheduleTimeSlotRepository
  ) {}

  async execute(request: CreateOrUpdateScheduleConfigRequest): Promise<CreateOrUpdateScheduleConfigResponse> {
    try {
      const { restaurantId, daySchedules, ...configData } = request;

      // Vérifier si une configuration existe déjà
      const existingConfig = await this.scheduleConfigRepository.findByRestaurantId(restaurantId);
      
      let scheduleConfig: ScheduleConfig;

      if (existingConfig) {
        // Mettre à jour la configuration existante
        scheduleConfig = await this.scheduleConfigRepository.update(existingConfig.id, configData);
        
        // Supprimer les anciens horaires et créneaux
        await this.dayScheduleRepository.deleteByScheduleConfigId(scheduleConfig.id);
      } else {
        // Créer une nouvelle configuration
        scheduleConfig = await this.scheduleConfigRepository.create({
          restaurantId,
          ...configData,
        });
      }

      // Créer les nouveaux horaires et créneaux
      for (const dayScheduleData of daySchedules) {
        const daySchedule = await this.dayScheduleRepository.create({
          scheduleConfigId: scheduleConfig.id,
          dayOfWeek: dayScheduleData.dayOfWeek,
          isOpen: dayScheduleData.isOpen,
          openingTime: dayScheduleData.openingTime || null,
          closingTime: dayScheduleData.closingTime || null,
          notes: dayScheduleData.notes || null,
        });

        // Créer les créneaux pour ce jour
        if (dayScheduleData.timeSlots && Array.isArray(dayScheduleData.timeSlots)) {
          for (const timeSlotData of dayScheduleData.timeSlots) {
            await this.scheduleTimeSlotRepository.create({
              dayScheduleId: daySchedule.id,
              time: timeSlotData.time,
              isAvailable: timeSlotData.isAvailable,
              capacity: timeSlotData.capacity,
              isRecommended: timeSlotData.isRecommended || false,
            });
          }
        }
      }

      // Récupérer la configuration complète
      const updatedConfig = await this.scheduleConfigRepository.findByRestaurantId(restaurantId);
      const daySchedulesWithSlots = await this.dayScheduleRepository.findByScheduleConfigId(scheduleConfig.id);
      
      const scheduleWithSlots = await Promise.all(
        daySchedulesWithSlots.map(async (daySchedule) => {
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
        message: existingConfig ? 'Schedule configuration updated' : 'Schedule configuration created',
      };
    } catch (error) {
      return {
        success: false,
        message: error instanceof Error ? error.message : 'Unknown error',
      };
    }
  }
}
