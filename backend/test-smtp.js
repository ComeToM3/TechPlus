const nodemailer = require('nodemailer');

// Configuration SMTP
const transporter = nodemailer.createTransport({
  host: 'smtp.gmail.com',
  port: 587,
  secure: false,
  auth: {
    user: 'martincsdurand@gmail.com',
    pass: 'xuxsgquenpzncgio'
  }
});

async function testSMTP() {
  try {
    console.log('🧪 Testing SMTP connection...');
    
    // Test de connexion
    await transporter.verify();
    console.log('✅ SMTP connection successful!');
    
    // Test d'envoi d'email
    const info = await transporter.sendMail({
      from: 'noreply@techplus.com',
      to: 'martincsdurand@gmail.com',
      subject: 'Test SMTP - TechPlus',
      text: 'Ceci est un test de configuration SMTP.',
      html: '<p>Ceci est un test de configuration SMTP.</p>'
    });
    
    console.log('✅ Email sent successfully!');
    console.log('📧 Message ID:', info.messageId);
    console.log('📬 Check your inbox: martincsdurand@gmail.com');
    
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
