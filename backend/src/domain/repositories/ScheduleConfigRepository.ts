import { ScheduleConfig } from '../entities/ScheduleConfig';

export interface CreateScheduleConfigData {
  restaurantId: string;
  slotDurationMinutes: number;
  bufferTimeMinutes: number;
  maxAdvanceBookingDays: number;
  minAdvanceBookingHours: number;
  allowSameDayBooking: boolean;
  allowWeekendBooking: boolean;
  defaultCapacityPerSlot: number;
}

export interface UpdateScheduleConfigData {
  slotDurationMinutes?: number;
  bufferTimeMinutes?: number;
  maxAdvanceBookingDays?: number;
  minAdvanceBookingHours?: number;
  allowSameDayBooking?: boolean;
  allowWeekendBooking?: boolean;
  defaultCapacityPerSlot?: number;
}

export interface ScheduleConfigRepository {
  findByRestaurantId(restaurantId: string): Promise<ScheduleConfig | null>;
  create(data: CreateScheduleConfigData): Promise<ScheduleConfig>;
  update(id: string, data: UpdateScheduleConfigData): Promise<ScheduleConfig>;
  delete(id: string): Promise<void>;
  exists(restaurantId: string): Promise<boolean>;
}
