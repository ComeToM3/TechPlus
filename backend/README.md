# TechPlus Backend API

[![Node.js](https://img.shields.io/badge/Node.js-18+-green.svg)](https://nodejs.org/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.9+-blue.svg)](https://www.typescriptlang.org/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-17+-blue.svg)](https://www.postgresql.org/)
[![Redis](https://img.shields.io/badge/Redis-6+-red.svg)](https://redis.io/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

> **API Backend complète pour le système de réservation de restaurant TechPlus**  
> Architecture moderne, sécurisée et scalable avec authentification OAuth2, paiements Stripe, et notifications email.

## 🚀 Vue d'ensemble

TechPlus Backend est une API REST moderne construite avec Node.js, TypeScript et Express.js, conçue pour gérer un système de réservation de restaurant complet. L'application offre une architecture robuste avec des fonctionnalités avancées de sécurité, d'authentification, de paiements et de notifications.

### ✨ Fonctionnalités Principales

- 🔐 **Authentification Sécurisée** - JWT + OAuth2 (Google, Facebook)
- 💳 **Paiements Intégrés** - Stripe avec webhooks
- 📧 **Notifications Email** - Templates personnalisés HTML
- 🛡️ **Sécurité Avancée** - Helmet, CORS, Rate Limiting, CSRF Protection
- 📊 **Monitoring** - Health checks, métriques, logging
- 🗄️ **Base de Données** - PostgreSQL avec Prisma ORM
- ⚡ **Cache** - Redis pour sessions et performance
- 🧪 **Tests** - Suite complète avec Jest

## 🏗️ Architecture

```
src/
├── config/              # Configuration de l'application
│   ├── database.ts      # Configuration PostgreSQL + Prisma
│   ├── redis.ts         # Configuration Redis
│   ├── environment.ts   # Variables d'environnement
│   ├── security.ts      # Configuration sécurité
│   └── session.ts       # Configuration sessions
├── controllers/         # Contrôleurs des routes API
│   ├── authController.ts
│   ├── reservationController.ts
│   ├── paymentController.ts
│   └── adminController.ts
├── middleware/          # Middlewares Express
│   ├── auth.ts          # Authentification JWT
│   ├── security.ts      # Protection sécurité
│   ├── validation.ts    # Validation des données
│   ├── rateLimit.ts     # Rate limiting
│   └── error.ts         # Gestion d'erreurs
├── routes/              # Définition des routes
│   ├── auth.ts          # Routes d'authentification
│   ├── reservations.ts  # Routes de réservations
│   ├── payments.ts      # Routes de paiements
│   └── admin.ts         # Routes d'administration
├── services/            # Logique métier
│   ├── reservationService.ts
│   ├── paymentService.ts
│   ├── notificationService.ts
│   ├── oauthService.ts
│   └── emailTemplateService.ts
├── templates/           # Templates email HTML
│   └── email/
├── types/               # Types TypeScript
├── utils/               # Utilitaires
└── test/                # Tests unitaires et d'intégration
```

## 🚀 Démarrage Rapide

### Prérequis

- **Node.js** >= 24.8.0
- **npm** >= 11.6.0
- **PostgreSQL** >= 17.6
- **Redis** >= 7.0.15

### Installation

1. **Cloner le projet et installer les dépendances**
   ```bash
   cd backend
   npm install
   ```

2. **Configuration de l'environnement**
   ```bash
   cp .env.example .env
   # Éditer le fichier .env avec vos configurations
   ```

3. **Configuration de la base de données**
   ```bash
   # Générer le client Prisma
   npm run db:generate
   
   # Appliquer les migrations
   npm run db:migrate
   
   # Peupler avec des données de test
   npm run db:seed
   ```

4. **Démarrer en mode développement**
   ```bash
   npm run dev
   ```

5. **Build pour la production**
   ```bash
   npm run build
   npm start
   ```

## 📋 Scripts Disponibles

| Script | Description |
|--------|-------------|
| `npm run dev` | Démarre le serveur en mode développement avec hot-reload |
| `npm run build` | Compile TypeScript vers JavaScript |
| `npm start` | Démarre le serveur en production |
| `npm run test` | Lance les tests unitaires |
| `npm run test:coverage` | Lance les tests avec rapport de couverture |
| `npm run lint` | Vérifie le code avec ESLint |
| `npm run lint:fix` | Corrige automatiquement les erreurs ESLint |
| `npm run format` | Formate le code avec Prettier |
| `npm run db:generate` | Génère le client Prisma |
| `npm run db:migrate` | Applique les migrations |
| `npm run db:seed` | Peuple la base avec des données de test |
| `npm run db:studio` | Ouvre Prisma Studio |

## 🔧 Configuration

### Variables d'Environnement

```env
# Base de données
DATABASE_URL="postgresql://user:password@localhost:5432/techplus"
DB_HOST=localhost
DB_PORT=5432
DB_NAME=techplus
DB_USER=techplus
DB_PASSWORD=techplus123

# Redis
REDIS_URL="redis://localhost:6379/0"

# JWT
JWT_SECRET="your-super-secret-jwt-key"
JWT_EXPIRES_IN="7d"
JWT_REFRESH_EXPIRES_IN="30d"

# OAuth2
GOOGLE_CLIENT_ID="your-google-client-id"
GOOGLE_CLIENT_SECRET="your-google-client-secret"
FACEBOOK_APP_ID="your-facebook-app-id"
FACEBOOK_APP_SECRET="your-facebook-app-secret"

# Email (SMTP)
# ⚠️  SECURITY WARNING: Never commit real SMTP credentials to version control!
# Use environment variables and keep your .env file in .gitignore
SMTP_HOST="smtp.gmail.com"
SMTP_PORT="587"
SMTP_SECURE="false"
SMTP_USER="your-email@gmail.com"
SMTP_PASS="your-app-password"
SMTP_FROM="noreply@techplus.com"
SMTP_FROM_NAME="TechPlus"
SMTP_TEST_EMAIL="test@example.com"

# Stripe
STRIPE_SECRET_KEY="sk_test_..."
STRIPE_PUBLISHABLE_KEY="pk_test_..."
STRIPE_WEBHOOK_SECRET="whsec_..."

# Application
NODE_ENV="development"
PORT=3000
FRONTEND_URL="http://localhost:3000"
```

### Base de Données

L'application utilise **PostgreSQL** avec **Prisma ORM** pour la gestion des données.

#### Modèles Principaux

- **User** - Utilisateurs (clients, admins)
- **Restaurant** - Informations du restaurant
- **Table** - Tables du restaurant
- **Reservation** - Réservations
- **MenuItem** - Articles du menu
- **Analytics** - Métriques et statistiques
- **OAuthAccount** - Comptes OAuth (Google, Facebook)

#### Commandes Prisma

```bash
# Générer le client
npm run db:generate

# Créer une migration
npm run db:migrate

# Réinitialiser la base
npm run db:reset

# Peupler avec des données de test
npm run db:seed

# Ouvrir Prisma Studio
npm run db:studio
```

### Cache Redis

**Redis** est utilisé pour :
- Sessions utilisateur
- Cache des requêtes
- Rate limiting
- Queue de notifications

## 🔐 Sécurité

### Fonctionnalités de Sécurité Implémentées

- **Helmet.js** - Headers de sécurité HTTP
- **CORS** - Configuration stricte des origines
- **Rate Limiting** - Protection contre les abus
- **CSRF Protection** - Protection contre les attaques CSRF
- **Input Validation** - Validation et sanitization des données
- **SQL Injection Protection** - Protection contre les injections SQL
- **XSS Protection** - Protection contre les attaques XSS
- **JWT Authentication** - Authentification sécurisée
- **OAuth2 Integration** - Google et Facebook

### Configuration de Sécurité

```typescript
// Rate Limiting
- API générale: 100 req/15min
- Authentification: 5 req/15min
- Paiements: 10 req/15min
- Webhooks: 50 req/15min

// Headers de Sécurité
- Content Security Policy
- X-Frame-Options: DENY
- X-Content-Type-Options: nosniff
- Strict-Transport-Security
```

## 📡 API Endpoints

### Authentification
```
POST   /api/auth/register     # Inscription
POST   /api/auth/login        # Connexion
POST   /api/auth/logout       # Déconnexion
POST   /api/auth/refresh      # Rafraîchir le token
GET    /api/auth/me           # Profil utilisateur
POST   /api/auth/google       # OAuth Google
POST   /api/auth/facebook     # OAuth Facebook
```

### Réservations
```
GET    /api/reservations              # Liste des réservations
POST   /api/reservations              # Créer une réservation
GET    /api/reservations/:id          # Détails d'une réservation
PUT    /api/reservations/:id          # Modifier une réservation
DELETE /api/reservations/:id          # Annuler une réservation

# Gestion par token (Guest)
GET    /api/reservations/manage/:token # Accéder avec token
PUT    /api/reservations/manage/:token # Modifier avec token
DELETE /api/reservations/manage/:token # Annuler avec token
```

### Disponibilités
```
GET    /api/availability              # Créneaux disponibles
GET    /api/availability/:date        # Disponibilités pour une date
GET    /api/tables/available          # Tables disponibles
```

### Paiements
```
POST   /api/payments/create-intent    # Créer PaymentIntent Stripe
POST   /api/payments/confirm          # Confirmer le paiement
POST   /api/payments/refund           # Remboursement
GET    /api/payments/:id              # Détails du paiement
POST   /api/payments/calculate        # Calculer l'acompte
```

### Administration
```
GET    /api/admin/dashboard/metrics   # Métriques du dashboard
GET    /api/admin/reservations        # Liste admin avec filtres
POST   /api/admin/reservations        # Créer réservation admin
PUT    /api/admin/reservations/:id    # Modifier réservation admin
DELETE /api/admin/reservations/:id    # Annuler réservation admin
```

### Health Check
```
GET    /api/health                    # État de l'application
GET    /api/ready                     # Prêt à recevoir du trafic
GET    /api/live                      # Liveness check
GET    /api/metrics                   # Métriques de performance
```

## 🧪 Tests

### Structure des Tests

```
src/test/
├── services/              # Tests des services
│   ├── reservation.service.test.ts
│   ├── payment.service.test.ts
│   └── notification.service.test.ts
├── controllers/           # Tests des contrôleurs
├── middleware/            # Tests des middlewares
└── integration/           # Tests d'intégration
```

### Commandes de Test

```bash
# Tests unitaires
npm run test

# Tests avec couverture
npm run test:coverage

# Tests en mode watch
npm run test:watch

# Tests d'intégration
npm run test:integration
```

### Couverture de Code

- **Objectif** : 80% de couverture minimum
- **Rapport** : Généré automatiquement dans `coverage/`
- **Outils** : Jest + Istanbul

## 📊 Monitoring et Observabilité

### Health Checks

- **`/api/health`** - État général de l'application
- **`/api/ready`** - Prêt à recevoir du trafic
- **`/api/live`** - Liveness check pour Kubernetes
- **`/api/metrics`** - Métriques de performance

### Logging

- **Winston** - Logging structuré
- **Niveaux** : error, warn, info, debug
- **Rotation** : Logs quotidiens avec rétention
- **Formats** : JSON pour production, texte pour développement

### Métriques

- **Uptime** - Temps de fonctionnement
- **Performance** - Temps de réponse, throughput
- **Base de données** - Connexions, requêtes
- **Redis** - Cache hit/miss ratio

## 🚀 Déploiement

### Production

```bash
# Build de production
npm run build

# Démarrage en production
npm start

# Variables d'environnement
NODE_ENV=production
PORT=3000
```

### Docker

```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build
EXPOSE 3000
CMD ["npm", "start"]
```

### Variables d'Environnement Production

```env
NODE_ENV=production
DATABASE_URL=postgresql://user:password@host:5432/techplus
REDIS_URL=redis://host:6379/0
JWT_SECRET=your-production-secret
STRIPE_SECRET_KEY=sk_live_...
SMTP_HOST=smtp.your-provider.com
```

## 🔧 Développement

### Structure du Code

- **Clean Architecture** - Séparation des responsabilités
- **TypeScript** - Typage strict
- **ESLint + Prettier** - Qualité du code
- **Husky** - Pre-commit hooks
- **Jest** - Tests automatisés

### Standards de Code

- **Conventions** : camelCase, PascalCase pour les classes
- **Documentation** : JSDoc pour les fonctions publiques
- **Tests** : Minimum 80% de couverture
- **Commits** : Conventional Commits

### Workflow de Développement

1. **Fork** du repository
2. **Feature branch** : `git checkout -b feature/nouvelle-fonctionnalite`
3. **Développement** avec tests
4. **Commit** : `git commit -m "feat: ajouter nouvelle fonctionnalité"`
5. **Push** : `git push origin feature/nouvelle-fonctionnalite`
6. **Pull Request** vers main

## 📚 Documentation

- **API Documentation** : `/docs/api/`
- **Database Schema** : `/docs/database/`
- **Security Guide** : `/docs/security/`
- **Deployment Guide** : `/docs/deployment/`

## 🤝 Contribution

1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/AmazingFeature`)
3. Commit les changements (`git commit -m 'Add some AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

## 👥 Équipe

- **Backend Developer** - Architecture et API
- **DevOps Engineer** - Infrastructure et déploiement
- **QA Engineer** - Tests et qualité

## 📞 Support

- **Email** : support@techplus.com
- **Documentation** : [docs.techplus.com](https://docs.techplus.com)
- **Issues** : [GitHub Issues](https://github.com/techplus/backend/issues)

---

**TechPlus Backend** - Système de réservation de restaurant moderne et sécurisé 🚀