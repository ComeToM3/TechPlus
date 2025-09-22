# Maintenance et Support - TechPlus

## 🔍 Monitoring

### Logs
#### Winston Configuration
```javascript
// logger.js
const winston = require('winston');
const path = require('path');

const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: winston.format.combine(
    winston.format.timestamp({
      format: 'YYYY-MM-DD HH:mm:ss'
    }),
    winston.format.errors({ stack: true }),
    winston.format.json()
  ),
  defaultMeta: { service: 'techplus-api' },
  transports: [
    // Error logs
    new winston.transports.File({
      filename: path.join('logs', 'error.log'),
      level: 'error',
      maxsize: 5242880, // 5MB
      maxFiles: 5
    }),
    // Combined logs
    new winston.transports.File({
      filename: path.join('logs', 'combined.log'),
      maxsize: 5242880, // 5MB
      maxFiles: 5
    }),
    // Console for development
    new winston.transports.Console({
      format: winston.format.combine(
        winston.format.colorize(),
        winston.format.simple()
      )
    })
  ]
});

module.exports = logger;
```

#### Log Levels
- **Error** : Erreurs critiques nécessitant une intervention
- **Warn** : Avertissements et problèmes potentiels
- **Info** : Informations générales sur le fonctionnement
- **Debug** : Informations détaillées pour le débogage

#### Log Rotation
```bash
# logrotate configuration
/var/log/techplus/*.log {
    daily
    missingok
    rotate 30
    compress
    delaycompress
    notifempty
    create 644 nodejs nodejs
    postrotate
        systemctl reload techplus-backend
    endscript
}
```

### Health Checks
#### Endpoints de Santé
```javascript
// health.js
const express = require('express');
const router = express.Router();

// Health check simple
router.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    memory: process.memoryUsage(),
    version: process.env.npm_package_version
  });
});

// Health check détaillé
router.get('/health/detailed', async (req, res) => {
  const checks = {
    database: false,
    redis: false,
    external_apis: false
  };

  try {
    // Check database
    await prisma.$queryRaw`SELECT 1`;
    checks.database = true;
  } catch (error) {
    logger.error('Database health check failed', error);
  }

  try {
    // Check Redis
    await redis.ping();
    checks.redis = true;
  } catch (error) {
    logger.error('Redis health check failed', error);
  }

  try {
    // Check external APIs
    const stripeResponse = await fetch('https://api.stripe.com/v1/charges?limit=1', {
      headers: { 'Authorization': `Bearer ${process.env.STRIPE_SECRET_KEY}` }
    });
    checks.external_apis = stripeResponse.ok;
  } catch (error) {
    logger.error('External APIs health check failed', error);
  }

  const isHealthy = Object.values(checks).every(check => check === true);
  
  res.status(isHealthy ? 200 : 503).json({
    status: isHealthy ? 'healthy' : 'unhealthy',
    timestamp: new Date().toISOString(),
    checks,
    uptime: process.uptime(),
    memory: process.memoryUsage()
  });
});

module.exports = router;
```

### Error Tracking
#### Sentry Integration
```javascript
// sentry.js
const Sentry = require('@sentry/node');
const { ProfilingIntegration } = require('@sentry/profiling-node');

Sentry.init({
  dsn: process.env.SENTRY_DSN,
  environment: process.env.NODE_ENV,
  integrations: [
    new ProfilingIntegration(),
  ],
  tracesSampleRate: 1.0,
  profilesSampleRate: 1.0,
});

// Capture exceptions
process.on('uncaughtException', (error) => {
  Sentry.captureException(error);
  logger.error('Uncaught Exception', error);
  process.exit(1);
});

process.on('unhandledRejection', (reason, promise) => {
  Sentry.captureException(reason);
  logger.error('Unhandled Rejection', { reason, promise });
});

module.exports = Sentry;
```

