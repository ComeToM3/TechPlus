# API Endpoints - TechPlus

## 🔌 Endpoints Principaux

### Réservations

#### CRUD Standard
```
GET    /api/reservations              # Liste des réservations
POST   /api/reservations              # Créer une réservation
GET    /api/reservations/:id          # Détails d'une réservation
PUT    /api/reservations/:id          # Modifier une réservation
DELETE /api/reservations/:id          # Annuler une réservation
```

#### Gestion par Token (Guest)
```
GET    /api/reservations/manage/:token # Accéder avec token
PUT    /api/reservations/manage/:token # Modifier avec token
DELETE /api/reservations/manage/:token # Annuler avec token
```

#### Administration
```
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

### Authentification
```
POST   /api/auth/login                # Connexion
POST   /api/auth/register             # Inscription
POST   /api/auth/logout               # Déconnexion
POST   /api/auth/refresh              # Rafraîchir token
GET    /api/auth/me                   # Profil utilisateur
```

### OAuth2
```
GET    /api/auth/google               # Connexion Google
GET    /api/auth/facebook             # Connexion Facebook
POST   /api/auth/oauth/callback       # Callback OAuth
```

### Menu
```
GET    /api/menu                      # Liste du menu
GET    /api/menu/categories           # Catégories du menu
GET    /api/menu/:id                  # Détails d'un plat
POST   /api/admin/menu                # Créer un plat (admin)
PUT    /api/admin/menu/:id            # Modifier un plat (admin)
DELETE /api/admin/menu/:id            # Supprimer un plat (admin)
```

### Tables
```
GET    /api/tables                    # Liste des tables
GET    /api/tables/:id                # Détails d'une table
POST   /api/admin/tables              # Créer une table (admin)
PUT    /api/admin/tables/:id          # Modifier une table (admin)
DELETE /api/admin/tables/:id          # Supprimer une table (admin)
```

### Analytics
```
GET    /api/admin/analytics           # Statistiques générales
GET    /api/admin/analytics/revenue   # Revenus
GET    /api/admin/analytics/occupancy # Taux d'occupation
GET    /api/admin/analytics/reports   # Rapports détaillés
```

## 📝 Formats de Réponse

### Succès
```json
{
  "success": true,
  "data": { ... },
  "message": "Opération réussie"
}
```

### Erreur
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Données invalides",
    "details": { ... }
  }
}
```

## 🔐 Authentification

### Headers Requis
```
Authorization: Bearer <jwt_token>
Content-Type: application/json
```

### Codes de Statut
- **200** : Succès
- **201** : Créé
- **400** : Erreur de validation
- **401** : Non authentifié
- **403** : Non autorisé
- **404** : Non trouvé
- **429** : Rate limit dépassé
- **500** : Erreur serveur
