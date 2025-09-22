# Documentation TechPlus

## 📚 Vue d'Ensemble

Cette documentation technique couvre tous les aspects du développement de TechPlus V1, un système de réservation de restaurant moderne avec interface publique et administration.

## 📁 Structure de la Documentation

### 🏗️ Architecture
- **[Architecture Flutter](architecture/flutter-architecture.md)** - Structure et organisation du frontend mobile
- **[Architecture Backend](architecture/backend-architecture.md)** - Structure et organisation du backend Node.js

### 🗄️ Base de Données
- **[Schéma Prisma](database/schema.prisma)** - Modèle de données complet
- **[Vue d'ensemble Base de Données](database/database-overview.md)** - Explication des entités et relations

### 🔌 API
- **[Endpoints API](api/endpoints.md)** - Documentation complète des endpoints REST

### 🧭 Navigation
- **[Flux Public](navigation/public-flow.md)** - Parcours utilisateur pour les clients
- **[Flux Admin](navigation/admin-flow.md)** - Interface d'administration

### 🔐 Sécurité et Performance
- **[Sécurité et Performance](security/security-performance.md)** - Mesures de sécurité et optimisations

### 🎨 Design
- **[Design Responsive](design/responsive-design.md)** - Adaptation multi-devices

### 🌍 Internationalisation
- **[Internationalisation](i18n/internationalization.md)** - Support multi-langues
- **[Traductions FR](assets/translations/fr.json)** - Fichier de traduction français
- **[Traductions EN](assets/translations/en.json)** - Fichier de traduction anglais

### 🚀 Déploiement
- **[Déploiement](deployment/deployment.md)** - Configuration et déploiement en production

### 📊 Analytics
- **[Métriques et Analytics](analytics/analytics.md)** - KPIs et système de reporting

### 🔧 Maintenance
- **[Maintenance et Support](maintenance/maintenance-support.md)** - Monitoring et maintenance

### 📋 Développement
- **[Guide de Démarrage Rapide](development/quick-start-guide.md)** - Installation et configuration
- **[Plan de Développement](development/development-plan.md)** - Plan détaillé par phases
- **[Spécifications des Dépendances](development/dependencies-specifications.md)** - Versions et compatibilité
- **[Checklist de Développement](development/checklist.md)** - Étapes de développement V1

## 🚀 Démarrage Rapide

### Prérequis
- Node.js 24.8.0
- Flutter 3.35.4
- Dart 3.9.2
- PostgreSQL 17.6
- Redis 7.4.1
- TypeScript 5.8.2

### Installation
```bash
# Cloner le repository
git clone https://github.com/your-org/techplus.git
cd techplus

# Backend
cd backend
npm install
npm run db:migrate
npm run dev

# Frontend
cd frontend
flutter pub get
flutter run
```

## 📖 Guide de Lecture

### Pour les Développeurs
1. Commencer par l'[Architecture](architecture/) pour comprendre la structure
2. Consulter le [Schéma de Base de Données](database/) pour les modèles
3. Référencer les [Endpoints API](api/) pour l'intégration
4. Suivre la [Checklist de Développement](development/checklist.md)

### Pour les Administrateurs
1. Comprendre les [Flux de Navigation](navigation/) pour l'utilisation
2. Consulter les [Analytics](analytics/) pour le reporting
3. Référencer la [Maintenance](maintenance/) pour l'exploitation

### Pour les Designers
1. Étudier le [Design Responsive](design/) pour l'adaptation
2. Consulter les [Flux de Navigation](navigation/) pour l'UX
3. Référencer l'[Internationalisation](i18n/) pour les traductions

## 🔄 Mise à Jour

Cette documentation est maintenue à jour avec le code source. Les modifications importantes sont documentées dans le [Plan de Développement](development/development-plan.md).

## 🤝 Contribution

Pour contribuer à la documentation :
1. Créer une branche feature
2. Modifier les fichiers markdown
3. Créer une pull request
4. Attendre la review

## 📞 Support

- **Documentation** : Cette documentation
- **Issues** : GitHub Issues
- **Email** : dev@techplus.com
- **Slack** : #techplus-dev

---

*Dernière mise à jour : $(date)*
