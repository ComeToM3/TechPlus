# Internationalisation - TechPlus

## 🌍 Langues Supportées

### Langues Disponibles
- **Français (fr)** : Langue par défaut
- **Anglais (en)** : Langue secondaire
- **Espagnol (es)** : Extension future
- **Italien (it)** : Extension future

## 📁 Structure des Traductions

### Frontend (Flutter)
```
assets/
└── translations/
    ├── fr.json
    ├── en.json
    ├── es.json (future)
    └── it.json (future)
```

### Backend (Node.js)
```
src/
└── locales/
    ├── fr.json
    ├── en.json
    ├── es.json (future)
    └── it.json (future)
```

## 📝 Clés de Traduction

### Structure Hiérarchique
```json
{
  "common": {
    "save": "Enregistrer",
    "cancel": "Annuler",
    "confirm": "Confirmer",
    "delete": "Supprimer",
    "edit": "Modifier",
    "search": "Rechercher",
    "loading": "Chargement...",
    "error": "Erreur",
    "success": "Succès"
  },
  "navigation": {
    "home": "Accueil",
    "menu": "Menu",
    "reservation": "Réservation",
    "about": "À propos",
    "contact": "Contact",
    "admin": "Administration"
  },
  "reservation": {
    "title": "Réserver une table",
    "date": "Date",
    "time": "Heure",
    "partySize": "Nombre de personnes",
    "clientName": "Nom",
    "clientEmail": "Email",
    "clientPhone": "Téléphone",
    "specialRequests": "Demandes spéciales",
    "confirm": "Confirmer la réservation",
    "cancel": "Annuler la réservation",
    "modify": "Modifier la réservation",
    "status": {
      "pending": "En attente",
      "confirmed": "Confirmée",
      "cancelled": "Annulée",
      "completed": "Terminée",
      "noShow": "Absent"
    }
  },
  "admin": {
    "dashboard": "Tableau de bord",
    "reservations": "Réservations",
    "tables": "Tables",
    "menu": "Menu",
    "analytics": "Analytics",
    "settings": "Paramètres",
    "users": "Utilisateurs",
    "logout": "Déconnexion"
  },
  "auth": {
    "login": "Connexion",
    "register": "Inscription",
    "logout": "Déconnexion",
    "email": "Email",
    "password": "Mot de passe",
    "forgotPassword": "Mot de passe oublié",
    "rememberMe": "Se souvenir de moi",
    "google": "Continuer avec Google",
    "facebook": "Continuer avec Facebook"
  },
  "menu": {
    "categories": {
      "starters": "Entrées",
      "mains": "Plats principaux",
      "desserts": "Desserts",
      "beverages": "Boissons"
    },
    "allergens": {
      "gluten": "Contient du gluten",
      "dairy": "Contient des produits laitiers",
      "nuts": "Contient des fruits à coque",
      "eggs": "Contient des œufs",
      "fish": "Contient du poisson",
      "shellfish": "Contient des crustacés",
      "soy": "Contient du soja"
    }
  },
  "payment": {
    "title": "Paiement",
    "deposit": "Acompte",
    "amount": "Montant",
    "cardNumber": "Numéro de carte",
    "expiryDate": "Date d'expiration",
    "cvv": "CVV",
    "cardholderName": "Nom du titulaire",
    "process": "Traiter le paiement",
    "success": "Paiement réussi",
    "failed": "Échec du paiement",
    "refund": "Remboursement"
  },
  "notifications": {
    "reservationConfirmed": "Votre réservation a été confirmée",
    "reservationCancelled": "Votre réservation a été annulée",
    "paymentReceived": "Paiement reçu",
    "reminder": "Rappel de réservation",
    "welcome": "Bienvenue chez TechPlus"
  },
  "errors": {
    "network": "Erreur de connexion",
    "validation": "Données invalides",
    "unauthorized": "Non autorisé",
    "notFound": "Non trouvé",
    "serverError": "Erreur serveur",
    "timeout": "Délai d'attente dépassé"
  }
}
```

## 🔧 Implémentation

### Flutter (Frontend)

#### Configuration
```dart
// pubspec.yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: ^0.18.0

// main.dart
import 'package:flutter_localizations/flutter_localizations.dart';

MaterialApp(
  localizationsDelegates: [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: [
    Locale('fr', 'FR'),
    Locale('en', 'US'),
  ],
  locale: Locale('fr', 'FR'),
)
```