### Performance Monitoring
#### Métriques de Performance
```javascript
// metrics.js
const prometheus = require('prom-client');

// Métriques personnalisées
const httpRequestDuration = new prometheus.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code']
});

const httpRequestTotal = new prometheus.Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status_code']
});

const activeConnections = new prometheus.Gauge({
  name: 'active_connections',
  help: 'Number of active connections'
});

const reservationCounter = new prometheus.Counter({
  name: 'reservations_total',
  help: 'Total number of reservations',
  labelNames: ['status']
});

module.exports = {
  httpRequestDuration,
  httpRequestTotal,
  activeConnections,
  reservationCounter
};
```

## 🔧 Maintenance

### Base de Données
#### Nettoyage Automatique
```sql
-- Nettoyage des réservations anciennes
DELETE FROM reservations 
WHERE status = 'COMPLETED' 
  AND date < CURRENT_DATE - INTERVAL '1 year';

-- Nettoyage des tokens expirés
DELETE FROM reservations 
WHERE management_token IS NOT NULL 
  AND token_expires_at < NOW();

-- Optimisation des index
REINDEX TABLE reservations;
REINDEX TABLE users;
REINDEX TABLE tables;
```

#### Sauvegarde
```bash
#!/bin/bash
# backup.sh - Script de sauvegarde quotidienne

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/var/backups/techplus"
DB_NAME="techplus"

# Créer le répertoire de sauvegarde
mkdir -p $BACKUP_DIR

# Sauvegarde de la base de données
pg_dump $DATABASE_URL > $BACKUP_DIR/backup_$DATE.sql

# Compression
gzip $BACKUP_DIR/backup_$DATE.sql

# Upload vers S3
aws s3 cp $BACKUP_DIR/backup_$DATE.sql.gz s3://techplus-backups/database/

# Nettoyage local (garder 7 jours)
find $BACKUP_DIR -name "backup_*.sql.gz" -mtime +7 -delete

# Nettoyage S3 (garder 30 jours)
aws s3 ls s3://techplus-backups/database/ | \
  awk '$1 < "'$(date -d '30 days ago' '+%Y-%m-%d')'" {print $4}' | \
  xargs -I {} aws s3 rm s3://techplus-backups/database/{}

echo "Backup completed: backup_$DATE.sql.gz"
```

#### Monitoring de la Base
```sql
-- Requêtes lentes
SELECT 
  query,
  mean_time,
  calls,
  total_time
FROM pg_stat_statements 
ORDER BY mean_time DESC 
LIMIT 10;

-- Taille des tables
SELECT 
  schemaname,
  tablename,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
FROM pg_tables 
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- Index non utilisés
SELECT 
  schemaname,
  tablename,
  indexname,
  idx_scan,
  idx_tup_read,
  idx_tup_fetch
FROM pg_stat_user_indexes 
WHERE idx_scan = 0;
```

### Cache Redis
#### Monitoring
```bash
# Statistiques Redis
redis-cli info stats

# Mémoire utilisée
redis-cli info memory

# Clés expirées
redis-cli info stats | grep expired_keys

# Connexions
redis-cli info clients
```

#### Nettoyage
```bash
# Nettoyage des clés expirées
redis-cli --scan --pattern "expired:*" | xargs redis-cli del

# Nettoyage des sessions inactives
redis-cli --scan --pattern "session:*" | while read key; do
  ttl=$(redis-cli ttl "$key")
  if [ $ttl -eq -1 ]; then
    redis-cli del "$key"
  fi
done
```

### Application
#### Restart Automatique
```bash
#!/bin/bash
# restart.sh - Script de redémarrage

# Vérifier l'état de l'application
if ! curl -f http://localhost:3000/health > /dev/null 2>&1; then
  echo "Application is down, restarting..."
  
  # Redémarrer avec PM2
  pm2 restart techplus-backend
  
  # Attendre que l'application soit prête
  sleep 30
  
  # Vérifier à nouveau
  if curl -f http://localhost:3000/health > /dev/null 2>&1; then
    echo "Application restarted successfully"
  else
    echo "Failed to restart application"
    # Envoyer une alerte
    curl -X POST -H 'Content-type: application/json' \
      --data '{"text":"TechPlus application failed to restart"}' \
      $SLACK_WEBHOOK_URL
  fi
fi
```

