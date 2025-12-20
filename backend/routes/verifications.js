const express = require('express');
const router = express.Router();
const pool = require('../config/database');
const { authenticateToken } = require('../middleware/auth');
const urlExtractor = require('../services/urlExtractor');
const acrcloudService = require('../services/acrcloud');
const audioExtractor = require('../services/audioExtractor');
const s3Service = require('../services/s3');

// All routes require authentication
router.use(authenticateToken);

// POST /api/v1/verifications - Verify URL with ACRCloud
router.post('/', async (req, res) => {
    try {
        const { videoUrl, trackId } = req.body;

        if (!videoUrl) {
            return res.status(400).json({
                success: false,
                message: 'Video URL is required'
            });
        }

        // Validate URL format
        if (!urlExtractor.isValidUrl(videoUrl)) {
            return res.status(400).json({
                success: false,
                message: 'Invalid URL format'
            });
        }

        // Extract metadata from URL
        let metadata;
        try {
            metadata = await urlExtractor.extractMetadata(videoUrl);
        } catch (error) {
            return res.status(400).json({
                success: false,
                message: error.message
            });
        }

        // If trackId provided, verify ownership
        if (trackId) {
            const trackCheck = await pool.query(
                'SELECT user_id FROM tracks WHERE id = $1',
                [trackId]
            );

            if (trackCheck.rows.length === 0) {
                return res.status(404).json({
                    success: false,
                    message: 'Track not found'
                });
            }

            if (trackCheck.rows[0].user_id !== req.user.userId) {
                return res.status(403).json({
                    success: false,
                    message: 'Not authorized to verify against this track'
                });
            }
        }

        // Create verification record
        const result = await pool.query(
            `INSERT INTO verifications 
             (user_id, track_id, platform, video_url, video_id, video_title, channel_name, channel_url, status)
             VALUES ($1, $2, $3, $4, $5, $6, $7, $8, 'pending')
             RETURNING *`,
            [
                req.user.id,
                trackId || null,
                metadata.platform,
                metadata.videoUrl,
                metadata.videoId,
                metadata.videoTitle,
                metadata.channelName,
                metadata.channelUrl
            ]
        );

        const verification = result.rows[0];

        // Extract audio from video URL
        console.log(`🎵 Starting audio extraction for verification ${verification.id}`);
        let audioData, audioSampleUrl, matchResult;
        
        try {
            // Step 1: Extract audio from video
            audioData = await audioExtractor.extractAudio(videoUrl);
            console.log(`✅ Audio extracted: ${audioData.buffer.length} bytes`);

            // Step 2: Upload audio sample to S3 (TEMPORARILY DISABLED - S3 permissions issue)
            // audioSampleUrl = await s3Service.uploadAudioSample(audioData.buffer, verification.id);
            // console.log(`✅ Audio sample uploaded to S3: ${audioSampleUrl}`);
            audioSampleUrl = null; // Skip S3 for now
            console.log(`⚠️  S3 upload skipped (permissions issue - fix later)`);

            // Step 3: Identify audio with ACRCloud
            matchResult = await acrcloudService.identifyAudio(audioData.buffer);
            console.log(`✅ ACRCloud identification complete`);

            // Step 4: Update verification with results
            const updateQuery = `
                UPDATE verifications 
                SET audio_sample_url = $1,
                    match_found = $2,
                    confidence_score = $3,
                    matched_track_title = $4,
                    matched_artist = $5,
                    view_count = $6,
                    upload_date = $7
                WHERE id = $8
                RETURNING *
            `;

            const updateResult = await pool.query(updateQuery, [
                audioSampleUrl,
                matchResult.found,
                matchResult.confidence ? (matchResult.confidence / 100) : null, // Convert 0-100 to 0-1
                matchResult.trackTitle || null,
                matchResult.artist || null,
                audioData.metadata.viewCount || null,
                audioData.metadata.uploadDate || null,
                verification.id
            ]);

            const updatedVerification = updateResult.rows[0];

            res.status(201).json({
                success: true,
                data: {
                    ...updatedVerification,
                    matchDetails: matchResult
                },
                message: matchResult.found 
                    ? `Match found with ${matchResult.confidence}% confidence` 
                    : 'No match found in your track library'
            });

        } catch (extractionError) {
            console.error('❌ Audio extraction/matching error:', extractionError);
            
            // Update verification with error status
            await pool.query(
                'UPDATE verifications SET status = $1 WHERE id = $2',
                ['error', verification.id]
            );

            return res.status(500).json({
                success: false,
                message: `Audio extraction failed: ${extractionError.message}`,
                data: verification
            });
        }
    } catch (error) {
        console.error('Verification error:', error);
        res.status(500).json({
            success: false,
            message: 'Verification failed'
        });
    }
});

