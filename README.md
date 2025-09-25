# TechPlus - Système de Réservation Restaurant

[![Flutter](https://img.shields.io/badge/Flutter-3.35.4-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.9.2-blue.svg)](https://dart.dev/)
[![Node.js](https://img.shields.io/badge/Node.js-24.8.0-green.svg)](https://nodejs.org/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.9.2-blue.svg)](https://www.typescriptlang.org/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-17.6-blue.svg)](https://www.postgresql.org/)
[![Redis](https://img.shields.io/badge/Redis-7.0.15-red.svg)](https://redis.io/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

> **Solution complète de réservation en ligne pour restaurants**  
> Application Flutter moderne avec backend Node.js, authentification OAuth2, paiements Stripe, et interface d'administration complète.

## 🍽️ Vue d'ensemble

TechPlus est une solution complète de réservation en ligne pour restaurants, développée avec Flutter (frontend) et Node.js (backend). Le système permet aux clients de réserver des tables en ligne 24/7, tandis que les administrateurs peuvent gérer efficacement leurs réservations et analyser leurs performances.

### ✨ **Statut Actuel - Application Fonctionnelle** ✅

- ✅ **Backend** : 100% opérationnel avec API complète
- ✅ **Frontend** : 100% fonctionnel avec interface responsive
- ✅ **Authentification** : JWT + OAuth2 (Google, Facebook)
- ✅ **Base de données** : PostgreSQL avec données de test
- ✅ **Cache** : Redis configuré et fonctionnel
- ✅ **Paiements** : Stripe intégré
- ✅ **Notifications** : Templates email personnalisés
- ✅ **Tests** : Suite complète implémentée
- ✅ **Sécurité** : Configuration avancée

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │   Backend API   │    │   Base de       │
│   Flutter       │◄──►│   Node.js       │◄──►│   Données       │
│                 │    │   TypeScript    │    │   PostgreSQL    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   App Public    │    │   Cache         │    │   Notifications │
│   + Admin       │    │   Redis 7.4.1   │    │   Email + SMS   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🚀 Fonctionnalités

### Frontend Public
- 🏠 **Vitrine Restaurant** : Présentation des services et menu
- 📅 **Réservation en ligne** : Interface intuitive 24/7
- 🌍 **Multilingue** : Français et Anglais
- 📱 **Responsive** : Mobile, tablette, desktop

### Frontend Admin
- 📊 **Dashboard** : Statistiques en temps réel
- 🗓️ **Gestion des réservations** : Vue calendrier et liste
- 🪑 **Gestion des tables** : Configuration flexible
- 📋 **Gestion du menu** : CRUD complet avec images
- 📈 **Analytics** : Rapports et métriques

### Backend API
- 🔐 **Authentification** : OAuth2 (Google/Facebook) + JWT
- 📧 **Notifications** : Email et SMS automatiques
- ⚡ **Cache intelligent** : Performance optimisée
- 🔒 **Sécurité** : Validation, sanitization, rate limiting

## 🛠️ Technologies

### Frontend
- **Flutter 3.35.4** : Framework multiplateforme
- **Dart 3.9.2** : Langage de programmation
- **Riverpod** : Gestion d'état moderne
- **GoRouter** : Navigation déclarative
- **Dio** : Client HTTP
- **Intl** : Internationalisation

### Backend
- **Node.js 24.8.0** : Runtime JavaScript
- **TypeScript 5.9.2** : Langage typé
- **Express.js 5.1.0** : Framework web
- **Prisma 6.16.2** : ORM moderne
- **PostgreSQL 17.6** : Base de données
- **Redis 7.0.15** : Cache et sessions
- **JWT** : Authentification sécurisée
- **Stripe 18.5.0** : Paiements intégrés

## 📁 Structure du Projet

```
TechPlus/
├── frontend/                 # Application Flutter
│   ├── lib/
│   │   ├── core/            # Configuration, constants, utils
│   │   ├── features/        # Fonctionnalités métier
│   │   │   ├── auth/        # Authentification
│   │   │   ├── reservation/ # Réservations
│   │   │   ├── menu/        # Menu restaurant
│   │   │   └── admin/       # Interface admin
│   │   ├── shared/          # Composants partagés
│   │   └── main.dart
│   ├── assets/              # Images, traductions
│   └── pubspec.yaml
├── backend/                 # API Node.js
│   ├── src/
│   │   ├── controllers/     # Contrôleurs API
│   │   ├── services/        # Logique métier
│   │   ├── models/          # Modèles Prisma
│   │   ├── middleware/      # Middlewares Express
│   │   ├── routes/          # Routes API
│   │   └── utils/           # Utilitaires
│   ├── prisma/              # Schémas et migrations
│   └── package.json
├── docs/                    # Documentation
└── docker/                  # Configuration Docker
```

## 🚀 Démarrage Rapide

### Prérequis
- **Flutter** >= 3.35.4
- **Dart** >= 3.9.2
- **Node.js** >= 24.8.0
- **npm** >= 11.6.0
- **PostgreSQL** >= 17.6
- **Redis** >= 7.0.15
- **TypeScript** >= 5.9.2

### Installation

1. **Cloner le projet**
```bash
git clone <repository-url>
cd TechPlus
```

2. **Installation complète**
```bash
npm run install:all
```

3. **Configuration de la base de données**
```bash
cd backend
npm run db:generate
npm run db:migrate
npm run db:seed
```

4. **Développement**
```bash
# Terminal 1 - Backend
cd backend && npm run dev

# Terminal 2 - Frontend
cd frontend && flutter run
```

## 🔗 Informations de Connexion

### Comptes de Test Disponibles
- **Admin** : `admin@techplus-restaurant.com` / `admin123`
- **Client** : `client@example.com` / `client123`

### URLs d'Accès
- **API Backend** : `http://localhost:3000`
- **Health Check** : `http://localhost:3000/health`
- **Frontend Web** : `http://localhost:3000` (après build)
- **Frontend Mobile** : Via émulateur ou device physique

### Configuration API
```dart
// Dans frontend/lib/core/constants/app_constants.dart
static const String baseUrl = 'http://localhost:3000';
// Pour émulateur Android : 'http://172.20.0.1:3000'
```

## 🛠️ Commandes Disponibles

### Commandes Globales (Racine du projet)

#### Installation et Setup
```bash
npm run install:all      # Installe toutes les dépendances (backend + frontend)
npm run clean           # Nettoie les builds (backend + frontend)
```

#### Développement
```bash
npm run dev             # Lance backend + frontend en mode développement
npm run dev:backend     # Lance uniquement le backend
npm run dev:frontend    # Lance uniquement le frontend
```

#### Tests
```bash
npm run test            # Lance tous les tests (backend + frontend)
npm run test:coverage   # Tests avec rapports de couverture
npm run test:backend    # Tests backend uniquement
npm run test:frontend   # Tests frontend uniquement
```

#### Qualité du Code
```bash
npm run lint            # Linting backend + frontend
npm run format          # Formatage backend + frontend
npm run format:check    # Vérification du formatage
```

#### Build
```bash
npm run build           # Build production (backend + frontend)
npm run build:backend   # Build backend uniquement
npm run build:frontend  # Build frontend uniquement
```

### Commandes Backend

```bash
cd backend

# Développement
npm run dev             # Mode développement avec hot reload
npm run dev:watch       # Mode développement avec watch

# Tests
npm test                # Tests unitaires et intégration
npm run test:watch      # Tests en mode watch
npm run test:coverage   # Tests avec couverture

# Qualité du code
npm run lint            # ESLint
npm run lint:fix        # ESLint avec correction automatique
npm run format          # Prettier
npm run format:check    # Vérification Prettier
npm run type-check      # Vérification TypeScript

# Base de données
npm run db:seed         # Seeds de données
npm run db:reset        # Reset de la base de données
npm run db:studio       # Interface Prisma Studio

# Build
npm run build           # Build TypeScript
npm run start           # Démarrage production
npm run clean           # Nettoyage des builds
```

### Commandes Frontend

```bash
cd frontend

# Développement
flutter run             # Lance l'application
flutter run -d web      # Lance sur le web
flutter run -d chrome   # Lance sur Chrome

# Tests
flutter test            # Tests unitaires et widgets
flutter test --coverage # Tests avec couverture

# Qualité du code
flutter analyze         # Analyse statique
dart format .           # Formatage du code
dart format --set-exit-if-changed . # Vérification formatage

# Build
flutter build web       # Build web
flutter build apk       # Build Android APK
flutter build ios       # Build iOS
flutter clean           # Nettoyage
```

## 🔧 Configuration de Qualité du Code

### Pre-commit Hooks (Husky)
- **Pre-commit** : Linting + formatage automatique
- **Pre-push** : Tests complets avant push
- **Commit-msg** : Validation du format des messages

### Linting et Formatage
- **Backend** : ESLint + Prettier + TypeScript
- **Frontend** : Flutter analyze + dart format
- **Automatique** : Correction automatique avec lint-staged

### Tests et Couverture
- **Backend** : Jest avec TypeScript
- **Frontend** : Flutter test
- **Couverture** : Rapports HTML, JSON, LCOV
- **Seuils** : 80% minimum (configurable)

## 📦 Dépendances

### Versions Testées et Compatibles
- **Flutter** : `3.35.4` (stable)
- **Dart** : `3.9.2` (stable)
- **Node.js** : `24.8.0` (LTS)
- **npm** : `11.6.0` (stable)
- **TypeScript** : `5.9.2` (stable)
- **PostgreSQL** : `17.6` (stable)
- **Prisma** : `6.16.2` (stable)
- **Redis** : `7.0.15` (stable)
- **Express.js** : `5.1.0` (stable)
- **Stripe** : `18.5.0` (stable)

> 📋 **Documentation complète** : Voir [docs/development/dependencies-specifications.md](docs/development/dependencies-specifications.md) pour la liste complète des dépendances et leurs versions.

## 📋 Roadmap

### Phase 1 : Infrastructure et Setup ✅ TERMINÉE
- [x] Architecture de base
- [x] Spécifications techniques
- [x] Documentation complète
- [x] Configuration backend (Node.js + TypeScript)
- [x] Configuration frontend (Flutter + Riverpod)
- [x] Base de données (PostgreSQL + Prisma)
- [x] Cache et sessions (Redis)
- [x] Authentification JWT + OAuth2
- [x] Notifications email (Templates personnalisés)
- [x] Paiements (Stripe intégré)
- [x] Tests automatisés (Jest + Flutter Test)
- [x] CI/CD (GitHub Actions)
- [x] Qualité du code (Husky + ESLint + Prettier)

### Phase 2 : Backend Core ✅ TERMINÉE
- [x] APIs complètes et fonctionnelles
- [x] Système d'authentification robuste
- [x] Gestion des réservations de base
- [x] Intégrations Stripe et email
- [x] Tests automatisés complets
- [x] Sécurité avancée (Helmet, CORS, Rate Limiting)
- [x] Monitoring et logging

### Phase 3 : Frontend Public ✅ TERMINÉE
- [x] Interface publique complète
- [x] Système de réservation fonctionnel
- [x] Authentification utilisateur
- [x] Design responsive (Mobile, tablette, desktop)
- [x] Internationalisation (FR/EN)
- [x] Tests automatisés

### Phase 4 : Frontend Admin ✅ TERMINÉE
- [x] Interface d'administration complète
- [x] Gestion avancée des réservations
- [x] Analytics et reporting
- [x] Configuration complète
- [x] Tests automatisés
- [x] Dashboard avec métriques en temps réel

### Phase 5 : Tests et Optimisation 🔄 EN COURS
- [x] Tests unitaires et d'intégration
- [x] Performance optimisée
- [x] Sécurité renforcée
- [ ] Tests end-to-end complets
- [ ] Monitoring avancé

### Phase 6 : Déploiement et Production 📋 PLANIFIÉE
- [ ] Déploiement en production
- [ ] Monitoring et maintenance
- [ ] Formation des utilisateurs

## 🔄 Workflow de Développement

### Pre-commit Hooks
Le projet utilise Husky pour automatiser la qualité du code :

1. **Pre-commit** : Linting + formatage automatique
2. **Pre-push** : Tests complets avant push
3. **Commit-msg** : Validation du format des messages

### Format des Messages de Commit
```bash
<type>(<scope>): <description>

# Types autorisés
feat: nouvelle fonctionnalité
fix: correction de bug
docs: documentation
style: formatage
refactor: refactoring
test: tests
chore: tâches de maintenance

# Exemples
feat(auth): add OAuth2 login
fix(reservation): correct date validation
docs(readme): update installation guide
```

### Standards de Code
- **Backend** : ESLint + Prettier + TypeScript strict
- **Frontend** : Flutter analyze + dart format
- **Tests** : Couverture minimum 80%
- **Documentation** : JSDoc pour le backend, DartDoc pour le frontend

## 🤝 Contribution

Ce projet suit les standards de développement modernes et est conçu pour être maintenable et évolutif.

### Comment Contribuer
1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/nouvelle-fonctionnalite`)
3. Commiter les changements (`git commit -m 'feat: add nouvelle fonctionnalité'`)
4. Push vers la branche (`git push origin feature/nouvelle-fonctionnalite`)
5. Ouvrir une Pull Request

### Guidelines
- Respecter les conventions de nommage
- Ajouter des tests pour les nouvelles fonctionnalités
- Maintenir la couverture de code à 80%+
- Documenter les APIs publiques
- Suivre le format de commit conventionnel

## 📄 Licence

MIT License - Voir le fichier LICENSE pour plus de détails.
