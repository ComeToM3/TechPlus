import { ScheduleTimeSlot } from '../entities/ScheduleTimeSlot';

export interface CreateScheduleTimeSlotData {
  dayScheduleId: string;
  time: string;
  isAvailable: boolean;
  capacity: number;
  isRecommended?: boolean;
}

export interface UpdateScheduleTimeSlotData {
  isAvailable?: boolean;
  capacity?: number;
  isRecommended?: boolean;
}

export interface ScheduleTimeSlotRepository {
  findByDayScheduleId(dayScheduleId: string): Promise<ScheduleTimeSlot[]>;
  findByTime(dayScheduleId: string, time: string): Promise<ScheduleTimeSlot | null>;
  create(data: CreateScheduleTimeSlotData): Promise<ScheduleTimeSlot>;
  update(id: string, data: UpdateScheduleTimeSlotData): Promise<ScheduleTimeSlot>;
  delete(id: string): Promise<void>;
  deleteByDayScheduleId(dayScheduleId: string): Promise<void>;
  findAvailableSlots(dayScheduleId: string, partySize?: number): Promise<ScheduleTimeSlot[]>;
}
