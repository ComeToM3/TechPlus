import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
import { config } from '@/config/environment';
import { testDatabaseConnection } from '@/config/database';
import sessionConfig from '@/config/session';
import { initSentry, sentryRequestHandler, sentryTracingHandler, sentryErrorHandler } from '@/config/sentry-simple';
import { 
  helmetConfig,
  corsConfig,
  generalRateLimit,
  authRateLimit,
  passwordResetRateLimit,
  publicApiRateLimit,
  securityHeadersMiddleware,
  dosProtectionMiddleware,
  enumerationProtectionMiddleware,
  sessionSecurityConfig
} from '@/config/security';
// import { 
//   httpLoggingMiddleware, 
//   errorLoggingMiddleware, 
//   slowRequestLoggingMiddleware,
//   authLoggingMiddleware,
//   sensitiveOperationLoggingMiddleware 
// } from '@/middleware/logging';
// import { 
//   sanitizeInput as securitySanitizeInput,
//   sqlInjectionProtection,
//   xssProtection,
//   enumerationProtection,
//   dosProtection,
//   securityHeadersValidation,
//   timingAttackProtection,
//   resourceEnumerationProtection
// } from '@/middleware/security';
// import { 
//   csrfProtectionMiddleware,
//   provideCsrfToken,
//   requireCsrfToken
// } from '@/middleware/csrf';
// import { 
//   sanitizeInput, 
//   validateContentType, 
//   validateRequestSize, 
//   validateHeaders, 
//   validateUrlParams, 
//   validateJsonData, 
//   validateFileUpload,
//   setupSanitizer
// } from '@/middleware/sanitization';
import { 
  uptimeMonitoringMiddleware,
  healthCheckMonitoringMiddleware,
  availabilityMonitoringMiddleware,
  periodicUptimeLogging
} from '@/middleware/uptime';
import { 
  setupDatabaseMonitoring,
  databaseConnectionMonitoring,
  periodicDatabaseLogging
} from '@/middleware/database-monitoring';
// import { performanceMetricsMiddleware, memoryUsageMiddleware } from '@/utils/performance';
import logger from '@/utils/logger';

const app = express();

// Initialiser Sentry (doit être en premier)
initSentry();

// Sentry middleware (doit être avant tous les autres middlewares)
app.use(sentryRequestHandler);
app.use(sentryTracingHandler);

// Logging middleware
// app.use(httpLoggingMiddleware);
// app.use(performanceMetricsMiddleware);
// app.use(memoryUsageMiddleware);
// app.use(slowRequestLoggingMiddleware(1000)); // Alerte si > 1s
// app.use(authLoggingMiddleware);
// app.use(sensitiveOperationLoggingMiddleware);

// Uptime monitoring middleware
app.use(uptimeMonitoringMiddleware);
app.use(availabilityMonitoringMiddleware);

// Security middleware (ordre important)
app.use(helmetConfig);
app.use(cors(corsConfig));
// app.use(securityHeadersValidation);
// app.use(dosProtection);
// app.use(enumerationProtection);
// app.use(timingAttackProtection);
// app.use(resourceEnumerationProtection);

// Rate limiting (différents niveaux selon les routes)
app.use(generalRateLimit);

// Session middleware (doit être avant body parsing)
app.use(sessionConfig);

// Body parsing middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Input validation and sanitization middleware
// app.use(setupSanitizer);
// app.use(validateContentType);
// app.use(validateRequestSize());
// app.use(validateHeaders);
// app.use(validateUrlParams);
// app.use(sanitizeInput);
// app.use(validateJsonData);
// app.use(validateFileUpload);
// app.use(securitySanitizeInput);
// app.use(sqlInjectionProtection);
// app.use(xssProtection);

// CSRF protection middleware
// app.use(csrfProtectionMiddleware);
// app.use(provideCsrfToken);

// Health check endpoint
app.get('/health', async (req, res) => {
  const dbConnected = await testDatabaseConnection();
  
  // Test Redis connection
  let redisConnected = false;
  try {
    const { testRedisConnection } = await import('@/config/redis');
    redisConnected = await testRedisConnection();
  } catch (error) {
    console.warn('Redis not available for health check');
  }
  
  const overallStatus = dbConnected ? 'OK' : 'ERROR';
  
  res.status(dbConnected ? 200 : 503).json({
    status: overallStatus,
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: config.nodeEnv,
    services: {
      database: dbConnected ? 'connected' : 'disconnected',
      redis: redisConnected ? 'connected' : 'disconnected',
    },
  });
});

