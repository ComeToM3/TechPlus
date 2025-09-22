# Flux de Navigation - Frontend Admin

## 🔐 Authentification Admin

```
Login
└── Dashboard
    ├── Réservations
    ├── Tables
    ├── Menu
    ├── Analytics
    └── Paramètres
```

## 📊 Dashboard Principal

### Vue d'ensemble
- **Réservations du jour** : Nombre et statuts
- **Taux d'occupation** : Pourcentage de tables occupées
- **Revenus** : Chiffre d'affaires du jour
- **Alertes** : Réservations en attente, annulations

### Widgets
- **Graphique réservations** : Évolution sur 7 jours
- **Top tables** : Tables les plus demandées
- **Heures de pointe** : Créneaux populaires
- **Revenus** : Évolution des revenus

## 📅 Gestion des Réservations

### Calendrier
#### Vue Mensuelle
- **Grille complète** : Tous les jours du mois
- **Indicateurs** : Nombre de réservations par jour
- **Couleurs** : Statuts (confirmé, en attente, annulé)
- **Navigation** : Mois précédent/suivant

#### Vue Hebdomadaire
- **Planning détaillé** : Créneaux horaires
- **Tables** : Colonnes par table
- **Réservations** : Blocs colorés par statut
- **Drag & Drop** : Déplacement des réservations

#### Vue Quotidienne
- **Timeline** : Créneaux de 30 minutes
- **Détails** : Informations complètes
- **Actions rapides** : Confirmer, annuler, modifier

### Liste des Réservations
#### Filtres
- **Date** : Période sélectionnée
- **Statut** : Pending, Confirmed, Cancelled
- **Table** : Table spécifique
- **Client** : Nom ou email

#### Recherche
- **Nom client** : Recherche textuelle
- **Email** : Recherche par email
- **Téléphone** : Recherche par numéro
- **Token** : Recherche par code de gestion

#### Actions en Lot
- **Sélection multiple** : Checkbox pour chaque réservation
- **Confirmer** : Confirmer plusieurs réservations
- **Annuler** : Annuler avec motif
- **Exporter** : Export CSV/PDF

### Détails de Réservation
#### Informations Client
- **Profil complet** : Nom, email, téléphone
- **Historique** : Réservations précédentes
- **Préférences** : Table préférée, notes

#### Historique Modifications
- **Timeline** : Chronologie des changements
- **Utilisateur** : Qui a fait la modification
- **Champ modifié** : Ce qui a changé
- **Timestamp** : Date et heure

#### Notes Internes
- **Notes admin** : Commentaires internes
- **Raison annulation** : Motif si annulé
- **Demandes spéciales** : Besoins particuliers

### Nouvelle Réservation
#### Sélection Client
- **Recherche** : Client existant
- **Création** : Nouveau client
- **Import** : Depuis un autre système

#### Créneaux Disponibles
- **Date** : Sélection du jour
- **Heure** : Créneaux libres
- **Table** : Tables disponibles
- **Durée** : Temps de réservation

#### Validation
- **Vérification** : Conflits potentiels
- **Confirmation** : Validation finale
- **Notification** : Email au client

## 🪑 Gestion des Tables

### Configuration
#### Création/Modification
- **Numéro** : Identifiant unique
- **Capacité** : Nombre de personnes
- **Position** : Emplacement dans le restaurant
- **Statut** : Active/Inactive

#### Plan du Restaurant
- **Vue schématique** : Disposition des tables
- **Drag & Drop** : Repositionnement
- **Zones** : Secteurs du restaurant

### Disponibilités
#### Planning
- **Vue temps réel** : État actuel
- **Réservations** : Occupations futures
- **Maintenance** : Tables en réparation

## 🍽️ Gestion du Menu

### Articles
#### CRUD
- **Création** : Nouvel article
- **Modification** : Édition existante
- **Suppression** : Retrait du menu
- **Duplication** : Copie d'un article

#### Détails
- **Nom** : Titre de l'article
- **Description** : Détails du plat
- **Prix** : Tarif
- **Catégorie** : Type d'article
- **Allergènes** : Liste des allergènes

### Images
#### Upload
- **Drag & Drop** : Interface intuitive
- **Redimensionnement** : Automatique
- **Optimisation** : Compression
- **CDN** : Distribution rapide

## 📈 Analytics

### Statistiques
#### KPIs
- **Taux d'occupation** : Pourcentage
- **Revenus** : Chiffre d'affaires
- **Réservations** : Nombre total
- **Annulations** : Taux d'annulation

#### Graphiques
- **Évolution** : Courbes temporelles
- **Comparaisons** : Périodes
- **Prédictions** : Tendances futures

### Rapports
#### Quotidien
- **Réservations du jour** : Détail
- **Revenus** : Chiffre d'affaires
- **Tables** : Utilisation

#### Hebdomadaire
- **Tendances** : Évolution sur 7 jours
- **Comparaison** : Semaine précédente
- **Recommandations** : Optimisations

#### Mensuel
- **Performance** : Bilan du mois
- **Objectifs** : Atteinte des cibles
- **Planification** : Mois suivant

## ⚙️ Paramètres

### Restaurant
#### Informations
- **Nom** : Nom du restaurant
- **Adresse** : Localisation
- **Contact** : Téléphone, email
- **Horaires** : Ouverture/fermeture

#### Configuration
- **Paiements** : Seuils et pourcentages
- **Politique** : Annulation
- **Notifications** : Paramètres email/SMS

### Utilisateurs
#### Gestion
- **Création** : Nouveaux admins
- **Permissions** : Rôles et droits
- **Suppression** : Retrait d'accès

### Notifications
#### Configuration
- **Email** : Paramètres SMTP
- **SMS** : Configuration Twilio
- **Templates** : Modèles de messages
