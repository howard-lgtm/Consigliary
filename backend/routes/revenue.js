const express = require('express');
const router = express.Router();
const { query } = require('../config/database');
const { authenticateToken } = require('../middleware/auth');

// All routes require authentication
router.use(authenticateToken);

// GET /api/v1/revenue - List revenue events
router.get('/', async (req, res) => {
    try {
        const result = await query(
            `SELECT * FROM revenue_events 
             WHERE user_id = $1 
             ORDER BY date DESC`,
            [req.user.id]
        );

        res.json({
            success: true,
            data: {
                revenueEvents: result.rows
            }
        });
    } catch (error) {
        console.error('Fetch revenue error:', error);
        res.status(500).json({
            success: false,
            error: {
                code: 'INTERNAL_ERROR',
                message: 'Failed to fetch revenue'
            }
        });
    }
});

// GET /api/v1/revenue/summary - Get revenue summary
router.get('/summary', async (req, res) => {
    try {
        const result = await query(
            `SELECT 
                SUM(amount) as total_revenue,
                SUM(CASE WHEN source = 'streaming' THEN amount ELSE 0 END) as streaming_revenue,
                SUM(CASE WHEN source = 'syncLicense' THEN amount ELSE 0 END) as sync_revenue,
                SUM(CASE WHEN source = 'performanceRights' THEN amount ELSE 0 END) as performance_revenue,
                COUNT(*) as total_events
             FROM revenue_events 
             WHERE user_id = $1`,
            [req.user.id]
        );

        res.json({
            success: true,
            data: {
                summary: result.rows[0]
            }
        });
    } catch (error) {
        console.error('Fetch revenue summary error:', error);
        res.status(500).json({
            success: false,
            error: {
                code: 'INTERNAL_ERROR',
                message: 'Failed to fetch revenue summary'
            }
        });
    }
});

module.exports = router;
