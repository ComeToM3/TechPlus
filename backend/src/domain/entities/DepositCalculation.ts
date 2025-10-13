interface DepositCalculationProps {
  depositAmount: number;
  isRequired: boolean;
  partySize: number;
  averagePricePerPerson: number;
  calculatedAt: Date;
}

export class DepositCalculation {
  private props: DepositCalculationProps;

  constructor(props: DepositCalculationProps) {
    this.props = props;
  }

  // Getters
  get depositAmount(): number { return this.props.depositAmount; }
  get isRequired(): boolean { return this.props.isRequired; }
  get partySize(): number { return this.props.partySize; }
  get averagePricePerPerson(): number { return this.props.averagePricePerPerson; }
  get calculatedAt(): Date { return this.props.calculatedAt; }

  // Business logic methods
  getTotalReservationValue(): number {
    return this.props.partySize * this.props.averagePricePerPerson;
  }

  getDepositPercentage(): number {
    if (this.props.depositAmount === 0) return 0;
    return Math.round((this.props.depositAmount / this.getTotalReservationValue()) * 100);
  }

  getRemainingAmount(): number {
    return this.getTotalReservationValue() - this.props.depositAmount;
  }

  isDepositRequired(): boolean {
    return this.props.isRequired && this.props.depositAmount > 0;
  }

  // Factory method to create DepositCalculation
  static calculate(partySize: number, averagePricePerPerson: number): DepositCalculation {
    const isRequired = partySize >= 6; // Exemple : acompte requis pour 6+ personnes
    const depositAmount = isRequired ? Math.round(partySize * averagePricePerPerson * 0.3) : 0; // 30% de l'acompte

    return new DepositCalculation({
      depositAmount,
      isRequired,
      partySize,
      averagePricePerPerson,
      calculatedAt: new Date(),
    });
  }

  toJSON() {
    return {
      depositAmount: this.depositAmount,
      isRequired: this.isRequired,
      partySize: this.partySize,
      averagePricePerPerson: this.averagePricePerPerson,
      totalReservationValue: this.getTotalReservationValue(),
      depositPercentage: this.getDepositPercentage(),
      remainingAmount: this.getRemainingAmount(),
      calculatedAt: this.calculatedAt,
    };
  }
}
