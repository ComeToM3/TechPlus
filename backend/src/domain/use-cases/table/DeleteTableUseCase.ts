import { TableRepositoryExtended } from '../../repositories/TableRepositoryExtended';

export interface DeleteTableRequest {
  tableId: string;
}

export interface DeleteTableResponse {
  success: boolean;
  message?: string;
}

export class DeleteTableUseCase {
  constructor(
    private tableRepository: TableRepositoryExtended
  ) {}

  async execute(request: DeleteTableRequest): Promise<DeleteTableResponse> {
    try {
      const { tableId } = request;

      // Vérifier si la table existe
      const existingTable = await this.tableRepository.findById(tableId);
      if (!existingTable) {
        return {
          success: false,
          message: 'Table not found',
        };
      }

      // Vérifier s'il y a des réservations futures
      const canDelete = await this.tableRepository.canDeleteTable(tableId);
      if (!canDelete) {
        return {
          success: false,
          message: 'Cannot delete table with future reservations',
        };
      }

      await this.tableRepository.delete(tableId);

      return {
        success: true,
        message: 'Table deleted successfully',
      };
    } catch (error) {
      return {
        success: false,
        message: error instanceof Error ? error.message : 'Unknown error',
      };
    }
  }
}
