# TechPlus V1 - Spécifications Techniques

## 📋 Vue d'ensemble du Système

### Objectif
Créer un système de réservation complet pour restaurants PME, permettant la transformation d'un système de réservation manuscrite vers une solution digitale moderne et efficace.

### Portée V1
- Système de réservation en ligne 24/7
- Interface d'administration pour la gestion
- Authentification sécurisée
- Notifications automatiques
- Support multilingue (FR/EN)

## 🏗️ Architecture Technique

### Frontend Flutter
```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter Application                      │
├─────────────────────────────────────────────────────────────┤
│  Public App (Vitrine + Réservation)  │  Admin App (Gestion) │
├─────────────────────────────────────────────────────────────┤
│                    Shared Components                        │
│  • Navigation (GoRouter)                                   │
│  • State Management (Riverpod)                             │
│  • HTTP Client (Dio)                                       │
│  • Localization (Intl)                                     │
│  • Secure Storage                                          │
└─────────────────────────────────────────────────────────────┘
```

### Backend Node.js
```
┌─────────────────────────────────────────────────────────────┐
│                    Express.js API                           │
├─────────────────────────────────────────────────────────────┤
│  Controllers  │  Services  │  Middleware  │  Routes         │
├─────────────────────────────────────────────────────────────┤
│                    Business Logic                           │
│  • Authentication (JWT + OAuth2)                           │
│  • Reservation Management                                   │
│  • Notification System                                      │
│  • Analytics & Reporting                                    │
└─────────────────────────────────────────────────────────────┘
```

### Base de Données
```
┌─────────────────────────────────────────────────────────────┐
│                    PostgreSQL 17+                           │
├─────────────────────────────────────────────────────────────┤
│  Tables Principales:                                        │
│  • users (clients + admins)                                │
│  • restaurants (infos restaurant)                          │
│  • tables (configuration tables)                           │
│  • reservations (réservations)                             │
│  • menu_items (éléments menu)                              │
│  • analytics (métriques)                                   │
└─────────────────────────────────────────────────────────────┘
```

## 🎯 Fonctionnalités Détaillées

### 1. Interface Publique (Vitrine + Réservation)

#### Page d'Accueil
- **Hero Section** : Image restaurant, nom, slogan
- **Services** : Présentation des services offerts
- **Menu Preview** : Aperçu du menu avec images
- **Call-to-Action** : Bouton "Réserver maintenant"

#### Système de Réservation
- **Sélection Date/Heure** : Calendrier interactif
- **Nombre de personnes** : 1-12 personnes
- **Durée automatique** :
  - 1h30 pour 1-4 personnes
  - 2h00 pour 5+ personnes
- **Informations client** : Nom, email, téléphone
- **Paiement obligatoire** : Pour groupes de 6+ personnes
- **Confirmation** : Récapitulatif et confirmation

#### Gestion des Créneaux
- **Heures d'ouverture** : Configuration flexible
- **Disponibilités** : Calcul en temps réel
- **Blocage automatique** : Tables non disponibles
- **Buffer time** : Temps de nettoyage entre réservations

### 2. Interface d'Administration

#### Dashboard Principal
- **Métriques clés** : Réservations du jour, revenus, occupation
- **Graphiques** : Évolution des réservations
- **Alertes** : Réservations en attente, annulations

#### Gestion des Réservations
- **Vue calendrier** : Planning visuel avec drag & drop
- **Vue liste** : Filtres et recherche avancée
- **Actions client** : Confirmer, annuler, modifier
- **Actions admin** : 
  - Créer une nouvelle réservation
  - Modifier les détails (date, heure, table, nombre de personnes)
  - Annuler avec motif
  - Changer le statut (en attente → confirmée)
  - Ajouter des notes internes
  - Gérer les demandes spéciales
- **Statuts** : En attente, confirmée, annulée, terminée, no-show
- **Notifications** : Email automatique lors des modifications admin

#### Configuration Restaurant
- **Informations générales** : Nom, adresse, contact
- **Heures d'ouverture** : Par jour de la semaine
- **Gestion des tables** : Nombre, capacité, position
- **Menu** : CRUD complet avec images
- **Configuration paiements** :
  - Prix moyen par personne
  - Montant fixe d'acompte (10$)
  - Seuil de paiement obligatoire (défaut: 6 personnes)
  - Politique de remboursement (24h)

