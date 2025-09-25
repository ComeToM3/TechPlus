# TechPlus Frontend

[![Flutter](https://img.shields.io/badge/Flutter-3.35.4-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.9.2-blue.svg)](https://dart.dev/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

> **Application Flutter moderne pour le système de réservation de restaurant TechPlus**  
> Interface utilisateur complète avec authentification, réservations, et administration.

## 🚀 Vue d'ensemble

TechPlus Frontend est une application Flutter moderne construite avec une architecture Clean Architecture, offrant une expérience utilisateur fluide pour la gestion des réservations de restaurant. L'application supporte l'authentification, les réservations en temps réel, et une interface d'administration complète.

### ✨ Fonctionnalités Principales

- 🔐 **Authentification Sécurisée** - JWT + OAuth2 (Google, Facebook)
- 📱 **Interface Responsive** - Mobile, tablette, desktop
- 🌍 **Internationalisation** - Français et Anglais
- 🎨 **Design Moderne** - Material Design 3
- 🛡️ **Sécurité Avancée** - Stockage sécurisé, certificats
- 📊 **Dashboard Admin** - Gestion complète des réservations
- 💳 **Paiements Intégrés** - Stripe avec interface native
- 🔔 **Notifications** - Push notifications et emails

## 🏗️ Architecture

```
lib/
├── core/                    # Configuration de base
│   ├── constants/          # Constantes de l'application
│   ├── network/            # Client HTTP et configuration
│   ├── navigation/         # Configuration du routing
│   ├── security/           # Services de sécurité
│   ├── theme/              # Thèmes et styles
│   └── l10n/               # Internationalisation
├── features/               # Fonctionnalités métier
│   ├── auth/              # Authentification
│   │   ├── data/          # Services et modèles
│   │   ├── domain/        # Entités et cas d'usage
│   │   └── presentation/   # Pages et widgets
│   ├── reservation/        # Gestion des réservations
│   ├── admin/             # Interface d'administration
│   └── public/            # Pages publiques
├── shared/                # Composants partagés
│   ├── widgets/           # Widgets réutilisables
│   ├── animations/        # Animations personnalisées
│   └── utils/             # Utilitaires
└── generated/             # Code généré automatiquement
```

## 🚀 Démarrage Rapide

### Prérequis

- **Flutter** >= 3.35.4
- **Dart** >= 3.9.2
- **Android Studio** ou **VS Code** avec extensions Flutter
- **Backend TechPlus** en cours d'exécution

### Installation

1. **Cloner le projet et installer les dépendances**
   ```bash
   cd frontend
   flutter pub get
   ```

2. **Configuration de l'environnement**
   ```bash
   # Copier le fichier de configuration
   cp lib/core/constants/app_constants.dart.example lib/core/constants/app_constants.dart
   # Éditer avec vos configurations API
   ```

3. **Générer les fichiers de localisation**
   ```bash
   flutter gen-l10n
   ```

4. **Démarrer en mode développement**
   ```bash
   flutter run
   ```

5. **Build pour la production**
   ```bash
   # Android
   flutter build apk --release
   
   # iOS
   flutter build ios --release
   
   # Web
   flutter build web --release
   ```

## 📋 Scripts Disponibles

| Script | Description |
|--------|-------------|
| `flutter run` | Démarre l'application en mode développement |
| `flutter build apk` | Build Android APK |
| `flutter build ios` | Build iOS |
| `flutter build web` | Build Web |
| `flutter test` | Lance les tests unitaires |
| `flutter test integration_test/` | Lance les tests d'intégration |
| `flutter analyze` | Analyse statique du code |
| `flutter format` | Formate le code |
| `flutter gen-l10n` | Génère les fichiers de localisation |
| `flutter clean` | Nettoie le cache et les builds |

## 🔧 Configuration

### Variables d'Environnement

```dart
// lib/core/constants/app_constants.dart
class AppConstants {
  // API Configuration
  static const String baseUrl = 'http://localhost:3000';
  static const String apiVersion = 'v1';
  
  // Security
  static const String certificatePinning = 'your-certificate-hash';
  
  // Features
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
  static const bool enablePushNotifications = true;
}
```

### Configuration API

```dart
// Configuration du client HTTP
final dio = Dio();
dio.options.baseUrl = AppConstants.baseUrl;
dio.options.connectTimeout = const Duration(seconds: 30);
dio.options.receiveTimeout = const Duration(seconds: 30);

// Intercepteurs de sécurité
dio.interceptors.add(AuthInterceptor());
dio.interceptors.add(SecurityInterceptor());
dio.interceptors.add(LoggingInterceptor());
```

### Internationalisation

```yaml
# pubspec.yaml
flutter:
  generate: true

# l10n.yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
```

## 🎨 Design System

### Thème Material Design 3

```dart
// Thème clair
static ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue,
    brightness: Brightness.light,
  ),
  fontFamily: 'Roboto',
);

// Thème sombre
static ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue,
    brightness: Brightness.dark,
  ),
  fontFamily: 'Roboto',
);
```

### Composants Personnalisés

- **BentoCard** - Cartes avec design moderne
- **AnimatedButton** - Boutons avec animations
- **ResponsiveLayout** - Layout adaptatif
- **LoadingWidget** - Indicateurs de chargement
- **ErrorWidget** - Gestion des erreurs

## 🔐 Sécurité

### Fonctionnalités de Sécurité Implémentées

- **Flutter Secure Storage** - Stockage sécurisé des tokens
- **Certificate Pinning** - Validation des certificats SSL
- **Token Management** - Gestion automatique des tokens JWT
- **Input Validation** - Validation des formulaires
- **HTTPS Enforcement** - Forçage des connexions sécurisées

### Configuration de Sécurité

```dart
// Service de sécurité
class SecurityService {
  static Future<void> initialize() async {
    // Configuration du stockage sécurisé
    await _configureSecureStorage();
    
    // Configuration du pinning de certificats
    await _configureCertificatePinning();
    
    // Configuration des canaux sécurisés
    await _configureSecurityChannels();
  }
}
```

## 📱 Fonctionnalités

### Authentification

- **Login/Register** - Connexion et inscription
- **OAuth2** - Google et Facebook
- **Token Management** - Gestion automatique des tokens
- **Session Management** - Gestion des sessions utilisateur

### Réservations

- **Création** - Processus de réservation en étapes
- **Gestion** - Modification et annulation
- **Paiements** - Intégration Stripe
- **Notifications** - Confirmations par email

### Administration

- **Dashboard** - Métriques et statistiques
- **Gestion des Réservations** - CRUD complet
- **Configuration** - Paramètres du restaurant
- **Rapports** - Analytics et exports

### Interface Publique

- **Vitrine** - Présentation du restaurant
- **Menu** - Affichage des plats
- **Réservation** - Processus simplifié
- **Contact** - Informations et localisation

## 🧪 Tests

### Structure des Tests

```
test/
├── unit/                   # Tests unitaires
│   ├── providers/         # Tests des providers
│   ├── services/         # Tests des services
│   └── utils/            # Tests des utilitaires
├── widget/                # Tests de widgets
├── integration/           # Tests d'intégration
└── coverage/              # Rapports de couverture
```

### Commandes de Test

```bash
# Tests unitaires
flutter test

# Tests avec couverture
flutter test --coverage

# Tests d'intégration
flutter test integration_test/

# Tests spécifiques
flutter test test/unit/providers/
```

### Couverture de Code

- **Objectif** : 80% de couverture minimum
- **Rapport** : Généré automatiquement dans `coverage/`
- **Outils** : Flutter Test + Coverage

## 🌍 Internationalisation

### Langues Supportées

- **Français** (fr_FR) - Langue par défaut
- **Anglais** (en_US) - Langue secondaire

### Configuration

```dart
// Détection automatique de la langue
final locale = ref.watch(localeProvider);

// Changement de langue
ref.read(localeProvider.notifier).setLocale(Locale('en', 'US'));
```

### Fichiers de Traduction

```
lib/l10n/
├── app_en.arb            # Traductions anglaises
├── app_fr.arb            # Traductions françaises
└── app_localizations.dart # Code généré
```

## 📊 Performance

### Optimisations

- **Lazy Loading** - Chargement à la demande
- **Image Caching** - Cache des images
- **State Management** - Riverpod pour la performance
- **Memory Management** - Gestion optimisée de la mémoire

### Métriques

- **First Frame** - < 100ms
- **Build Time** - < 2s
- **Memory Usage** - < 100MB
- **Battery Usage** - Optimisé

## 🚀 Déploiement

### Android

```bash
# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release

# Signer l'APK
flutter build apk --release --target-platform android-arm64
```

### iOS

```bash
# Build iOS
flutter build ios --release

# Archive pour App Store
flutter build ipa --release
```

### Web

```bash
# Build Web
flutter build web --release

# Optimiser pour la production
flutter build web --release --web-renderer html
```

## 🔧 Développement

### Standards de Code

- **Dart Style Guide** - Conventions Dart
- **Flutter Lints** - Règles de linting
- **Clean Architecture** - Architecture propre
- **SOLID Principles** - Principes SOLID

### Workflow de Développement

1. **Feature Branch** - `git checkout -b feature/nouvelle-fonctionnalite`
2. **Développement** - Code avec tests
3. **Tests** - `flutter test`
4. **Format** - `flutter format`
5. **Analyze** - `flutter analyze`
6. **Commit** - `git commit -m "feat: ajouter nouvelle fonctionnalité"`
7. **Push** - `git push origin feature/nouvelle-fonctionnalite`
8. **Pull Request** - Vers main

### Outils de Développement

- **Flutter Inspector** - Debug de l'UI
- **Performance View** - Analyse des performances
- **Memory View** - Gestion de la mémoire
- **Network View** - Requêtes réseau

## 📚 Documentation

- **API Documentation** - Documentation des services
- **Widget Documentation** - Documentation des composants
- **Architecture Guide** - Guide d'architecture
- **Deployment Guide** - Guide de déploiement

## 🤝 Contribution

1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/AmazingFeature`)
3. Commit les changements (`git commit -m 'Add some AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

## 👥 Équipe

- **Frontend Developer** - Interface utilisateur
- **UI/UX Designer** - Design et expérience utilisateur
- **QA Engineer** - Tests et qualité

## 📞 Support

- **Email** : support@techplus.com
- **Documentation** : [docs.techplus.com](https://docs.techplus.com)
- **Issues** : [GitHub Issues](https://github.com/techplus/frontend/issues)

---

**TechPlus Frontend** - Application Flutter moderne et performante pour la gestion de réservations 🚀