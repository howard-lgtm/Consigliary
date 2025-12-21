const nodemailer = require('nodemailer');

class EmailService {
  constructor() {
    // Configure SendGrid SMTP transport
    this.transporter = nodemailer.createTransport({
      host: 'smtp.sendgrid.net',
      port: 587,
      secure: false,
      auth: {
        user: 'apikey',
        pass: process.env.SENDGRID_API_KEY
      }
    });
  }

  /**
   * Send license invoice email
   * @param {Object} emailData - Email information
   * @returns {Promise<Object>} Email result
   */
  async sendLicenseInvoice(emailData) {
    try {
      const {
        to,
        licensorName,
        licensorEmail,
        trackTitle,
        trackArtist,
        licenseFee,
        currency,
        pdfUrl,
        stripeInvoiceUrl,
        licenseId
      } = emailData;

      const subject = `Music License Invoice: "${trackTitle}" by ${trackArtist}`;
      
      const htmlContent = this.generateLicenseInvoiceHTML({
        licensorName,
        trackTitle,
        trackArtist,
        licenseFee,
        currency,
        pdfUrl,
        stripeInvoiceUrl
      });

      const textContent = this.generateLicenseInvoiceText({
        licensorName,
        trackTitle,
        trackArtist,
        licenseFee,
        currency,
        pdfUrl,
        stripeInvoiceUrl
      });

      const mailOptions = {
        from: `${licensorName} <${process.env.SENDGRID_FROM_EMAIL || licensorEmail}>`,
        to: to,
        subject: subject,
        text: textContent,
        html: htmlContent,
        headers: {
          'X-License-ID': licenseId
        }
      };

      const result = await this.transporter.sendMail(mailOptions);
      
      console.log('✅ License invoice email sent:', result.messageId);
      
      return {
        success: true,
        messageId: result.messageId,
        to: to
      };
    } catch (error) {
      console.error('❌ Email sending error:', error);
      throw new Error(`Failed to send email: ${error.message}`);
    }
  }

  /**
   * Generate HTML email template for license invoice
   */
  generateLicenseInvoiceHTML(data) {
    return `
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Music License Invoice</title>
  <style>
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
      line-height: 1.6;
      color: #333;
      max-width: 600px;
      margin: 0 auto;
      padding: 20px;
      background-color: #f5f5f5;
    }
    .container {
      background-color: white;
      border-radius: 8px;
      padding: 40px;
      box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }
    .header {
      text-align: center;
      margin-bottom: 30px;
      padding-bottom: 20px;
      border-bottom: 2px solid #4F46E5;
    }
    .header h1 {
      color: #4F46E5;
      margin: 0;
      font-size: 28px;
    }
    .content {
      margin: 30px 0;
    }
    .track-info {
      background-color: #F9FAFB;
      padding: 20px;
      border-radius: 6px;
      margin: 20px 0;
    }
    .track-info h2 {
      margin-top: 0;
      color: #1F2937;
      font-size: 20px;
    }
    .amount {
      font-size: 32px;
      font-weight: bold;
      color: #4F46E5;
      text-align: center;
      margin: 30px 0;
    }
    .button {
      display: inline-block;
      padding: 14px 28px;
      background-color: #4F46E5;
      color: white;
      text-decoration: none;
      border-radius: 6px;
      font-weight: 600;
      text-align: center;
      margin: 10px 5px;
    }
    .button:hover {
      background-color: #4338CA;
    }
    .button-secondary {
      background-color: #6B7280;
    }
    .button-secondary:hover {
      background-color: #4B5563;
    }
    .buttons {
      text-align: center;
      margin: 30px 0;
    }
    .footer {
      margin-top: 40px;
      padding-top: 20px;
      border-top: 1px solid #E5E7EB;
      text-align: center;
      color: #6B7280;
      font-size: 14px;
    }
    .notice {
      background-color: #FEF3C7;
      border-left: 4px solid #F59E0B;
      padding: 15px;
      margin: 20px 0;
      border-radius: 4px;
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>🎵 Music License Invoice</h1>
      <p>Unauthorized Usage Detected</p>
    </div>

    <div class="content">
      <p>Hello,</p>
      
      <p>This is <strong>${data.licensorName}</strong>, the copyright owner of the musical work used in your content.</p>

      <div class="track-info">
        <h2>Licensed Musical Work</h2>
        <p><strong>Title:</strong> ${data.trackTitle}</p>
        <p><strong>Artist:</strong> ${data.trackArtist}</p>
        <p><strong>Copyright Owner:</strong> ${data.licensorName}</p>
      </div>

      <p>We've detected that you're using this copyrighted music in your content without proper authorization. To continue using this music legally, please purchase a license.</p>

      <div class="amount">
        ${data.currency} $${data.licenseFee.toFixed(2)}
      </div>

      <div class="notice">
        <strong>⚠️ Payment Due:</strong> Payment is due within 14 days of receiving this invoice. Failure to pay may result in license termination and potential legal action.
      </div>

      <div class="buttons">
        ${data.stripeInvoiceUrl ? `
        <a href="${data.stripeInvoiceUrl}" class="button">Pay Invoice Online</a>
        ` : ''}
        <a href="${data.pdfUrl}" class="button button-secondary">Download License Agreement (PDF)</a>
      </div>

      <p><strong>What happens after payment:</strong></p>
      <ul>
        <li>You'll receive a signed license agreement</li>
        <li>Your content will be legally licensed</li>
        <li>No copyright claims or takedowns</li>
        <li>Peace of mind for your channel</li>
      </ul>

      <p><strong>Questions?</strong> Reply to this email and I'll be happy to discuss the license terms or answer any questions you may have.</p>

      <p>Best regards,<br>
      <strong>${data.licensorName}</strong></p>
    </div>

    <div class="footer">
      <p>This invoice was generated by Consigliary</p>
      <p>© ${new Date().getFullYear()} All Rights Reserved</p>
    </div>
  </div>
</body>
</html>
    `.trim();
  }

