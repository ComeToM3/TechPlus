# Spécifications des Dépendances TechPlus V1
*Mises à jour pour septembre 2025 - Versions stables*

## 📋 Vue d'Ensemble

Ce document spécifie toutes les dépendances du projet TechPlus V1 avec leurs versions stables et compatibles au 20 septembre 2025.

## 🎯 Versions de Base

### Flutter & Dart
- **Flutter** : `3.35.4` (stable - 16 septembre 2025) ✅ **Votre version actuelle**
- **Dart** : `3.9.2` (stable - 27 août 2025) ⚠️ **Mineur à jour vers 3.9.3**
- **SDK Constraint** : `>=3.9.0 <4.0.0`

### Node.js & TypeScript
- **Node.js** : `24.8.0` (LTS - septembre 2025) ✅ **Votre version actuelle**
- **TypeScript** : `5.8.2` (stable - septembre 2025) 🔴 **À installer**
- **npm** : `11.6.0` (inclus avec Node.js 24) ✅ **Votre version actuelle**

---

## 📱 Dépendances Flutter

### Configuration de Base
```yaml
# pubspec.yaml
name: techplus
description: Système de réservation restaurant
version: 1.0.0+1

environment:
  sdk: '>=3.9.0 <4.0.0'
  flutter: ">=3.35.0"

flutter:
  uses-material-design: true
```

### Dépendances Principales
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.6.1
  
  # Navigation
  go_router: ^14.6.2
  
  # HTTP & API
  dio: ^5.7.0
  retrofit: ^4.4.1
  json_annotation: ^4.9.0
  
  # Local Storage
  shared_preferences: ^2.3.2
  flutter_secure_storage: ^9.2.2
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  
  # UI Components
  cupertino_icons: ^1.0.8
  material_design_icons_flutter: ^7.0.7296
  flutter_svg: ^2.0.10+1
  cached_network_image: ^3.4.1
  shimmer: ^3.0.0
  
  # Forms & Validation
  form_builder_validators: ^11.0.0
  flutter_form_builder: ^9.4.1
  
  # Date & Time
  intl: ^0.19.0
  table_calendar: ^3.1.2
  
  # Authentication
  google_sign_in: ^6.2.1
  sign_in_with_apple: ^6.1.2
  
  # Payments
  flutter_stripe: ^11.1.0
  
  # Notifications
  flutter_local_notifications: ^17.2.3
  
  # Internationalization
  flutter_localizations:
    sdk: flutter
  
  # Utils
  equatable: ^2.0.5
  freezed_annotation: ^2.4.4
  uuid: ^4.5.1
  url_launcher: ^6.3.1
  permission_handler: ^11.3.1
```

### Dépendances de Développement
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  
  # Code Generation
  build_runner: ^2.4.13
  riverpod_generator: ^2.6.2
  retrofit_generator: ^8.1.0
  json_serializable: ^6.8.0
  freezed: ^2.5.7
  hive_generator: ^2.0.1
  
  # Linting & Formatting
  flutter_lints: ^4.0.0
  very_good_analysis: ^6.0.0
  
  # Testing
  mockito: ^5.4.4
  integration_test:
    sdk: flutter
  
  # Coverage
  coverage: ^1.9.1
```

---

## 🖥️ Dépendances Backend (Node.js)

### Configuration de Base
```json
{
  "name": "techplus-backend",
  "version": "1.0.0",
  "description": "TechPlus Backend API",
  "main": "dist/app.js",
  "engines": {
    "node": ">=22.0.0",
    "npm": ">=10.0.0"
  }
}
```

### Dépendances Principales
```json
{
  "dependencies": {
    "@prisma/client": "^6.1.0",
    "prisma": "^6.1.0",
    
    "express": "^4.21.1",
    "cors": "^2.8.5",
    "helmet": "^8.0.0",
    "compression": "^1.7.5",
    "morgan": "^1.10.0",
    
    "jsonwebtoken": "^9.0.2",
    "bcryptjs": "^2.4.3",
    "passport": "^0.7.0",
    "passport-jwt": "^4.0.1",
    "passport-google-oauth20": "^2.0.0",
    "passport-facebook": "^3.0.0",
    
    "stripe": "^17.3.0",
    "nodemailer": "^6.9.15",
    "twilio": "^5.3.5",
    
    "joi": "^17.13.3",
    "express-rate-limit": "^7.4.1",
    "express-validator": "^7.2.0",
    
    "redis": "^4.7.0",
    "ioredis": "^5.4.1",
    
    "winston": "^3.17.0",
    "dotenv": "^16.4.7",
    
    "multer": "^1.4.5-lts.1",
    "sharp": "^0.33.5",
    
    "node-cron": "^3.0.3",
    "uuid": "^10.0.0"
  }
}
```

