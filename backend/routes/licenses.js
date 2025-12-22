const express = require('express');
const router = express.Router();
const { query } = require('../config/database');
const { authenticateToken } = require('../middleware/auth');
const licensePDF = require('../services/licensePDF');
const s3Service = require('../services/s3');
const stripeService = require('../services/stripe');
const emailService = require('../services/email');

// All routes require authentication
router.use(authenticateToken);

// POST /api/v1/licenses - Generate license
router.post('/', async (req, res) => {
    try {
        const {
            trackId,
            verificationId,
            licenseeName,
            licenseeEmail,
            licenseePlatform,
            licenseeChannelUrl,
            licenseFee,
            currency = 'USD',
            territory = 'Worldwide',
            duration = 'Perpetual',
            exclusivity = 'non-exclusive',
            sendEmail = true
        } = req.body;

        // Validation
        if (!trackId || !licenseeEmail || !licenseFee) {
            return res.status(400).json({
                success: false,
                error: {
                    code: 'VALIDATION_ERROR',
                    message: 'Track ID, licensee email, and license fee are required'
                }
            });
        }

        // Get track details
        const trackResult = await query(
            'SELECT * FROM tracks WHERE id = $1 AND user_id = $2',
            [trackId, req.user.id]
        );

        if (trackResult.rows.length === 0) {
            return res.status(404).json({
                success: false,
                error: {
                    code: 'NOT_FOUND',
                    message: 'Track not found'
                }
            });
        }

        const track = trackResult.rows[0];

        // Get user details
        const userResult = await query(
            'SELECT name, email, artist_name FROM users WHERE id = $1',
            [req.user.id]
        );
        const user = userResult.rows[0];

        // Get verification details if provided
        let verification = null;
        if (verificationId) {
            const verificationResult = await query(
                'SELECT * FROM verifications WHERE id = $1 AND user_id = $2',
                [verificationId, req.user.id]
            );
            if (verificationResult.rows.length > 0) {
                verification = verificationResult.rows[0];
            }
        }

        // Generate license ID
        const licenseId = require('crypto').randomUUID();

        // Prepare PDF data
        const pdfData = {
            licenseId,
            createdAt: new Date(),
            licensorName: user.artist_name || user.name,
            licensorEmail: user.email,
            licenseeName,
            licenseeEmail,
            licenseePlatform: licenseePlatform || verification?.platform || 'Unknown',
            licenseeChannelUrl: licenseeChannelUrl || verification?.channel_url,
            trackTitle: track.title,
            trackArtist: track.artist_name,
            copyrightOwner: track.copyright_owner,
            copyrightYear: track.copyright_year,
            videoUrl: verification?.video_url || 'N/A',
            videoTitle: verification?.video_title,
            platform: verification?.platform || licenseePlatform || 'Unknown',
            viewCount: verification?.view_count,
            licenseFee: parseFloat(licenseFee),
            currency,
            territory,
            duration,
            exclusivity
        };

        // Generate PDF
        console.log('📄 Generating license PDF...');
        const pdfBuffer = await licensePDF.generateLicensePDF(pdfData);

        // Upload PDF to S3
        console.log('☁️  Uploading PDF to S3...');
        const s3Result = await s3Service.uploadAudioFile(
            pdfBuffer,
            req.user.id,
            licenseId,
            `license_${licenseId}.pdf`
        );

        // Create Stripe invoice
        let stripeInvoice = null;
        try {
            console.log('💳 Creating Stripe invoice...');
            stripeInvoice = await stripeService.createInvoice({
                licenseId,
                userId: req.user.id,
                trackId,
                trackTitle: track.title,
                trackArtist: track.artist_name,
                licenseeName,
                licenseeEmail,
                licenseFee: parseFloat(licenseFee),
                currency
            });
            console.log('✅ Stripe invoice created:', stripeInvoice.invoiceId);
        } catch (stripeError) {
            console.error('⚠️  Stripe invoice creation failed:', stripeError.message);
            // Continue without Stripe - license can still be generated
        }

        // Create license record
        const result = await query(
            `INSERT INTO licenses (
                id, user_id, track_id, verification_id,
                licensee_name, licensee_email, licensee_platform, licensee_channel_url,
                license_fee, currency, territory, duration, exclusivity,
                pdf_url, status, stripe_invoice_id
            ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16)
            RETURNING *`,
            [
                licenseId, req.user.id, trackId, verificationId,
                licenseeName, licenseeEmail, licenseePlatform, licenseeChannelUrl,
                licenseFee, currency, territory, duration, exclusivity,
                s3Result.url, 'draft', stripeInvoice?.invoiceId || null
            ]
        );

        // Send email if requested
        let emailSent = false;
        if (sendEmail) {
            try {
                console.log('📧 Sending license invoice email...');
                await emailService.sendLicenseInvoice({
                    to: licenseeEmail,
                    licensorName: user.artist_name || user.name,
                    licensorEmail: user.email,
                    trackTitle: track.title,
                    trackArtist: track.artist_name,
                    licenseFee: parseFloat(licenseFee),
                    currency,
                    pdfUrl: s3Result.url,
                    stripeInvoiceUrl: stripeInvoice?.invoiceUrl,
                    licenseId
                });
                
                // Update license status to 'sent'
                await query(
                    `UPDATE licenses SET status = 'sent', sent_at = CURRENT_TIMESTAMP WHERE id = $1`,
                    [licenseId]
                );
                
                emailSent = true;
                console.log('✅ License invoice email sent successfully');
            } catch (emailError) {
                console.error('⚠️  Email sending failed:', emailError.message);
                // Continue even if email fails - license is still created
            }
        }

        // Generate pre-signed URL for PDF access (valid for 7 days)
        const pdfKey = s3Result.key;
        const signedPdfUrl = await s3Service.getSignedUrl(pdfKey, 604800); // 7 days

        res.status(201).json({
            success: true,
            data: {
                license: result.rows[0],
                pdfUrl: signedPdfUrl,
                stripeInvoiceUrl: stripeInvoice?.invoiceUrl || null,
                stripeInvoiceId: stripeInvoice?.invoiceId || null,
                emailSent
            },
            message: emailSent 
                ? 'License generated and email sent successfully' 
                : 'License generated successfully'
        });
    } catch (error) {
        console.error('License generation error:', error);
        res.status(500).json({
            success: false,
            error: {
                code: 'INTERNAL_ERROR',
                message: error.message || 'License generation failed'
            }
        });
    }
});

