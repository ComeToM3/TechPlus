import app from './app';
import { config } from '@/config/environment';
import { disconnectDatabase, testDatabaseConnection } from '@/config/database';
import prisma from '@/config/database';
import { disconnectRedis } from '@/config/redis';
import { setupDatabaseMonitoring, periodicDatabaseLogging } from '@/middleware/database-monitoring';
import { periodicUptimeLogging } from '@/middleware/uptime';

const PORT = config.port || 3000;

// Initialize database connection and start server
const startServer = async () => {
  try {
    // Test database connection first
    console.log('🔄 Testing database connection...');
    const dbConnected = await testDatabaseConnection();
    
    if (!dbConnected) {
      console.warn('⚠️  Database connection failed, but continuing with server startup...');
    }

    // Setup database monitoring
    setupDatabaseMonitoring(prisma);
    
    // Start periodic monitoring
    periodicUptimeLogging();
    periodicDatabaseLogging();

    // Start server
    const server = app.listen(PORT, () => {
      console.log(`🚀 Server running on port ${PORT}`);
      console.log(`📊 Environment: ${config.nodeEnv}`);
      console.log(`🔗 Health check: http://localhost:${PORT}/health`);
      console.log(`🌐 API Base URL: http://localhost:${PORT}`);
      console.log(`💾 Database: ${dbConnected ? 'Connected' : 'Disconnected'}`);
    });

    // Handle server errors
    server.on('error', (error: any) => {
      if (error.code === 'EADDRINUSE') {
        console.error(`❌ Port ${PORT} is already in use`);
        process.exit(1);
      } else {
        console.error('❌ Server error:', error);
        process.exit(1);
      }
    });

  } catch (error) {
    console.error('❌ Failed to start server:', error);
    process.exit(1);
  }
};

// Start the server
startServer();

// Graceful shutdown
process.on('SIGTERM', async () => {
  console.log('SIGTERM received. Shutting down gracefully...');
  await Promise.all([
    disconnectDatabase(),
    disconnectRedis(),
  ]);
  process.exit(0);
});

process.on('SIGINT', async () => {
  console.log('SIGINT received. Shutting down gracefully...');
  await Promise.all([
    disconnectDatabase(),
    disconnectRedis(),
  ]);
  process.exit(0);
});
