import { Restaurant } from '../entities/Restaurant';

export interface RestaurantRepository {
  findById(id: string): Promise<Restaurant | null>;
  findActiveRestaurant(): Promise<Restaurant | null>;
  findAll(): Promise<Restaurant[]>;
}


