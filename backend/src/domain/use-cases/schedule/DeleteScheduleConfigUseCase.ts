import { ScheduleConfigRepository } from '../../repositories/ScheduleConfigRepository';

export interface DeleteScheduleConfigRequest {
  restaurantId: string;
}

export interface DeleteScheduleConfigResponse {
  success: boolean;
  message?: string;
}

export class DeleteScheduleConfigUseCase {
  constructor(
    private scheduleConfigRepository: ScheduleConfigRepository
  ) {}

  async execute(request: DeleteScheduleConfigRequest): Promise<DeleteScheduleConfigResponse> {
    try {
      const { restaurantId } = request;

      // Vérifier si la configuration existe
      const existingConfig = await this.scheduleConfigRepository.findByRestaurantId(restaurantId);
      
      if (!existingConfig) {
        return {
          success: false,
          message: 'Schedule configuration not found',
        };
      }

      // Supprimer la configuration (les relations seront supprimées en cascade)
      await this.scheduleConfigRepository.delete(existingConfig.id);

      return {
        success: true,
        message: 'Schedule configuration deleted successfully',
      };
    } catch (error) {
      return {
        success: false,
        message: error instanceof Error ? error.message : 'Unknown error',
      };
    }
  }
}
