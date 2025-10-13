import { Table } from '../entities/Table';
import { TableMetadata } from '../entities/TableMetadata';
import { TableStatistics } from '../entities/TableStatistics';

export interface CreateTableData {
  number: number;
  capacity: number;
  position?: string | null;
  status?: string;
  restaurantId: string;
}

export interface UpdateTableData {
  number?: number;
  capacity?: number;
  position?: string | null;
  isActive?: boolean;
}

export interface TableFilters {
  restaurantId?: string;
  isActive?: boolean;
  minCapacity?: number;
  maxCapacity?: number;
}

export interface BatchUpdateData {
  id: string;
  data: UpdateTableData;
}

export interface TableRepositoryExtended {
  // Basic CRUD operations
  findById(id: string): Promise<Table | null>;
  findByRestaurantId(restaurantId: string, filters?: TableFilters): Promise<Table[]>;
  create(data: CreateTableData): Promise<Table>;
  update(id: string, data: UpdateTableData): Promise<Table>;
  delete(id: string): Promise<void>;

  // Extended operations
  findByNumber(restaurantId: string, number: number): Promise<Table | null>;
  findAvailableTable(date: Date, time: string, partySize: number, restaurantId: string, excludeReservationId?: string): Promise<Table | null>;
  countAvailableTables(date: Date, time: string, partySize: number, restaurantId: string, excludeReservationId?: string): Promise<number>;
  
  // Metadata operations
  getMetadata(restaurantId: string): Promise<TableMetadata[]>;
  getTableMetadata(id: string): Promise<TableMetadata | null>;
  
  // Statistics operations
  getStatistics(restaurantId: string): Promise<TableStatistics>;
  getTableStats(id: string): Promise<{
    totalReservations: number;
    todayReservations: number;
    tableId: string;
  }>;
  
  // Batch operations
  batchUpdate(updates: BatchUpdateData[]): Promise<{
    successful: number;
    failed: number;
    total: number;
  }>;
  
  // Status operations
  updateStatus(id: string, isActive: boolean): Promise<Table>;
  updateCapacity(id: string, capacity: number): Promise<Table>;
  updatePosition(id: string, position: string | null): Promise<Table>;
  updateNumber(id: string, number: number): Promise<Table>;
  
  // Validation operations
  canDeleteTable(id: string): Promise<boolean>;
  hasFutureReservations(id: string): Promise<boolean>;
}
