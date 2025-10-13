interface RefundProps {
  id: string;
  amount: number;
  currency: string;
  status: string;
  reason: string;
  reservationId: string;
  paymentIntentId: string;
  metadata?: Record<string, any> | undefined;
  createdAt: Date;
  updatedAt: Date;
}

export class Refund {
  private props: RefundProps;

  constructor(props: RefundProps) {
    this.props = props;
  }

  // Getters
  get id(): string { return this.props.id; }
  get amount(): number { return this.props.amount; }
  get currency(): string { return this.props.currency; }
  get status(): string { return this.props.status; }
  get reason(): string { return this.props.reason; }
  get reservationId(): string { return this.props.reservationId; }
  get paymentIntentId(): string { return this.props.paymentIntentId; }
  get metadata(): Record<string, any> | undefined { return this.props.metadata; }
  get createdAt(): Date { return this.props.createdAt; }
  get updatedAt(): Date { return this.props.updatedAt; }

  // Business logic methods
  isCompleted(): boolean {
    return this.props.status === 'succeeded';
  }

  isPending(): boolean {
    return this.props.status === 'pending';
  }

  isFailed(): boolean {
    return this.props.status === 'failed' || this.props.status === 'canceled';
  }

  getAmountInEuros(): number {
    return this.props.amount / 100; // Stripe utilise les centimes
  }

  getAmountInCents(): number {
    return this.props.amount;
  }

  // Factory method to create Refund from Stripe data
  static fromStripe(stripeRefund: any, reservationId: string, paymentIntentId: string): Refund {
    return new Refund({
      id: stripeRefund.id,
      amount: stripeRefund.amount,
      currency: stripeRefund.currency,
      status: stripeRefund.status,
      reason: stripeRefund.reason || 'requested_by_customer',
      reservationId,
      paymentIntentId,
      metadata: stripeRefund.metadata,
      createdAt: new Date(stripeRefund.created * 1000),
      updatedAt: new Date(),
    });
  }

  toJSON() {
    return {
      id: this.id,
      amount: this.amount,
      currency: this.currency,
      status: this.status,
      reason: this.reason,
      reservationId: this.reservationId,
      paymentIntentId: this.paymentIntentId,
      metadata: this.metadata,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt,
    };
  }
}
