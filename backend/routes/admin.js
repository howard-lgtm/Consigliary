const express = require('express');
const router = express.Router();
const { pool } = require('../config/database');
const fs = require('fs');
const path = require('path');
const bcrypt = require('bcryptjs');

router.post('/init-database', async (req, res) => {
    try {
        console.log('🔄 Initializing database...');
        
        const schemaPath = path.join(__dirname, '..', 'database', 'schema.sql');
        const schema = fs.readFileSync(schemaPath, 'utf8');
        
        await pool.query(schema);
        console.log('✅ Schema created');
        
        const passwordHash = await bcrypt.hash('password123', 10);
        await pool.query(`
            INSERT INTO users (email, password_hash, name, artist_name, subscription_plan)
            VALUES ($1, $2, $3, $4, $5)
            ON CONFLICT (email) DO NOTHING
            RETURNING id
        `, ['test@consigliary.com', passwordHash, 'Test User', 'Test Artist', 'pro']);
        
        console.log('✅ Test user created');
        
        res.json({
            success: true,
            message: 'Database initialized successfully',
            testUser: {
                email: 'test@consigliary.com',
                password: 'password123'
            }
        });
        
    } catch (error) {
        console.error('❌ Database initialization failed:', error);
        res.status(500).json({
            success: false,
            error: error.message
        });
    }
});

module.exports = router;
