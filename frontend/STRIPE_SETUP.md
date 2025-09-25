# Configuration Stripe pour TechPlus

## 🎯 Vue d'Ensemble

Ce document explique comment configurer Stripe pour les paiements réels dans TechPlus.

## 🔧 Configuration Requise

### 1. Compte Stripe

1. **Créer un compte Stripe** : https://stripe.com
2. **Activer le compte** : Vérifier l'identité et ajouter les informations bancaires
3. **Obtenir les clés API** : Dashboard → Developers → API Keys

### 2. Clés API Stripe

#### **Clés de Test (Développement)**
```bash
# Clé publique (publishable key)
STRIPE_PUBLISHABLE_KEY=pk_test_51...

# Clé secrète (secret key) - NE JAMAIS exposer côté client
STRIPE_SECRET_KEY=sk_test_51...

# Secret webhook
STRIPE_WEBHOOK_SECRET=whsec_...
```

#### **Clés de Production**
```bash
# Clé publique (publishable key)
STRIPE_PUBLISHABLE_KEY=pk_live_51...

# Clé secrète (secret key) - NE JAMAIS exposer côté client
STRIPE_SECRET_KEY=sk_live_51...

# Secret webhook
STRIPE_WEBHOOK_SECRET=whsec_...
```

### 3. Configuration Frontend

#### **Variables d'Environnement**
Créer un fichier `.env` dans le dossier `frontend/` :

```env
# Stripe Configuration
STRIPE_PUBLISHABLE_KEY=pk_test_51...
STRIPE_SECRET_KEY=sk_test_51...
STRIPE_WEBHOOK_SECRET=whsec_...
```

#### **Configuration dans le Code**
Le fichier `lib/core/config/stripe_config.dart` utilise les variables d'environnement :

```dart
static const String publishableKey = String.fromEnvironment(
  'STRIPE_PUBLISHABLE_KEY',
  defaultValue: 'pk_test_...',
);
```

### 4. Configuration Backend

#### **Variables d'Environnement Backend**
Créer un fichier `.env` dans le dossier `backend/` :

```env
# Stripe Configuration
STRIPE_SECRET_KEY=sk_test_51...
STRIPE_WEBHOOK_SECRET=whsec_...
STRIPE_PUBLISHABLE_KEY=pk_test_51...
```

#### **Endpoints API Requis**
Le backend doit implémenter ces endpoints :

```typescript
// POST /api/payments/create-intent
{
  "amount": 1000, // 10€ en centimes
  "currency": "EUR",
  "reservationId": "reservation_123"
}

// POST /api/payments/confirm
{
  "paymentIntentId": "pi_123..."
}

// POST /api/payments/refund
{
  "paymentIntentId": "pi_123...",
  "amount": 1000 // Optionnel, pour remboursement partiel
}
```

## 💳 Logique de Paiement

### **Paiement Obligatoire**
- **Seuil** : 6 personnes et plus
- **Montant** : 10€ d'acompte fixe
- **Devise** : EUR

### **Règles de Remboursement**
- **Plus de 24h avant** : Remboursement complet automatique
- **Moins de 24h avant** : Aucun remboursement (acompte perdu)
- **No-show** : Aucun remboursement (acompte perdu)
- **Annulation restaurant** : Remboursement complet

### **Types de Cartes Acceptées**
- Visa
- Mastercard
- American Express
- Apple Pay (iOS)
- Google Pay (Android)

## 🔒 Sécurité

### **Bonnes Pratiques**
1. **Jamais exposer la clé secrète** côté client
2. **Utiliser HTTPS** en production
3. **Valider côté serveur** tous les paiements
4. **Implémenter les webhooks** pour la sécurité
5. **Logger les transactions** pour l'audit

### **Webhooks Stripe**
Configurer ces événements dans le dashboard Stripe :

```
payment_intent.succeeded
payment_intent.payment_failed
payment_intent.canceled
charge.dispute.created
```

## 🧪 Tests

### **Cartes de Test Stripe**
```bash
# Carte qui réussit
4242 4242 4242 4242

# Carte qui échoue
4000 0000 0000 0002

# Carte qui nécessite une authentification
4000 0025 0000 3155
```

### **Codes de Test**
- **CVV** : 123 (ou n'importe quel code 3 chiffres)
- **Date d'expiration** : N'importe quelle date future
- **Code postal** : 12345

## 🚀 Déploiement

### **Variables d'Environnement Production**
```bash
# Production
STRIPE_PUBLISHABLE_KEY=pk_live_51...
STRIPE_SECRET_KEY=sk_live_51...
STRIPE_WEBHOOK_SECRET=whsec_...
```

### **Configuration Serveur**
1. **HTTPS obligatoire** en production
2. **Certificats SSL** valides
3. **Webhooks** configurés avec l'URL de production
4. **Monitoring** des paiements

## 📊 Monitoring

### **Dashboard Stripe**
- **Transactions** : Voir tous les paiements
- **Remboursements** : Gérer les remboursements
- **Disputes** : Résoudre les litiges
- **Analytics** : Métriques de performance

### **Logs Application**
```dart
// Exemple de logging
print('💳 Payment Intent created: ${paymentIntent.id}');
print('💰 Amount: ${paymentIntent.amount} ${paymentIntent.currency}');
print('📊 Status: ${paymentIntent.status}');
```

## 🆘 Dépannage

### **Erreurs Communes**

#### **"Invalid API Key"**
- Vérifier que la clé publique est correcte
- S'assurer que la clé correspond à l'environnement (test/production)

#### **"Payment Intent not found"**
- Vérifier que le PaymentIntent existe
- S'assurer que l'ID est correct

#### **"Card declined"**
- Utiliser une carte de test valide
- Vérifier les détails de la carte

### **Support**
- **Documentation Stripe** : https://stripe.com/docs
- **Support Stripe** : https://support.stripe.com
- **Communauté** : https://github.com/stripe/stripe-flutter

---

## ✅ Checklist de Configuration

- [ ] Compte Stripe créé et activé
- [ ] Clés API obtenues (test et production)
- [ ] Variables d'environnement configurées
- [ ] Backend configuré avec les endpoints
- [ ] Webhooks configurés
- [ ] Tests avec cartes de test
- [ ] HTTPS configuré en production
- [ ] Monitoring en place

**Une fois cette checklist complétée, les paiements Stripe seront fonctionnels !**
