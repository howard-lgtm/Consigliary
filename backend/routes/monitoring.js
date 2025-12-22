const express = require('express');
const router = express.Router();
const { query } = require('../config/database');
const { authenticateToken } = require('../middleware/auth');
const youtubeMonitor = require('../services/youtubeMonitor');

// All routes require authentication
router.use(authenticateToken);

// POST /api/v1/monitoring/jobs - Create or update monitoring job for a track
router.post('/jobs', async (req, res) => {
  try {
    const { trackId, enabled, frequency, platforms } = req.body;

    if (!trackId) {
      return res.status(400).json({
        success: false,
        error: { code: 'VALIDATION_ERROR', message: 'Track ID is required' }
      });
    }

    // Verify track ownership
    const trackResult = await query(
      'SELECT * FROM tracks WHERE id = $1 AND user_id = $2',
      [trackId, req.user.id]
    );

    if (trackResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: { code: 'NOT_FOUND', message: 'Track not found' }
      });
    }

    const track = trackResult.rows[0];

    // Check if job exists
    const existingJob = await query(
      'SELECT * FROM monitoring_jobs WHERE track_id = $1',
      [trackId]
    );

    let job;
    if (existingJob.rows.length > 0) {
      // Update existing job
      const updateResult = await query(
        `UPDATE monitoring_jobs 
         SET enabled = COALESCE($1, enabled),
             frequency = COALESCE($2, frequency),
             platforms = COALESCE($3, platforms),
             updated_at = CURRENT_TIMESTAMP
         WHERE track_id = $4
         RETURNING *`,
        [enabled, frequency, platforms, trackId]
      );
      job = updateResult.rows[0];
    } else {
      // Create new job
      const createResult = await query(
        `INSERT INTO monitoring_jobs (
          user_id, track_id, enabled, frequency, platforms,
          search_terms, next_run_at
        ) VALUES ($1, $2, $3, $4, $5, $6, CURRENT_TIMESTAMP)
        RETURNING *`,
        [
          req.user.id,
          trackId,
          enabled !== undefined ? enabled : true,
          frequency || 'weekly',
          platforms || ['YouTube', 'TikTok', 'Instagram'],
          [track.title, track.artist_name]
        ]
      );
      job = createResult.rows[0];
    }

    res.status(201).json({
      success: true,
      data: { job },
      message: existingJob.rows.length > 0 ? 'Monitoring job updated' : 'Monitoring job created'
    });

  } catch (error) {
    console.error('Create monitoring job error:', error);
    res.status(500).json({
      success: false,
      error: { code: 'INTERNAL_ERROR', message: 'Failed to create monitoring job' }
    });
  }
});

// GET /api/v1/monitoring/jobs - List all monitoring jobs
router.get('/jobs', async (req, res) => {
  try {
    const result = await query(
      `SELECT mj.*, t.title as track_title, t.artist_name
       FROM monitoring_jobs mj
       INNER JOIN tracks t ON mj.track_id = t.id
       WHERE mj.user_id = $1
       ORDER BY mj.created_at DESC`,
      [req.user.id]
    );

    res.json({
      success: true,
      data: { jobs: result.rows }
    });

  } catch (error) {
    console.error('Fetch monitoring jobs error:', error);
    res.status(500).json({
      success: false,
      error: { code: 'INTERNAL_ERROR', message: 'Failed to fetch monitoring jobs' }
    });
  }
});

// GET /api/v1/monitoring/jobs/:trackId - Get monitoring job for a track
router.get('/jobs/:trackId', async (req, res) => {
  try {
    const result = await query(
      `SELECT mj.*, t.title as track_title, t.artist_name
       FROM monitoring_jobs mj
       INNER JOIN tracks t ON mj.track_id = t.id
       WHERE mj.track_id = $1 AND mj.user_id = $2`,
      [req.params.trackId, req.user.id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: { code: 'NOT_FOUND', message: 'Monitoring job not found' }
      });
    }

    res.json({
      success: true,
      data: { job: result.rows[0] }
    });

  } catch (error) {
    console.error('Fetch monitoring job error:', error);
    res.status(500).json({
      success: false,
      error: { code: 'INTERNAL_ERROR', message: 'Failed to fetch monitoring job' }
    });
  }
});

