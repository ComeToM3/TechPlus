# Configuration API Backend pour TechPlus

## Vue d'ensemble

Ce document explique comment configurer les APIs backend pour remplacer toutes les simulations dans TechPlus.

## Configuration requise

### 1. URL de l'API Backend

Mettre à jour le fichier `lib/core/config/api_config.dart` :

```dart
class ApiConfig {
  // URL de base de l'API backend
  static const String baseUrl = 'https://your-backend-url.com'; // À configurer
}
```

### 2. Configuration OAuth

Mettre à jour le fichier `lib/core/config/oauth_config.dart` :

```dart
class OAuthConfig {
  // Configuration Google OAuth
  static const String googleClientId = 'YOUR_GOOGLE_CLIENT_ID';
  static const String googleServerClientId = 'YOUR_GOOGLE_SERVER_CLIENT_ID';
  
  // Configuration Facebook OAuth
  static const String facebookAppId = 'YOUR_FACEBOOK_APP_ID';
  static const String facebookClientToken = 'YOUR_FACEBOOK_CLIENT_TOKEN';
  
  // Configuration Apple OAuth
  static const String appleServiceId = 'YOUR_APPLE_SERVICE_ID';
  static const String appleTeamId = 'YOUR_APPLE_TEAM_ID';
  static const String appleKeyId = 'YOUR_APPLE_KEY_ID';
  static const String applePrivateKey = 'YOUR_APPLE_PRIVATE_KEY';
}
```

## APIs Backend Requises

### 1. Authentification

#### POST /api/auth/login
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Réponse :**
```json
{
  "user": {
    "id": "user_id",
    "email": "user@example.com",
    "name": "User Name",
    "role": "CLIENT",
    "avatar": "https://avatar-url.com"
  },
  "tokens": {
    "accessToken": "jwt_access_token",
    "refreshToken": "jwt_refresh_token"
  }
}
```

#### POST /api/auth/register
```json
{
  "email": "user@example.com",
  "password": "password123",
  "name": "User Name",
  "phone": "+33123456789"
}
```

#### POST /api/auth/token
```json
{
  "token": "guest_management_token"
}
```

#### POST /api/auth/refresh
```json
{
  "refreshToken": "jwt_refresh_token"
}
```

#### POST /api/auth/logout
```json
{}
```

### 2. Réservations

#### GET /api/reservations
**Paramètres de requête :**
- `userId` (optionnel) : ID de l'utilisateur
- `status` (optionnel) : Statut de la réservation
- `startDate` (optionnel) : Date de début
- `endDate` (optionnel) : Date de fin

**Réponse :**
```json
{
  "reservations": [
    {
      "id": "reservation_id",
      "date": "2025-01-15T19:00:00Z",
      "time": "19:00",
      "duration": 90,
      "partySize": 4,
      "status": "CONFIRMED",
      "clientName": "Jean Dupont",
      "clientEmail": "jean@example.com",
      "clientPhone": "+33123456789",
      "specialRequests": "Table près de la fenêtre",
      "requiresPayment": false,
      "depositAmount": 0.0,
      "paymentStatus": "NONE",
      "restaurantId": "restaurant_1"
    }
  ]
}
```

#### POST /api/reservations
```json
{
  "date": "2025-01-15T19:00:00Z",
  "time": "19:00",
  "duration": 90,
  "partySize": 4,
  "clientName": "Jean Dupont",
  "clientEmail": "jean@example.com",
  "clientPhone": "+33123456789",
  "specialRequests": "Table près de la fenêtre",
  "restaurantId": "restaurant_1"
}
```

#### PUT /api/reservations/:id
```json
{
  "date": "2025-01-15T20:00:00Z",
  "time": "20:00",
  "partySize": 6,
  "specialRequests": "Anniversaire"
}
```

#### DELETE /api/reservations/:id
```json
{
  "reason": "Changement de plans"
}
```

### 3. Gestion des Guests

