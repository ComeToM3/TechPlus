import { TableMetadata } from '../../entities/TableMetadata';
import { TableRepositoryExtended } from '../../repositories/TableRepositoryExtended';

export interface GetTableMetadataRequest {
  restaurantId: string;
}

export interface GetTableMetadataResponse {
  success: boolean;
  data?: TableMetadata[];
  message?: string;
}

export class GetTableMetadataUseCase {
  constructor(
    private tableRepository: TableRepositoryExtended
  ) {}

  async execute(request: GetTableMetadataRequest): Promise<GetTableMetadataResponse> {
    try {
      const { restaurantId } = request;

      const metadata = await this.tableRepository.getMetadata(restaurantId);

      return {
        success: true,
        data: metadata,
      };
    } catch (error) {
      return {
        success: false,
        message: error instanceof Error ? error.message : 'Unknown error',
      };
    }
  }
}
