/**
 * Container d'injection de dépendances simple
 * Gère l'injection des dépendances pour l'architecture Clean
 */

import { PrismaClient } from '@prisma/client';
import prisma from '@/config/database';

// Repositories
import { PrismaUserRepository } from '../repositories/PrismaUserRepository';
import { PrismaReservationRepository } from '../repositories/PrismaReservationRepository';
import { PrismaReservationRepositoryNew } from '../repositories/PrismaReservationRepositoryNew';
import { PrismaTableRepository } from '../repositories/PrismaTableRepository';
import { PrismaRestaurantRepository } from '../repositories/PrismaRestaurantRepository';
import { PrismaNotificationRepository } from '../repositories/PrismaNotificationRepository';
import { PrismaAvailabilityRepository } from '../repositories/PrismaAvailabilityRepository';
import { PrismaScheduleConfigRepository } from '../repositories/PrismaScheduleConfigRepository';
import { PrismaDayScheduleRepository } from '../repositories/PrismaDayScheduleRepository';
import { PrismaScheduleTimeSlotRepository } from '../repositories/PrismaScheduleTimeSlotRepository';
import { PrismaTableRepositoryExtended } from '../repositories/PrismaTableRepositoryExtended';
import { PrismaPaymentRepository } from '../repositories/PrismaPaymentRepository';

// Services
import { PasswordService } from '../services/PasswordService';
import { JWTService } from '../services/JWTService';
import { EmailService } from '../services/EmailService';

// Use Cases - Auth
import { RegisterUserUseCase } from '../../domain/use-cases/auth/RegisterUserUseCase';
import { LoginUserUseCase } from '../../domain/use-cases/auth/LoginUserUseCase';
import { RefreshTokenUseCase } from '../../domain/use-cases/auth/RefreshTokenUseCase';
import { GetProfileUseCase } from '../../domain/use-cases/auth/GetProfileUseCase';
import { UpdateProfileUseCase } from '../../domain/use-cases/auth/UpdateProfileUseCase';
import { ChangePasswordUseCase } from '../../domain/use-cases/auth/ChangePasswordUseCase';
import { LoginWithTokenUseCase } from '../../domain/use-cases/auth/LoginWithTokenUseCase';
import { LogoutUseCase } from '../../domain/use-cases/auth/LogoutUseCase';

// Use Cases - Reservation
import { CreateReservationUseCase } from '../../domain/use-cases/reservation/CreateReservationUseCase';
import { GetReservationUseCase } from '../../domain/use-cases/reservation/GetReservationUseCase';
import { GetUserReservationsUseCase } from '../../domain/use-cases/reservation/GetUserReservationsUseCase';
import { UpdateReservationUseCase } from '../../domain/use-cases/reservation/UpdateReservationUseCase';
import { CancelReservationUseCase } from '../../domain/use-cases/reservation/CancelReservationUseCase';
import { GetReservationByTokenUseCase } from '../../domain/use-cases/reservation/GetReservationByTokenUseCase';
import { UpdateReservationByTokenUseCase } from '../../domain/use-cases/reservation/UpdateReservationByTokenUseCase';
import { CancelReservationByTokenUseCase } from '../../domain/use-cases/reservation/CancelReservationByTokenUseCase';

// Use Cases - Notification
import { SendReservationNotificationUseCase } from '../../domain/use-cases/notification/SendReservationNotificationUseCase';
import { SendCustomEmailUseCase } from '../../domain/use-cases/notification/SendCustomEmailUseCase';
import { GetNotificationHistoryUseCase } from '../../domain/use-cases/notification/GetNotificationHistoryUseCase';
import { RetryFailedNotificationsUseCase } from '../../domain/use-cases/notification/RetryFailedNotificationsUseCase';
import { GetNotificationStatsUseCase } from '../../domain/use-cases/notification/GetNotificationStatsUseCase';
import { VerifySMTPConnectionUseCase } from '../../domain/use-cases/notification/VerifySMTPConnectionUseCase';
import { SendTestEmailUseCase } from '../../domain/use-cases/notification/SendTestEmailUseCase';

// Use Cases - Availability
import { GetAvailabilityUseCase } from '../../domain/use-cases/availability/GetAvailabilityUseCase';
import { GetAvailableTablesUseCase } from '../../domain/use-cases/availability/GetAvailableTablesUseCase';
import { CheckSlotAvailabilityUseCase } from '../../domain/use-cases/availability/CheckSlotAvailabilityUseCase';

