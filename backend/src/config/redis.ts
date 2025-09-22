import { RedisClientType, createClient } from 'redis';
import { config } from './environment';

// Singleton pattern pour Redis Client
declare global {
  var __redis: RedisClientType | undefined;
}

// Créer une instance Redis Client
const redis =
  globalThis.__redis ||
  createClient({
    url: config.redis.url,
    socket: {
      connectTimeout: 5000,
      reconnectStrategy: retries => {
        if (retries > 10) {
          console.error('❌ Redis: Too many reconnection attempts, giving up');
          return new Error('Too many reconnection attempts');
        }
        return Math.min(retries * 100, 3000);
      },
    },
  });

// En développement, sauvegarder l'instance globalement pour éviter les reconnexions
if (config.nodeEnv === 'development') {
  globalThis.__redis = redis;
}

// Gestion des erreurs Redis
redis.on('error', err => {
  console.error('❌ Redis Client Error:', err);
});

redis.on('connect', () => {
  console.log('✅ Redis Client Connected');
});

redis.on('ready', () => {
  console.log('✅ Redis Client Ready');
});

redis.on('end', () => {
  console.log('🔌 Redis Client Disconnected');
});

// Fonction pour tester la connexion Redis
export const testRedisConnection = async (): Promise<boolean> => {
  try {
    if (!redis.isOpen) {
      await redis.connect();
    }
    await redis.ping();
    console.log('✅ Redis connection successful');
    return true;
  } catch (error) {
    console.warn(
      '⚠️  Redis connection failed (continuing without cache):',
      error instanceof Error ? error.message : error
    );
    return false;
  }
};

// Fonction pour fermer la connexion Redis proprement
export const disconnectRedis = async (): Promise<void> => {
  try {
    if (redis.isOpen) {
      await redis.quit();
    }
    console.log('✅ Redis disconnected successfully');
  } catch (error) {
    console.error('❌ Error disconnecting from Redis:', error);
  }
};

// Fonctions utilitaires pour le cache
export const cacheUtils = {
  // Mettre en cache avec expiration
  set: async (key: string, value: any, ttlSeconds?: number): Promise<void> => {
    try {
      const serializedValue = JSON.stringify(value);
      if (ttlSeconds) {
        await redis.setEx(key, ttlSeconds, serializedValue);
      } else {
        await redis.set(key, serializedValue);
      }
    } catch (error) {
      console.error('❌ Error setting cache:', error);
    }
  },

  // Récupérer du cache
  get: async <T>(key: string): Promise<T | null> => {
    try {
      const value = await redis.get(key);
      return value ? JSON.parse(value) : null;
    } catch (error) {
      console.error('❌ Error getting cache:', error);
      return null;
    }
  },

  // Supprimer du cache
  del: async (key: string): Promise<void> => {
    try {
      await redis.del(key);
    } catch (error) {
      console.error('❌ Error deleting cache:', error);
    }
  },

  // Supprimer plusieurs clés
  delPattern: async (pattern: string): Promise<void> => {
    try {
      const keys = await redis.keys(pattern);
      if (keys.length > 0) {
        await redis.del(keys);
      }
    } catch (error) {
      console.error('❌ Error deleting cache pattern:', error);
    }
  },

  // Vérifier si une clé existe
  exists: async (key: string): Promise<boolean> => {
    try {
      const result = await redis.exists(key);
      return result === 1;
    } catch (error) {
      console.error('❌ Error checking cache existence:', error);
      return false;
    }
  },

  // Incrémenter une valeur
  incr: async (key: string): Promise<number> => {
    try {
      return await redis.incr(key);
    } catch (error) {
      console.error('❌ Error incrementing cache:', error);
      return 0;
    }
  },

  // Définir l'expiration d'une clé
  expire: async (key: string, ttlSeconds: number): Promise<void> => {
    try {
      await redis.expire(key, ttlSeconds);
    } catch (error) {
      console.error('❌ Error setting cache expiration:', error);
    }
  },
};

export default redis;
