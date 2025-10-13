/**
 * Setup intelligent pour tous les tests
 * S'adapte automatiquement selon le type de test
 */

// Détecter le type de test
const isMigrationTest = process.env.npm_lifecycle_event?.includes('migration') || 
                       process.argv.some(arg => arg.includes('migration'));

const isIntegrationTest = process.env.npm_lifecycle_event?.includes('integration') || 
                         process.argv.some(arg => arg.includes('integration'));

// Setup pour tests de migration (simple)
if (isMigrationTest) {
  beforeAll(() => {
    console.log('🧪 Setup des tests de migration Clean Architecture');
  });

  afterAll(() => {
    console.log('✅ Tests de migration terminés');
  });
}

// Setup pour tests d'intégration (avec base de données)
if (isIntegrationTest) {
  const { PrismaClient } = require('@prisma/client');
  const { createClient } = require('redis');

  // Configuration globale des tests d'intégration
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
  module.exports = { prisma, redis };
}

// Setup par défaut pour tests unitaires
if (!isMigrationTest && !isIntegrationTest) {
  beforeAll(() => {
    console.log('🧪 Setup des tests unitaires');
  });

  afterAll(() => {
    console.log('✅ Tests unitaires terminés');
  });
}