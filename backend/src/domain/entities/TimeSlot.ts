interface TimeSlotProps {
  id: string;
  time: string;
  isAvailable: boolean;
  dayOfWeek: string;
  scheduleConfigId: string;
  createdAt: Date;
  updatedAt: Date;
}

export class TimeSlot {
  private props: TimeSlotProps;

  constructor(props: TimeSlotProps) {
    this.props = props;
  }

  // Getters
  get id(): string { return this.props.id; }
  get time(): string { return this.props.time; }
  get isAvailable(): boolean { return this.props.isAvailable; }
  get dayOfWeek(): string { return this.props.dayOfWeek; }
  get scheduleConfigId(): string { return this.props.scheduleConfigId; }
  get createdAt(): Date { return this.props.createdAt; }
  get updatedAt(): Date { return this.props.updatedAt; }

  // Business logic methods
  isActive(): boolean {
    return this.props.isAvailable;
  }

  isWeekend(): boolean {
    return this.props.dayOfWeek === 'saturday' || this.props.dayOfWeek === 'sunday';
  }

  isWeekday(): boolean {
    return !this.isWeekend();
  }

  getTimeInMinutes(): number {
    const [hours, minutes] = this.props.time.split(':').map(Number);
    return (hours || 0) * 60 + (minutes || 0);
  }

  isMorning(): boolean {
    const minutes = this.getTimeInMinutes();
    return minutes >= 6 * 60 && minutes < 12 * 60; // 06:00 - 12:00
  }

  isAfternoon(): boolean {
    const minutes = this.getTimeInMinutes();
    return minutes >= 12 * 60 && minutes < 18 * 60; // 12:00 - 18:00
  }

  isEvening(): boolean {
    const minutes = this.getTimeInMinutes();
    return minutes >= 18 * 60 && minutes < 24 * 60; // 18:00 - 24:00
  }

  // Factory method to create TimeSlot from Prisma model
  static fromPrisma(prismaTimeSlot: any): TimeSlot {
    return new TimeSlot({
      id: prismaTimeSlot.id,
      time: prismaTimeSlot.time,
      isAvailable: prismaTimeSlot.isAvailable,
      dayOfWeek: prismaTimeSlot.dayOfWeek,
      scheduleConfigId: prismaTimeSlot.scheduleConfigId,
      createdAt: prismaTimeSlot.createdAt,
      updatedAt: prismaTimeSlot.updatedAt,
    });
  }

  toJSON() {
    return {
      id: this.id,
      time: this.time,
      isAvailable: this.isAvailable,
      dayOfWeek: this.dayOfWeek,
      scheduleConfigId: this.scheduleConfigId,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt,
    };
  }
}
