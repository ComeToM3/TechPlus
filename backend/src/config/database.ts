import { PrismaClient } from '@prisma/client';
import { config } from './environment';

// Singleton pattern pour Prisma Client
declare global {
  var __prisma: PrismaClient | undefined;
}

// Créer une instance Prisma Client
const prisma =
  globalThis.__prisma ||
  new PrismaClient({
    log: config.nodeEnv === 'development' ? ['query', 'error', 'warn'] : ['error'],
    datasources: {
      db: {
        url: config.database.url,
      },
    },
  });

// En développement, sauvegarder l'instance globalement pour éviter les reconnexions
if (config.nodeEnv === 'development') {
  globalThis.__prisma = prisma;
}

// Fonction pour tester la connexion à la base de données
export const testDatabaseConnection = async (): Promise<boolean> => {
  try {
    await prisma.$connect();
    console.log('✅ Database connection successful');
    return true;
  } catch (error) {
    console.error('❌ Database connection failed:', error);
    return false;
  }
};

// Fonction pour fermer la connexion proprement
export const disconnectDatabase = async (): Promise<void> => {
  try {
    await prisma.$disconnect();
    console.log('✅ Database disconnected successfully');
  } catch (error) {
    console.error('❌ Error disconnecting from database:', error);
  }
};

// Note: Prisma v5+ ne supporte plus $use middleware
// Le logging des requêtes est géré par l'option log dans la configuration

export default prisma;