// POST /api/v1/monitoring/run/:trackId - Manually trigger monitoring for a track
router.post('/run/:trackId', async (req, res) => {
  try {
    const { trackId } = req.params;

    // Verify track ownership
    const trackResult = await query(
      'SELECT * FROM tracks WHERE id = $1 AND user_id = $2',
      [trackId, req.user.id]
    );

    if (trackResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: { code: 'NOT_FOUND', message: 'Track not found' }
      });
    }

    // Run monitoring
    const result = await youtubeMonitor.monitorTrack(trackId, req.user.id);

    res.json({
      success: true,
      data: result,
      message: `Found ${result.newAlerts} new potential matches`
    });

  } catch (error) {
    console.error('Run monitoring error:', error);
    res.status(500).json({
      success: false,
      error: { code: 'INTERNAL_ERROR', message: error.message }
    });
  }
});

// GET /api/v1/monitoring/alerts - List all alerts
router.get('/alerts', async (req, res) => {
  try {
    const { status, trackId, limit = 50, offset = 0 } = req.query;

    let queryText = `
      SELECT ma.*, t.title as track_title, t.artist_name
      FROM monitoring_alerts ma
      INNER JOIN tracks t ON ma.track_id = t.id
      WHERE ma.user_id = $1
    `;
    const params = [req.user.id];
    let paramCount = 1;

    if (status) {
      paramCount++;
      queryText += ` AND ma.status = $${paramCount}`;
      params.push(status);
    }

    if (trackId) {
      paramCount++;
      queryText += ` AND ma.track_id = $${paramCount}`;
      params.push(trackId);
    }

    queryText += ` ORDER BY ma.created_at DESC LIMIT $${paramCount + 1} OFFSET $${paramCount + 2}`;
    params.push(limit, offset);

    const result = await query(queryText, params);

    // Get total count
    let countQuery = 'SELECT COUNT(*) FROM monitoring_alerts WHERE user_id = $1';
    const countParams = [req.user.id];
    if (status) {
      countQuery += ' AND status = $2';
      countParams.push(status);
    }
    if (trackId) {
      countQuery += ` AND track_id = $${countParams.length + 1}`;
      countParams.push(trackId);
    }

    const countResult = await query(countQuery, countParams);
    const total = parseInt(countResult.rows[0].count);

    res.json({
      success: true,
      data: {
        alerts: result.rows,
        pagination: {
          total,
          limit: parseInt(limit),
          offset: parseInt(offset),
          hasMore: offset + result.rows.length < total
        }
      }
    });

  } catch (error) {
    console.error('Fetch alerts error:', error);
    res.status(500).json({
      success: false,
      error: { code: 'INTERNAL_ERROR', message: 'Failed to fetch alerts' }
    });
  }
});

// GET /api/v1/monitoring/alerts/:id - Get single alert
router.get('/alerts/:id', async (req, res) => {
  try {
    const result = await query(
      `SELECT ma.*, t.title as track_title, t.artist_name
       FROM monitoring_alerts ma
       INNER JOIN tracks t ON ma.track_id = t.id
       WHERE ma.id = $1 AND ma.user_id = $2`,
      [req.params.id, req.user.id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: { code: 'NOT_FOUND', message: 'Alert not found' }
      });
    }

    res.json({
      success: true,
      data: { alert: result.rows[0] }
    });

  } catch (error) {
    console.error('Fetch alert error:', error);
    res.status(500).json({
      success: false,
      error: { code: 'INTERNAL_ERROR', message: 'Failed to fetch alert' }
    });
  }
});

