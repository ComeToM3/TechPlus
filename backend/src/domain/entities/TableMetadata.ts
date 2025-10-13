interface TableMetadataProps {
  id: string;
  number: string;
  capacity: number;
  isActive: boolean;
  position?: string | undefined;
  createdAt: Date;
  updatedAt: Date;
}

export class TableMetadata {
  private props: TableMetadataProps;

  constructor(props: TableMetadataProps) {
    this.props = props;
  }

  // Getters
  get id(): string { return this.props.id; }
  get number(): string { return this.props.number; }
  get capacity(): number { return this.props.capacity; }
  get isActive(): boolean { return this.props.isActive; }
  get position(): string | undefined { return this.props.position; }
  get createdAt(): Date { return this.props.createdAt; }
  get updatedAt(): Date { return this.props.updatedAt; }

  // Business logic methods
  isAvailable(): boolean {
    return this.props.isActive;
  }

  canAccommodate(partySize: number): boolean {
    return this.props.capacity >= partySize && this.props.isActive;
  }

  getCapacity(): number {
    return this.props.capacity;
  }

  getNumber(): string {
    return this.props.number;
  }

  getPosition(): string | undefined {
    return this.props.position;
  }

  // Factory method to create TableMetadata from Prisma model
  static fromPrisma(prismaTable: any): TableMetadata {
    return new TableMetadata({
      id: prismaTable.id,
      number: prismaTable.number,
      capacity: prismaTable.capacity,
      isActive: prismaTable.isActive,
      position: prismaTable.position,
      createdAt: prismaTable.createdAt,
      updatedAt: prismaTable.updatedAt,
    });
  }

  toJSON() {
    return {
      id: this.id,
      number: this.number,
      capacity: this.capacity,
      isActive: this.isActive,
      position: this.position,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt,
    };
  }
}
