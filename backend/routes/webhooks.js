const express = require('express');
const router = express.Router();
const { query } = require('../config/database');
const stripeService = require('../services/stripe');
const emailService = require('../services/email');

// Stripe webhook - NO authentication middleware (Stripe validates with signature)
router.post('/stripe', express.raw({ type: 'application/json' }), async (req, res) => {
    const signature = req.headers['stripe-signature'];

    try {
        // Verify webhook signature
        const event = stripeService.verifyWebhook(req.body, signature);
        
        console.log('📨 Stripe webhook received:', event.type);

        // Handle different event types
        switch (event.type) {
            case 'invoice.paid':
                await handleInvoicePaid(event.data.object);
                break;
            
            case 'invoice.payment_failed':
                await handleInvoicePaymentFailed(event.data.object);
                break;
            
            case 'invoice.finalized':
                await handleInvoiceFinalized(event.data.object);
                break;
            
            case 'invoice.sent':
                await handleInvoiceSent(event.data.object);
                break;
            
            case 'payment_intent.succeeded':
                await handlePaymentIntentSucceeded(event.data.object);
                break;
            
            case 'payment_intent.payment_failed':
                await handlePaymentIntentFailed(event.data.object);
                break;
            
            default:
                console.log(`⚠️  Unhandled event type: ${event.type}`);
        }

        res.json({ received: true });
    } catch (error) {
        console.error('❌ Webhook error:', error);
        res.status(400).json({ error: error.message });
    }
});

/**
 * Handle invoice paid event
 */
async function handleInvoicePaid(invoice) {
    try {
        const licenseId = invoice.metadata?.license_id;
        if (!licenseId) {
            console.log('⚠️  No license_id in invoice metadata');
            return;
        }

        console.log(`💰 Invoice paid for license: ${licenseId}`);

        // Update license payment status
        await query(
            `UPDATE licenses 
             SET payment_status = 'paid', 
                 paid_at = CURRENT_TIMESTAMP,
                 status = CASE WHEN status = 'draft' THEN 'sent' ELSE status END
             WHERE id = $1`,
            [licenseId]
        );

        // Get license details for revenue event
        const licenseResult = await query(
            'SELECT * FROM licenses WHERE id = $1',
            [licenseId]
        );

        if (licenseResult.rows.length > 0) {
            const license = licenseResult.rows[0];

            // Create revenue event
            await query(
                `INSERT INTO revenue_events (
                    user_id, track_id, license_id, source, amount, currency, date, description, payment_status
                ) VALUES ($1, $2, $3, $4, $5, $6, CURRENT_TIMESTAMP, $7, 'paid')`,
                [
                    license.user_id,
                    license.track_id,
                    license.id,
                    'syncLicense',
                    license.license_fee,
                    license.currency,
                    `License payment for "${license.licensee_email}"`
                ]
            );

            // Update track revenue
            await query(
                `UPDATE tracks 
                 SET revenue = revenue + $1 
                 WHERE id = $2`,
                [license.license_fee, license.track_id]
            );

            // Get user and track details for confirmation email
            const userResult = await query(
                'SELECT name, email, artist_name FROM users WHERE id = $1',
                [license.user_id]
            );
            
            const trackResult = await query(
                'SELECT title FROM tracks WHERE id = $1',
                [license.track_id]
            );

            if (userResult.rows.length > 0 && trackResult.rows.length > 0) {
                const user = userResult.rows[0];
                const track = trackResult.rows[0];

                // Send payment confirmation email to licensee
                try {
                    await emailService.sendPaymentConfirmation({
                        to: license.licensee_email,
                        licensorName: user.artist_name || user.name,
                        licensorEmail: user.email,
                        trackTitle: track.title,
                        amount: parseFloat(license.license_fee),
                        currency: license.currency,
                        pdfUrl: license.pdf_url
                    });
                    console.log('✅ Payment confirmation email sent');
                } catch (emailError) {
                    console.error('⚠️  Failed to send confirmation email:', emailError.message);
                }
            }

            console.log('✅ License payment processed successfully');
        }
    } catch (error) {
        console.error('❌ Error handling invoice paid:', error);
        throw error;
    }
}

/**
 * Handle invoice payment failed event
 */
async function handleInvoicePaymentFailed(invoice) {
    try {
        const licenseId = invoice.metadata?.license_id;
        if (!licenseId) return;

        console.log(`⚠️  Payment failed for license: ${licenseId}`);

        await query(
            `UPDATE licenses 
             SET payment_status = 'failed' 
             WHERE id = $1`,
            [licenseId]
        );
    } catch (error) {
        console.error('❌ Error handling payment failed:', error);
    }
}

/**
 * Handle invoice finalized event
 */
async function handleInvoiceFinalized(invoice) {
    try {
        const licenseId = invoice.metadata?.license_id;
        if (!licenseId) return;

        console.log(`📋 Invoice finalized for license: ${licenseId}`);

        await query(
            `UPDATE licenses 
             SET stripe_invoice_id = $1 
             WHERE id = $2`,
            [invoice.id, licenseId]
        );
    } catch (error) {
        console.error('❌ Error handling invoice finalized:', error);
    }
}

/**
 * Handle invoice sent event
 */
async function handleInvoiceSent(invoice) {
    try {
        const licenseId = invoice.metadata?.license_id;
        if (!licenseId) return;

        console.log(`📧 Invoice sent for license: ${licenseId}`);

        await query(
            `UPDATE licenses 
             SET status = 'sent', 
                 sent_at = CURRENT_TIMESTAMP 
             WHERE id = $1`,
            [licenseId]
        );
    } catch (error) {
        console.error('❌ Error handling invoice sent:', error);
    }
}

/**
 * Handle payment intent succeeded
 */
async function handlePaymentIntentSucceeded(paymentIntent) {
    try {
        const licenseId = paymentIntent.metadata?.license_id;
        if (!licenseId) return;

        console.log(`✅ Payment succeeded for license: ${licenseId}`);

        await query(
            `UPDATE licenses 
             SET stripe_payment_intent_id = $1,
                 payment_status = 'paid',
                 paid_at = CURRENT_TIMESTAMP
             WHERE id = $2`,
            [paymentIntent.id, licenseId]
        );
    } catch (error) {
        console.error('❌ Error handling payment intent succeeded:', error);
    }
}

/**
 * Handle payment intent failed
 */
async function handlePaymentIntentFailed(paymentIntent) {
    try {
        const licenseId = paymentIntent.metadata?.license_id;
        if (!licenseId) return;

        console.log(`❌ Payment failed for license: ${licenseId}`);

        await query(
            `UPDATE licenses 
             SET payment_status = 'failed' 
             WHERE id = $1`,
            [licenseId]
        );
    } catch (error) {
        console.error('❌ Error handling payment intent failed:', error);
    }
}

module.exports = router;
