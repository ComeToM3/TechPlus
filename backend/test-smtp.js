/**
 * SMTP Test Script
 * 
 * ⚠️  SECURITY WARNING: This file should never contain hardcoded credentials!
 * All SMTP credentials must be provided via environment variables.
 * 
 * Required environment variables:
 * - SMTP_USER: Your email address
 * - SMTP_PASS: Your email password or app password
 * 
 * Optional environment variables:
 * - SMTP_HOST: SMTP server host (default: smtp.gmail.com)
 * - SMTP_PORT: SMTP server port (default: 587)
 * - SMTP_SECURE: Use SSL/TLS (default: false)
 * - SMTP_FROM: From email address (default: noreply@techplus.com)
 * - SMTP_TEST_EMAIL: Test recipient email (default: SMTP_USER)
 */

const nodemailer = require('nodemailer');

// Configuration SMTP - Using environment variables for security
const transporter = nodemailer.createTransport({
  host: process.env.SMTP_HOST || 'smtp.gmail.com',
  port: parseInt(process.env.SMTP_PORT || '587'),
  secure: process.env.SMTP_SECURE === 'true',
  auth: {
    user: process.env.SMTP_USER,
    pass: process.env.SMTP_PASS
  }
});

async function testSMTP() {
  try {
    // Vérification des variables d'environnement requises
    if (!process.env.SMTP_USER || !process.env.SMTP_PASS) {
      console.error('❌ SMTP credentials not configured!');
      console.log('🔧 Please set the following environment variables:');
      console.log('   SMTP_USER=your-email@gmail.com');
      console.log('   SMTP_PASS=your-app-password');
      console.log('   SMTP_HOST=smtp.gmail.com (optional)');
      console.log('   SMTP_PORT=587 (optional)');
      console.log('   SMTP_SECURE=false (optional)');
      console.log('   SMTP_FROM=noreply@techplus.com (optional)');
      console.log('   SMTP_TEST_EMAIL=test@example.com (optional)');
      return;
    }
    
    console.log('🧪 Testing SMTP connection...');
    
    // Test de connexion
    await transporter.verify();
    console.log('✅ SMTP connection successful!');
    
    // Test d'envoi d'email
    const info = await transporter.sendMail({
      from: process.env.SMTP_FROM || 'noreply@techplus.com',
      to: process.env.SMTP_TEST_EMAIL || process.env.SMTP_USER,
      subject: 'Test SMTP - TechPlus',
      text: 'Ceci est un test de configuration SMTP.',
      html: '<p>Ceci est un test de configuration SMTP.</p>'
    });
    
    console.log('✅ Email sent successfully!');
    console.log('📧 Message ID:', info.messageId);
    console.log('📬 Check your inbox:', process.env.SMTP_TEST_EMAIL || process.env.SMTP_USER);
    
  } catch (error) {
    console.error('❌ SMTP test failed:', error.message);
    
    if (error.message.includes('Invalid login')) {
      console.log('🔧 Solution: Vérifiez votre mot de passe d\'application');
    } else if (error.message.includes('Authentication failed')) {
      console.log('🔧 Solution: Activez l\'authentification à 2 facteurs');
    } else if (error.message.includes('Connection timeout')) {
      console.log('🔧 Solution: Vérifiez votre connexion internet');
    }
  }
}

testSMTP();
