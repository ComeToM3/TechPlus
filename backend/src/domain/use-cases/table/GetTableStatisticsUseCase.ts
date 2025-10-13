import { TableStatistics } from '../../entities/TableStatistics';
import { TableRepositoryExtended } from '../../repositories/TableRepositoryExtended';

export interface GetTableStatisticsRequest {
  restaurantId: string;
}

export interface GetTableStatisticsResponse {
  success: boolean;
  data?: TableStatistics;
  message?: string;
}

export class GetTableStatisticsUseCase {
  constructor(
    private tableRepository: TableRepositoryExtended
  ) {}

  async execute(request: GetTableStatisticsRequest): Promise<GetTableStatisticsResponse> {
    try {
      const { restaurantId } = request;

      const statistics = await this.tableRepository.getStatistics(restaurantId);

      return {
        success: true,
        data: statistics,
      };
    } catch (error) {
      return {
        success: false,
        message: error instanceof Error ? error.message : 'Unknown error',
      };
    }
  }
}
