interface PaymentIntentProps {
  id: string;
  amount: number;
  currency: string;
  status: string;
  clientSecret: string;
  reservationId: string;
  userId: string;
  metadata?: Record<string, any> | undefined;
  createdAt: Date;
  updatedAt: Date;
}

export class PaymentIntent {
  private props: PaymentIntentProps;

  constructor(props: PaymentIntentProps) {
    this.props = props;
  }

  // Getters
  get id(): string { return this.props.id; }
  get amount(): number { return this.props.amount; }
  get currency(): string { return this.props.currency; }
  get status(): string { return this.props.status; }
  get clientSecret(): string { return this.props.clientSecret; }
  get reservationId(): string { return this.props.reservationId; }
  get userId(): string { return this.props.userId; }
  get metadata(): Record<string, any> | undefined { return this.props.metadata; }
  get createdAt(): Date { return this.props.createdAt; }
  get updatedAt(): Date { return this.props.updatedAt; }

  // Business logic methods
  isCompleted(): boolean {
    return this.props.status === 'succeeded';
  }

  isPending(): boolean {
    return this.props.status === 'requires_payment_method' || this.props.status === 'requires_confirmation';
  }

  isFailed(): boolean {
    return this.props.status === 'canceled' || this.props.status === 'payment_failed';
  }

  getAmountInEuros(): number {
    return this.props.amount / 100; // Stripe utilise les centimes
  }

  getAmountInCents(): number {
    return this.props.amount;
  }

  canBeRefunded(): boolean {
    return this.isCompleted();
  }

  // Factory method to create PaymentIntent from Stripe data
  static fromStripe(stripePaymentIntent: any, reservationId: string, userId: string): PaymentIntent {
    return new PaymentIntent({
      id: stripePaymentIntent.id,
      amount: stripePaymentIntent.amount,
      currency: stripePaymentIntent.currency,
      status: stripePaymentIntent.status,
      clientSecret: stripePaymentIntent.client_secret,
      reservationId,
      userId,
      metadata: stripePaymentIntent.metadata,
      createdAt: new Date(stripePaymentIntent.created * 1000),
      updatedAt: new Date(),
    });
  }

  toJSON() {
    return {
      id: this.id,
      amount: this.amount,
      currency: this.currency,
      status: this.status,
      clientSecret: this.clientSecret,
      reservationId: this.reservationId,
      userId: this.userId,
      metadata: this.metadata,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt,
    };
  }
}
