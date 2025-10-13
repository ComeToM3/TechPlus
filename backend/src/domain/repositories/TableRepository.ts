import { Table } from '../entities/Table';

export interface TableFilters {
  restaurantId?: string;
  isActive?: boolean;
  minCapacity?: number;
  maxCapacity?: number;
}

export interface TableRepository {
  findById(id: string): Promise<Table | null>;
  findByRestaurantId(restaurantId: string, filters?: TableFilters): Promise<Table[]>;
  findAvailableTable(date: Date, time: string, partySize: number, restaurantId: string, excludeReservationId?: string): Promise<Table | null>;
  countAvailableTables(date: Date, time: string, partySize: number, restaurantId: string, excludeReservationId?: string): Promise<number>;
}


