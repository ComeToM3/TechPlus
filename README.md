# TechPlus - Système de Réservation Restaurant

## 🍽️ Vue d'ensemble

TechPlus est une solution complète de réservation en ligne pour restaurants, développée avec Flutter (frontend) et Node.js (backend). Le système permet aux clients de réserver des tables en ligne 24/7, tandis que les administrateurs peuvent gérer efficacement leurs réservations et analyser leurs performances.

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
- **TypeScript 5.8.2** : Langage typé
- **Express.js** : Framework web
- **Prisma 6.16.2** : ORM moderne
- **PostgreSQL 17.6** : Base de données
- **Redis 7.4.1** : Cache et sessions

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
- Flutter 3.35.4
- Dart 3.9.2
- Node.js 24.8.0
- PostgreSQL 17.6
- Redis 7.4.1
- TypeScript 5.8.2

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

3. **Développement**
```bash
npm run dev
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
- **TypeScript** : `5.8.2` (stable)
- **PostgreSQL** : `17.6` (stable)
- **Prisma** : `6.16.2` (stable)
- **Redis** : `7.4.1` (stable)

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
- [x] Authentification JWT
- [x] Notifications email (Nodemailer)
- [x] Paiements (Stripe)
- [x] Tests automatisés (Jest + Flutter Test)
- [x] CI/CD (GitHub Actions)
- [x] Qualité du code (Husky + ESLint + Prettier)

### Phase 2 : Backend Core (En cours)
- [ ] APIs complètes et fonctionnelles
- [ ] Système d'authentification robuste
- [ ] Gestion des réservations de base
- [ ] Intégrations Stripe et email
- [ ] Tests automatisés complets

### Phase 3 : Frontend Public
- [ ] Interface publique complète
- [ ] Système de réservation fonctionnel
- [ ] Authentification utilisateur
- [ ] Design responsive
- [ ] Tests automatisés

### Phase 4 : Frontend Admin
- [ ] Interface d'administration complète
- [ ] Gestion avancée des réservations
- [ ] Analytics et reporting
- [ ] Configuration complète
- [ ] Tests automatisés

### Phase 5 : Tests et Optimisation
- [ ] Tests end-to-end complets
- [ ] Performance optimisée
- [ ] Sécurité renforcée
- [ ] Monitoring en place

### Phase 6 : Déploiement et Production
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
