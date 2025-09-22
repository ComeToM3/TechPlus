# Architecture Backend - TechPlus

## 📁 Structure des Dossiers

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

## 🏗️ Architecture MVC

### Controllers
- Gestion des requêtes HTTP
- Validation des données d'entrée
- Orchestration des services
- Retour des réponses formatées

### Services
- Logique métier
- Interactions avec la base de données
- Intégrations externes (email, SMS, paiements)
- Calculs et transformations

### Models
- Définition des entités TypeScript
- Validation des schémas
- Types pour les réponses API

### Middleware
- Authentification JWT
- Validation des données
- Gestion des erreurs
- Rate limiting

### Routes
- Définition des endpoints
- Association controllers
- Middleware spécifiques
- Documentation API

## 🔧 Technologies

- **Node.js** + **Express.js**
- **TypeScript** pour le typage
- **Prisma** ORM
- **PostgreSQL** base de données
- **Redis** pour le cache
- **JWT** pour l'authentification
- **Stripe** pour les paiements
- **Nodemailer** pour les emails