### Dépendances de Développement
```json
{
  "devDependencies": {
    "@types/node": "^22.10.2",
    "@types/express": "^5.0.0",
    "@types/cors": "^2.8.17",
    "@types/compression": "^1.7.5",
    "@types/morgan": "^1.9.9",
    "@types/jsonwebtoken": "^9.0.7",
    "@types/bcryptjs": "^2.4.6",
    "@types/passport": "^1.0.16",
    "@types/passport-jwt": "^4.0.1",
    "@types/passport-google-oauth20": "^2.0.14",
    "@types/passport-facebook": "^3.0.3",
    "@types/nodemailer": "^6.4.19",
    "@types/multer": "^1.4.12",
    "@types/node-cron": "^3.0.11",
    "@types/uuid": "^10.0.0",
    
    "typescript": "^5.8.2",
    "ts-node": "^10.9.2",
    "nodemon": "^3.1.7",
    "tsx": "^4.19.2",
    
    "jest": "^29.7.0",
    "@types/jest": "^29.5.14",
    "ts-jest": "^29.2.5",
    "supertest": "^7.0.0",
    "@types/supertest": "^6.0.2",
    
    "eslint": "^9.17.0",
    "@typescript-eslint/eslint-plugin": "^8.18.2",
    "@typescript-eslint/parser": "^8.18.2",
    "prettier": "^3.4.2",
    
    "husky": "^9.1.7",
    "lint-staged": "^15.2.10"
  }
}
```

---

## 🗄️ Base de Données et Services

### PostgreSQL
- **Version** : `17.6` (stable - septembre 2025) ✅ **Votre version actuelle**
- **Prisma** : `6.16.2` (compatible avec PostgreSQL 17+) ✅ **Votre version actuelle**
- **Connection Pool** : `pg-pool` version `3.7.0`

### Redis
- **Version** : `7.4.1` (stable - septembre 2025) 🔴 **À installer**
- **Client Node.js** : `redis` version `4.7.0`
- **Alternative** : `ioredis` version `5.4.1`

### Services Externes
```json
{
  "stripe": "^17.3.0",
  "twilio": "^5.3.5",
  "nodemailer": "^6.9.15",
  "passport-google-oauth20": "^2.0.0",
  "passport-facebook": "^3.0.0"
}
```

---

## 🔧 Outils de Développement

### Flutter
```yaml
# Outils recommandés
flutter_lints: ^4.0.0
very_good_analysis: ^6.0.0
build_runner: ^2.4.13
```

### Node.js
```json
{
  "eslint": "^9.17.0",
  "prettier": "^3.4.2",
  "husky": "^9.1.7",
  "lint-staged": "^15.2.10",
  "nodemon": "^3.1.7",
  "tsx": "^4.19.2"
}
```

### Testing
```json
{
  "jest": "^29.7.0",
  "supertest": "^7.0.0",
  "mockito": "^5.4.4",
  "coverage": "^1.9.1"
}
```

---

## 🚀 Scripts de Configuration

### Flutter (pubspec.yaml)
```yaml
flutter:
  assets:
    - assets/images/
    - assets/translations/
    - assets/icons/
  
  fonts:
    - family: CustomFont
      fonts:
        - asset: assets/fonts/CustomFont-Regular.ttf
        - asset: assets/fonts/CustomFont-Bold.ttf
          weight: 700
```

