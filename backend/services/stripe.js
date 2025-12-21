const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);

class StripeService {
  /**
   * Create a Stripe invoice for a license
   * @param {Object} licenseData - License information
   * @returns {Promise<Object>} Stripe invoice
   */
  async createInvoice(licenseData) {
    try {
      // Create or retrieve customer
      const customer = await this.getOrCreateCustomer(
        licenseData.licenseeEmail,
        licenseData.licenseeName
      );

      // Create invoice item
      const invoiceItem = await stripe.invoiceItems.create({
        customer: customer.id,
        amount: Math.round(licenseData.licenseFee * 100), // Convert to cents
        currency: licenseData.currency.toLowerCase(),
        description: `Music License: "${licenseData.trackTitle}" by ${licenseData.trackArtist}`,
        metadata: {
          license_id: licenseData.licenseId,
          track_id: licenseData.trackId,
          user_id: licenseData.userId
        }
      });

      // Create invoice
      const invoice = await stripe.invoices.create({
        customer: customer.id,
        collection_method: 'send_invoice',
        days_until_due: 14,
        description: `License Agreement for "${licenseData.trackTitle}"`,
        metadata: {
          license_id: licenseData.licenseId,
          track_id: licenseData.trackId,
          user_id: licenseData.userId
        },
        footer: 'Thank you for licensing this music. Payment is due within 14 days.'
      });

      // Finalize invoice to make it payable
      const finalizedInvoice = await stripe.invoices.finalizeInvoice(invoice.id);

      return {
        invoiceId: finalizedInvoice.id,
        invoiceUrl: finalizedInvoice.hosted_invoice_url,
        invoicePdf: finalizedInvoice.invoice_pdf,
        status: finalizedInvoice.status,
        amountDue: finalizedInvoice.amount_due / 100,
        dueDate: new Date(finalizedInvoice.due_date * 1000)
      };
    } catch (error) {
      console.error('Stripe invoice creation error:', error);
      throw new Error(`Failed to create Stripe invoice: ${error.message}`);
    }
  }

  /**
   * Get or create a Stripe customer
   * @param {string} email - Customer email
   * @param {string} name - Customer name
   * @returns {Promise<Object>} Stripe customer
   */
  async getOrCreateCustomer(email, name) {
    try {
      // Search for existing customer
      const customers = await stripe.customers.list({
        email: email,
        limit: 1
      });

      if (customers.data.length > 0) {
        return customers.data[0];
      }

      // Create new customer
      return await stripe.customers.create({
        email: email,
        name: name || email,
        description: 'Music license customer'
      });
    } catch (error) {
      console.error('Stripe customer error:', error);
      throw new Error(`Failed to get/create customer: ${error.message}`);
    }
  }

  /**
   * Send invoice via email
   * @param {string} invoiceId - Stripe invoice ID
   * @returns {Promise<Object>} Sent invoice
   */
  async sendInvoice(invoiceId) {
    try {
      const invoice = await stripe.invoices.sendInvoice(invoiceId);
      return {
        invoiceId: invoice.id,
        status: invoice.status,
        sent: true
      };
    } catch (error) {
      console.error('Stripe send invoice error:', error);
      throw new Error(`Failed to send invoice: ${error.message}`);
    }
  }

  /**
   * Get invoice status
   * @param {string} invoiceId - Stripe invoice ID
   * @returns {Promise<Object>} Invoice status
   */
  async getInvoiceStatus(invoiceId) {
    try {
      const invoice = await stripe.invoices.retrieve(invoiceId);
      return {
        invoiceId: invoice.id,
        status: invoice.status,
        paid: invoice.paid,
        amountPaid: invoice.amount_paid / 100,
        amountDue: invoice.amount_due / 100,
        paidAt: invoice.status_transitions.paid_at 
          ? new Date(invoice.status_transitions.paid_at * 1000) 
          : null
      };
    } catch (error) {
      console.error('Stripe get invoice error:', error);
      throw new Error(`Failed to get invoice status: ${error.message}`);
    }
  }

  /**
   * Create a payment intent for immediate payment
   * @param {Object} paymentData - Payment information
   * @returns {Promise<Object>} Payment intent
   */
  async createPaymentIntent(paymentData) {
    try {
      const paymentIntent = await stripe.paymentIntents.create({
        amount: Math.round(paymentData.amount * 100),
        currency: paymentData.currency.toLowerCase(),
        description: paymentData.description,
        metadata: paymentData.metadata || {},
        automatic_payment_methods: {
          enabled: true
        }
      });

      return {
        paymentIntentId: paymentIntent.id,
        clientSecret: paymentIntent.client_secret,
        status: paymentIntent.status
      };
    } catch (error) {
      console.error('Stripe payment intent error:', error);
      throw new Error(`Failed to create payment intent: ${error.message}`);
    }
  }

  /**
   * Verify webhook signature
   * @param {string} payload - Webhook payload
   * @param {string} signature - Stripe signature header
   * @returns {Object} Verified event
   */
  verifyWebhook(payload, signature) {
    try {
      const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET;
      if (!webhookSecret) {
        throw new Error('Stripe webhook secret not configured');
      }

      return stripe.webhooks.constructEvent(payload, signature, webhookSecret);
    } catch (error) {
      console.error('Webhook verification error:', error);
      throw new Error(`Webhook verification failed: ${error.message}`);
    }
  }

  /**
   * Cancel an invoice
   * @param {string} invoiceId - Stripe invoice ID
   * @returns {Promise<Object>} Cancelled invoice
   */
  async cancelInvoice(invoiceId) {
    try {
      const invoice = await stripe.invoices.voidInvoice(invoiceId);
      return {
        invoiceId: invoice.id,
        status: invoice.status,
        cancelled: true
      };
    } catch (error) {
      console.error('Stripe cancel invoice error:', error);
      throw new Error(`Failed to cancel invoice: ${error.message}`);
    }
  }
}

module.exports = new StripeService();
