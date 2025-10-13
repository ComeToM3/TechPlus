import { Table } from '../../entities/Table';
import { TableRepositoryExtended, CreateTableData } from '../../repositories/TableRepositoryExtended';

export interface CreateTableRequest {
  number: number;
  capacity: number;
  position?: string | null;
  status?: string;
  restaurantId: string;
}

export interface CreateTableResponse {
  success: boolean;
  data?: Table;
  message?: string;
}

export class CreateTableUseCase {
  constructor(
    private tableRepository: TableRepositoryExtended
  ) {}

  async execute(request: CreateTableRequest): Promise<CreateTableResponse> {
    try {
      const { number, capacity, position, status, restaurantId } = request;

      // Validation
      if (!number || !capacity) {
        return {
          success: false,
          message: 'Number and capacity are required',
        };
      }

      if (capacity < 1 || capacity > 20) {
        return {
          success: false,
          message: 'Capacity must be between 1 and 20',
        };
      }

      // Vérifier si le numéro de table existe déjà
      const existingTable = await this.tableRepository.findByNumber(restaurantId, number);
      if (existingTable) {
        return {
          success: false,
          message: 'Table number already exists',
        };
      }

      const tableData: CreateTableData = {
        number,
        capacity,
        position: position || null,
        status: status || 'AVAILABLE',
        restaurantId,
      };

      const table = await this.tableRepository.create(tableData);

      return {
        success: true,
        data: table,
        message: 'Table created successfully',
      };
    } catch (error) {
      return {
        success: false,
        message: error instanceof Error ? error.message : 'Unknown error',
      };
    }
  }
}
