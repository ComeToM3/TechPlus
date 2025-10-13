import { Table } from '../../entities/Table';
import { TableRepositoryExtended, UpdateTableData } from '../../repositories/TableRepositoryExtended';

export interface UpdateTableRequest {
  tableId: string;
  number?: number;
  capacity?: number;
  position?: string | null;
  isActive?: boolean;
}

export interface UpdateTableResponse {
  success: boolean;
  data?: Table;
  message?: string;
}

export class UpdateTableUseCase {
  constructor(
    private tableRepository: TableRepositoryExtended
  ) {}

  async execute(request: UpdateTableRequest): Promise<UpdateTableResponse> {
    try {
      const { tableId, number, capacity, position, isActive } = request;

      // Vérifier si la table existe
      const existingTable = await this.tableRepository.findById(tableId);
      if (!existingTable) {
        return {
          success: false,
          message: 'Table not found',
        };
      }

      // Validation
      if (capacity && (capacity < 1 || capacity > 20)) {
        return {
          success: false,
          message: 'Capacity must be between 1 and 20',
        };
      }

      // Vérifier si le nouveau numéro existe déjà (si changé)
      if (number && number !== parseInt(existingTable.number)) {
        const duplicateTable = await this.tableRepository.findByNumber(existingTable.restaurantId, number);
        if (duplicateTable && duplicateTable.id !== tableId) {
          return {
            success: false,
            message: 'Table number already exists',
          };
        }
      }

      const updateData: UpdateTableData = {};
      if (number !== undefined) updateData.number = number;
      if (capacity !== undefined) updateData.capacity = capacity;
      if (position !== undefined) updateData.position = position;
      if (isActive !== undefined) updateData.isActive = isActive;

      const table = await this.tableRepository.update(tableId, updateData);

      return {
        success: true,
        data: table,
        message: 'Table updated successfully',
      };
    } catch (error) {
      return {
        success: false,
        message: error instanceof Error ? error.message : 'Unknown error',
      };
    }
  }
}
