import { DayAvailability } from '../entities/DayAvailability';
import { AvailabilitySlot } from '../entities/AvailabilitySlot';
import { TimeSlot } from '../entities/TimeSlot';

export interface GetAvailabilityRequest {
  date: Date;
  partySize: number;
  restaurantId?: string;
}

export interface GetAvailableTablesRequest {
  date: Date;
  time: string;
  partySize: number;
  restaurantId?: string;
}

export interface CheckSlotAvailabilityRequest {
  date: Date;
  time: string;
  partySize: number;
  restaurantId?: string;
}

export interface AvailabilityRepository {
  getDayAvailability(request: GetAvailabilityRequest): Promise<DayAvailability>;
  getAvailableTables(request: GetAvailableTablesRequest): Promise<any[]>;
  checkSlotAvailability(request: CheckSlotAvailabilityRequest): Promise<boolean>;
  getTimeSlotsForDay(dayOfWeek: string, restaurantId: string): Promise<TimeSlot[]>;
  getRestaurantOpeningHours(restaurantId: string): Promise<any>;
}

