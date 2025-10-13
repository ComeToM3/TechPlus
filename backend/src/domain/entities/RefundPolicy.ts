interface RefundPolicyProps {
  id: string;
  name: string;
  description: string;
  rules: Array<{
    hoursBeforeReservation: number;
    refundPercentage: number;
    reason: string;
  }>;
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
}

export class RefundPolicy {
  private props: RefundPolicyProps;

  constructor(props: RefundPolicyProps) {
    this.props = props;
  }

  // Getters
  get id(): string { return this.props.id; }
  get name(): string { return this.props.name; }
  get description(): string { return this.props.description; }
  get rules(): Array<{ hoursBeforeReservation: number; refundPercentage: number; reason: string }> { 
    return this.props.rules; 
  }
  get isActive(): boolean { return this.props.isActive; }
  get createdAt(): Date { return this.props.createdAt; }
  get updatedAt(): Date { return this.props.updatedAt; }

  // Business logic methods
  calculateRefundAmount(reservationDate: Date, depositAmount: number, cancellationReason?: string): {
    amount: number;
    reason: string;
  } {
    const now = new Date();
    const hoursUntilReservation = (reservationDate.getTime() - now.getTime()) / (1000 * 60 * 60);

    // Trouver la règle applicable
    const applicableRule = this.props.rules
      .sort((a, b) => b.hoursBeforeReservation - a.hoursBeforeReservation)
      .find(rule => hoursUntilReservation >= rule.hoursBeforeReservation);

    if (!applicableRule) {
      return {
        amount: 0,
        reason: 'No refund applicable - too close to reservation time',
      };
    }

    const refundAmount = Math.round(depositAmount * (applicableRule.refundPercentage / 100));

    return {
      amount: refundAmount,
      reason: applicableRule.reason,
    };
  }

  isRefundEligible(reservationDate: Date): boolean {
    const now = new Date();
    const hoursUntilReservation = (reservationDate.getTime() - now.getTime()) / (1000 * 60 * 60);

    return this.props.rules.some(rule => hoursUntilReservation >= rule.hoursBeforeReservation);
  }

  getApplicableRule(reservationDate: Date): { hoursBeforeReservation: number; refundPercentage: number; reason: string } | null {
    const now = new Date();
    const hoursUntilReservation = (reservationDate.getTime() - now.getTime()) / (1000 * 60 * 60);

    return this.props.rules
      .sort((a, b) => b.hoursBeforeReservation - a.hoursBeforeReservation)
      .find(rule => hoursUntilReservation >= rule.hoursBeforeReservation) || null;
  }

  // Factory method to create default refund policy
  static createDefault(): RefundPolicy {
    return new RefundPolicy({
      id: 'default-policy',
      name: 'Standard Refund Policy',
      description: 'Standard refund policy for restaurant reservations',
      rules: [
        {
          hoursBeforeReservation: 24,
          refundPercentage: 100,
          reason: 'Full refund - more than 24 hours before reservation',
        },
        {
          hoursBeforeReservation: 12,
          refundPercentage: 50,
          reason: '50% refund - between 12-24 hours before reservation',
        },
        {
          hoursBeforeReservation: 2,
          refundPercentage: 0,
          reason: 'No refund - less than 2 hours before reservation',
        },
      ],
      isActive: true,
      createdAt: new Date(),
      updatedAt: new Date(),
    });
  }
}
