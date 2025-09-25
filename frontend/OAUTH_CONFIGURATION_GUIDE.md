# 🔐 Guide de Configuration OAuth pour TechPlus

## 📋 Vue d'ensemble

Ce guide vous explique comment configurer OAuth2 (Google, Facebook, Apple) pour l'authentification admin de TechPlus.

## 🚀 Configuration Rapide

### 1. Exécuter le script de configuration
```bash
cd frontend
dart run configure_oauth.dart
```

### 2. Ou configurer manuellement le fichier `.env`
```bash
# Configuration OAuth (Admin)
GOOGLE_CLIENT_ID=votre_google_client_id
GOOGLE_SERVER_CLIENT_ID=votre_google_server_client_id
FACEBOOK_APP_ID=votre_facebook_app_id
FACEBOOK_CLIENT_TOKEN=votre_facebook_client_token
APPLE_SERVICE_ID=votre_apple_service_id
APPLE_TEAM_ID=votre_apple_team_id
APPLE_KEY_ID=votre_apple_key_id
APPLE_PRIVATE_KEY=votre_apple_private_key
```

## 🔧 Configuration Détaillée

### Google OAuth

1. **Créer un projet Google Cloud Console**
   - Aller sur [Google Cloud Console](https://console.cloud.google.com/)
   - Créer un nouveau projet ou sélectionner un projet existant

2. **Activer l'API Google+**
   - Aller dans "APIs & Services" > "Library"
   - Rechercher "Google+ API" et l'activer

3. **Créer des identifiants OAuth**
   - Aller dans "APIs & Services" > "Credentials"
   - Cliquer sur "Create Credentials" > "OAuth client ID"
   - Choisir "Web application"
   - Ajouter les URLs autorisées :
     - `http://localhost:3000` (développement)
     - `https://votre-domaine.com` (production)

4. **Obtenir les clés**
   - **Client ID** : Copier la clé publique
   - **Server Client ID** : Utiliser la même clé ou créer une clé serveur séparée

### Facebook OAuth

1. **Créer une application Facebook**
   - Aller sur [Facebook Developers](https://developers.facebook.com/)
   - Cliquer sur "My Apps" > "Create App"
   - Choisir "Consumer" ou "Business"

2. **Configurer l'application**
   - Aller dans "Settings" > "Basic"
   - Ajouter les domaines autorisés :
     - `localhost:3000` (développement)
     - `votre-domaine.com` (production)

3. **Obtenir les clés**
   - **App ID** : Dans "Settings" > "Basic"
   - **Client Token** : Dans "Settings" > "Advanced"

### Apple OAuth

1. **Créer un identifiant de service**
   - Aller sur [Apple Developer](https://developer.apple.com/)
   - Aller dans "Certificates, Identifiers & Profiles"
   - Créer un nouvel "Services ID"

2. **Configurer Sign in with Apple**
   - Activer "Sign in with Apple"
   - Configurer les domaines et URLs de retour

3. **Créer une clé privée**
   - Aller dans "Keys"
   - Créer une nouvelle clé avec "Sign in with Apple"
   - Télécharger le fichier `.p8`

4. **Obtenir les informations**
   - **Service ID** : L'identifiant de service créé
   - **Team ID** : Dans "Membership" > "Team ID"
   - **Key ID** : L'ID de la clé créée
   - **Private Key** : Le contenu du fichier `.p8`

## 🔗 Configuration Backend

### Endpoints OAuth requis

Votre backend doit implémenter ces endpoints :

```javascript
// Google OAuth
POST /api/auth/google
{
  "accessToken": "string",
  "idToken": "string",
  "email": "string",
  "name": "string",
  "photoUrl": "string"
}

// Facebook OAuth
POST /api/auth/facebook
{
  "accessToken": "string",
  "userId": "string"
}

// Apple OAuth
POST /api/auth/apple
{
  "identityToken": "string",
  "authorizationCode": "string",
  "userIdentifier": "string",
  "email": "string",
  "givenName": "string",
  "familyName": "string"
}
```

### Réponse attendue

```javascript
{
  "user": {
    "id": "string",
    "email": "string",
    "name": "string",
    "role": "ADMIN",
    "photoUrl": "string"
  },
  "tokens": {
    "accessToken": "string",
    "refreshToken": "string"
  }
}
```

## 🧪 Test de la Configuration

### 1. Vérifier la configuration
```bash
cd frontend
flutter run -d web
```

### 2. Aller sur la page admin
- Naviguer vers `/admin/login`
- Vérifier que le widget "Test Configuration OAuth" affiche les bonnes informations

### 3. Tester la connexion OAuth
- Cliquer sur "Se connecter avec Google"
- Vérifier que la redirection fonctionne
- Tester avec Facebook et Apple

## 🐛 Dépannage

### Problèmes courants

1. **"OAuth not configured"**
   - Vérifier que les clés sont dans le fichier `.env`
   - Redémarrer l'application

2. **"Invalid client"**
   - Vérifier que les clés OAuth sont correctes
   - Vérifier les domaines autorisés

3. **"Redirect URI mismatch"**
   - Vérifier les URLs de redirection dans les consoles OAuth
   - S'assurer que l'URL correspond exactement

4. **"Backend error"**
   - Vérifier que le backend est démarré
   - Vérifier les endpoints OAuth
   - Consulter les logs du backend

### Logs utiles

```bash
# Vérifier les variables d'environnement
flutter run -d web --verbose

# Vérifier la configuration OAuth
dart run lib/core/config/oauth_test.dart
```

## 📚 Ressources

- [Google OAuth Documentation](https://developers.google.com/identity/protocols/oauth2)
- [Facebook Login Documentation](https://developers.facebook.com/docs/facebook-login/)
- [Apple Sign in Documentation](https://developer.apple.com/documentation/sign_in_with_apple)
- [Flutter OAuth Packages](https://pub.dev/packages/google_sign_in)
- [Flutter OAuth Packages](https://pub.dev/packages/flutter_facebook_auth)
- [Flutter OAuth Packages](https://pub.dev/packages/sign_in_with_apple)

## ✅ Checklist de Configuration

- [ ] Google OAuth configuré
- [ ] Facebook OAuth configuré  
- [ ] Apple OAuth configuré
- [ ] Backend endpoints implémentés
- [ ] Test de connexion réussi
- [ ] Redirection après connexion
- [ ] Gestion des erreurs
- [ ] Logs de débogage

## 🎯 Prochaines Étapes

1. **Configurer les assets locaux** (images, icônes)
2. **Nettoyer les simulations restantes**
3. **Implémenter les notifications email**
4. **Tester l'ensemble du flux**

---

**Note** : Ce guide est spécifique à TechPlus. Adaptez les URLs et domaines selon votre configuration.