#### GET /api/reservations/manage/:token
**Réponse :**
```json
{
  "id": "reservation_id",
  "date": "2025-01-15T19:00:00Z",
  "time": "19:00",
  "duration": 90,
  "partySize": 4,
  "status": "CONFIRMED",
  "clientName": "Jean Dupont",
  "clientEmail": "jean@example.com",
  "clientPhone": "+33123456789",
  "specialRequests": "Table près de la fenêtre",
  "requiresPayment": false,
  "depositAmount": 0.0,
  "paymentStatus": "NONE",
  "restaurantId": "restaurant_1"
}
```

#### PUT /api/reservations/manage/:token
```json
{
  "date": "2025-01-15T20:00:00Z",
  "time": "20:00",
  "partySize": 6,
  "specialRequests": "Anniversaire"
}
```

#### DELETE /api/reservations/manage/:token
```json
{
  "reason": "Changement de plans"
}
```

### 4. Disponibilités

#### GET /api/availability
**Paramètres de requête :**
- `date` : Date au format ISO (YYYY-MM-DD)
- `partySize` : Nombre de personnes

**Réponse :**
```json
{
  "timeSlots": [
    "18:00",
    "18:30",
    "19:00",
    "19:30",
    "20:00",
    "20:30",
    "21:00"
  ]
}
```

### 5. Paiements

#### POST /api/payments/create-intent
```json
{
  "amount": 1000,
  "currency": "eur",
  "reservationId": "reservation_id"
}
```

**Réponse :**
```json
{
  "clientSecret": "pi_xxx_secret_xxx",
  "paymentIntentId": "pi_xxx"
}
```

#### POST /api/payments/confirm
```json
{
  "paymentIntentId": "pi_xxx"
}
```

**Réponse :**
```json
{
  "success": true,
  "error": null
}
```

## Gestion des Erreurs

### Codes d'erreur HTTP

- **400** : Bad Request - Données invalides
- **401** : Unauthorized - Token manquant ou invalide
- **403** : Forbidden - Accès interdit
- **404** : Not Found - Ressource non trouvée
- **409** : Conflict - Conflit (ex: créneau déjà pris)
- **422** : Unprocessable Entity - Validation échouée
- **500** : Internal Server Error - Erreur serveur

### Format des erreurs

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Les données fournies sont invalides",
    "details": {
      "field": "email",
      "reason": "Format d'email invalide"
    }
  }
}
```

## Sécurité

### Authentification

- **JWT Tokens** : Pour l'authentification des utilisateurs
- **Guest Tokens** : Pour la gestion des réservations sans compte
- **Refresh Tokens** : Pour le renouvellement automatique des sessions

### Headers requis

```http
Authorization: Bearer <access_token>
Content-Type: application/json
Accept: application/json
```

### Rate Limiting

- **API générale** : 100 requêtes/15 minutes
- **Authentification** : 5 requêtes/15 minutes
- **Paiements** : 10 requêtes/15 minutes

## Tests

### Tests de connectivité

```bash
# Vérifier que l'API est accessible
curl -X GET https://your-backend-url.com/health

# Tester l'authentification
curl -X POST https://your-backend-url.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'
```

### Tests des endpoints

```bash
# Tester les réservations
curl -X GET https://your-backend-url.com/api/reservations \
  -H "Authorization: Bearer <token>"

# Tester les disponibilités
curl -X GET "https://your-backend-url.com/api/availability?date=2025-01-15&partySize=4"
```

## Déploiement

### Variables d'environnement

```env
# Backend
API_BASE_URL=https://your-backend-url.com
API_TIMEOUT=30000

# OAuth
GOOGLE_CLIENT_ID=your_google_client_id
FACEBOOK_APP_ID=your_facebook_app_id
APPLE_SERVICE_ID=your_apple_service_id
```

### Configuration de production

1. **HTTPS obligatoire** : Toutes les communications doivent être chiffrées
2. **CORS configuré** : Autoriser uniquement les domaines de production
3. **Rate limiting** : Limiter les requêtes par IP
4. **Monitoring** : Surveiller les performances et erreurs

## Support

Pour toute question ou problème :

1. Vérifier la configuration de l'API
2. Consulter les logs de débogage
3. Tester les endpoints individuellement
4. Vérifier les certificats SSL
5. Contacter l'équipe backend