// PUT /api/v1/monitoring/alerts/:id - Update alert status
router.put('/alerts/:id', async (req, res) => {
  try {
    const { status, notes } = req.body;

    const validStatuses = ['new', 'reviewed', 'verified', 'dismissed', 'licensed'];
    if (status && !validStatuses.includes(status)) {
      return res.status(400).json({
        success: false,
        error: { code: 'VALIDATION_ERROR', message: 'Invalid status' }
      });
    }

    // Verify ownership
    const alertCheck = await query(
      'SELECT user_id FROM monitoring_alerts WHERE id = $1',
      [req.params.id]
    );

    if (alertCheck.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: { code: 'NOT_FOUND', message: 'Alert not found' }
      });
    }

    if (alertCheck.rows[0].user_id !== req.user.id) {
      return res.status(403).json({
        success: false,
        error: { code: 'FORBIDDEN', message: 'Not authorized' }
      });
    }

    // Update alert
    const updates = [];
    const values = [];
    let paramCount = 0;

    if (status) {
      paramCount++;
      updates.push(`status = $${paramCount}`);
      values.push(status);
      
      if (status === 'reviewed' || status === 'verified' || status === 'dismissed') {
        updates.push('reviewed_at = CURRENT_TIMESTAMP');
        paramCount++;
        updates.push(`reviewed_by = $${paramCount}`);
        values.push(req.user.id);
      }
    }

    if (notes !== undefined) {
      paramCount++;
      updates.push(`notes = $${paramCount}`);
      values.push(notes);
    }

    if (updates.length === 0) {
      return res.status(400).json({
        success: false,
        error: { code: 'VALIDATION_ERROR', message: 'No valid fields to update' }
      });
    }

    values.push(req.params.id);
    const result = await query(
      `UPDATE monitoring_alerts 
       SET ${updates.join(', ')}
       WHERE id = $${paramCount + 1}
       RETURNING *`,
      values
    );

    res.json({
      success: true,
      data: { alert: result.rows[0] },
      message: 'Alert updated successfully'
    });

  } catch (error) {
    console.error('Update alert error:', error);
    res.status(500).json({
      success: false,
      error: { code: 'INTERNAL_ERROR', message: 'Failed to update alert' }
    });
  }
});

// GET /api/v1/monitoring/stats - Get monitoring statistics
router.get('/stats', async (req, res) => {
  try {
    const { trackId, period = '30d' } = req.query;

    // Calculate date range
    const periodDays = parseInt(period) || 30;
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - periodDays);

    let queryText = `
      SELECT 
        COUNT(*) as total_alerts,
        COUNT(CASE WHEN status = 'new' THEN 1 END) as new_alerts,
        COUNT(CASE WHEN status = 'reviewed' THEN 1 END) as reviewed_alerts,
        COUNT(CASE WHEN status = 'verified' THEN 1 END) as verified_alerts,
        COUNT(CASE WHEN status = 'dismissed' THEN 1 END) as dismissed_alerts,
        COUNT(CASE WHEN status = 'licensed' THEN 1 END) as licensed_alerts,
        SUM(view_count) as total_views,
        AVG(confidence_score) as avg_confidence
      FROM monitoring_alerts
      WHERE user_id = $1 AND created_at >= $2
    `;
    const params = [req.user.id, startDate];

    if (trackId) {
      queryText += ' AND track_id = $3';
      params.push(trackId);
    }

    const result = await query(queryText, params);
    const stats = result.rows[0];

    // Get active monitoring jobs count
    const jobsResult = await query(
      'SELECT COUNT(*) as active_jobs FROM monitoring_jobs WHERE user_id = $1 AND enabled = true',
      [req.user.id]
    );

    res.json({
      success: true,
      data: {
        period: `${periodDays} days`,
        totalAlerts: parseInt(stats.total_alerts),
        newAlerts: parseInt(stats.new_alerts),
        reviewedAlerts: parseInt(stats.reviewed_alerts),
        verifiedAlerts: parseInt(stats.verified_alerts),
        dismissedAlerts: parseInt(stats.dismissed_alerts),
        licensedAlerts: parseInt(stats.licensed_alerts),
        totalViews: parseInt(stats.total_views) || 0,
        avgConfidence: parseFloat(stats.avg_confidence) || 0,
        activeJobs: parseInt(jobsResult.rows[0].active_jobs)
      }
    });

  } catch (error) {
    console.error('Fetch stats error:', error);
    res.status(500).json({
      success: false,
      error: { code: 'INTERNAL_ERROR', message: 'Failed to fetch statistics' }
    });
  }
});

module.exports = router;
