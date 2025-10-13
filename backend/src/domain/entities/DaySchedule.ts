interface DayScheduleProps {
  id: string;
  scheduleConfigId: string;
  dayOfWeek: string;
  isOpen: boolean;
  openingTime: string | null;
  closingTime: string | null;
  notes: string | null;
  createdAt: Date;
  updatedAt: Date;
}

export class DaySchedule {
  private props: DayScheduleProps;

  constructor(props: DayScheduleProps) {
    this.props = props;
  }

  // Getters
  get id(): string { return this.props.id; }
  get scheduleConfigId(): string { return this.props.scheduleConfigId; }
  get dayOfWeek(): string { return this.props.dayOfWeek; }
  get isOpen(): boolean { return this.props.isOpen; }
  get openingTime(): string | null { return this.props.openingTime; }
  get closingTime(): string | null { return this.props.closingTime; }
  get notes(): string | null { return this.props.notes; }
  get createdAt(): Date { return this.props.createdAt; }
  get updatedAt(): Date { return this.props.updatedAt; }

  // Business logic methods
  isOpenOnDay(): boolean {
    return this.isOpen;
  }

  getOpeningTime(): string | null {
    return this.openingTime;
  }

  getClosingTime(): string | null {
    return this.closingTime;
  }

  getNotes(): string | null {
    return this.notes;
  }

  isTimeWithinHours(time: string): boolean {
    if (!this.isOpen || !this.openingTime || !this.closingTime) {
      return false;
    }

    return time >= this.openingTime && time < this.closingTime;
  }

  getDayOfWeek(): string {
    return this.dayOfWeek;
  }
}
