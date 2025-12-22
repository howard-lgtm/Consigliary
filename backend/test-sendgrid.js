require('dotenv').config();
const nodemailer = require('nodemailer');

async function testSendGrid() {
    console.log('🧪 Testing SendGrid Configuration\n');
    console.log('========================================\n');

    // Check environment variables
    console.log('1️⃣ Checking environment variables...');
    const apiKey = process.env.SENDGRID_API_KEY;
    const fromEmail = process.env.SENDGRID_FROM_EMAIL;

    if (!apiKey) {
        console.log('❌ SENDGRID_API_KEY not set in .env file');
        return;
    }
    if (!fromEmail) {
        console.log('❌ SENDGRID_FROM_EMAIL not set in .env file');
        return;
    }

    console.log('✅ SENDGRID_API_KEY:', apiKey.substring(0, 10) + '...');
    console.log('✅ SENDGRID_FROM_EMAIL:', fromEmail);
    console.log('');

    // Create transporter
    console.log('2️⃣ Creating SendGrid transporter...');
    const transporter = nodemailer.createTransport({
        host: 'smtp.sendgrid.net',
        port: 587,
        secure: false,
        auth: {
            user: 'apikey',
            pass: apiKey
        }
    });
    console.log('✅ Transporter created\n');

    // Test connection
    console.log('3️⃣ Testing SMTP connection...');
    try {
        await transporter.verify();
        console.log('✅ SMTP connection successful\n');
    } catch (error) {
        console.log('❌ SMTP connection failed:', error.message);
        return;
    }

    // Send test email
    console.log('4️⃣ Sending test email...');
    console.log(`   From: ${fromEmail}`);
    console.log(`   To: ${fromEmail}`);
    console.log('');

    try {
        const info = await transporter.sendMail({
            from: `"Consigliary Test" <${fromEmail}>`,
            to: fromEmail,
            subject: 'SendGrid Test Email',
            text: 'This is a test email from Consigliary to verify SendGrid integration.',
            html: '<p>This is a <strong>test email</strong> from Consigliary to verify SendGrid integration.</p>'
        });

        console.log('✅ Email sent successfully!');
        console.log('   Message ID:', info.messageId);
        console.log('   Response:', info.response);
        console.log('');
        console.log('========================================');
        console.log('🎉 SendGrid is working correctly!\n');
        console.log('Check your inbox:', fromEmail);
        console.log('');

    } catch (error) {
        console.log('❌ Failed to send email');
        console.log('   Error:', error.message);
        if (error.response) {
            console.log('   Response:', error.response);
        }
    }
}

testSendGrid();