#### Analytics et Rapports
- **Statistiques** : Réservations, revenus, popularité
- **Exports** : PDF, Excel
- **Métriques** : Taux d'occupation, durée moyenne

### 5. Gestion Administrative des Réservations

#### Création de Réservations par l'Admin
- **Interface dédiée** : Formulaire de création rapide
- **Sélection client** : Recherche par nom, email, téléphone
- **Créneaux disponibles** : Affichage en temps réel
- **Validation automatique** : Vérification des conflits
- **Notification client** : Email automatique de confirmation

#### Modification des Réservations
- **Champs modifiables** :
  - Date et heure
  - Nombre de personnes
  - Table assignée
  - Statut (en attente → confirmée)
  - Notes et demandes spéciales
- **Historique** : Traçabilité des modifications
- **Notifications** : Email au client en cas de changement
- **Validation** : Vérification des disponibilités

#### Annulation Administrative
- **Motifs prédéfinis** : Liste de raisons d'annulation
- **Notes internes** : Commentaires pour l'équipe
- **Notification client** : Email d'annulation automatique
- **Remboursement** : 
  - **> 24h avant** : Remboursement automatique complet
  - **< 24h avant** : Aucun remboursement
  - **No-show** : Aucun remboursement
- **Statistiques** : Suivi des annulations par motif

#### Interface de Gestion
- **Vue calendrier** : Planning visuel avec drag & drop
- **Filtres avancés** : Par date, statut, table, client
- **Recherche** : Par nom, email, téléphone, numéro de réservation
- **Actions en lot** : Confirmation/annulation multiple
- **Export** : Liste des réservations en PDF/Excel

### 6. Système d'Authentification

#### OAuth2 Integration
- **Google** : Connexion rapide
- **Facebook** : Alternative sociale
- **JWT Tokens** : Sécurité des sessions
- **Refresh Tokens** : Sessions persistantes

#### Rôles et Permissions
- **Guest** : Réservation sans compte avec token de gestion
- **Admin** : Accès complet à l'administration + gestion des réservations

#### Gestion des Réservations Guest
- **Token unique** : Généré automatiquement pour chaque réservation
- **Email de confirmation** : Contient le token et lien de gestion
- **Lien sécurisé** : `/manage-reservation?token=abc123xyz`
- **Actions possibles** : Modifier, annuler, voir détails
- **Expiration** : Token valide 48h après la réservation
- **Sécurité** : Rate limiting et logging des tentatives

### 7. Système de Paiement

#### Intégration Stripe
- **Paiement obligatoire** : Pour réservations de 6+ personnes
- **Méthodes acceptées** : Carte bancaire, Apple Pay, Google Pay
- **Sécurité** : Conformité PCI DSS via Stripe

#### Logique de Paiement
- **Seuil** : 6 personnes et plus
- **Montant fixe** : 10$ d'acompte pour toutes les réservations de 6+ personnes

#### Politique d'Annulation Détaillée
- **Plus de 24h avant** : Remboursement complet automatique
- **Moins de 24h avant** : Aucun remboursement (acompte perdu)
- **No-show** : Aucun remboursement (acompte perdu)
- **Annulation par le restaurant** : Remboursement complet

### 8. Système de Notifications

#### Email Automatique
- **Confirmation** : Détails de la réservation + token de gestion
- **Rappel** : 24h avant la réservation
- **Annulation** : Notification d'annulation
- **Modification** : Notification des changements
- **Template** : Design professionnel avec lien de gestion

#### Gestion des Tokens
- **Génération** : Token unique de 32 caractères aléatoires
- **Stockage** : Chiffré dans la base de données
- **Expiration** : 48h après la date de réservation
- **Usage unique** : Token invalidé après utilisation (optionnel)
- **Sécurité** : Rate limiting et audit trail

#### SMS (Optionnel)
- **Confirmation** : Numéro de réservation
- **Rappel** : Heure de la réservation
- **Intégration Twilio** : Service fiable


#### Architecture des Dossiers
```
lib/
├── core/
│   ├── constants/
│   │   ├── app_constants.dart
│   │   ├── api_constants.dart
│   │   └── theme_constants.dart
│   ├── errors/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── network/
│   │   ├── api_client.dart
│   │   └── network_info.dart
│   ├── utils/
│   │   ├── validators.dart
│   │   └── formatters.dart
│   └── theme/
│       ├── app_theme.dart
│       └── app_colors.dart
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   ├── repositories/
│   │   │   └── datasources/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── pages/
│   │       ├── widgets/
│   │       └── providers/
│   ├── reservation/
│   ├── menu/
│   └── admin/
├── shared/
│   ├── widgets/
│   │   ├── buttons/
│   │   ├── forms/
│   │   └── layouts/
│   └── utils/
└── main.dart
```

