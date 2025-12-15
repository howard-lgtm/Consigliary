const express = require('express');
const router = express.Router();
const { query } = require('../config/database');
const { authenticateToken } = require('../middleware/auth');

// All routes require authentication
router.use(authenticateToken);

// POST /api/v1/verifications - Verify URL (placeholder for Week 3)
router.post('/', async (req, res) => {
    try {
        const { videoUrl, platform } = req.body;

        if (!videoUrl || !platform) {
            return res.status(400).json({
                success: false,
                error: {
                    code: 'VALIDATION_ERROR',
                    message: 'Video URL and platform are required'
                }
            });
        }

        // TODO: Week 3 - Implement ACRCloud verification
        // For now, return placeholder response
        res.json({
            success: true,
            data: {
                verification: {
                    videoUrl,
                    platform,
                    matchFound: false,
                    message: 'Verification feature coming in Week 3'
                }
            }
        });
    } catch (error) {
        console.error('Verification error:', error);
        res.status(500).json({
            success: false,
            error: {
                code: 'INTERNAL_ERROR',
                message: 'Verification failed'
            }
        });
    }
});

// GET /api/v1/verifications - List verifications
router.get('/', async (req, res) => {
    try {
        const result = await query(
            `SELECT * FROM verifications 
             WHERE user_id = $1 
             ORDER BY created_at DESC`,
            [req.user.id]
        );

        res.json({
            success: true,
            data: {
                verifications: result.rows
            }
        });
    } catch (error) {
        console.error('Fetch verifications error:', error);
        res.status(500).json({
            success: false,
            error: {
                code: 'INTERNAL_ERROR',
                message: 'Failed to fetch verifications'
            }
        });
    }
});

module.exports = router;
