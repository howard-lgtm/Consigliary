const express = require('express');
const router = express.Router();
const pool = require('../config/database');
const { authenticateToken } = require('../middleware/auth');

// Get all contributors for a track
router.get('/tracks/:trackId/contributors', authenticateToken, async (req, res) => {
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
                message: 'Not authorized to view contributors for this track' 
            });
        }
        
        const result = await pool.query(
            `SELECT id, track_id, name, role, split_percentage, email, 
                    pro_affiliation, signed_at, created_at
             FROM contributors 
             WHERE track_id = $1 
             ORDER BY split_percentage DESC, created_at ASC`,
            [trackId]
        );
        
        res.json({
            success: true,
            data: result.rows
        });
    } catch (error) {
        console.error('Error fetching contributors:', error);
        res.status(500).json({ 
            success: false, 
            message: 'Server error' 
        });
    }
});

// Add contributor to track
router.post('/tracks/:trackId/contributors', authenticateToken, async (req, res) => {
    try {
        const { trackId } = req.params;
        const { name, role, splitPercentage, email, proAffiliation } = req.body;
        
        // Validate required fields
        if (!name || splitPercentage === undefined) {
            return res.status(400).json({ 
                success: false, 
                message: 'Name and split percentage are required' 
            });
        }
        
        // Validate split percentage
        if (splitPercentage < 0 || splitPercentage > 100) {
            return res.status(400).json({ 
                success: false, 
                message: 'Split percentage must be between 0 and 100' 
            });
        }
        
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
                message: 'Not authorized to add contributors to this track' 
            });
        }
        
        // Check total split percentage won't exceed 100%
        const totalSplitResult = await pool.query(
            'SELECT COALESCE(SUM(split_percentage), 0) as total FROM contributors WHERE track_id = $1',
            [trackId]
        );
        
        const currentTotal = parseFloat(totalSplitResult.rows[0].total);
        const newTotal = currentTotal + parseFloat(splitPercentage);
        
        if (newTotal > 100) {
            return res.status(400).json({ 
                success: false, 
                message: `Total split percentage would exceed 100%. Current total: ${currentTotal}%, attempting to add: ${splitPercentage}%` 
            });
        }
        
        // Insert contributor
        const result = await pool.query(
            `INSERT INTO contributors (track_id, name, role, split_percentage, email, pro_affiliation)
             VALUES ($1, $2, $3, $4, $5, $6)
             RETURNING id, track_id, name, role, split_percentage, email, pro_affiliation, signed_at, created_at`,
            [trackId, name, role, splitPercentage, email, proAffiliation]
        );
        
        res.status(201).json({
            success: true,
            data: result.rows[0],
            message: 'Contributor added successfully'
        });
    } catch (error) {
        console.error('Error adding contributor:', error);
        res.status(500).json({ 
            success: false, 
            message: 'Server error' 
        });
    }
});

