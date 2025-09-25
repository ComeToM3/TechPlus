export interface CreateReservationData {
  date: string;
  time: string;
  partySize: number;
  clientName?: string;
  clientEmail?: string;
  clientPhone?: string;
  notes?: string;
  specialRequests?: string;
  userId?: string;
  restaurantId: string;
}

export interface UpdateReservationData {
  date?: string;
  time?: string;
  partySize?: number;
  clientName?: string;
  clientEmail?: string;
  clientPhone?: string;
  notes?: string;
  specialRequests?: string;
  status?: string;
}

export interface ReservationFilters {
  date?: string;
  status?: string;
  tableId?: string;
  userId?: string;
  restaurantId?: string;
  page?: number;
  limit?: number;
}
