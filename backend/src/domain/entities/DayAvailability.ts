import { AvailabilitySlot } from './AvailabilitySlot';

interface DayAvailabilityProps {
  date: string;
  partySize: number;
  slots: AvailabilitySlot[];
  restaurantId: string | undefined;
  openingHours?: any;
}

export class DayAvailability {
  private props: DayAvailabilityProps;

  constructor(props: DayAvailabilityProps) {
    this.props = props;
  }

  // Getters
  get date(): string { return this.props.date; }
  get partySize(): number { return this.props.partySize; }
  get slots(): AvailabilitySlot[] { return this.props.slots; }
  get restaurantId(): string | undefined { return this.props.restaurantId; }
  get openingHours(): any | undefined { return this.props.openingHours; }

  // Business logic methods
  getAvailableSlots(): AvailabilitySlot[] {
    return this.props.slots.filter(slot => slot.available);
  }

  getAvailableTimes(): string[] {
    return this.getAvailableSlots().map(slot => slot.time);
  }

  getTotalAvailableSlots(): number {
    return this.getAvailableSlots().length;
  }

  getTotalSlots(): number {
    return this.props.slots.length;
  }

  getAvailabilityPercentage(): number {
    if (this.props.slots.length === 0) return 0;
    return Math.round((this.getTotalAvailableSlots() / this.props.slots.length) * 100);
  }

  hasAvailability(): boolean {
    return this.getTotalAvailableSlots() > 0;
  }

  isFullyBooked(): boolean {
    return this.getTotalAvailableSlots() === 0;
  }

  getSlotsByAvailability(): { available: AvailabilitySlot[]; unavailable: AvailabilitySlot[] } {
    return {
      available: this.getAvailableSlots(),
      unavailable: this.props.slots.filter(slot => !slot.available),
    };
  }

  getBestSlots(limit: number = 5): AvailabilitySlot[] {
    return this.getAvailableSlots()
      .sort((a, b) => b.availableTables - a.availableTables)
      .slice(0, limit);
  }

  toJSON() {
    return {
      date: this.date,
      partySize: this.partySize,
      slots: this.slots.map(slot => slot.toJSON()),
      restaurantId: this.restaurantId,
      openingHours: this.openingHours,
      totalSlots: this.getTotalSlots(),
      availableSlots: this.getTotalAvailableSlots(),
      availabilityPercentage: this.getAvailabilityPercentage(),
    };
  }
}
