# Flux de Navigation - Frontend Public

## 🏠 Navigation Principale

```
Home (Vitrine)
├── Menu
│   ├── Catégories
│   └── Détails plat
├── À propos
├── Contact
├── Réserver
│   ├── Sélection date/heure
│   ├── Nombre de personnes
│   ├── Informations client
│   ├── Paiement (si 6+ personnes)
│   │   ├── Montant minimum (10$)
│   │   ├── Affichage politique annulation
│   │   ├── Interface Stripe
│   │   └── Confirmation paiement
│   ├── Confirmation
│   └── Succès
└── Gérer Réservation (Guest)
    ├── Saisie token/email
    ├── Vérification
    ├── Actions disponibles
    │   ├── Modifier
    │   ├── Annuler
    │   └── Voir détails
    └── Confirmation action
```

## 📱 Pages Détaillées

### Home (Vitrine)
- **Hero Section** : Image du restaurant, CTA "Réserver"
- **À propos** : Présentation du restaurant
- **Menu** : Aperçu des plats populaires
- **Témoignages** : Avis clients
- **Contact** : Informations de contact

### Menu
- **Catégories** : Entrées, Plats, Desserts, Boissons
- **Filtres** : Végétarien, Sans gluten, Allergènes
- **Détails plat** : Description, prix, allergènes, image
- **Recherche** : Par nom ou ingrédient

### Réservation
#### Étape 1 : Sélection
- **Calendrier** : Sélection de la date
- **Créneaux** : Heures disponibles
- **Nombre de personnes** : Sélecteur 1-20

#### Étape 2 : Informations
- **Nom** : Obligatoire
- **Email** : Obligatoire
- **Téléphone** : Optionnel
- **Demandes spéciales** : Zone de texte

#### Étape 3 : Paiement (si requis)
- **Montant fixe** : 10$ d'acompte
- **Politique** : Affichage des conditions d'annulation
- **Stripe** : Interface de paiement sécurisée

#### Étape 4 : Confirmation
- **Récapitulatif** : Détails de la réservation
- **Token** : Code de gestion pour les guests
- **Email** : Confirmation envoyée

### Gestion Guest
#### Accès
- **Token** : Code de réservation
- **Email** : Adresse de confirmation
- **Vérification** : Validation des informations

#### Actions Disponibles
- **Modifier** : Date, heure, nombre de personnes
- **Annuler** : Avec confirmation
- **Détails** : Informations complètes

## 🔄 États de Navigation

### Authentifié
- **Profil** : Accès au compte
- **Historique** : Réservations passées
- **Préférences** : Informations sauvegardées

### Guest
- **Token** : Gestion par code
- **Email** : Confirmation par email
- **Limité** : Actions de base uniquement

## 📲 Responsive

### Mobile
- **Menu hamburger** : Navigation principale
- **Calendrier simplifié** : Sélection de date
- **Formulaires adaptés** : Champs tactiles
- **Paiement optimisé** : Interface mobile Stripe

### Desktop
- **Navigation horizontale** : Menu complet
- **Calendrier complet** : Vue mensuelle
- **Formulaires étendus** : Plus d'informations
- **Paiement standard** : Interface complète