  /**
   * Generate plain text email template for license invoice
   */
  generateLicenseInvoiceText(data) {
    return `
MUSIC LICENSE INVOICE
=====================

Hello,

This is ${data.licensorName}, the copyright owner of the musical work used in your content.

LICENSED MUSICAL WORK
---------------------
Title: ${data.trackTitle}
Artist: ${data.trackArtist}
Copyright Owner: ${data.licensorName}

We've detected that you're using this copyrighted music in your content without proper authorization. To continue using this music legally, please purchase a license.

LICENSE FEE: ${data.currency} $${data.licenseFee.toFixed(2)}

⚠️ PAYMENT DUE: Payment is due within 14 days of receiving this invoice. Failure to pay may result in license termination and potential legal action.

${data.stripeInvoiceUrl ? `
PAY ONLINE: ${data.stripeInvoiceUrl}
` : ''}

DOWNLOAD LICENSE AGREEMENT (PDF): ${data.pdfUrl}

WHAT HAPPENS AFTER PAYMENT:
- You'll receive a signed license agreement
- Your content will be legally licensed
- No copyright claims or takedowns
- Peace of mind for your channel

Questions? Reply to this email and I'll be happy to discuss the license terms or answer any questions you may have.

Best regards,
${data.licensorName}

---
This invoice was generated by Consigliary
© ${new Date().getFullYear()} All Rights Reserved
    `.trim();
  }

  /**
   * Send payment confirmation email
   * @param {Object} emailData - Email information
   * @returns {Promise<Object>} Email result
   */
  async sendPaymentConfirmation(emailData) {
    try {
      const {
        to,
        licensorName,
        licensorEmail,
        trackTitle,
        amount,
        currency,
        pdfUrl
      } = emailData;

      const subject = `Payment Received: License for "${trackTitle}"`;
      
      const htmlContent = `
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <style>
    body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px; }
    .container { background-color: #f9f9f9; border-radius: 8px; padding: 30px; }
    .header { text-align: center; color: #10B981; margin-bottom: 30px; }
    .content { background-color: white; padding: 20px; border-radius: 6px; }
    .footer { margin-top: 30px; text-align: center; color: #666; font-size: 14px; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>✅ Payment Received!</h1>
    </div>
    <div class="content">
      <p>Hello,</p>
      <p>Thank you for your payment! Your license for <strong>"${trackTitle}"</strong> is now active.</p>
      <p><strong>Amount Paid:</strong> ${currency} $${amount.toFixed(2)}</p>
      <p><strong>License Agreement:</strong> <a href="${pdfUrl}">Download PDF</a></p>
      <p>You may now use this music in your content legally. Keep this email and the license agreement for your records.</p>
      <p>Thank you for respecting copyright and supporting independent artists!</p>
      <p>Best regards,<br>${licensorName}</p>
    </div>
    <div class="footer">
      <p>© ${new Date().getFullYear()} Consigliary</p>
    </div>
  </div>
</body>
</html>
      `.trim();

      const textContent = `
PAYMENT RECEIVED
================

Hello,

Thank you for your payment! Your license for "${trackTitle}" is now active.

Amount Paid: ${currency} $${amount.toFixed(2)}

License Agreement: ${pdfUrl}

You may now use this music in your content legally. Keep this email and the license agreement for your records.

Thank you for respecting copyright and supporting independent artists!

Best regards,
${licensorName}

---
© ${new Date().getFullYear()} Consigliary
      `.trim();

      const mailOptions = {
        from: `${licensorName} <${process.env.SENDGRID_FROM_EMAIL || licensorEmail}>`,
        to: to,
        subject: subject,
        text: textContent,
        html: htmlContent
      };

      const result = await this.transporter.sendMail(mailOptions);
      
      console.log('✅ Payment confirmation email sent:', result.messageId);
      
      return {
        success: true,
        messageId: result.messageId,
        to: to
      };
    } catch (error) {
      console.error('❌ Email sending error:', error);
      throw new Error(`Failed to send confirmation email: ${error.message}`);
    }
  }

  /**
   * Test email configuration
   * @returns {Promise<boolean>} Test result
   */
  async testConnection() {
    try {
      await this.transporter.verify();
      console.log('✅ Email service connection successful');
      return true;
    } catch (error) {
      console.error('❌ Email service connection failed:', error.message);
      return false;
    }
  }
}

module.exports = new EmailService();