#### Utilisation
```dart
// Traduction simple
Text(AppLocalizations.of(context)!.reservationTitle)

// Traduction avec paramètres
Text(AppLocalizations.of(context)!.welcomeMessage('John'))

// Traduction plurielle
Text(AppLocalizations.of(context)!.itemCount(count))
```

### Node.js (Backend)

#### Configuration
```javascript
// package.json
{
  "dependencies": {
    "i18next": "^23.0.0",
    "i18next-fs-backend": "^2.0.0"
  }
}

// i18n.js
const i18next = require('i18next');
const Backend = require('i18next-fs-backend');

i18next
  .use(Backend)
  .init({
    lng: 'fr',
    fallbackLng: 'en',
    backend: {
      loadPath: './src/locales/{{lng}}.json'
    }
  });
```

#### Utilisation
```javascript
// Traduction simple
const message = i18next.t('reservation.title');

// Traduction avec paramètres
const message = i18next.t('welcome.message', { name: 'John' });

// Traduction plurielle
const message = i18next.t('item.count', { count: 5 });
```

## 🌐 Détection de Langue

### Frontend
```dart
// Détection automatique
Locale? deviceLocale = Platform.localeName;
String languageCode = deviceLocale?.split('_')[0] ?? 'fr';

// Stockage préférence
SharedPreferences prefs = await SharedPreferences.getInstance();
String? savedLanguage = prefs.getString('language');
```

### Backend
```javascript
// Détection via headers
const language = req.headers['accept-language']?.split(',')[0] || 'fr';

// Détection via paramètre
const language = req.query.lang || req.headers['accept-language'] || 'fr';
```

## 📅 Formatage des Données

### Dates
```dart
// Flutter
DateFormat('dd/MM/yyyy', 'fr').format(date)
DateFormat('MM/dd/yyyy', 'en').format(date)

// Node.js
new Intl.DateTimeFormat('fr-FR').format(date)
new Intl.DateTimeFormat('en-US').format(date)
```

### Nombres
```dart
// Flutter
NumberFormat.currency(locale: 'fr_FR', symbol: '€').format(amount)
NumberFormat.currency(locale: 'en_US', symbol: '\$').format(amount)

// Node.js
new Intl.NumberFormat('fr-FR', { style: 'currency', currency: 'EUR' }).format(amount)
new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(amount)
```

## 🔄 Changement de Langue

### Frontend
```dart
// Changement dynamique
void changeLanguage(String languageCode) {
  setState(() {
    _locale = Locale(languageCode);
  });
  
  // Sauvegarde préférence
  SharedPreferences.getInstance().then((prefs) {
    prefs.setString('language', languageCode);
  });
}
```

### Backend
```javascript
// Middleware de langue
app.use((req, res, next) => {
  const language = req.query.lang || req.headers['accept-language'] || 'fr';
  i18next.changeLanguage(language);
  next();
});
```

## 📱 RTL Support

### Configuration
```dart
// Flutter
MaterialApp(
  textDirection: TextDirection.ltr, // ou rtl pour l'arabe
  locale: Locale('ar', 'SA'),
)
```

### CSS
```css
/* RTL Support */
[dir="rtl"] .menu {
  text-align: right;
}

[dir="rtl"] .button {
  margin-left: 0;
  margin-right: 16px;
}
```

## 🧪 Tests

### Tests de Traduction
```dart
// Flutter
testWidgets('should display French text', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: [AppLocalizations.delegate],
      supportedLocales: [Locale('fr', 'FR')],
      locale: Locale('fr', 'FR'),
      home: MyWidget(),
    ),
  );
  
  expect(find.text('Réserver une table'), findsOneWidget);
});
```

### Validation des Clés
```javascript
// Node.js - Validation des clés manquantes
const validateTranslations = (baseLang, targetLang) => {
  const baseKeys = Object.keys(baseLang);
  const targetKeys = Object.keys(targetLang);
  
  const missingKeys = baseKeys.filter(key => !targetKeys.includes(key));
  if (missingKeys.length > 0) {
    console.warn('Missing translations:', missingKeys);
  }
};
```
