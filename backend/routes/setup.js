const express = require('express');
const router = express.Router();
const { query } = require('../config/database');
const fs = require('fs');
const path = require('path');

// POST /api/v1/setup/migrate - Run database migrations
router.post('/migrate', async (req, res) => {
  try {
    console.log('🔄 Running database migration...');
    
    // Read migration file
    const migrationPath = path.join(__dirname, '../database/migrations/001_add_monitoring_tables.sql');
    const migrationSQL = fs.readFileSync(migrationPath, 'utf8');
    
    // Run migration
    await query(migrationSQL);
    
    console.log('✅ Migration completed successfully!');
    
    // Verify tables were created
    const result = await query(`
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_schema = 'public' 
      AND table_name IN ('monitoring_jobs', 'monitoring_alerts', 'monitoring_stats')
      ORDER BY table_name
    `);
    
    const tables = result.rows.map(r => r.table_name);
    
    res.json({
      success: true,
      message: 'Migration completed successfully',
      data: {
        tablesCreated: tables
      }
    });
    
  } catch (error) {
    console.error('❌ Migration failed:', error);
    
    // Check if tables already exist
    if (error.message.includes('already exists')) {
      return res.json({
        success: true,
        message: 'Migration already applied (tables exist)',
        data: {
          tablesCreated: ['monitoring_jobs', 'monitoring_alerts', 'monitoring_stats']
        }
      });
    }
    
    res.status(500).json({
      success: false,
      error: {
        code: 'MIGRATION_ERROR',
        message: error.message
      }
    });
  }
});

// GET /api/v1/setup/status - Check database setup status
router.get('/status', async (req, res) => {
  try {
    // Check which tables exist
    const result = await query(`
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_schema = 'public' 
      ORDER BY table_name
    `);
    
    const tables = result.rows.map(r => r.table_name);
    
    const requiredTables = [
      'users', 'tracks', 'verifications', 'licenses', 
      'monitoring_jobs', 'monitoring_alerts', 'monitoring_stats'
    ];
    
    const missingTables = requiredTables.filter(t => !tables.includes(t));
    
    res.json({
      success: true,
      data: {
        allTables: tables,
        requiredTables,
        missingTables,
        isReady: missingTables.length === 0
      }
    });
    
  } catch (error) {
    console.error('Status check error:', error);
    res.status(500).json({
      success: false,
      error: {
        code: 'STATUS_ERROR',
        message: error.message
      }
    });
  }
});

module.exports = router;