// Use Cases - Schedule
import { GetScheduleConfigUseCase } from '../../domain/use-cases/schedule/GetScheduleConfigUseCase';
import { CreateOrUpdateScheduleConfigUseCase } from '../../domain/use-cases/schedule/CreateOrUpdateScheduleConfigUseCase';
import { DeleteScheduleConfigUseCase } from '../../domain/use-cases/schedule/DeleteScheduleConfigUseCase';
import { GetAvailableSlotsUseCase } from '../../domain/use-cases/schedule/GetAvailableSlotsUseCase';
import { ValidateReservationUseCase } from '../../domain/use-cases/schedule/ValidateReservationUseCase';

// Use Cases - Table
import { GetTablesUseCase } from '../../domain/use-cases/table/GetTablesUseCase';
import { GetTableByIdUseCase } from '../../domain/use-cases/table/GetTableByIdUseCase';
import { CreateTableUseCase } from '../../domain/use-cases/table/CreateTableUseCase';
import { UpdateTableUseCase } from '../../domain/use-cases/table/UpdateTableUseCase';
import { DeleteTableUseCase } from '../../domain/use-cases/table/DeleteTableUseCase';
import { GetTableStatisticsUseCase } from '../../domain/use-cases/table/GetTableStatisticsUseCase';
import { GetTableMetadataUseCase } from '../../domain/use-cases/table/GetTableMetadataUseCase';
import { BatchUpdateTablesUseCase } from '../../domain/use-cases/table/BatchUpdateTablesUseCase';

// Use Cases - Payment
import { CreatePaymentIntentUseCase } from '../../domain/use-cases/payment/CreatePaymentIntentUseCase';
import { ConfirmPaymentUseCase } from '../../domain/use-cases/payment/ConfirmPaymentUseCase';
import { ProcessRefundUseCase } from '../../domain/use-cases/payment/ProcessRefundUseCase';
import { GetPaymentDetailsUseCase } from '../../domain/use-cases/payment/GetPaymentDetailsUseCase';
import { CalculateDepositUseCase } from '../../domain/use-cases/payment/CalculateDepositUseCase';
import { GetRefundPolicyUseCase } from '../../domain/use-cases/payment/GetRefundPolicyUseCase';
import { TestRefundLogicUseCase } from '../../domain/use-cases/payment/TestRefundLogicUseCase';
import { HandleWebhookUseCase } from '../../domain/use-cases/payment/HandleWebhookUseCase';

// Controllers
import { AuthController } from '../../controllers/authControllerNew';
import { ReservationController } from '../../controllers/reservationControllerNew';
import { NotificationController } from '../../controllers/notificationControllerNew';
import { AvailabilityController } from '../../controllers/availabilityControllerNew';
import { ScheduleControllerNew } from '../../controllers/scheduleControllerNew';
import { TableControllerNew } from '../../controllers/tableControllerNew';
import { PaymentControllerNew } from '../../controllers/paymentControllerNew';

export class Container {
  private static instance: Container;
  private services: Map<string, any> = new Map();

  private constructor() {
    this.setupServices();
  }

  static getInstance(): Container {
    if (!Container.instance) {
      Container.instance = new Container();
    }
    return Container.instance;
  }

