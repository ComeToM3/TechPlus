# Base de Données TechPlus

## 🗄️ Configuration

### PostgreSQL avec Docker
```bash
# Démarrer le conteneur PostgreSQL
docker run --name techplus-postgres \
  -e POSTGRES_DB=techplus \
  -e POSTGRES_USER=techplus \
  -e POSTGRES_PASSWORD=techplus123 \
  -p 5433:5432 \
  -d postgres:17-alpine

# Vérifier le statut
docker ps | grep techplus-postgres
```

### Variables d'Environnement
```env
DATABASE_URL=postgresql://techplus:techplus123@localhost:5433/techplus
DB_HOST=localhost
DB_PORT=5433
DB_NAME=techplus
DB_USER=techplus
DB_PASSWORD=techplus123
```

## 🚀 Commandes Prisma

### Scripts NPM Disponibles
```bash
# Générer le client Prisma
npm run prisma:generate

# Créer une migration
npx prisma migrate dev --name nom_de_la_migration

# Appliquer les migrations
npx prisma migrate deploy

# Réinitialiser la base de données
npm run db:reset

# Peupler avec des données de test
npm run db:seed

# Ouvrir Prisma Studio (interface graphique)
npm run db:studio
```

### Commandes Prisma Directes
```bash
# Générer le client
npx prisma generate

# Créer une migration
npx prisma migrate dev

# Appliquer les migrations en production
npx prisma migrate deploy

# Réinitialiser complètement
npx prisma migrate reset

# Voir le statut des migrations
npx prisma migrate status

# Ouvrir Prisma Studio
npx prisma studio
```

## 📊 Modèle de Données

### Entités Principales
- **User** : Utilisateurs (clients, admins)
- **Restaurant** : Informations du restaurant
- **Table** : Tables du restaurant
- **Reservation** : Réservations
- **MenuItem** : Articles du menu
- **Analytics** : Métriques et statistiques
- **OAuthAccount** : Comptes OAuth (Google, Facebook)

### Relations
- User ↔ Reservation (1:N)
- Restaurant ↔ Table (1:N)
- Restaurant ↔ Reservation (1:N)
- Restaurant ↔ MenuItem (1:N)
- Table ↔ Reservation (1:N)
- User ↔ OAuthAccount (1:N)

## 🧪 Données de Test

### Utilisateurs Créés
- **Admin** : `admin@techplus-restaurant.com`
- **Client** : `client@example.com`

### Données Incluses
- 1 Restaurant (TechPlus Restaurant)
- 20 Tables (capacités variées)
- 9 Articles de menu
- 2 Réservations d'exemple
- 90 enregistrements d'analytics (30 jours × 3 métriques)

## 🔧 Utilisation dans le Code

### Import du Client Prisma
```typescript
import prisma from '@/config/database';

// Exemple d'utilisation
const users = await prisma.user.findMany();
const restaurant = await prisma.restaurant.findFirst();
```

### Test de Connexion
```typescript
import { testDatabaseConnection } from '@/config/database';

const isConnected = await testDatabaseConnection();
```

## 🏥 Health Check

L'endpoint `/health` vérifie automatiquement la connexion à la base de données :

```bash
curl http://localhost:3000/health
```

Réponse :
```json
{
  "status": "OK",
  "timestamp": "2025-09-22T00:05:01.393Z",
  "uptime": 27.416550439,
  "environment": "development",
  "database": "connected"
}
```

## 🚨 Dépannage

### Problèmes Courants

1. **Connexion refusée**
   ```bash
   # Vérifier que le conteneur est en cours d'exécution
   docker ps | grep techplus-postgres
   
   # Redémarrer le conteneur
   docker restart techplus-postgres
   ```

2. **Migration échouée**
   ```bash
   # Réinitialiser et recréer
   npm run db:reset
   npm run db:seed
   ```

3. **Client Prisma non généré**
   ```bash
   npx prisma generate
   ```

### Logs de Base de Données
```bash
# Voir les logs du conteneur PostgreSQL
docker logs techplus-postgres

# Suivre les logs en temps réel
docker logs -f techplus-postgres
```

## 📈 Performance

### Configuration Optimisée
- Connection pooling automatique
- Logging des requêtes en développement
- Index sur les clés étrangères
- Contraintes d'unicité pour éviter les doublons

### Monitoring
- Health check avec statut de la base de données
- Logs des requêtes lentes en développement
- Métriques d'uptime dans l'API