#### Architecture des Dossiers
```
src/
├── controllers/
│   ├── auth.controller.ts
│   ├── reservation.controller.ts
│   ├── menu.controller.ts
│   └── admin.controller.ts
├── services/
│   ├── auth.service.ts
│   ├── reservation.service.ts
│   ├── notification.service.ts
│   └── analytics.service.ts
├── models/
│   ├── User.ts
│   ├── Reservation.ts
│   ├── Table.ts
│   └── MenuItem.ts
├── middleware/
│   ├── auth.middleware.ts
│   ├── validation.middleware.ts
│   ├── error.middleware.ts
│   └── rateLimit.middleware.ts
├── routes/
│   ├── auth.routes.ts
│   ├── reservation.routes.ts
│   ├── menu.routes.ts
│   └── admin.routes.ts
├── utils/
│   ├── database.ts
│   ├── redis.ts
│   ├── logger.ts
│   └── validators.ts
├── types/
│   ├── auth.types.ts
│   ├── reservation.types.ts
│   └── common.types.ts
└── app.ts
```

## 🗄️ Modèle de Données

### Schéma Prisma
```prisma
// prisma/schema.prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id        String   @id @default(cuid())
  email     String   @unique
  name      String?
  phone     String?
  avatar    String?
  role      UserRole @default(CLIENT)
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  // Relations
  reservations Reservation[]
  oauthAccounts OAuthAccount[]

  @@map("users")
}

model OAuthAccount {
  id       String @id @default(cuid())
  provider String
  providerId String
  userId   String
  user     User   @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@unique([provider, providerId])
  @@map("oauth_accounts")
}

model Restaurant {
  id          String @id @default(cuid())
  name        String
  description String?
  address     String
  phone       String
  email       String
  website     String?
  logo        String?
  images      String[]
  settings    Json?
  
  // Configuration paiements
  averagePricePerPerson Decimal @default(25.00)
  minimumDepositAmount  Decimal @default(10.00)
  paymentThreshold      Int     @default(6)
  cancellationPolicy    String? // Politique d'annulation (24h)
  
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt

  // Relations
  tables      Table[]
  menuItems   MenuItem[]
  reservations Reservation[]

  @@map("restaurants")
}

model Table {
  id           String @id @default(cuid())
  number       Int
  capacity     Int
  position     String?
  isActive     Boolean @default(true)
  restaurantId String
  restaurant   Restaurant @relation(fields: [restaurantId], references: [id], onDelete: Cascade)

  // Relations
  reservations Reservation[]

  @@unique([restaurantId, number])
  @@map("tables")
}

model Reservation {
  id           String @id @default(cuid())
  date         DateTime
  time         String
  duration     Int // en minutes
  partySize    Int
  status       ReservationStatus @default(PENDING)
  notes        String?
  specialRequests String?
  
  // Client info (pour les réservations sans compte)
  clientName   String?
  clientEmail  String?
  clientPhone  String?
  
  // Token de gestion pour les guests
  managementToken String? @unique
  tokenExpiresAt  DateTime?
  
  // Notes internes admin
  adminNotes   String?
  cancellationReason String?
  
  // Paiement
  requiresPayment Boolean @default(false)
  estimatedAmount Decimal?
  depositAmount   Decimal?
  paymentStatus   PaymentStatus @default(NONE)
  stripePaymentId String?
  
  // Relations
  userId       String?
  user         User? @relation(fields: [userId], references: [id])
  tableId      String?
  table        Table? @relation(fields: [tableId], references: [id])
  restaurantId String
  restaurant   Restaurant @relation(fields: [restaurantId], references: [id], onDelete: Cascade)

  createdAt    DateTime @default(now())
  updatedAt    DateTime @updatedAt

  @@map("reservations")
}

model MenuItem {
  id           String @id @default(cuid())
  name         String
  description  String?
  price        Decimal
  category     String
  image        String?
  isAvailable  Boolean @default(true)
  allergens    String[]
  restaurantId String
  restaurant   Restaurant @relation(fields: [restaurantId], references: [id], onDelete: Cascade)

  createdAt    DateTime @default(now())
  updatedAt    DateTime @updatedAt

  @@map("menu_items")
}

model Analytics {
  id           String @id @default(cuid())
  date         DateTime
  metric       String
  value        Decimal
  restaurantId String
  restaurant   Restaurant @relation(fields: [restaurantId], references: [id], onDelete: Cascade)

  createdAt    DateTime @default(now())

  @@unique([restaurantId, date, metric])
  @@map("analytics")
}

enum UserRole {
  CLIENT
  ADMIN
  SUPER_ADMIN
}

enum ReservationStatus {
  PENDING
  CONFIRMED
  CANCELLED
  COMPLETED
  NO_SHOW
}

enum PaymentStatus {
  NONE
  PENDING
  COMPLETED
  FAILED
  REFUNDED
  PARTIALLY_REFUNDED
}
```

