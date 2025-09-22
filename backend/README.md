# TechPlus Backend API

API backend pour le système de réservation de restaurant TechPlus.

## 🚀 Démarrage Rapide

### Prérequis

- Node.js >= 18.0.0
- npm >= 8.0.0
- PostgreSQL >= 13
- Redis >= 6.0

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

3. **Démarrer en mode développement**
   ```bash
   npm run dev
   ```

4. **Build pour la production**
   ```bash
   npm run build
   npm start
   ```

## 📋 Scripts Disponibles

- `npm run dev` - Démarre le serveur en mode développement avec hot-reload
- `npm run build` - Compile TypeScript vers JavaScript
- `npm start` - Démarre le serveur en production
- `npm run lint` - Vérifie le code avec ESLint
- `npm run lint:fix` - Corrige automatiquement les erreurs ESLint
- `npm run format` - Formate le code avec Prettier
- `npm run test` - Lance les tests
- `npm run test:watch` - Lance les tests en mode watch
- `npm run test:coverage` - Lance les tests avec rapport de couverture

## 🏗️ Architecture

```
src/
├── config/          # Configuration de l'application
├── controllers/     # Contrôleurs des routes
├── middleware/      # Middlewares Express
├── models/          # Modèles de données
├── routes/          # Définition des routes
├── services/        # Logique métier
├── utils/           # Utilitaires
├── types/           # Types TypeScript
└── index.ts         # Point d'entrée de l'application
```

## 🔧 Configuration

### Variables d'Environnement

Voir le fichier `.env.example` pour la liste complète des variables d'environnement.

### Base de Données

L'application utilise PostgreSQL avec Prisma ORM.

### Cache

Redis est utilisé pour le cache et les sessions.

## 🧪 Tests

```bash
# Tests unitaires
npm run test

# Tests avec couverture
npm run test:coverage

# Tests en mode watch
npm run test:watch
```

## 📊 Monitoring

- Health check: `GET /health`
- Métriques: `GET /metrics`

## 🔒 Sécurité

- Helmet.js pour les headers de sécurité
- Rate limiting
- CORS configuré
- Validation des entrées
- Protection XSS/CSRF

## 📝 Documentation API

La documentation de l'API sera disponible à l'adresse `/api/docs` une fois Swagger configuré.

## 🤝 Contribution

1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/AmazingFeature`)
3. Commit les changements (`git commit -m 'Add some AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

