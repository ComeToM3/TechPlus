/**
 * Implémentation Prisma du UserRepository
 * Cette classe implémente l'interface UserRepository en utilisant Prisma
 */

import { PrismaClient } from '@prisma/client';
import { UserRepository, CreateUserData, UpdateUserData } from '../../domain/repositories/UserRepository';
import { User } from '../../domain/entities/User';

export class PrismaUserRepository implements UserRepository {
  constructor(private readonly prisma: PrismaClient) {}

  async findByEmail(email: string): Promise<User | null> {
    const user = await this.prisma.user.findUnique({
      where: { email },
      select: {
        id: true,
        email: true,
        name: true,
        phone: true,
        avatar: true,
        role: true,
        isActive: true,
        lastLoginAt: true,
        createdAt: true,
        updatedAt: true
      }
    });

    return user ? User.fromPrisma(user) : null;
  }

  async findById(id: string): Promise<User | null> {
    const user = await this.prisma.user.findUnique({
      where: { id },
      select: {
        id: true,
        email: true,
        name: true,
        phone: true,
        avatar: true,
        role: true,
        isActive: true,
        lastLoginAt: true,
        createdAt: true,
        updatedAt: true
      }
    });

    return user ? User.fromPrisma(user) : null;
  }

  async create(userData: CreateUserData): Promise<User> {
    const user = await this.prisma.user.create({
      data: {
        email: userData.email,
        password: userData.password || null,
        name: userData.name || null,
        phone: userData.phone || null,
        avatar: userData.avatar || null,
        role: (userData.role as any) || 'CLIENT',
        isActive: userData.isActive ?? true
      },
      select: {
        id: true,
        email: true,
        name: true,
        phone: true,
        avatar: true,
        role: true,
        isActive: true,
        lastLoginAt: true,
        createdAt: true,
        updatedAt: true
      }
    });

    return User.fromPrisma(user);
  }

  async update(id: string, userData: UpdateUserData): Promise<User> {
    const user = await this.prisma.user.update({
      where: { id },
      data: {
        ...(userData.name !== undefined && { name: userData.name }),
        ...(userData.phone !== undefined && { phone: userData.phone }),
        ...(userData.avatar !== undefined && { avatar: userData.avatar }),
        ...(userData.password !== undefined && { password: userData.password }),
        ...(userData.isActive !== undefined && { isActive: userData.isActive }),
        ...(userData.lastLoginAt !== undefined && { lastLoginAt: userData.lastLoginAt })
      },
      select: {
        id: true,
        email: true,
        name: true,
        phone: true,
        avatar: true,
        role: true,
        isActive: true,
        lastLoginAt: true,
        createdAt: true,
        updatedAt: true
      }
    });

    return User.fromPrisma(user);
  }

  async delete(id: string): Promise<void> {
    await this.prisma.user.delete({
      where: { id }
    });
  }

  async existsByEmail(email: string): Promise<boolean> {
    const count = await this.prisma.user.count({
      where: { email }
    });
    return count > 0;
  }

  async findByEmailWithPassword(email: string): Promise<{ user: User; password: string } | null> {
    const user = await this.prisma.user.findUnique({
      where: { email },
      select: {
        id: true,
        email: true,
        password: true,
        name: true,
        phone: true,
        avatar: true,
        role: true,
        isActive: true,
        lastLoginAt: true,
        createdAt: true,
        updatedAt: true
      }
    });

    if (!user || !user.password) {
      return null;
    }

    return {
      user: User.fromPrisma(user),
      password: user.password
    };
  }

  async updateLastLogin(id: string): Promise<void> {
    await this.prisma.user.update({
      where: { id },
      data: { lastLoginAt: new Date() }
    });
  }
}
