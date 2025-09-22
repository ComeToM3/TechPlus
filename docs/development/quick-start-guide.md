# Guide de Démarrage Rapide - TechPlus

## 🚀 Installation et Configuration

### Prérequis
- **Flutter** : `3.35.4`
- **Dart** : `3.9.2`
- **Node.js** : `24.8.0`
- **TypeScript** : `5.8.2`
- **PostgreSQL** : `17.6`
- **Redis** : `7.4.1`

### 1. Installation des Outils

#### Flutter & Dart
```bash
# Vérifier la version
flutter --version
dart --version

# Mettre à jour si nécessaire
flutter upgrade
```

#### Node.js & TypeScript
```bash
# Vérifier la version
node --version
npm --version

# Installer TypeScript globalement
npm install -g typescript@latest

# Vérifier TypeScript
tsc --version
```

#### PostgreSQL
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install postgresql postgresql-contrib

# Vérifier l'installation
psql --version

# Démarrer le service
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

#### Redis
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install redis-server

# Vérifier l'installation
redis-server --version

# Démarrer le service
sudo systemctl start redis-server
sudo systemctl enable redis-server
```

### 2. Configuration de la Base de Données

#### PostgreSQL
```bash
# Se connecter à PostgreSQL
sudo -u postgres psql

# Créer la base de données
CREATE DATABASE techplus;
CREATE USER techplus_user WITH PASSWORD 'your_password';
GRANT ALL PRIVILEGES ON DATABASE techplus TO techplus_user;
\q
```

#### Variables d'Environnement
```bash
# Créer le fichier .env
cp .env.example .env

# Éditer les variables
nano .env
```

```env
# Database
DATABASE_URL="postgresql://techplus_user:your_password@localhost:5432/techplus"

# Redis
REDIS_URL="redis://localhost:6379"

# JWT
JWT_SECRET="your-super-secret-jwt-key"
JWT_EXPIRES_IN="7d"

# OAuth (optionnel pour le développement)
GOOGLE_CLIENT_ID="your-google-client-id"
GOOGLE_CLIENT_SECRET="your-google-client-secret"

# Email (optionnel pour le développement)
SMTP_HOST="smtp.gmail.com"
SMTP_PORT="587"
SMTP_USER="your-email@gmail.com"
SMTP_PASS="your-app-password"

# Stripe (optionnel pour le développement)
STRIPE_SECRET_KEY="sk_test_..."
STRIPE_PUBLISHABLE_KEY="pk_test_..."
```

### 3. Setup du Backend

```bash
# Aller dans le dossier backend
cd backend

# Installer les dépendances
npm install

# Générer le client Prisma
npx prisma generate

# Exécuter les migrations
npx prisma migrate dev

# (Optionnel) Seeder la base de données
npx prisma db seed

# Démarrer le serveur de développement
npm run dev
```

### 4. Setup du Frontend

```bash
# Aller dans le dossier frontend
cd frontend

# Installer les dépendances
flutter pub get

# Générer les fichiers de code
flutter packages pub run build_runner build

# Démarrer l'application
flutter run
```

## 🧪 Tests

### Backend
```bash
cd backend

# Tests unitaires
npm test

# Tests avec couverture
npm run test:coverage

# Tests d'intégration
npm run test:integration
```

### Frontend
```bash
cd frontend

# Tests unitaires
flutter test

# Tests d'intégration
flutter test integration_test/
```

## 🔧 Développement

### Structure des Projets

#### Backend (Node.js)
```
backend/
├── src/
│   ├── controllers/     # Contrôleurs API
│   ├── services/        # Logique métier
│   ├── models/          # Modèles TypeScript
│   ├── middleware/      # Middlewares Express
│   ├── routes/          # Routes API
│   ├── utils/           # Utilitaires
│   └── types/           # Types TypeScript
├── prisma/              # Schémas et migrations
├── tests/               # Tests
└── package.json
```

#### Frontend (Flutter)
```
frontend/
├── lib/
│   ├── core/            # Configuration, constants, utils
│   ├── features/        # Fonctionnalités métier
│   │   ├── auth/        # Authentification
│   │   ├── reservation/ # Réservations
│   │   ├── menu/        # Menu restaurant
│   │   └── admin/       # Interface admin
│   ├── shared/          # Composants partagés
│   └── main.dart
├── assets/              # Images, traductions
└── pubspec.yaml
```

### Commandes Utiles

#### Backend
```bash
# Développement avec hot reload
npm run dev

# Build de production
npm run build

# Linting
npm run lint

# Formatage du code
npm run format

# Migration de base de données
npx prisma migrate dev

# Reset de la base de données
npx prisma migrate reset

# Studio Prisma (interface graphique)
npx prisma studio
```

#### Frontend
```bash
# Développement avec hot reload
flutter run

# Build pour production
flutter build web
flutter build apk
flutter build ios

# Analyse du code
flutter analyze

# Formatage du code
dart format .

# Génération de code
flutter packages pub run build_runner build --delete-conflicting-outputs

# Tests
flutter test

# Nettoyage
flutter clean
flutter pub get
```

## 🐛 Dépannage

### Problèmes Courants

#### Base de Données
```bash
# Erreur de connexion PostgreSQL
sudo systemctl status postgresql
sudo systemctl restart postgresql

# Erreur de migration Prisma
npx prisma migrate reset
npx prisma migrate dev
```

#### Redis
```bash
# Erreur de connexion Redis
sudo systemctl status redis-server
sudo systemctl restart redis-server

# Tester la connexion
redis-cli ping
```

#### Flutter
```bash
# Erreurs de dépendances
flutter clean
flutter pub get

# Erreurs de build
flutter pub deps
flutter pub upgrade
```

#### Node.js
```bash
# Erreurs de dépendances
rm -rf node_modules package-lock.json
npm install

# Erreurs TypeScript
npx tsc --noEmit
```

## 📚 Ressources

### Documentation
- [Flutter Documentation](https://docs.flutter.dev/)
- [Node.js Documentation](https://nodejs.org/docs/)
- [Prisma Documentation](https://www.prisma.io/docs/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)

### Outils de Développement
- [VS Code](https://code.visualstudio.com/)
- [Android Studio](https://developer.android.com/studio)
- [Postman](https://www.postman.com/) (pour tester les APIs)
- [Prisma Studio](https://www.prisma.io/studio) (interface graphique pour la base de données)

### Extensions VS Code Recommandées
- Flutter
- Dart
- TypeScript
- Prisma
- PostgreSQL
- GitLens
- Prettier
- ESLint

---

*Ce guide sera mis à jour au fur et à mesure de l'évolution du projet.*
