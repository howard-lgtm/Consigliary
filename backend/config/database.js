const { Pool } = require('pg');

// PostgreSQL connection pool
// Disable TLS certificate validation globally for Railway's self-signed certs
process.env.NODE_TLS_REJECT_UNAUTHORIZED = '0';

const isRailwayInternal = process.env.DATABASE_URL?.includes('railway.internal');

const pool = new Pool({
    connectionString: process.env.DATABASE_URL?.split('?')[0], // Strip any query params
    ssl: isRailwayInternal ? false : true, // Simple boolean for external connections
    max: 20,
    idleTimeoutMillis: 30000,
    connectionTimeoutMillis: 2000,
});

console.log('🔍 Database connection config:', {
    isRailwayInternal,
    sslMode: isRailwayInternal ? 'disabled' : 'enabled (no cert validation)',
    tlsRejectUnauthorized: process.env.NODE_TLS_REJECT_UNAUTHORIZED
});

// Test connection
pool.on('connect', () => {
    console.log('✅ Database connected');
});

// Handle connection errors gracefully (57P01 autosuspend errors)
pool.on('error', (err, client) => {
    console.error('❌ Unexpected error on idle client:', err.message);
    // Don't exit - let the pool create new connections on next request
    if (err.code === '57P01') {
        console.log('⚠️  Database autosuspended - pool will reconnect on next query');
    }
});

// Query helper
const query = async (text, params) => {
    const start = Date.now();
    try {
        const res = await pool.query(text, params);
        const duration = Date.now() - start;
        console.log('Executed query', { text, duration, rows: res.rowCount });
        return res;
    } catch (error) {
        console.error('Database query error:', error);
        throw error;
    }
};

// Transaction helper
const transaction = async (callback) => {
    const client = await pool.connect();
    try {
        await client.query('BEGIN');
        const result = await callback(client);
        await client.query('COMMIT');
        return result;
    } catch (error) {
        await client.query('ROLLBACK');
        throw error;
    } finally {
        client.release();
    }
};

module.exports = {
    pool,
    query,
    transaction
};
