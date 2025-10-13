import { Table } from '../../entities/Table';
import { TableRepositoryExtended } from '../../repositories/TableRepositoryExtended';

export interface GetTableByIdRequest {
  tableId: string;
}

export interface GetTableByIdResponse {
  success: boolean;
  data?: Table;
  message?: string;
}

export class GetTableByIdUseCase {
  constructor(
    private tableRepository: TableRepositoryExtended
  ) {}

  async execute(request: GetTableByIdRequest): Promise<GetTableByIdResponse> {
    try {
      const { tableId } = request;

      const table = await this.tableRepository.findById(tableId);

      if (!table) {
        return {
          success: false,
          message: 'Table not found',
        };
      }

      return {
        success: true,
        data: table,
      };
    } catch (error) {
      return {
        success: false,
        message: error instanceof Error ? error.message : 'Unknown error',
      };
    }
  }
}
