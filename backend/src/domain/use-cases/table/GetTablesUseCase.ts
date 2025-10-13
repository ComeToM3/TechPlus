import { Table } from '../../entities/Table';
import { TableRepositoryExtended, TableFilters } from '../../repositories/TableRepositoryExtended';

export interface GetTablesRequest {
  restaurantId: string;
  filters?: TableFilters;
}

export interface GetTablesResponse {
  success: boolean;
  data?: Table[];
  message?: string;
}

export class GetTablesUseCase {
  constructor(
    private tableRepository: TableRepositoryExtended
  ) {}

  async execute(request: GetTablesRequest): Promise<GetTablesResponse> {
    try {
      const { restaurantId, filters } = request;

      const tables = await this.tableRepository.findByRestaurantId(restaurantId, filters);

      return {
        success: true,
        data: tables,
      };
    } catch (error) {
      return {
        success: false,
        message: error instanceof Error ? error.message : 'Unknown error',
      };
    }
  }
}
