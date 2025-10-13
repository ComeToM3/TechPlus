import nodemailer from 'nodemailer';
import logger from '@/utils/logger';

export class EmailService {
  private transporter!: nodemailer.Transporter;
  private isConfigured: boolean = false;

  constructor() {
    this.initializeTransporter();
  }

  /**
   * Initialise le transporteur email
   */
  private initializeTransporter(): void {
    try {
      const smtpConfig = {
        host: process.env.SMTP_HOST || 'smtp.gmail.com',
        port: parseInt(process.env.SMTP_PORT || '587'),
        secure: process.env.SMTP_SECURE === 'true',
        auth: {
          user: process.env.SMTP_USER,
          pass: process.env.SMTP_PASS,
        },
        tls: {
          rejectUnauthorized: false,
        },
      };

      if (!smtpConfig.auth.user || !smtpConfig.auth.pass) {
        logger.warn('SMTP credentials not configured. Email notifications will be disabled.');
        return;
      }

      this.transporter = nodemailer.createTransport(smtpConfig);
      this.isConfigured = true;
      logger.info('Email transporter initialized successfully');
    } catch (error) {
      logger.error('Failed to initialize email transporter:', error);
      this.isConfigured = false;
    }
  }

  /**
   * Vérifie la configuration SMTP
   */
  async verifyConnection(): Promise<boolean> {
    if (!this.isConfigured) {
      logger.warn('SMTP not configured, skipping verification');
      return false;
    }

    try {
      await this.transporter.verify();
      logger.info('SMTP connection verified successfully');
      return true;
    } catch (error) {
      logger.error('SMTP connection verification failed:', error);
      return false;
    }
  }

  /**
   * Envoie un email
   */
  async sendEmail(
    to: string,
    subject: string,
    htmlContent: string,
    textContent?: string,
    attachments?: any[]
  ): Promise<boolean> {
    if (!this.isConfigured) {
      logger.warn('SMTP not configured, email not sent');
      return false;
    }

    try {
      const mailOptions: nodemailer.SendMailOptions = {
        from: `"${process.env.SMTP_FROM_NAME || 'TechPlus'}" <${process.env.SMTP_FROM_EMAIL || process.env.SMTP_USER}>`,
        to,
        subject,
        html: htmlContent,
        text: textContent,
        attachments,
      };

      const result = await this.transporter.sendMail(mailOptions);
      logger.info(`Email sent successfully to ${to}. MessageId: ${result.messageId}`);
      return true;
    } catch (error) {
      logger.error(`Failed to send email to ${to}:`, error);
      return false;
    }
  }
}
