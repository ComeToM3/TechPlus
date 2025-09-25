# Modèle de Données - TechPlus

## 🗄️ Vue d'ensemble

Le modèle de données utilise **PostgreSQL** avec **Prisma ORM** pour une gestion type-safe et performante.

## 📊 Entités Principales

### User
- Gestion des utilisateurs (clients, admins)
- Support OAuth2 (Google, Facebook)
- Rôles et permissions

### Restaurant
- Informations du restaurant
- Configuration des paiements
- Paramètres de gestion
- Heures d'ouverture (configuration flexible)
- Buffer time (temps de nettoyage entre réservations)

### Table
- Gestion des tables
- Capacité et position
- Statut actif/inactif

### Reservation
- Réservations sans compte
- Gestion des paiements
- Tokens de gestion pour les guests
- Notes internes admin
- Durée automatique :
  - 1h30 pour 1-4 personnes
  - 2h00 pour 5+ personnes

### MenuItem
- Articles du menu
- Catégories et allergènes
- Disponibilité

### Analytics
- Métriques de performance
- Statistiques d'occupation
- Revenus

## 🔗 Relations

- **User** ↔ **Reservation** (1:N)
- **Restaurant** ↔ **Table** (1:N)
- **Restaurant** ↔ **Reservation** (1:N)
- **Restaurant** ↔ **MenuItem** (1:N)
- **Table** ↔ **Reservation** (1:N)
- **User** ↔ **OAuthAccount** (1:N)

## 💳 Système de Paiement

### Configuration
- Seuil de paiement : 6+ personnes
- Montant minimum : 10$
- Politique d'annulation : 24h

### Statuts de Paiement
- **NONE** : Pas de paiement requis
- **PENDING** : Paiement en attente
- **COMPLETED** : Paiement validé
- **FAILED** : Échec du paiement
- **REFUNDED** : Remboursement complet
- **PARTIALLY_REFUNDED** : Remboursement partiel

## 🔐 Sécurité

- **CUID** pour les IDs (non-séquentiels)
- **Cascade delete** pour l'intégrité
- **Unique constraints** pour éviter les doublons
- **Timestamps** automatiques
