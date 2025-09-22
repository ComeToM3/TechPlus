# Métriques et Analytics - TechPlus

## 📊 KPIs Principaux

### Taux d'Occupation
- **Définition** : Pourcentage de tables occupées par rapport au total
- **Calcul** : (Tables occupées / Tables totales) × 100
- **Objectif** : 70-80% en moyenne
- **Période** : Quotidien, hebdomadaire, mensuel

### Revenus
- **Définition** : Chiffre d'affaires généré par les réservations
- **Calcul** : Somme des montants des réservations confirmées
- **Objectif** : Croissance de 10% par mois
- **Période** : Quotidien, hebdomadaire, mensuel, annuel

### Réservations
- **Définition** : Nombre total de réservations
- **Types** : Nouvelles, confirmées, annulées, no-show
- **Objectif** : Augmentation du volume
- **Période** : Quotidien, hebdomadaire, mensuel

### Taux d'Annulation
- **Définition** : Pourcentage de réservations annulées
- **Calcul** : (Réservations annulées / Réservations totales) × 100
- **Objectif** : < 15%
- **Période** : Hebdomadaire, mensuel

### Satisfaction Client
- **Définition** : Notes et commentaires clients
- **Méthode** : Enquêtes post-réservation
- **Objectif** : > 4.5/5
- **Période** : Mensuel

## 📈 Métriques Détaillées

### Réservations
```sql
-- Réservations par jour
SELECT 
  DATE(date) as reservation_date,
  COUNT(*) as total_reservations,
  COUNT(CASE WHEN status = 'CONFIRMED' THEN 1 END) as confirmed,
  COUNT(CASE WHEN status = 'CANCELLED' THEN 1 END) as cancelled,
  COUNT(CASE WHEN status = 'NO_SHOW' THEN 1 END) as no_show
FROM reservations 
WHERE date >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY DATE(date)
ORDER BY reservation_date;
```

### Revenus
```sql
-- Revenus par période
SELECT 
  DATE_TRUNC('month', date) as month,
  SUM(estimated_amount) as total_revenue,
  SUM(deposit_amount) as deposit_revenue,
  AVG(estimated_amount) as average_revenue_per_reservation
FROM reservations 
WHERE status = 'CONFIRMED' 
  AND date >= CURRENT_DATE - INTERVAL '12 months'
GROUP BY DATE_TRUNC('month', date)
ORDER BY month;
```

### Tables
```sql
-- Utilisation des tables
SELECT 
  t.number as table_number,
  t.capacity,
  COUNT(r.id) as total_reservations,
  COUNT(CASE WHEN r.status = 'CONFIRMED' THEN 1 END) as confirmed_reservations,
  ROUND(
    COUNT(CASE WHEN r.status = 'CONFIRMED' THEN 1 END)::decimal / 
    NULLIF(COUNT(r.id), 0) * 100, 2
  ) as confirmation_rate
FROM tables t
LEFT JOIN reservations r ON t.id = r.table_id
WHERE r.date >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY t.id, t.number, t.capacity
ORDER BY t.number;
```

## 📊 Rapports Disponibles

### Quotidien
#### Réservations du Jour
- **Nouvelles réservations** : Nombre et détails
- **Confirmations** : Réservations confirmées
- **Annulations** : Réservations annulées
- **No-show** : Clients absents
- **Revenus** : Chiffre d'affaires du jour

#### Performance
- **Taux d'occupation** : Par heure
- **Tables populaires** : Tables les plus demandées
- **Heures de pointe** : Créneaux les plus occupés
- **Temps d'attente** : Moyenne des attentes

### Hebdomadaire
#### Tendances
- **Évolution** : Comparaison avec la semaine précédente
- **Jours populaires** : Répartition par jour de la semaine
- **Heures de pointe** : Créneaux les plus demandés
- **Types de réservations** : Taille des groupes

#### Analyse
- **Corrélations** : Météo, événements, promotions
- **Prédictions** : Tendances pour la semaine suivante
- **Recommandations** : Optimisations possibles

### Mensuel
#### Performance Globale
- **Bilan du mois** : Tous les KPIs
- **Objectifs** : Atteinte des cibles
- **Comparaison** : Mois précédent et année précédente
- **Croissance** : Évolution des métriques

#### Analyse Détaillée
- **Segmentation** : Par type de client, table, heure
- **Saisonnalité** : Patterns saisonniers
- **ROI** : Retour sur investissement des actions
- **Planification** : Objectifs pour le mois suivant

### Annuel
#### Bilan Annuel
- **Performance globale** : Tous les KPIs sur l'année
- **Évolution** : Croissance et tendances
- **Saisonnalité** : Patterns annuels
- **Objectifs** : Atteinte des objectifs annuels

#### Stratégie
- **Analyse SWOT** : Forces, faiblesses, opportunités, menaces
- **Benchmarking** : Comparaison avec la concurrence
- **Innovation** : Nouvelles fonctionnalités à développer
- **Planification** : Objectifs pour l'année suivante

## 📱 Dashboard Analytics

