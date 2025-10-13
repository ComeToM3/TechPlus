import { ReservationStatus, PaymentStatus } from '@prisma/client';

interface ReservationProps {
  id: string;
  date: Date;
  time: string;
  duration: number;
  partySize: number;
  status: ReservationStatus;
  requiresPayment: boolean;
  depositAmount: number;
  paymentStatus: PaymentStatus;
  notes?: string;
  specialRequests?: string;
  clientName?: string;
  clientEmail?: string;
  clientPhone?: string;
  managementToken?: string;
  tokenExpiresAt?: Date;
  cancellationReason?: string;
  userId?: string;
  restaurantId: string;
  tableId?: string;
  createdAt: Date;
  updatedAt: Date;
}

export class Reservation {
  private props: ReservationProps;

  constructor(props: ReservationProps) {
    this.props = props;
  }

  // Getters
  get id(): string { return this.props.id; }
  get date(): Date { return this.props.date; }
  get time(): string { return this.props.time; }
  get duration(): number { return this.props.duration; }
  get partySize(): number { return this.props.partySize; }
  get status(): ReservationStatus { return this.props.status; }
  get requiresPayment(): boolean { return this.props.requiresPayment; }
  get depositAmount(): number { return this.props.depositAmount; }
  get paymentStatus(): PaymentStatus { return this.props.paymentStatus; }
  get notes(): string | undefined { return this.props.notes; }
  get specialRequests(): string | undefined { return this.props.specialRequests; }
  get clientName(): string | undefined { return this.props.clientName; }
  get clientEmail(): string | undefined { return this.props.clientEmail; }
  get clientPhone(): string | undefined { return this.props.clientPhone; }
  get managementToken(): string | undefined { return this.props.managementToken; }
  get tokenExpiresAt(): Date | undefined { return this.props.tokenExpiresAt; }
  get cancellationReason(): string | undefined { return this.props.cancellationReason; }
  get userId(): string | undefined { return this.props.userId; }
  get restaurantId(): string { return this.props.restaurantId; }
  get tableId(): string | undefined { return this.props.tableId; }
  get createdAt(): Date { return this.props.createdAt; }
  get updatedAt(): Date { return this.props.updatedAt; }

  // Business logic methods
  isGuestReservation(): boolean {
    return !this.props.userId && !!this.props.managementToken;
  }

  isTokenExpired(): boolean {
    if (!this.props.tokenExpiresAt) return false;
    return this.props.tokenExpiresAt < new Date();
  }

  canBeCancelled(): boolean {
    return this.props.status === ReservationStatus.PENDING || 
           this.props.status === ReservationStatus.CONFIRMED;
  }

  canBeModified(): boolean {
    return this.props.status === ReservationStatus.PENDING || 
           this.props.status === ReservationStatus.CONFIRMED;
  }

  isActive(): boolean {
    return this.props.status !== ReservationStatus.CANCELLED;
  }

  // Factory method to create Reservation from Prisma model
  static fromPrisma(prismaReservation: any): Reservation {
    return new Reservation({
      id: prismaReservation.id,
      date: prismaReservation.date,
      time: prismaReservation.time,
      duration: prismaReservation.duration,
      partySize: prismaReservation.partySize,
      status: prismaReservation.status,
      requiresPayment: prismaReservation.requiresPayment,
      depositAmount: prismaReservation.depositAmount,
      paymentStatus: prismaReservation.paymentStatus,
      notes: prismaReservation.notes,
      specialRequests: prismaReservation.specialRequests,
      clientName: prismaReservation.clientName,
      clientEmail: prismaReservation.clientEmail,
      clientPhone: prismaReservation.clientPhone,
      managementToken: prismaReservation.managementToken,
      tokenExpiresAt: prismaReservation.tokenExpiresAt,
      cancellationReason: prismaReservation.cancellationReason,
      userId: prismaReservation.userId,
      restaurantId: prismaReservation.restaurantId,
      tableId: prismaReservation.tableId,
      createdAt: prismaReservation.createdAt,
      updatedAt: prismaReservation.updatedAt,
    });
  }

  toJSON() {
    return {
      id: this.id,
      date: this.date,
      time: this.time,
      duration: this.duration,
      partySize: this.partySize,
      status: this.status,
      requiresPayment: this.requiresPayment,
      depositAmount: this.depositAmount,
      paymentStatus: this.paymentStatus,
      notes: this.notes,
      specialRequests: this.specialRequests,
      clientName: this.clientName,
      clientEmail: this.clientEmail,
      clientPhone: this.clientPhone,
      managementToken: this.managementToken,
      tokenExpiresAt: this.tokenExpiresAt,
      cancellationReason: this.cancellationReason,
      userId: this.userId,
      restaurantId: this.restaurantId,
      tableId: this.tableId,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt,
    };
  }
}