## 🔌 API Endpoints

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

# Administration
GET    /api/admin/reservations        # Liste admin avec filtres
POST   /api/admin/reservations        # Créer réservation admin
PUT    /api/admin/reservations/:id    # Modifier réservation admin
DELETE /api/admin/reservations/:id    # Annuler réservation admin
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
GET    /api/payments/refund-policy    # Politique de remboursement
```

### Notifications
```
POST   /api/notifications/send        # Envoyer notification
GET    /api/notifications/history     # Historique des notifications
```

## 🔄 Flux de Navigation

### Frontend Public
```
Home (Vitrine)
├── Menu
│   ├── Catégories
│   └── Détails plat
├── À propos
├── Contact
├── Réserver
│   ├── Sélection date/heure
│   ├── Nombre de personnes
│   ├── Informations client
│   ├── Paiement (si 6+ personnes)
│   │   ├── Montant fixe (10$)
│   │   ├── Affichage politique annulation
│   │   ├── Interface Stripe
│   │   └── Confirmation paiement
│   ├── Confirmation
│   └── Succès
└── Gérer Réservation (Guest)
    ├── Saisie token/email
    ├── Vérification
    ├── Actions disponibles
    │   ├── Modifier
    │   ├── Annuler
    │   └── Voir détails
    └── Confirmation action
```

### Frontend Admin
```
Login
└── Dashboard
    ├── Réservations
    │   ├── Calendrier
    │   │   ├── Vue mensuelle
    │   │   ├── Vue hebdomadaire
    │   │   └── Drag & Drop
    │   ├── Liste
    │   │   ├── Filtres (date, statut, table)
    │   │   ├── Recherche
    │   │   └── Actions en lot
    │   ├── Détails
    │   │   ├── Informations client
    │   │   ├── Historique modifications
    │   │   └── Notes internes
    │   └── Nouvelle Réservation
    │       ├── Sélection client
    │       ├── Créneaux disponibles
    │       └── Validation
    ├── Tables
    │   ├── Configuration
    │   └── Disponibilités
    ├── Menu
    │   ├── Gestion
    │   └── Images
    ├── Analytics
    │   ├── Statistiques
    │   └── Rapports
    └── Paramètres
        ├── Restaurant
        ├── Notifications
        └── Utilisateurs
```

## 🔐 Sécurité et Performance

### Sécurité
- **HTTPS** : Communication chiffrée
- **JWT** : Tokens sécurisés avec expiration
- **Rate Limiting** : Protection contre les abus
- **Validation** : Sanitization des données
- **CORS** : Configuration stricte
- **Helmet** : Headers de sécurité

### Performance
- **Cache Redis** : Sessions et données fréquentes
- **Lazy Loading** : Chargement à la demande
- **Image Optimization** : Compression et redimensionnement
- **Database Indexing** : Requêtes optimisées
- **CDN** : Distribution des assets statiques

## 📱 Responsive Design

### Breakpoints
- **Mobile** : < 768px
- **Tablet** : 768px - 1024px
- **Desktop** : > 1024px

### Adaptations
- **Navigation** : Menu hamburger sur mobile
- **Calendrier** : Vue simplifiée sur mobile
- **Formulaires** : Champs adaptés au tactile
- **Images** : Tailles optimisées par device

## 🌍 Internationalisation

### Structure des Traductions
```
assets/
└── translations/
    ├── fr.json
    └── en.json