#### Mise à Jour
```bash
#!/bin/bash
# update.sh - Script de mise à jour

# Sauvegarder la base de données
./backup.sh

# Mettre à jour le code
git pull origin main

# Installer les dépendances
npm ci --only=production

# Exécuter les migrations
npm run db:migrate

# Redémarrer l'application
pm2 restart techplus-backend

# Vérifier la santé
sleep 30
if curl -f http://localhost:3000/health > /dev/null 2>&1; then
  echo "Update completed successfully"
else
  echo "Update failed, rolling back..."
  git reset --hard HEAD~1
  pm2 restart techplus-backend
fi
```

## 🛡️ Sécurité

### Audit de Sécurité
#### Vérifications Automatiques
```bash
#!/bin/bash
# security-audit.sh

# Vérifier les vulnérabilités npm
npm audit

# Vérifier les certificats SSL
echo | openssl s_client -connect techplus.com:443 2>/dev/null | \
  openssl x509 -noout -dates

# Vérifier les ports ouverts
nmap -sT -O localhost

# Vérifier les permissions
find /var/www/techplus -type f -perm /o+w

# Vérifier les logs de sécurité
grep "Failed password" /var/log/auth.log | tail -10
```

#### Mise à Jour de Sécurité
```bash
#!/bin/bash
# security-update.sh

# Mettre à jour le système
apt update && apt upgrade -y

# Mettre à jour les dépendances
npm audit fix

# Redémarrer les services
systemctl restart nginx
pm2 restart techplus-backend

# Vérifier les services
systemctl status nginx
pm2 status
```

### Backup et Récupération
#### Stratégie de Backup
- **Base de données** : Sauvegarde quotidienne
- **Fichiers** : Sauvegarde hebdomadaire
- **Configuration** : Sauvegarde mensuelle
- **Rétention** : 30 jours local, 1 an cloud

#### Test de Récupération
```bash
#!/bin/bash
# recovery-test.sh

# Créer une base de test
createdb techplus_test

# Restaurer la sauvegarde
gunzip -c backup_latest.sql.gz | psql techplus_test

# Vérifier l'intégrité
psql techplus_test -c "SELECT COUNT(*) FROM reservations;"
psql techplus_test -c "SELECT COUNT(*) FROM users;"

# Nettoyer
dropdb techplus_test

echo "Recovery test completed successfully"
```

## 📞 Support

### Documentation
#### Guide Utilisateur
- **Réservations** : Comment réserver une table
- **Gestion** : Comment gérer sa réservation
- **Paiements** : Comment payer en ligne
- **FAQ** : Questions fréquentes

#### Guide Administrateur
- **Dashboard** : Utilisation du tableau de bord
- **Réservations** : Gestion des réservations
- **Tables** : Configuration des tables
- **Menu** : Gestion du menu
- **Analytics** : Interprétation des données

### Support Technique
#### Niveaux de Support
1. **Niveau 1** : Support utilisateur (FAQ, guides)
2. **Niveau 2** : Support technique (bugs, problèmes)
3. **Niveau 3** : Support développeur (corrections)

#### SLA
- **Critique** : 1 heure (système down)
- **Élevé** : 4 heures (fonctionnalité majeure)
- **Moyen** : 24 heures (fonctionnalité mineure)
- **Faible** : 72 heures (amélioration)

### Communication
#### Canaux
- **Email** : support@techplus.com
- **Chat** : Support en ligne
- **Téléphone** : Support urgent
- **Documentation** : Wiki interne

#### Escalade
```javascript
// Système d'escalade automatique
const escalationRules = {
  critical: {
    threshold: 1, // heure
    action: 'call_on_call_engineer',
    notification: 'slack_alert'
  },
  high: {
    threshold: 4, // heures
    action: 'assign_to_senior_support',
    notification: 'email_alert'
  },
  medium: {
    threshold: 24, // heures
    action: 'assign_to_support_team',
    notification: 'ticket_update'
  }
};
```
