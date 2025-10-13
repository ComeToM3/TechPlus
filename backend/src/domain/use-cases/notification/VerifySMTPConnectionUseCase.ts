import { EmailService } from '../../../infrastructure/services/EmailService';

export interface VerifySMTPConnectionRequest {
  // Pas de paramètres requis
}

export interface VerifySMTPConnectionResponse {
  isConnected: boolean;
  message: string;
}

export class VerifySMTPConnectionUseCase {
  constructor(private emailService: EmailService) {}

  async execute(request: VerifySMTPConnectionRequest): Promise<VerifySMTPConnectionResponse> {
    try {
      const isConnected = await this.emailService.verifyConnection();

      return {
        isConnected,
        message: isConnected
          ? 'SMTP connection verified successfully'
          : 'SMTP connection failed or not configured',
      };
    } catch (error) {
      return {
        isConnected: false,
        message: `SMTP verification failed: ${error}`,
      };
    }
  }
}