// GET /api/v1/licenses - List licenses
router.get('/', async (req, res) => {
    try {
        const result = await query(
            `SELECT * FROM licenses 
             WHERE user_id = $1 
             ORDER BY created_at DESC`,
            [req.user.id]
        );

        // Generate pre-signed URLs for all PDFs
        const licensesWithSignedUrls = await Promise.all(
            result.rows.map(async (license) => {
                if (license.pdf_url) {
                    try {
                        const key = license.pdf_url.split('.amazonaws.com/')[1];
                        const signedUrl = await s3Service.getSignedUrl(key, 604800);
                        return { ...license, pdf_url: signedUrl };
                    } catch (error) {
                        console.error('Failed to generate signed URL:', error);
                        return license;
                    }
                }
                return license;
            })
        );

        res.json({
            success: true,
            data: {
                licenses: licensesWithSignedUrls
            }
        });
    } catch (error) {
        console.error('Fetch licenses error:', error);
        res.status(500).json({
            success: false,
            error: {
                code: 'INTERNAL_ERROR',
                message: 'Failed to fetch licenses'
            }
        });
    }
});

// GET /api/v1/licenses/:id - Get single license
router.get('/:id', async (req, res) => {
    try {
        const result = await query(
            'SELECT * FROM licenses WHERE id = $1 AND user_id = $2',
            [req.params.id, req.user.id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({
                success: false,
                error: {
                    code: 'NOT_FOUND',
                    message: 'License not found'
                }
            });
        }

        const license = result.rows[0];
        
        // Generate pre-signed URL for PDF if it exists
        if (license.pdf_url) {
            try {
                const key = license.pdf_url.split('.amazonaws.com/')[1];
                const signedUrl = await s3Service.getSignedUrl(key, 604800);
                license.pdf_url = signedUrl;
            } catch (error) {
                console.error('Failed to generate signed URL:', error);
            }
        }

        res.json({
            success: true,
            data: {
                license
            }
        });
    } catch (error) {
        console.error('Fetch license error:', error);
        res.status(500).json({
            success: false,
            error: {
                code: 'INTERNAL_ERROR',
                message: 'Failed to fetch license'
            }
        });
    }
});

// PUT /api/v1/licenses/:id - Update license status
router.put('/:id', async (req, res) => {
    try {
        const { status, paymentStatus } = req.body;

        // Verify ownership
        const existing = await query(
            'SELECT id FROM licenses WHERE id = $1 AND user_id = $2',
            [req.params.id, req.user.id]
        );

        if (existing.rows.length === 0) {
            return res.status(404).json({
                success: false,
                error: {
                    code: 'NOT_FOUND',
                    message: 'License not found'
                }
            });
        }

        // Build update query dynamically
        const updates = [];
        const values = [];
        let paramCount = 1;

        if (status) {
            updates.push(`status = $${paramCount}`);
            values.push(status);
            paramCount++;

            // Set sent_at if status is 'sent'
            if (status === 'sent') {
                updates.push(`sent_at = CURRENT_TIMESTAMP`);
            }
        }

        if (paymentStatus) {
            updates.push(`payment_status = $${paramCount}`);
            values.push(paymentStatus);
            paramCount++;

            // Set paid_at if payment_status is 'paid'
            if (paymentStatus === 'paid') {
                updates.push(`paid_at = CURRENT_TIMESTAMP`);
            }
        }

        if (updates.length === 0) {
            return res.status(400).json({
                success: false,
                error: {
                    code: 'VALIDATION_ERROR',
                    message: 'No valid fields to update'
                }
            });
        }

        values.push(req.params.id, req.user.id);
        const result = await query(
            `UPDATE licenses SET ${updates.join(', ')} 
             WHERE id = $${paramCount} AND user_id = $${paramCount + 1}
             RETURNING *`,
            values
        );

        res.json({
            success: true,
            data: {
                license: result.rows[0]
            },
            message: 'License updated successfully'
        });
    } catch (error) {
        console.error('Update license error:', error);
        res.status(500).json({
            success: false,
            error: {
                code: 'INTERNAL_ERROR',
                message: 'Failed to update license'
            }
        });
    }
});

module.exports = router;