### Node.js (package.json)
```json
{
  "scripts": {
    "dev": "nodemon --exec tsx src/app.ts",
    "build": "tsc",
    "start": "node dist/app.js",
    "test": "jest",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage",
    "lint": "eslint src/**/*.ts",
    "lint:fix": "eslint src/**/*.ts --fix",
    "format": "prettier --write src/**/*.ts",
    "db:generate": "prisma generate",
    "db:push": "prisma db push",
    "db:migrate": "prisma migrate dev",
    "db:seed": "tsx prisma/seed.ts"
  }
}
```

---

## 🔐 Variables d'Environnement

### Flutter (.env)
```env
# API Configuration
API_BASE_URL=https://api.techplus.com
API_TIMEOUT=30000

# Stripe
STRIPE_PUBLISHABLE_KEY=pk_live_...

# Google Sign-In
GOOGLE_CLIENT_ID=your-google-client-id

# Apple Sign-In
APPLE_CLIENT_ID=your-apple-client-id
```

### Backend (.env)
```env
# Server
NODE_ENV=production
PORT=3000

# Database
DATABASE_URL="postgresql://user:password@localhost:5432/techplus"
REDIS_URL="redis://localhost:6379"

# JWT
JWT_SECRET="your-super-secret-jwt-key"
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

# SMS
TWILIO_ACCOUNT_SID="your-twilio-sid"
TWILIO_AUTH_TOKEN="your-twilio-token"
TWILIO_PHONE_NUMBER="+1234567890"

# Stripe
STRIPE_SECRET_KEY="sk_live_..."
STRIPE_PUBLISHABLE_KEY="pk_live_..."
STRIPE_WEBHOOK_SECRET="whsec_..."
```

---

## 📋 Checklist de Compatibilité

### ✅ Flutter & Dart
- [ ] Flutter 3.35.3 installé
- [ ] Dart 3.9.3 installé
- [ ] SDK constraint >=3.9.0 <4.0.0
- [ ] Toutes les dépendances compatibles
- [ ] Tests passent avec les nouvelles versions

### ✅ Node.js & TypeScript
- [ ] Node.js 22.12.0 LTS installé
- [ ] TypeScript 5.7.2 installé
- [ ] npm 10.9.2 installé
- [ ] Toutes les dépendances compatibles
- [ ] Tests passent avec les nouvelles versions

### ✅ Base de Données
- [ ] PostgreSQL 17.2 installé
- [ ] Prisma 6.1.0 configuré
- [ ] Redis 7.4.1 installé
- [ ] Migrations fonctionnelles
- [ ] Seeds fonctionnels

### ✅ Services Externes
- [ ] Stripe 17.3.0 configuré
- [ ] OAuth2 providers configurés
- [ ] SMTP configuré
- [ ] Twilio configuré (optionnel)

---

## 🔄 Mise à Jour des Dépendances

### Flutter
```bash
# Mettre à jour Flutter
flutter upgrade

# Mettre à jour les dépendances
flutter pub upgrade

# Vérifier les dépendances obsolètes
flutter pub outdated

# Nettoyer et réinstaller
flutter clean
flutter pub get
```

### Node.js
```bash
# Mettre à jour npm
npm install -g npm@latest

# Mettre à jour les dépendances
npm update

# Vérifier les dépendances obsolètes
npm outdated

# Nettoyer et réinstaller
rm -rf node_modules package-lock.json
npm install
```

---

## 📚 Ressources et Documentation

### Flutter
- [Documentation Flutter](https://docs.flutter.dev/)
- [Pub.dev](https://pub.dev/)
- [Flutter Release Notes](https://docs.flutter.dev/release/archive-whats-new)

### Node.js
- [Documentation Node.js](https://nodejs.org/docs/)
- [npm Registry](https://www.npmjs.com/)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)

### Base de Données
- [Prisma Documentation](https://www.prisma.io/docs/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Redis Documentation](https://redis.io/docs/)

---

*Ce document sera mis à jour régulièrement pour refléter les dernières versions stables et les meilleures pratiques de compatibilité.*

**Dernière mise à jour** : 20 septembre 2025
**Versions documentées** : Flutter 3.35.4, Dart 3.9.2, Node.js 24.8.0, TypeScript 5.8.2
**Status** : ✅ Flutter/Node.js à jour, ⚠️ Dart mineur à jour, 🔴 TypeScript/Redis à installer
