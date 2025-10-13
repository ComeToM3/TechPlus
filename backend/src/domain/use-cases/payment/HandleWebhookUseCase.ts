import { PaymentRepository } from '../../repositories/PaymentRepository';

export interface HandleWebhookRequest {
  eventType: string;
  eventData: any;
}

export interface HandleWebhookResponse {
  success: boolean;
  message?: string;
}

export class HandleWebhookUseCase {
  constructor(
    private paymentRepository: PaymentRepository
  ) {}

  async execute(request: HandleWebhookRequest): Promise<HandleWebhookResponse> {
    try {
      const { eventType, eventData } = request;

      // Validation
      if (!eventType || !eventData) {
        return {
          success: false,
          message: 'Event type and event data are required',
        };
      }

      // Traiter l'événement webhook
      await this.paymentRepository.handleWebhookEvent(eventType, eventData);

      return {
        success: true,
        message: 'Webhook event processed successfully',
      };
    } catch (error) {
      return {
        success: false,
        message: error instanceof Error ? error.message : 'Unknown error',
      };
    }
  }
}
