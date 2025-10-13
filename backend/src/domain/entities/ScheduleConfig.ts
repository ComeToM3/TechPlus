interface ScheduleConfigProps {
  id: string;
  restaurantId: string;
  slotDurationMinutes: number;
  bufferTimeMinutes: number;
  maxAdvanceBookingDays: number;
  minAdvanceBookingHours: number;
  allowSameDayBooking: boolean;
  allowWeekendBooking: boolean;
  defaultCapacityPerSlot: number;
  createdAt: Date;
  updatedAt: Date;
}

export class ScheduleConfig {
  private props: ScheduleConfigProps;

  constructor(props: ScheduleConfigProps) {
    this.props = props;
  }

  // Getters
  get id(): string { return this.props.id; }
  get restaurantId(): string { return this.props.restaurantId; }
  get slotDurationMinutes(): number { return this.props.slotDurationMinutes; }
  get bufferTimeMinutes(): number { return this.props.bufferTimeMinutes; }
  get maxAdvanceBookingDays(): number { return this.props.maxAdvanceBookingDays; }
  get minAdvanceBookingHours(): number { return this.props.minAdvanceBookingHours; }
  get allowSameDayBooking(): boolean { return this.props.allowSameDayBooking; }
  get allowWeekendBooking(): boolean { return this.props.allowWeekendBooking; }
  get defaultCapacityPerSlot(): number { return this.props.defaultCapacityPerSlot; }
  get createdAt(): Date { return this.props.createdAt; }
  get updatedAt(): Date { return this.props.updatedAt; }

  // Business logic methods
  canBookOnDate(date: Date): boolean {
    const now = new Date();
    const isWeekend = date.getDay() === 0 || date.getDay() === 6;
    const isSameDay = date.toDateString() === now.toDateString();

    // Vérifier les règles de réservation
    if (!this.allowWeekendBooking && isWeekend) {
      return false;
    }

    if (!this.allowSameDayBooking && isSameDay) {
      return false;
    }

    // Vérifier le délai minimum
    const minDateTime = new Date(now.getTime() + this.minAdvanceBookingHours * 60 * 60 * 1000);
    if (date < minDateTime) {
      return false;
    }

    // Vérifier le délai maximum
    const maxDateTime = new Date(now.getTime() + this.maxAdvanceBookingDays * 24 * 60 * 60 * 1000);
    if (date > maxDateTime) {
      return false;
    }

    return true;
  }

  getSlotDurationInMinutes(): number {
    return this.slotDurationMinutes;
  }

  getBufferTimeInMinutes(): number {
    return this.bufferTimeMinutes;
  }

  getMaxAdvanceBookingDays(): number {
    return this.maxAdvanceBookingDays;
  }

  getMinAdvanceBookingHours(): number {
    return this.minAdvanceBookingHours;
  }

  allowsSameDayBooking(): boolean {
    return this.allowSameDayBooking;
  }

  allowsWeekendBooking(): boolean {
    return this.allowWeekendBooking;
  }

  getDefaultCapacityPerSlot(): number {
    return this.defaultCapacityPerSlot;
  }
}