// GET /api/v1/verifications - List verifications
router.get('/', async (req, res) => {
    try {
        const result = await pool.query(
            `SELECT v.*, t.title as track_title, t.artist_name 
             FROM verifications v
             LEFT JOIN tracks t ON v.track_id = t.id
             WHERE v.user_id = $1 
             ORDER BY v.created_at DESC`,
            [req.user.userId]
        );

        res.json({
            success: true,
            data: result.rows
        });
    } catch (error) {
        console.error('Fetch verifications error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to fetch verifications'
        });
    }
});

// GET /api/v1/verifications/:id - Get single verification
router.get('/:id', async (req, res) => {
    try {
        const { id } = req.params;

        const result = await pool.query(
            `SELECT v.*, t.title as track_title, t.artist_name 
             FROM verifications v
             LEFT JOIN tracks t ON v.track_id = t.id
             WHERE v.id = $1 AND v.user_id = $2`,
            [id, req.user.userId]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'Verification not found'
            });
        }

        res.json({
            success: true,
            data: result.rows[0]
        });
    } catch (error) {
        console.error('Fetch verification error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to fetch verification'
        });
    }
});

// PUT /api/v1/verifications/:id/status - Update verification status
router.put('/:id/status', async (req, res) => {
    try {
        const { id } = req.params;
        const { status } = req.body;

        const validStatuses = ['pending', 'confirmed', 'disputed', 'dismissed'];
        if (!validStatuses.includes(status)) {
            return res.status(400).json({
                success: false,
                message: 'Invalid status. Must be one of: pending, confirmed, disputed, dismissed'
            });
        }

        // Verify ownership
        const verificationCheck = await pool.query(
            'SELECT user_id FROM verifications WHERE id = $1',
            [id]
        );

        if (verificationCheck.rows.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'Verification not found'
            });
        }

        if (verificationCheck.rows[0].user_id !== req.user.userId) {
            return res.status(403).json({
                success: false,
                message: 'Not authorized to update this verification'
            });
        }

        const result = await pool.query(
            `UPDATE verifications 
             SET status = $1, reviewed_at = CURRENT_TIMESTAMP
             WHERE id = $2
             RETURNING *`,
            [status, id]
        );

        res.json({
            success: true,
            data: result.rows[0],
            message: 'Verification status updated'
        });
    } catch (error) {
        console.error('Update verification error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to update verification'
        });
    }
});

// DELETE /api/v1/verifications/:id - Delete verification
router.delete('/:id', async (req, res) => {
    try {
        const { id } = req.params;

        // Verify ownership
        const verificationCheck = await pool.query(
            'SELECT user_id FROM verifications WHERE id = $1',
            [id]
        );

        if (verificationCheck.rows.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'Verification not found'
            });
        }

        if (verificationCheck.rows[0].user_id !== req.user.userId) {
            return res.status(403).json({
                success: false,
                message: 'Not authorized to delete this verification'
            });
        }

        await pool.query('DELETE FROM verifications WHERE id = $1', [id]);

        res.json({
            success: true,
            message: 'Verification deleted'
        });
    } catch (error) {
        console.error('Delete verification error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to delete verification'
        });
    }
});

// GET /api/v1/tracks/:trackId/verifications - Get verifications for a track
router.get('/tracks/:trackId/verifications', async (req, res) => {
    try {
        const { trackId } = req.params;

        // Verify track ownership
        const trackCheck = await pool.query(
            'SELECT user_id FROM tracks WHERE id = $1',
            [trackId]
        );

        if (trackCheck.rows.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'Track not found'
            });
        }

        if (trackCheck.rows[0].user_id !== req.user.userId) {
            return res.status(403).json({
                success: false,
                message: 'Not authorized to view verifications for this track'
            });
        }

        const result = await pool.query(
            `SELECT * FROM verifications 
             WHERE track_id = $1 
             ORDER BY created_at DESC`,
            [trackId]
        );

        res.json({
            success: true,
            data: result.rows
        });
    } catch (error) {
        console.error('Fetch track verifications error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to fetch verifications'
        });
    }
});

module.exports = router;