```

### Clés de Traduction
```json
{
  "common": {
    "save": "Enregistrer",
    "cancel": "Annuler",
    "confirm": "Confirmer"
  },
  "reservation": {
    "title": "Réserver une table",
    "date": "Date",
    "time": "Heure",
    "partySize": "Nombre de personnes"
  },
  "admin": {
    "dashboard": "Tableau de bord",
    "reservations": "Réservations",
    "tables": "Tables"
  }
}
```

## 🚀 Déploiement

### Environnements
- **Development** : Local avec hot reload
- **Staging** : Tests et validation
- **Production** : Environnement stable

### Docker Configuration
```dockerfile
# Backend Dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build
EXPOSE 3000
CMD ["npm", "start"]
```

### Variables d'Environnement
```env
# Database
DATABASE_URL="postgresql://user:password@localhost:5432/techplus"

# Redis
REDIS_URL="redis://localhost:6379"

# JWT
JWT_SECRET="your-secret-key"
JWT_EXPIRES_IN="7d"

# OAuth
GOOGLE_CLIENT_ID="your-google-client-id"
GOOGLE_CLIENT_SECRET="your-google-client-secret"
FACEBOOK_APP_ID="your-facebook-app-id"
FACEBOOK_APP_SECRET="your-facebook-app-secret"

# Email
SMTP_HOST="smtp.gmail.com"
SMTP_PORT="587"
SMTP_USER="your-email@gmail.com"
SMTP_PASS="your-app-password"

# SMS (Optional)
TWILIO_ACCOUNT_SID="your-twilio-sid"
TWILIO_AUTH_TOKEN="your-twilio-token"
TWILIO_PHONE_NUMBER="+1234567890"

# Stripe
STRIPE_SECRET_KEY="sk_test_..."
STRIPE_PUBLISHABLE_KEY="pk_test_..."
STRIPE_WEBHOOK_SECRET="whsec_..."
```

## 📊 Métriques et Analytics

### KPIs Principaux
- **Taux d'occupation** : Pourcentage de tables occupées
- **Revenus** : Chiffre d'affaires généré
- **Réservations** : Nombre total de réservations
- **Annulations** : Taux d'annulation
- **Satisfaction** : Notes et commentaires clients

### Rapports Disponibles
- **Quotidien** : Réservations du jour
- **Hebdomadaire** : Tendances de la semaine
- **Mensuel** : Performance du mois
- **Annuel** : Bilan annuel

## 🔧 Maintenance et Support

### Monitoring
- **Logs** : Winston pour le logging structuré
- **Health Checks** : Endpoints de santé
- **Error Tracking** : Capture des erreurs
- **Performance** : Métriques de performance

### Backup
- **Base de données** : Sauvegarde quotidienne
- **Images** : Stockage sécurisé
- **Configuration** : Versioning des paramètres

---

## 📋 Checklist de Développement V1

### Phase 1 : Setup et Architecture
- [ ] Configuration de l'environnement de développement
- [ ] Setup de la base de données PostgreSQL
- [ ] Configuration de Redis/KeyDB
- [ ] Structure des projets Flutter et Node.js
- [ ] Configuration des outils de développement

### Phase 2 : Backend Core
- [ ] Modèles Prisma et migrations
- [ ] Authentification JWT + OAuth2
- [ ] API de base (CRUD)
- [ ] Middleware de sécurité
- [ ] Système de notifications email

### Phase 3 : Frontend Public
- [ ] Interface vitrine restaurant
- [ ] Système de réservation
- [ ] Authentification OAuth2
- [ ] Internationalisation FR/EN
- [ ] Design responsive

### Phase 4 : Frontend Admin
- [ ] Dashboard principal
- [ ] Gestion des réservations
- [ ] Configuration des tables
- [ ] Gestion du menu
- [ ] Analytics de base

### Phase 5 : Intégration et Tests
- [ ] Tests unitaires
- [ ] Tests d'intégration
- [ ] Tests end-to-end
- [ ] Optimisation des performances
- [ ] Documentation utilisateur

### Phase 6 : Déploiement
- [ ] Configuration production
- [ ] Déploiement backend
- [ ] Déploiement frontend
- [ ] Monitoring et logs
- [ ] Formation utilisateurs

---

*Ce document constitue la base technique pour le développement de TechPlus V1. Il sera mis à jour au fur et à mesure de l'avancement du projet.*
