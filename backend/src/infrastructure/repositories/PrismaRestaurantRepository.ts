import { PrismaClient } from '@prisma/client';
import { RestaurantRepository } from '@/domain/repositories/RestaurantRepository';
import { Restaurant } from '@/domain/entities/Restaurant';

export class PrismaRestaurantRepository implements RestaurantRepository {
  private prisma: PrismaClient;

  constructor(prisma: PrismaClient) {
    this.prisma = prisma;
  }

  async findById(id: string): Promise<Restaurant | null> {
    const restaurant = await this.prisma.restaurant.findUnique({
      where: { id },
    });
    return restaurant ? Restaurant.fromPrisma(restaurant) : null;
  }

  async findActiveRestaurant(): Promise<Restaurant | null> {
    const restaurant = await this.prisma.restaurant.findFirst({
      where: { isActive: true },
    });
    return restaurant ? Restaurant.fromPrisma(restaurant) : null;
  }

  async findAll(): Promise<Restaurant[]> {
    const restaurants = await this.prisma.restaurant.findMany({
      orderBy: { name: 'asc' },
    });
    return restaurants.map(r => Restaurant.fromPrisma(r));
  }
}