### Vue d'Ensemble
```javascript
// Métriques principales
const dashboardMetrics = {
  todayReservations: 45,
  todayRevenue: 1250.00,
  occupancyRate: 78.5,
  cancellationRate: 12.3,
  averagePartySize: 3.2,
  peakHours: ['19:00', '20:00', '21:00']
};
```

### Graphiques
#### Évolution des Réservations
```javascript
// Données pour graphique linéaire
const reservationTrend = [
  { date: '2024-01-01', reservations: 35, revenue: 875.00 },
  { date: '2024-01-02', reservations: 42, revenue: 1050.00 },
  { date: '2024-01-03', reservations: 38, revenue: 950.00 },
  // ...
];
```

#### Répartition par Heure
```javascript
// Données pour graphique en barres
const hourlyDistribution = [
  { hour: '12:00', reservations: 5, occupancy: 25 },
  { hour: '13:00', reservations: 8, occupancy: 40 },
  { hour: '19:00', reservations: 15, occupancy: 75 },
  { hour: '20:00', reservations: 18, occupancy: 90 },
  // ...
];
```

#### Top Tables
```javascript
// Données pour graphique en secteurs
const topTables = [
  { table: 'Table 5', reservations: 45, revenue: 1125.00 },
  { table: 'Table 8', reservations: 42, revenue: 1050.00 },
  { table: 'Table 12', reservations: 38, revenue: 950.00 },
  // ...
];
```

## 🔍 Analytics Avancées

### Prédictions
#### Machine Learning
- **Modèles** : Régression linéaire, Random Forest
- **Variables** : Historique, météo, événements
- **Prédictions** : Réservations, revenus, occupation
- **Précision** : 85-90% sur 7 jours

#### Exemple
```python
# Modèle de prédiction des réservations
from sklearn.ensemble import RandomForestRegressor

def predict_reservations(features):
    model = RandomForestRegressor(n_estimators=100)
    # Entraînement avec données historiques
    model.fit(X_train, y_train)
    # Prédiction
    prediction = model.predict(features)
    return prediction
```

### Segmentation
#### Clients
- **VIP** : Clients fréquents et à forte valeur
- **Occasionnels** : Clients peu fréquents
- **Nouveaux** : Première réservation
- **Fidèles** : Clients réguliers

#### Comportement
- **Heures** : Préférences horaires
- **Tables** : Tables préférées
- **Taille** : Taille de groupe habituelle
- **Saisonnalité** : Patterns saisonniers

### A/B Testing
#### Tests
- **Prix** : Impact des changements de prix
- **Interface** : Nouveaux designs
- **Promotions** : Efficacité des offres
- **Communication** : Messages et emails

#### Métriques
- **Conversion** : Taux de conversion
- **Engagement** : Temps passé sur le site
- **Satisfaction** : Notes et commentaires
- **Rétention** : Retour des clients

## 📊 Intégrations

### Google Analytics
```javascript
// Tracking des événements
gtag('event', 'reservation_created', {
  'event_category': 'reservation',
  'event_label': 'online',
  'value': reservation.estimatedAmount
});

gtag('event', 'payment_completed', {
  'event_category': 'payment',
  'event_label': 'stripe',
  'value': payment.amount
});
```

### Facebook Pixel
```javascript
// Tracking des conversions
fbq('track', 'Purchase', {
  value: reservation.estimatedAmount,
  currency: 'EUR'
});

fbq('track', 'Lead', {
  content_name: 'Reservation',
  content_category: 'Restaurant'
});
```

### Mixpanel
```javascript
// Analytics détaillées
mixpanel.track('Reservation Created', {
  'Party Size': reservation.partySize,
  'Date': reservation.date,
  'Time': reservation.time,
  'Table': reservation.table?.number,
  'Revenue': reservation.estimatedAmount
});
```

## 📈 Alertes et Notifications

### Seuils
- **Occupation** : < 50% ou > 95%
- **Annulations** : > 20%
- **Revenus** : -20% par rapport à la moyenne
- **Erreurs** : > 5% de taux d'erreur

### Notifications
```javascript
// Système d'alertes
const alerts = {
  lowOccupancy: {
    threshold: 50,
    message: 'Taux d\'occupation faible',
    action: 'Considérer des promotions'
  },
  highCancellations: {
    threshold: 20,
    message: 'Taux d\'annulation élevé',
    action: 'Vérifier la politique d\'annulation'
  },
  revenueDrop: {
    threshold: -20,
    message: 'Baisse des revenus',
    action: 'Analyser les causes'
  }
};
```

## 📋 Rapports Automatisés

### Email Quotidien
- **Résumé** : Métriques principales
- **Graphiques** : Évolution des KPIs
- **Alertes** : Points d'attention
- **Actions** : Recommandations

### Rapport Hebdomadaire
- **Analyse** : Tendances et patterns
- **Comparaison** : Semaine précédente
- **Prédictions** : Semaine suivante
- **Stratégie** : Actions recommandées

### Rapport Mensuel
- **Bilan** : Performance complète
- **Objectifs** : Atteinte des cibles
- **Planification** : Mois suivant
- **Innovation** : Nouvelles idées
