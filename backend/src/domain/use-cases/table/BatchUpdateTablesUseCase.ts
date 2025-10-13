import { TableRepositoryExtended, BatchUpdateData } from '../../repositories/TableRepositoryExtended';

export interface BatchUpdateTablesRequest {
  updates: Array<{
    id: string;
    data: {
      number?: number;
      capacity?: number;
      position?: string | null;
      isActive?: boolean;
    };
  }>;
}

export interface BatchUpdateTablesResponse {
  success: boolean;
  data?: {
    successful: number;
    failed: number;
    total: number;
  };
  message?: string;
}

export class BatchUpdateTablesUseCase {
  constructor(
    private tableRepository: TableRepositoryExtended
  ) {}

  async execute(request: BatchUpdateTablesRequest): Promise<BatchUpdateTablesResponse> {
    try {
      const { updates } = request;

      if (!Array.isArray(updates) || updates.length === 0) {
        return {
          success: false,
          message: 'Updates array is required and must not be empty',
        };
      }

      const batchUpdateData: BatchUpdateData[] = updates.map(update => ({
        id: update.id,
        data: update.data,
      }));

      const result = await this.tableRepository.batchUpdate(batchUpdateData);

      return {
        success: true,
        data: result,
      };
    } catch (error) {
      return {
        success: false,
        message: error instanceof Error ? error.message : 'Unknown error',
      };
    }
  }
}
