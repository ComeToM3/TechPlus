# Configuration de l'API Backend

## 📋 Vue d'ensemble

Ce document explique comment configurer l'URL de l'API backend pour l'application TechPlus.

## 🔧 Configuration

### 1. Configuration par défaut

L'application est configurée par défaut pour utiliser l'API backend local :

```dart
// lib/core/config/environment_config.dart
static String get baseUrl {
  switch (environment) {
    case 'development':
    default:
      return 'http://localhost:3000';  // Backend local
  }
}
```

### 2. Environnements supportés

#### **Development (développement)**
- **URL** : `http://localhost:3000`
- **Timeout** : 10s connexion, 30s réception/envoi
- **Headers** : Content-Type + X-Debug-Mode

#### **Staging (test)**
- **URL** : `https://staging-api.techplus.com`
- **Timeout** : 8s connexion, 20s réception/envoi
- **Headers** : Content-Type standard

#### **Production (production)**
- **URL** : `https://api.techplus.com`
- **Timeout** : 5s connexion, 15s réception/envoi
- **Headers** : Content-Type standard

### 3. Comment changer l'environnement

#### **Option 1 : Variable d'environnement**
```bash
# Développement (par défaut)
flutter run

# Staging
flutter run --dart-define=ENV=staging

# Production
flutter run --dart-define=ENV=production
```

#### **Option 2 : Modification du code**
```dart
// lib/core/config/environment_config.dart
static const String environment = 'staging'; // ou 'production'
```

### 4. Configuration personnalisée

Pour utiliser une URL personnalisée, modifiez le fichier `environment_config.dart` :

```dart
static String get baseUrl {
  switch (environment) {
    case 'custom':
      return 'https://your-custom-api.com';
    // ... autres environnements
  }
}
```

## 🚀 Démarrage du Backend

### 1. Prérequis
- Node.js 18+
- PostgreSQL 17+
- Redis (optionnel)

### 2. Installation
```bash
cd backend
npm install
```

### 3. Configuration
```bash
# Copier le fichier d'environnement
cp .env.example .env

# Configurer les variables
DATABASE_URL="postgresql://user:password@localhost:5432/techplus"
JWT_SECRET="your-secret-key"
```

### 4. Démarrage
```bash
# Développement
npm run dev

# Production
npm start
```

Le backend sera disponible sur `http://localhost:3000`

## 🔍 Vérification

### 1. Vérifier la configuration
L'application vérifie automatiquement si l'API est configurée :

```dart
if (!ApiConfig.isConfigured) {
  throw Exception('API backend non configurée. Veuillez configurer ApiConfig.baseUrl');
}
```

### 2. Tester la connexion
```bash
# Tester l'API backend
curl http://localhost:3000/api/health

# Réponse attendue
{"status": "ok", "timestamp": "2025-01-27T10:30:00Z"}
```

## 📝 Endpoints disponibles

### **Authentification**
- `POST /api/auth/login` - Connexion
- `POST /api/auth/register` - Inscription
- `POST /api/auth/token` - Connexion avec token
- `POST /api/auth/logout` - Déconnexion
- `POST /api/auth/refresh` - Rafraîchir le token

### **Réservations**
- `GET /api/reservations` - Liste des réservations
- `POST /api/reservations` - Créer une réservation
- `GET /api/reservations/:id` - Détails d'une réservation
- `PUT /api/reservations/:id` - Modifier une réservation
- `DELETE /api/reservations/:id` - Annuler une réservation

### **Gestion Guest**
- `GET /api/reservations/manage/:token` - Accéder avec token
- `PUT /api/reservations/manage/:token` - Modifier avec token
- `DELETE /api/reservations/manage/:token` - Annuler avec token

### **Disponibilités**
- `GET /api/availability` - Créneaux disponibles
- `GET /api/availability/:date` - Disponibilités pour une date
- `GET /api/tables/available` - Tables disponibles

### **Paiements**
- `POST /api/payments/create-intent` - Créer PaymentIntent Stripe
- `POST /api/payments/confirm` - Confirmer le paiement
- `POST /api/payments/refund` - Remboursement

## 🛠️ Dépannage

### **Erreur : "API backend non configurée"**
1. Vérifiez que l'URL est configurée dans `environment_config.dart`
2. Vérifiez que `ApiConfig.isConfigured` retourne `true`
3. Redémarrez l'application

### **Erreur : "Connection refused"**
1. Vérifiez que le backend est démarré sur le port 3000
2. Vérifiez l'URL dans la configuration
3. Vérifiez les paramètres de firewall

### **Erreur : "Timeout"**
1. Vérifiez les timeouts dans `environment_config.dart`
2. Vérifiez la performance du backend
3. Vérifiez la connexion réseau

## 📚 Ressources

- [Documentation API Backend](../backend/README.md)
- [Configuration OAuth](OAUTH_SETUP.md)
- [Guide de déploiement](../docs/deployment/README.md)
