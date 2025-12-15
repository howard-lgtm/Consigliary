const express = require('express');
const router = express.Router();
const { query } = require('../config/database');
const { authenticateToken } = require('../middleware/auth');

// All routes require authentication
router.use(authenticateToken);

// POST /api/v1/licenses - Generate license (placeholder for Week 4)
router.post('/', async (req, res) => {
    try {
        // TODO: Week 4 - Implement license generation
        res.json({
            success: true,
            data: {
                message: 'License generation feature coming in Week 4'
            }
        });
    } catch (error) {
        console.error('License generation error:', error);
        res.status(500).json({
            success: false,
            error: {
                code: 'INTERNAL_ERROR',
                message: 'License generation failed'
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

        res.json({
            success: true,
            data: {
                licenses: result.rows
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

module.exports = router;
