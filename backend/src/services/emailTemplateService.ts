import fs from 'fs';
import path from 'path';
import logger from '@/utils/logger';

export interface TemplateData {
  // Données du restaurant
  restaurantName: string;
  restaurantAddress: string;
  restaurantPhone: string;

  // Données du client
  clientName: string;
  clientEmail: string;

  // Données de la réservation
  reservationId: string;
  reservationDate: string;
  reservationTime: string;
  partySize: number;
  tableNumber?: string;

  // Données spécifiques
  specialRequests?: string;
  cancellationReason?: string;
  refundAmount?: number;
  refundStatus?: string;
  requiresPayment?: boolean;

  // URLs
  managementUrl?: string;
}

export class EmailTemplateService {
  private static templatesPath = path.join(__dirname, '../templates/email');

  /**
   * Génère le contenu HTML d'un template email
   */
  static generateTemplate(templateName: string, data: TemplateData): string {
    try {
      const templatePath = path.join(this.templatesPath, `${templateName}.html`);

      if (!fs.existsSync(templatePath)) {
        logger.error(`Template not found: ${templatePath}`);
        throw new Error(`Template ${templateName} not found`);
      }

      let template = fs.readFileSync(templatePath, 'utf8');

      // Remplacer les variables du template
      template = this.replaceVariables(template, data);

      return template;
    } catch (error) {
      logger.error(`Error generating template ${templateName}:`, error);
      throw error;
    }
  }

  /**
   * Remplace les variables dans le template
   */
  private static replaceVariables(template: string, data: TemplateData): string {
    let result = template;

    // Remplacer les variables simples {{variable}}
    Object.entries(data).forEach(([key, value]) => {
      if (value !== undefined && value !== null) {
        const regex = new RegExp(`{{${key}}}`, 'g');
        result = result.replace(regex, String(value));
      }
    });

    // Gérer les conditions {{#if variable}}...{{/if}}
    result = this.processConditionals(result, data);

    return result;
  }

  /**
   * Traite les conditions dans le template
   */
  private static processConditionals(template: string, data: TemplateData): string {
    // Pattern pour {{#if variable}}...{{/if}}
    const conditionalRegex = /{{#if\s+(\w+)}}(.*?){{\/if}}/gs;

    return template.replace(conditionalRegex, (match, variable, content) => {
      const value = (data as any)[variable];
      if (value && value !== '' && value !== false && value !== 0) {
        return content;
      }
      return '';
    });
  }

  /**
   * Génère le template de confirmation de réservation
   */
  static generateReservationConfirmation(data: TemplateData): string {
    return this.generateTemplate('reservation-confirmation', data);
  }

  /**
   * Génère le template de rappel de réservation
   */
  static generateReservationReminder(data: TemplateData): string {
    return this.generateTemplate('reservation-reminder', data);
  }

  /**
   * Génère le template d'annulation de réservation
   */
  static generateReservationCancellation(data: TemplateData): string {
    return this.generateTemplate('reservation-cancellation', data);
  }

  /**
   * Génère le template de modification de réservation
   */
  static generateReservationModification(data: TemplateData): string {
    return this.generateTemplate('reservation-modification', data);
  }

  /**
   * Génère le template de confirmation de paiement
   */
  static generatePaymentConfirmation(data: TemplateData): string {
    return this.generateTemplate('payment-confirmation', data);
  }

  /**
   * Génère le template d'échec de paiement
   */
  static generatePaymentFailed(data: TemplateData): string {
    return this.generateTemplate('payment-failed', data);
  }

  /**
   * Liste tous les templates disponibles
   */
  static getAvailableTemplates(): string[] {
    try {
      const files = fs.readdirSync(this.templatesPath);
      return files.filter(file => file.endsWith('.html')).map(file => file.replace('.html', ''));
    } catch (error) {
      logger.error('Error listing templates:', error);
      return [];
    }
  }

  /**
   * Vérifie si un template existe
   */
  static templateExists(templateName: string): boolean {
    const templatePath = path.join(this.templatesPath, `${templateName}.html`);
    return fs.existsSync(templatePath);
  }
}