  private setupServices(): void {
    // Repositories
    this.services.set('UserRepository', new PrismaUserRepository(prisma));
    this.services.set('ReservationRepository', new PrismaReservationRepository(prisma));
    this.services.set('ReservationRepositoryNew', new PrismaReservationRepositoryNew(prisma));
    this.services.set('TableRepository', new PrismaTableRepository(prisma));
    this.services.set('RestaurantRepository', new PrismaRestaurantRepository(prisma));
    this.services.set('NotificationRepository', new PrismaNotificationRepository(prisma));
    this.services.set('AvailabilityRepository', new PrismaAvailabilityRepository(prisma));
    this.services.set('ScheduleConfigRepository', new PrismaScheduleConfigRepository(prisma));
    this.services.set('DayScheduleRepository', new PrismaDayScheduleRepository(prisma));
    this.services.set('ScheduleTimeSlotRepository', new PrismaScheduleTimeSlotRepository(prisma));
    this.services.set('TableRepositoryExtended', new PrismaTableRepositoryExtended(prisma));

    // Services
    this.services.set('PasswordService', new PasswordService());
    this.services.set('JWTService', new JWTService());
    this.services.set('EmailService', new EmailService());

    // Use Cases
    this.services.set('RegisterUserUseCase', new RegisterUserUseCase(
      this.services.get('UserRepository'),
      this.services.get('PasswordService'),
      this.services.get('JWTService')
    ));

    this.services.set('LoginUserUseCase', new LoginUserUseCase(
      this.services.get('UserRepository'),
      this.services.get('PasswordService'),
      this.services.get('JWTService')
    ));

    this.services.set('RefreshTokenUseCase', new RefreshTokenUseCase(
      this.services.get('UserRepository'),
      this.services.get('JWTService')
    ));

    this.services.set('GetProfileUseCase', new GetProfileUseCase(
      this.services.get('UserRepository')
    ));

    this.services.set('UpdateProfileUseCase', new UpdateProfileUseCase(
      this.services.get('UserRepository')
    ));

    this.services.set('ChangePasswordUseCase', new ChangePasswordUseCase(
      this.services.get('UserRepository'),
      this.services.get('PasswordService')
    ));

    this.services.set('LoginWithTokenUseCase', new LoginWithTokenUseCase(
      this.services.get('JWTService'),
      this.services.get('ReservationRepository')
    ));


    this.services.set('LogoutUseCase', new LogoutUseCase());

    // Reservation Use Cases
    this.services.set('CreateReservationUseCase', new CreateReservationUseCase(
      this.services.get('ReservationRepositoryNew'),
      this.services.get('TableRepository'),
      this.services.get('RestaurantRepository')
    ));

    this.services.set('GetReservationUseCase', new GetReservationUseCase(
      this.services.get('ReservationRepositoryNew')
    ));

    this.services.set('GetUserReservationsUseCase', new GetUserReservationsUseCase(
      this.services.get('ReservationRepositoryNew')
    ));

    this.services.set('UpdateReservationUseCase', new UpdateReservationUseCase(
      this.services.get('ReservationRepositoryNew'),
      this.services.get('TableRepository')
    ));

    this.services.set('CancelReservationUseCase', new CancelReservationUseCase(
      this.services.get('ReservationRepositoryNew')
    ));

    this.services.set('GetReservationByTokenUseCase', new GetReservationByTokenUseCase(
      this.services.get('ReservationRepositoryNew')
    ));

    this.services.set('UpdateReservationByTokenUseCase', new UpdateReservationByTokenUseCase(
      this.services.get('ReservationRepositoryNew'),
      this.services.get('TableRepository')
    ));

    this.services.set('CancelReservationByTokenUseCase', new CancelReservationByTokenUseCase(
      this.services.get('ReservationRepositoryNew')
    ));

    // Use Cases - Notification
    this.services.set('SendReservationNotificationUseCase', new SendReservationNotificationUseCase(
      this.services.get('NotificationRepository'),
      this.services.get('EmailService')
    ));

    this.services.set('SendCustomEmailUseCase', new SendCustomEmailUseCase(
      this.services.get('NotificationRepository'),
      this.services.get('EmailService')
    ));

    this.services.set('GetNotificationHistoryUseCase', new GetNotificationHistoryUseCase(
      this.services.get('NotificationRepository')
    ));

    this.services.set('RetryFailedNotificationsUseCase', new RetryFailedNotificationsUseCase(
      this.services.get('NotificationRepository'),
      this.services.get('EmailService')
    ));

    this.services.set('GetNotificationStatsUseCase', new GetNotificationStatsUseCase(
      this.services.get('NotificationRepository')
    ));

    this.services.set('VerifySMTPConnectionUseCase', new VerifySMTPConnectionUseCase(
      this.services.get('EmailService')
    ));

    this.services.set('SendTestEmailUseCase', new SendTestEmailUseCase(
      this.services.get('NotificationRepository'),
      this.services.get('EmailService')
    ));

    // Use Cases - Availability
    this.services.set('GetAvailabilityUseCase', new GetAvailabilityUseCase(
      this.services.get('AvailabilityRepository')
    ));

    this.services.set('GetAvailableTablesUseCase', new GetAvailableTablesUseCase(
      this.services.get('AvailabilityRepository')
    ));

    this.services.set('CheckSlotAvailabilityUseCase', new CheckSlotAvailabilityUseCase(
      this.services.get('AvailabilityRepository')
    ));

    // Use Cases - Schedule
    this.services.set('GetScheduleConfigUseCase', new GetScheduleConfigUseCase(
      this.services.get('ScheduleConfigRepository'),
      this.services.get('DayScheduleRepository'),
      this.services.get('ScheduleTimeSlotRepository')
    ));

    this.services.set('CreateOrUpdateScheduleConfigUseCase', new CreateOrUpdateScheduleConfigUseCase(
      this.services.get('ScheduleConfigRepository'),
      this.services.get('DayScheduleRepository'),
      this.services.get('ScheduleTimeSlotRepository')
    ));

    this.services.set('DeleteScheduleConfigUseCase', new DeleteScheduleConfigUseCase(
      this.services.get('ScheduleConfigRepository')
    ));

    this.services.set('GetAvailableSlotsUseCase', new GetAvailableSlotsUseCase(
      this.services.get('ScheduleConfigRepository'),
      this.services.get('DayScheduleRepository'),
      this.services.get('ScheduleTimeSlotRepository')
    ));

    this.services.set('ValidateReservationUseCase', new ValidateReservationUseCase(
      this.services.get('ScheduleConfigRepository'),
      this.services.get('DayScheduleRepository')
    ));

    // Use Cases - Table
    this.services.set('GetTablesUseCase', new GetTablesUseCase(
      this.services.get('TableRepositoryExtended')
    ));

    this.services.set('GetTableByIdUseCase', new GetTableByIdUseCase(
      this.services.get('TableRepositoryExtended')
    ));

    this.services.set('CreateTableUseCase', new CreateTableUseCase(
      this.services.get('TableRepositoryExtended')
    ));

    this.services.set('UpdateTableUseCase', new UpdateTableUseCase(
      this.services.get('TableRepositoryExtended')
    ));

    this.services.set('DeleteTableUseCase', new DeleteTableUseCase(
      this.services.get('TableRepositoryExtended')
    ));

    this.services.set('GetTableStatisticsUseCase', new GetTableStatisticsUseCase(
      this.services.get('TableRepositoryExtended')
    ));

    this.services.set('GetTableMetadataUseCase', new GetTableMetadataUseCase(
      this.services.get('TableRepositoryExtended')
    ));

    this.services.set('BatchUpdateTablesUseCase', new BatchUpdateTablesUseCase(
      this.services.get('TableRepositoryExtended')
    ));

    // Use Cases - Payment
    this.services.set('CreatePaymentIntentUseCase', new CreatePaymentIntentUseCase(
      this.services.get('PaymentRepository')
    ));

    this.services.set('ConfirmPaymentUseCase', new ConfirmPaymentUseCase(
      this.services.get('PaymentRepository')
    ));

    this.services.set('ProcessRefundUseCase', new ProcessRefundUseCase(
      this.services.get('PaymentRepository')
    ));

    this.services.set('GetPaymentDetailsUseCase', new GetPaymentDetailsUseCase(
      this.services.get('PaymentRepository')
    ));

    this.services.set('CalculateDepositUseCase', new CalculateDepositUseCase());

    this.services.set('GetRefundPolicyUseCase', new GetRefundPolicyUseCase(
      this.services.get('PaymentRepository')
    ));

    this.services.set('TestRefundLogicUseCase', new TestRefundLogicUseCase(
      this.services.get('PaymentRepository')
    ));

    this.services.set('HandleWebhookUseCase', new HandleWebhookUseCase(
      this.services.get('PaymentRepository')
    ));

    // Controllers
    this.services.set('AuthController', new AuthController(
      this.services.get('RegisterUserUseCase'),
      this.services.get('LoginUserUseCase'),
      this.services.get('RefreshTokenUseCase'),
      this.services.get('GetProfileUseCase'),
      this.services.get('UpdateProfileUseCase'),
      this.services.get('ChangePasswordUseCase'),
      this.services.get('LoginWithTokenUseCase'),
      this.services.get('LogoutUseCase')
    ));

    this.services.set('ReservationController', new ReservationController(
      this.services.get('CreateReservationUseCase'),
      this.services.get('GetReservationUseCase'),
      this.services.get('GetUserReservationsUseCase'),
      this.services.get('UpdateReservationUseCase'),
      this.services.get('CancelReservationUseCase'),
      this.services.get('GetReservationByTokenUseCase'),
      this.services.get('UpdateReservationByTokenUseCase'),
      this.services.get('CancelReservationByTokenUseCase')
    ));

    this.services.set('NotificationController', new NotificationController(
      this.services.get('SendReservationNotificationUseCase'),
      this.services.get('SendCustomEmailUseCase'),
      this.services.get('GetNotificationHistoryUseCase'),
      this.services.get('RetryFailedNotificationsUseCase'),
      this.services.get('GetNotificationStatsUseCase'),
      this.services.get('VerifySMTPConnectionUseCase'),
      this.services.get('SendTestEmailUseCase')
    ));

    this.services.set('AvailabilityController', new AvailabilityController(
      this.services.get('GetAvailabilityUseCase'),
      this.services.get('GetAvailableTablesUseCase'),
      this.services.get('CheckSlotAvailabilityUseCase')
    ));

    console.log('🔍 Registering ScheduleController...');
    const getScheduleConfigUseCase = this.services.get('GetScheduleConfigUseCase');
    const createOrUpdateScheduleConfigUseCase = this.services.get('CreateOrUpdateScheduleConfigUseCase');
    const deleteScheduleConfigUseCase = this.services.get('DeleteScheduleConfigUseCase');
    const getAvailableSlotsUseCase = this.services.get('GetAvailableSlotsUseCase');
    const validateReservationUseCase = this.services.get('ValidateReservationUseCase');
    
    console.log('🔍 Schedule Use Cases resolved:', {
      getScheduleConfigUseCase: !!getScheduleConfigUseCase,
      createOrUpdateScheduleConfigUseCase: !!createOrUpdateScheduleConfigUseCase,
      deleteScheduleConfigUseCase: !!deleteScheduleConfigUseCase,
      getAvailableSlotsUseCase: !!getAvailableSlotsUseCase,
      validateReservationUseCase: !!validateReservationUseCase,
    });
    
    this.services.set('ScheduleController', new ScheduleControllerNew(
      getScheduleConfigUseCase,
      createOrUpdateScheduleConfigUseCase,
      deleteScheduleConfigUseCase,
      getAvailableSlotsUseCase,
      validateReservationUseCase
    ));
    console.log('✅ ScheduleController registered');

    this.services.set('TableController', new TableControllerNew(
      this.services.get('GetTablesUseCase'),
      this.services.get('GetTableByIdUseCase'),
      this.services.get('CreateTableUseCase'),
      this.services.get('UpdateTableUseCase'),
      this.services.get('DeleteTableUseCase'),
      this.services.get('GetTableStatisticsUseCase'),
      this.services.get('GetTableMetadataUseCase'),
      this.services.get('BatchUpdateTablesUseCase')
    ));

    this.services.set('PaymentController', new PaymentControllerNew(
      this.services.get('CreatePaymentIntentUseCase'),
      this.services.get('ConfirmPaymentUseCase'),
      this.services.get('ProcessRefundUseCase'),
      this.services.get('GetPaymentDetailsUseCase'),
      this.services.get('CalculateDepositUseCase'),
      this.services.get('GetRefundPolicyUseCase'),
      this.services.get('TestRefundLogicUseCase'),
      this.services.get('HandleWebhookUseCase')
    ));
  }

  resolve<T>(key: string): T {
    const service = this.services.get(key);
    if (!service) {
      throw new Error(`Service ${key} not found`);
    }
    return service;
  }

  // Méthodes pour obtenir les controllers
  getAuthController(): AuthController {
    return this.resolve<AuthController>('AuthController');
  }

  getReservationController(): ReservationController {
    return this.resolve<ReservationController>('ReservationController');
  }

  getNotificationController(): NotificationController {
    return this.resolve<NotificationController>('NotificationController');
  }

  getAvailabilityController(): AvailabilityController {
    return this.resolve<AvailabilityController>('AvailabilityController');
  }

  getScheduleController(): ScheduleControllerNew {
    return this.resolve<ScheduleControllerNew>('ScheduleController');
  }

  getTableController(): TableControllerNew {
    return this.resolve<TableControllerNew>('TableController');
  }

  getPaymentController(): PaymentControllerNew {
    return this.resolve<PaymentControllerNew>('PaymentController');
  }
}

