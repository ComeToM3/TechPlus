interface ScheduleTimeSlotProps {
  id: string;
  dayScheduleId: string;
  time: string;
  isAvailable: boolean;
  capacity: number;
  isRecommended: boolean;
  createdAt: Date;
  updatedAt: Date;
}

export class ScheduleTimeSlot {
  private props: ScheduleTimeSlotProps;

  constructor(props: ScheduleTimeSlotProps) {
    this.props = props;
  }

  // Getters
  get id(): string { return this.props.id; }
  get dayScheduleId(): string { return this.props.dayScheduleId; }
  get time(): string { return this.props.time; }
  get isAvailable(): boolean { return this.props.isAvailable; }
  get capacity(): number { return this.props.capacity; }
  get isRecommended(): boolean { return this.props.isRecommended; }
  get createdAt(): Date { return this.props.createdAt; }
  get updatedAt(): Date { return this.props.updatedAt; }

  // Business logic methods
  isAvailableForParty(partySize: number): boolean {
    return this.isAvailable && this.capacity >= partySize;
  }

  getTime(): string {
    return this.time;
  }

  getCapacity(): number {
    return this.capacity;
  }

  isRecommendedSlot(): boolean {
    return this.isRecommended;
  }

  canAccommodate(partySize: number): boolean {
    return this.capacity >= partySize;
  }

  getTimeInMinutes(): number {
    const [hours, minutes] = this.time.split(':').map(Number);
    return (hours || 0) * 60 + (minutes || 0);
  }
}
