import { PrismaClient } from '@prisma/client';
import { createClient } from 'redis';

// Configuration globale des tests
const prisma = new PrismaClient();
const redis = createClient({
  url: process.env.REDIS_URL || 'redis://localhost:6379/1',
});

// Setup global avant tous les tests
beforeAll(async () => {
  // Connexion à la base de données de test
  await prisma.$connect();

  // Connexion à Redis de test
  await redis.connect();

  // Nettoyage initial
  await cleanup();
});

// Cleanup après chaque test
afterEach(async () => {
  await cleanup();
});

// Cleanup global après tous les tests
afterAll(async () => {
  await cleanup();
  await prisma.$disconnect();
  await redis.disconnect();
});

// Fonction de nettoyage
async function cleanup() {
  // Nettoyer la base de données
  await prisma.reservation.deleteMany();
  await prisma.user.deleteMany();
  await prisma.restaurant.deleteMany();
  await prisma.table.deleteMany();
  await prisma.menuItem.deleteMany();
  await prisma.analytics.deleteMany();

  // Nettoyer Redis
  await redis.flushDb();
}

// Exporter les instances pour les tests
export { prisma, redis };
