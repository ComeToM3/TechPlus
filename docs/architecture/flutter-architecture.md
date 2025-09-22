# Architecture Flutter - TechPlus

## 📁 Structure des Dossiers

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_constants.dart
│   │   ├── api_constants.dart
│   │   └── theme_constants.dart
│   ├── errors/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── network/
│   │   ├── api_client.dart
│   │   └── network_info.dart
│   ├── utils/
│   │   ├── validators.dart
│   │   └── formatters.dart
│   └── theme/
│       ├── app_theme.dart
│       └── app_colors.dart
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   ├── repositories/
│   │   │   └── datasources/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── pages/
│   │       ├── widgets/
│   │       └── providers/
│   ├── reservation/
│   ├── menu/
│   └── admin/
├── shared/
│   ├── widgets/
│   │   ├── buttons/
│   │   ├── forms/
│   │   └── layouts/
│   └── utils/
└── main.dart
```

## 🏗️ Architecture Clean

### Core Layer
- **Constants** : Configuration globale de l'application
- **Errors** : Gestion centralisée des erreurs
- **Network** : Client API et vérification de connectivité
- **Utils** : Fonctions utilitaires communes
- **Theme** : Configuration du thème et couleurs

### Features Layer
Chaque feature suit l'architecture Clean avec :
- **Data** : Modèles, repositories et datasources
- **Domain** : Entités, repositories abstraits et use cases
- **Presentation** : Pages, widgets et providers (state management)

### Shared Layer
- **Widgets** : Composants réutilisables
- **Utils** : Utilitaires partagés entre features

## 📱 State Management

Utilisation de **Provider** ou **Riverpod** pour :
- Gestion d'état globale
- Injection de dépendances
- Gestion des providers par feature

## 🔄 Navigation

- **GoRouter** pour la navigation déclarative
- Routes protégées pour l'authentification
- Navigation conditionnelle selon le rôle utilisateur
