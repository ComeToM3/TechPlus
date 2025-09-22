# API de Notification - TechPlus

## Vue d'ensemble

Le service de notification de TechPlus permet d'envoyer des emails automatiques pour les réservations, avec un système de queue robuste et des templates personnalisés.

## Configuration SMTP

### Variables d'environnement requises

```env
SMTP_HOST="smtp.gmail.com"
SMTP_PORT="587"
SMTP_SECURE="false"
SMTP_USER="your-email@gmail.com"
SMTP_PASS="your-app-password"
SMTP_FROM_NAME="TechPlus"
SMTP_FROM_EMAIL="noreply@techplus.com"
```

## Endpoints API

### 1. Vérifier la configuration SMTP

```http
GET /api/notifications/verify-smtp
Authorization: Bearer <token>
```

**Réponse :**
```json
{
  "success": true,
  "data": {
    "smtpConfigured": true,
    "message": "SMTP connection verified"
  }
}
```

### 2. Envoyer un email de test

```http
POST /api/notifications/send-test
Authorization: Bearer <token>
Content-Type: application/json

{
  "to": "test@example.com"
}
```

**Réponse :**
```json
{
  "success": true,
  "message": "Test email sent successfully",
  "data": {
    "to": "test@example.com",
    "subject": "Test Email - TechPlus Notification Service"
  }
}
```

### 3. Envoyer une notification de réservation

```http
POST /api/notifications/send-reservation
Authorization: Bearer <token>
Content-Type: application/json

{
  "reservationId": "reservation_id",
  "type": "RESERVATION_CONFIRMATION",
  "recipientEmail": "client@example.com",
  "data": {
    "reason": "Optional reason for cancellation"
  }
}
```

**Types de notification disponibles :**
- `RESERVATION_CONFIRMATION`
- `RESERVATION_REMINDER`
- `RESERVATION_CANCELLATION`
- `RESERVATION_MODIFICATION`
- `PAYMENT_CONFIRMATION`
- `PAYMENT_FAILED`
- `ADMIN_NOTIFICATION`

### 4. Envoyer un email personnalisé

```http
POST /api/notifications/send-custom
Authorization: Bearer <token>
Content-Type: application/json

{
  "to": "recipient@example.com",
  "subject": "Custom Subject",
  "htmlContent": "<h1>Custom HTML Content</h1>",
  "textContent": "Custom text content",
  "attachments": []
}
```

### 5. Récupérer l'historique des notifications

```http
GET /api/notifications/history?limit=50&offset=0&type=RESERVATION_CONFIRMATION
Authorization: Bearer <token>
```

**Paramètres de requête :**
- `limit` : Nombre de notifications à récupérer (défaut: 50)
- `offset` : Décalage pour la pagination (défaut: 0)
- `type` : Filtrer par type de notification
- `status` : Filtrer par statut (PENDING, SENT, FAILED, RETRYING)
- `recipientEmail` : Filtrer par email du destinataire
- `reservationId` : Filtrer par ID de réservation

### 6. Retry les notifications échouées

```http
POST /api/notifications/retry-failed
Authorization: Bearer <token>
```

**Réponse :**
```json
{
  "success": true,
  "message": "Retried 5 failed notifications",
  "data": {
    "retryCount": 5
  }
}
```

### 7. Obtenir les statistiques des notifications

```http
GET /api/notifications/stats?period=7d
Authorization: Bearer <token>
```

**Paramètres de requête :**
- `period` : Période d'analyse (1d, 7d, 30d)

**Réponse :**
```json
{
  "success": true,
  "data": {
    "total": 150,
    "sent": 140,
    "failed": 8,
    "pending": 2,
    "successRate": 93,
    "byType": {
      "RESERVATION_CONFIRMATION": 80,
      "RESERVATION_REMINDER": 50,
      "RESERVATION_CANCELLATION": 20
    },
    "byStatus": {
      "SENT": 140,
      "FAILED": 8,
      "PENDING": 2
    },
    "period": "7d",
    "startDate": "2025-09-15T00:00:00.000Z",
    "endDate": "2025-09-22T00:00:00.000Z"
  }
}
```

## Templates d'emails

### Template de confirmation de réservation

Le service génère automatiquement des emails HTML et texte pour :
- **Confirmation** : Détails de la réservation + lien de gestion
- **Rappel** : Notification 24h avant la réservation
- **Annulation** : Notification d'annulation avec raison
- **Modification** : Notification des changements

### Personnalisation des templates

Les templates incluent :
- Design responsive
- Couleurs du restaurant
- Informations de contact
- Lien de gestion (pour les réservations guest)
- Politique d'annulation

## Système de Queue

### Fonctionnalités

- **Queue asynchrone** : Traitement en arrière-plan
- **Retry automatique** : 3 tentatives maximum
- **Priorités** : Notifications urgentes traitées en premier
- **Programmation** : Envoi différé possible
- **Monitoring** : Statistiques en temps réel

### Configuration

- **Intervalle de traitement** : 30 secondes
- **Taille des lots** : 10 notifications par cycle
- **Délai de retry** : 1 minute (progressif)
- **Nettoyage automatique** : 30 jours de rétention

## Gestion des erreurs

### Types d'erreurs gérées

1. **Erreurs SMTP** : Connexion, authentification, envoi
2. **Erreurs de template** : Données manquantes, format invalide
3. **Erreurs de queue** : Base de données, traitement
4. **Erreurs de validation** : Paramètres manquants, formats invalides

### Logging

Toutes les erreurs sont loggées avec :
- Timestamp
- Type d'erreur
- Détails de la notification
- Stack trace (en développement)
- Tentatives de retry

## Rate Limiting

- **Notifications** : 50 requêtes par heure
- **Emails de test** : 10 par heure
- **Retry** : 5 par heure

## Sécurité

- **Authentification** : Token JWT requis
- **Validation** : Tous les paramètres validés
- **Sanitisation** : Contenu HTML nettoyé
- **Rate limiting** : Protection contre les abus
- **Logs d'audit** : Traçabilité complète

## Exemples d'utilisation

### Intégration dans les contrôleurs

```typescript
import { notificationService } from '@/services/notificationService';

// Après création d'une réservation
await notificationService.sendReservationNotification(
  NotificationType.RESERVATION_CONFIRMATION,
  reservation.id,
  reservation.clientEmail,
  {}
);

// Après annulation
await notificationService.sendReservationNotification(
  NotificationType.RESERVATION_CANCELLATION,
  reservation.id,
  reservation.clientEmail,
  { reason: 'Client request' }
);
```

### Utilisation de la queue

```typescript
import { notificationQueueService } from '@/services/notificationQueueService';

// Ajouter à la queue
await notificationQueueService.enqueueReservationNotification(
  NotificationType.RESERVATION_REMINDER,
  reservationId,
  clientEmail,
  {},
  2, // Priorité
  new Date(Date.now() + 24 * 60 * 60 * 1000) // Dans 24h
);
```

## Monitoring et maintenance

### Métriques importantes

- Taux de succès des envois
- Temps de traitement de la queue
- Nombre de retries
- Erreurs par type

### Maintenance

- Nettoyage automatique des anciennes notifications
- Retry manuel des échecs
- Vérification de la configuration SMTP
- Tests réguliers des templates