// Update contributor
router.put('/contributors/:id', authenticateToken, async (req, res) => {
    try {
        const { id } = req.params;
        const { name, role, splitPercentage, email, proAffiliation } = req.body;
        
        // Get contributor and verify track ownership
        const contributorCheck = await pool.query(
            `SELECT c.*, t.user_id 
             FROM contributors c
             JOIN tracks t ON c.track_id = t.id
             WHERE c.id = $1`,
            [id]
        );
        
        if (contributorCheck.rows.length === 0) {
            return res.status(404).json({ 
                success: false, 
                message: 'Contributor not found' 
            });
        }
        
        const contributor = contributorCheck.rows[0];
        
        if (contributor.user_id !== req.user.userId) {
            return res.status(403).json({ 
                success: false, 
                message: 'Not authorized to update this contributor' 
            });
        }
        
        // Validate split percentage if provided
        if (splitPercentage !== undefined) {
            if (splitPercentage < 0 || splitPercentage > 100) {
                return res.status(400).json({ 
                    success: false, 
                    message: 'Split percentage must be between 0 and 100' 
                });
            }
            
            // Check total split percentage won't exceed 100%
            const totalSplitResult = await pool.query(
                'SELECT COALESCE(SUM(split_percentage), 0) as total FROM contributors WHERE track_id = $1 AND id != $2',
                [contributor.track_id, id]
            );
            
            const currentTotal = parseFloat(totalSplitResult.rows[0].total);
            const newTotal = currentTotal + parseFloat(splitPercentage);
            
            if (newTotal > 100) {
                return res.status(400).json({ 
                    success: false, 
                    message: `Total split percentage would exceed 100%. Current total (excluding this contributor): ${currentTotal}%, attempting to set: ${splitPercentage}%` 
                });
            }
        }
        
        // Build update query
        const updates = [];
        const values = [];
        let paramCount = 1;
        
        if (name !== undefined) {
            updates.push(`name = $${paramCount++}`);
            values.push(name);
        }
        if (role !== undefined) {
            updates.push(`role = $${paramCount++}`);
            values.push(role);
        }
        if (splitPercentage !== undefined) {
            updates.push(`split_percentage = $${paramCount++}`);
            values.push(splitPercentage);
        }
        if (email !== undefined) {
            updates.push(`email = $${paramCount++}`);
            values.push(email);
        }
        if (proAffiliation !== undefined) {
            updates.push(`pro_affiliation = $${paramCount++}`);
            values.push(proAffiliation);
        }
        
        if (updates.length === 0) {
            return res.status(400).json({ 
                success: false, 
                message: 'No fields to update' 
            });
        }
        
        values.push(id);
        
        const result = await pool.query(
            `UPDATE contributors 
             SET ${updates.join(', ')}
             WHERE id = $${paramCount}
             RETURNING id, track_id, name, role, split_percentage, email, pro_affiliation, signed_at, created_at`,
            values
        );
        
        res.json({
            success: true,
            data: result.rows[0],
            message: 'Contributor updated successfully'
        });
    } catch (error) {
        console.error('Error updating contributor:', error);
        res.status(500).json({ 
            success: false, 
            message: 'Server error' 
        });
    }
});

// Delete contributor
router.delete('/contributors/:id', authenticateToken, async (req, res) => {
    try {
        const { id } = req.params;
        
        // Get contributor and verify track ownership
        const contributorCheck = await pool.query(
            `SELECT c.*, t.user_id 
             FROM contributors c
             JOIN tracks t ON c.track_id = t.id
             WHERE c.id = $1`,
            [id]
        );
        
        if (contributorCheck.rows.length === 0) {
            return res.status(404).json({ 
                success: false, 
                message: 'Contributor not found' 
            });
        }
        
        if (contributorCheck.rows[0].user_id !== req.user.userId) {
            return res.status(403).json({ 
                success: false, 
                message: 'Not authorized to delete this contributor' 
            });
        }
        
        await pool.query('DELETE FROM contributors WHERE id = $1', [id]);
        
        res.json({
            success: true,
            message: 'Contributor deleted successfully'
        });
    } catch (error) {
        console.error('Error deleting contributor:', error);
        res.status(500).json({ 
            success: false, 
            message: 'Server error' 
        });
    }
});

// Get split sheet summary for a track
router.get('/tracks/:trackId/split-sheet', authenticateToken, async (req, res) => {
    try {
        const { trackId } = req.params;
        
        // Verify track ownership
        const trackCheck = await pool.query(
            'SELECT user_id, title, artist_name FROM tracks WHERE id = $1',
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
                message: 'Not authorized to view split sheet for this track' 
            });
        }
        
        const contributors = await pool.query(
            `SELECT id, name, role, split_percentage, email, pro_affiliation, signed_at
             FROM contributors 
             WHERE track_id = $1 
             ORDER BY split_percentage DESC, created_at ASC`,
            [trackId]
        );
        
        const totalSplit = await pool.query(
            'SELECT COALESCE(SUM(split_percentage), 0) as total FROM contributors WHERE track_id = $1',
            [trackId]
        );
        
        res.json({
            success: true,
            data: {
                track: trackCheck.rows[0],
                contributors: contributors.rows,
                totalSplitPercentage: parseFloat(totalSplit.rows[0].total),
                remainingSplitPercentage: 100 - parseFloat(totalSplit.rows[0].total),
                isComplete: parseFloat(totalSplit.rows[0].total) === 100
            }
        });
    } catch (error) {
        console.error('Error fetching split sheet:', error);
        res.status(500).json({ 
            success: false, 
            message: 'Server error' 
        });
    }
});

module.exports = router;