// Import des routes
import authRoutes from '@/routes/auth';
import reservationRoutes from '@/routes/reservations';
import availabilityRoutes from '@/routes/availability';
import paymentRoutes from '@/routes/payments';
import notificationRoutes from '@/routes/notifications';
import healthRoutes from '@/routes/health';

// API routes
app.get('/', (req, res) => {
  res.json({
    message: 'TechPlus Restaurant Reservation API',
    version: '1.0.0',
    documentation: '/api/docs',
    endpoints: {
      auth: '/api/auth',
      reservations: '/api/reservations',
      availability: '/api/availability',
      payments: '/api/payments',
      health: '/health',
    },
  });
});

// Routes API avec rate limiting spécifique
app.use('/api/auth', authRateLimit, authRoutes);
app.use('/api/reservations', reservationRoutes);
app.use('/api/availability', publicApiRateLimit, availabilityRoutes);
app.use('/api/payments', paymentRoutes);
app.use('/api/notifications', notificationRoutes);
app.use('/api/health', healthCheckMonitoringMiddleware, databaseConnectionMonitoring, healthRoutes);

// Test session endpoint
app.get('/api/test-session', (req, res) => {
  const sessionId = req.sessionID;
  const isAuthenticated = (req.session as any).isAuthenticated || false;
  
  res.json({
    sessionId,
    isAuthenticated,
    sessionData: req.session,
  });
});

// Test endpoint pour créer une session
app.post('/api/test-session', (req, res) => {
  (req.session as any).testData = {
    message: 'Session test data',
    timestamp: new Date().toISOString(),
  };
  
  res.json({
    success: true,
    message: 'Session data set',
    sessionId: req.sessionID,
  });
});

// Test cache endpoint (Redis)
app.get('/api/test-cache', async (req, res) => {
  try {
    const { cacheUtils, testRedisConnection } = await import('@/config/redis');
    
    // Test Redis connection first
    const redisConnected = await testRedisConnection();
    
    if (!redisConnected) {
      res.status(503).json({
        success: false,
        message: 'Redis not available',
        error: 'Redis service is not running or not accessible',
      });
      return;
    }
    
    const testKey = 'test:cache';
    const testValue = { 
      message: 'Hello from cache!', 
      timestamp: new Date().toISOString() 
    };
    
    await cacheUtils.set(testKey, testValue, 60); // 60 secondes
    const cachedValue = await cacheUtils.get(testKey);
    
    res.json({
      success: true,
      message: 'Cache test successful',
      data: {
        set: testValue,
        get: cachedValue,
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Cache test failed',
      error: error instanceof Error ? error.message : 'Unknown error',
    });
  }
});

// Test JWT endpoint
app.get('/api/test-jwt', async (req, res) => {
  try {
    const { jwtService } = await import('@/services/jwt');
    
    const testPayload = {
      userId: 'test-user-123',
      email: 'test@techplus.com',
      role: 'CLIENT',
    };
    
    const tokenPair = jwtService.generateTokenPair(testPayload);
    const decodedAccess = jwtService.verifyAccessToken(tokenPair.accessToken);
    const decodedRefresh = jwtService.verifyRefreshToken(tokenPair.refreshToken);
    
    res.json({
      success: true,
      message: 'JWT test successful',
      data: {
        payload: testPayload,
        accessToken: tokenPair.accessToken,
        refreshToken: tokenPair.refreshToken,
        decodedAccess,
        decodedRefresh,
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'JWT test failed',
      error: error instanceof Error ? error.message : 'Unknown error',
    });
  }
});

// Import des middlewares d'erreur
import { errorHandler, notFoundHandler } from '@/middleware/error';

// Error logging middleware (doit être avant errorHandler)
// app.use(errorLoggingMiddleware);

// Sentry error handler (doit être avant les autres error handlers)
app.use(sentryErrorHandler);

// Error handling middleware
app.use(errorHandler);

// 404 handler
app.use(notFoundHandler);

export default app;