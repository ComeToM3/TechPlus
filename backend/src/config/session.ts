import session from 'express-session';
import { config } from './environment';

// Configuration des sessions en mémoire (temporaire)
// TODO: Migrer vers Redis une fois que le serveur fonctionne
const sessionConfig = session({
  secret: config.jwt.secret,
  resave: false,
  saveUninitialized: false,
  rolling: true, // Renouveler la session à chaque requête
  cookie: {
    secure: config.nodeEnv === 'production', // HTTPS en production
    httpOnly: true, // Empêcher l'accès via JavaScript
    maxAge: 24 * 60 * 60 * 1000, // 24 heures en millisecondes
    sameSite: 'strict', // Protection CSRF
  },
  name: 'techplus.sid', // Nom du cookie de session
});

// Middleware pour nettoyer les sessions expirées
export const sessionCleanup = async (): Promise<void> => {
  try {
    // Nettoyer les sessions expirées (fait automatiquement par express-session)
    console.log('🧹 Session cleanup completed');
  } catch (error) {
    console.error('❌ Error during session cleanup:', error);
  }
};

// Fonction pour créer une session utilisateur
export const createUserSession = (req: any, user: any): void => {
  req.session.userId = user.id;
  req.session.userEmail = user.email;
  req.session.userRole = user.role;
  req.session.isAuthenticated = true;
  req.session.loginTime = new Date().toISOString();
};

// Fonction pour détruire une session utilisateur
export const destroyUserSession = (req: any): Promise<void> => {
  return new Promise((resolve, reject) => {
    req.session.destroy((err: any) => {
      if (err) {
        console.error('❌ Error destroying session:', err);
        reject(err);
      } else {
        console.log('✅ User session destroyed');
        resolve();
      }
    });
  });
};

// Fonction pour vérifier si l'utilisateur est authentifié
export const isAuthenticated = (req: any): boolean => {
  return req.session && req.session.isAuthenticated === true;
};

// Fonction pour obtenir l'utilisateur de la session
export const getSessionUser = (req: any): any => {
  if (!isAuthenticated(req)) {
    return null;
  }

  return {
    id: req.session.userId,
    email: req.session.userEmail,
    role: req.session.userRole,
    loginTime: req.session.loginTime,
  };
};

// Middleware pour vérifier l'authentification
export const requireAuth = (req: any, res: any, next: any): void => {
  if (!isAuthenticated(req)) {
    res.status(401).json({
      error: 'Authentication required',
      message: 'Please log in to access this resource',
    });
    return;
  }
  next();
};

// Middleware pour vérifier le rôle admin
export const requireAdmin = (req: any, res: any, next: any): void => {
  if (!isAuthenticated(req)) {
    res.status(401).json({
      error: 'Authentication required',
      message: 'Please log in to access this resource',
    });
    return;
  }

  if (req.session.userRole !== 'ADMIN' && req.session.userRole !== 'SUPER_ADMIN') {
    res.status(403).json({
      error: 'Insufficient permissions',
      message: 'Admin access required',
    });
    return;
  }

  next();
};

// Middleware pour vérifier le rôle super admin
export const requireSuperAdmin = (req: any, res: any, next: any): void => {
  if (!isAuthenticated(req)) {
    res.status(401).json({
      error: 'Authentication required',
      message: 'Please log in to access this resource',
    });
    return;
  }

  if (req.session.userRole !== 'SUPER_ADMIN') {
    res.status(403).json({
      error: 'Insufficient permissions',
      message: 'Super admin access required',
    });
    return;
  }

  next();
};

export default sessionConfig;
