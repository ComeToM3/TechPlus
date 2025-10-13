interface AvailabilitySlotProps {
  time: string;
  available: boolean;
  availableTables: number;
  tables: any[];
}

export class AvailabilitySlot {
  private props: AvailabilitySlotProps;

  constructor(props: AvailabilitySlotProps) {
    this.props = props;
  }

  // Getters
  get time(): string { return this.props.time; }
  get available(): boolean { return this.props.available; }
  get availableTables(): number { return this.props.availableTables; }
  get tables(): any[] { return this.props.tables; }

  // Business logic methods
  isFullyBooked(): boolean {
    return this.props.availableTables === 0;
  }

  hasLimitedAvailability(): boolean {
    return this.props.availableTables > 0 && this.props.availableTables < 3;
  }

  hasGoodAvailability(): boolean {
    return this.props.availableTables >= 3;
  }

  canAccommodate(partySize: number): boolean {
    return this.props.tables.some(table => table.capacity >= partySize);
  }

  getBestTableForParty(partySize: number): any | null {
    return this.props.tables
      .filter(table => table.capacity >= partySize)
      .sort((a, b) => a.capacity - b.capacity)[0] || null;
  }

  toJSON() {
    return {
      time: this.time,
      available: this.available,
      availableTables: this.availableTables,
      tables: this.tables,
    };
  }
}

