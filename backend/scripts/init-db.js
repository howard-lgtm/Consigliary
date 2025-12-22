const { Pool } = require('pg');
const fs = require('fs');
const path = require('path');

async function initializeDatabase() {
    const pool = new Pool({
        connectionString: process.env.DATABASE_URL,
        ssl: process.env.DATABASE_URL?.includes('railway.internal') 
            ? false 
            : { rejectUnauthorized: false }
    });

    try {
        console.log('🔄 Connecting to database...');
        
        // Read schema file
        const schemaPath = path.join(__dirname, '..', 'database', 'schema.sql');
        const schema = fs.readFileSync(schemaPath, 'utf8');
        
        console.log('📝 Executing schema...');
        await pool.query(schema);
        
        console.log('✅ Database initialized successfully!');
        
        // Create test user
        console.log('👤 Creating test user...');
        const bcrypt = require('bcryptjs');
        const passwordHash = await bcrypt.hash('password123', 10);
        
        await pool.query(`
            INSERT INTO users (email, password_hash, name, artist_name, subscription_plan)
            VALUES ($1, $2, $3, $4, $5)
            ON CONFLICT (email) DO NOTHING
        `, ['test@consigliary.com', passwordHash, 'Test User', 'Test Artist', 'pro']);
        
        console.log('✅ Test user created: test@consigliary.com / password123');
        
    } catch (error) {
        console.error('❌ Database initialization failed:', error);
        throw error;
    } finally {
        await pool.end();
    }
}

initializeDatabase().catch(console.error);
