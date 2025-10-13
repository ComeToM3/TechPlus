import { DaySchedule } from '../entities/DaySchedule';

export interface CreateDayScheduleData {
  scheduleConfigId: string;
  dayOfWeek: string;
  isOpen: boolean;
  openingTime?: string | null;
  closingTime?: string | null;
  notes?: string | null;
}

export interface UpdateDayScheduleData {
  isOpen?: boolean;
  openingTime?: string | null;
  closingTime?: string | null;
  notes?: string | null;
}

export interface DayScheduleRepository {
  findByScheduleConfigId(scheduleConfigId: string): Promise<DaySchedule[]>;
  findByDayOfWeek(scheduleConfigId: string, dayOfWeek: string): Promise<DaySchedule | null>;
  create(data: CreateDayScheduleData): Promise<DaySchedule>;
  update(id: string, data: UpdateDayScheduleData): Promise<DaySchedule>;
  delete(id: string): Promise<void>;
  deleteByScheduleConfigId(scheduleConfigId: string): Promise<void>;
}
