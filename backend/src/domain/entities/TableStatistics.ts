interface TableStatisticsProps {
  overview: {
    totalTables: number;
    activeTables: number;
    inactiveTables: number;
    totalCapacity: number;
    averageCapacity: number;
  };
  reservations: {
    todayReservations: number;
    upcomingReservations: number;
    totalReservations: number;
  };
  capacityDistribution: Array<{
    capacity: number;
    count: number;
  }>;
  lastUpdated: string;
}

export class TableStatistics {
  private props: TableStatisticsProps;

  constructor(props: TableStatisticsProps) {
    this.props = props;
  }

  // Getters
  get overview() { return this.props.overview; }
  get reservations() { return this.props.reservations; }
  get capacityDistribution() { return this.props.capacityDistribution; }
  get lastUpdated() { return this.props.lastUpdated; }

  // Business logic methods
  getTotalTables(): number {
    return this.props.overview.totalTables;
  }

  getActiveTables(): number {
    return this.props.overview.activeTables;
  }

  getInactiveTables(): number {
    return this.props.overview.inactiveTables;
  }

  getTotalCapacity(): number {
    return this.props.overview.totalCapacity;
  }

  getAverageCapacity(): number {
    return this.props.overview.averageCapacity;
  }

  getTodayReservations(): number {
    return this.props.reservations.todayReservations;
  }

  getUpcomingReservations(): number {
    return this.props.reservations.upcomingReservations;
  }

  getTotalReservations(): number {
    return this.props.reservations.totalReservations;
  }

  getCapacityDistribution(): Array<{ capacity: number; count: number }> {
    return this.props.capacityDistribution;
  }

  getLastUpdated(): string {
    return this.props.lastUpdated;
  }

  // Calculated properties
  getOccupancyRate(): number {
    if (this.props.overview.totalCapacity === 0) return 0;
    return Math.round((this.props.reservations.totalReservations / this.props.overview.totalCapacity) * 100);
  }

  getActiveTablePercentage(): number {
    if (this.props.overview.totalTables === 0) return 0;
    return Math.round((this.props.overview.activeTables / this.props.overview.totalTables) * 100);
  }
}
