interface TableProps {
  id: string;
  number: string;
  capacity: number;
  position?: string | undefined;
  isActive: boolean;
  restaurantId: string;
  createdAt: Date;
  updatedAt: Date;
}

export class Table {
  private props: TableProps;

  constructor(props: TableProps) {
    this.props = props;
  }

  // Getters
  get id(): string { return this.props.id; }
  get number(): string { return this.props.number; }
  get capacity(): number { return this.props.capacity; }
  get position(): string | undefined { return this.props.position; }
  get isActive(): boolean { return this.props.isActive; }
  get restaurantId(): string { return this.props.restaurantId; }
  get createdAt(): Date { return this.props.createdAt; }
  get updatedAt(): Date { return this.props.updatedAt; }

  // Business logic methods
  canAccommodate(partySize: number): boolean {
    return this.props.capacity >= partySize && this.props.isActive;
  }

  isAvailable(): boolean {
    return this.props.isActive;
  }

  // Factory method to create Table from Prisma model
  static fromPrisma(prismaTable: any): Table {
    return new Table({
      id: prismaTable.id,
      number: prismaTable.number,
      capacity: prismaTable.capacity,
      position: prismaTable.position,
      isActive: prismaTable.isActive,
      restaurantId: prismaTable.restaurantId,
      createdAt: prismaTable.createdAt,
      updatedAt: prismaTable.updatedAt,
    });
  }

  toJSON() {
    return {
      id: this.id,
      number: this.number,
      capacity: this.capacity,
      position: this.position,
      isActive: this.isActive,
      restaurantId: this.restaurantId,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt,
    };
  }
}


