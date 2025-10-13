interface RestaurantProps {
  id: string;
  name: string;
  address?: string;
  phone?: string;
  email?: string;
  isActive: boolean;
  paymentThreshold: number;
  minimumDepositAmount: number;
  createdAt: Date;
  updatedAt: Date;
}

export class Restaurant {
  private props: RestaurantProps;

  constructor(props: RestaurantProps) {
    this.props = props;
  }

  // Getters
  get id(): string { return this.props.id; }
  get name(): string { return this.props.name; }
  get address(): string | undefined { return this.props.address; }
  get phone(): string | undefined { return this.props.phone; }
  get email(): string | undefined { return this.props.email; }
  get isActive(): boolean { return this.props.isActive; }
  get paymentThreshold(): number { return this.props.paymentThreshold; }
  get minimumDepositAmount(): number { return this.props.minimumDepositAmount; }
  get createdAt(): Date { return this.props.createdAt; }
  get updatedAt(): Date { return this.props.updatedAt; }

  // Business logic methods
  requiresPayment(partySize: number): boolean {
    return partySize >= this.props.paymentThreshold;
  }

  calculateDepositAmount(partySize: number): number {
    return this.requiresPayment(partySize) ? this.props.minimumDepositAmount : 0;
  }

  isOperational(): boolean {
    return this.props.isActive;
  }

  // Factory method to create Restaurant from Prisma model
  static fromPrisma(prismaRestaurant: any): Restaurant {
    return new Restaurant({
      id: prismaRestaurant.id,
      name: prismaRestaurant.name,
      address: prismaRestaurant.address,
      phone: prismaRestaurant.phone,
      email: prismaRestaurant.email,
      isActive: prismaRestaurant.isActive,
      paymentThreshold: prismaRestaurant.paymentThreshold,
      minimumDepositAmount: prismaRestaurant.minimumDepositAmount,
      createdAt: prismaRestaurant.createdAt,
      updatedAt: prismaRestaurant.updatedAt,
    });
  }

  toJSON() {
    return {
      id: this.id,
      name: this.name,
      address: this.address,
      phone: this.phone,
      email: this.email,
      isActive: this.isActive,
      paymentThreshold: this.paymentThreshold,
      minimumDepositAmount: this.minimumDepositAmount,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt,
    };
  }
}


