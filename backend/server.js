require('dotenv').config();
const express = require('express');
const cors = require('cors');
const app = express();

// Middleware
app.use(cors({
    origin: [
        process.env.FRONTEND_URL,
        'capacitor://localhost',
        'ionic://localhost',
        'http://localhost',
        'http://localhost:3000',
        'http://localhost:8100'
    ],
    credentials: true
}));

// Webhooks need raw body - must be before express.json()
const webhookRoutes = require('./routes/webhooks');
app.use('/webhooks', webhookRoutes);

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Request logging
app.use((req, res, next) => {
    console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
    next();
});

// Health check
app.get('/health', (req, res) => {
    res.json({
        status: 'ok',
        timestamp: new Date().toISOString(),
        version: process.env.API_VERSION || 'v1'
    });
});

// API Routes
const authRoutes = require('./routes/auth');
const trackRoutes = require('./routes/tracks');
const contributorRoutes = require('./routes/contributors');
const verificationRoutes = require('./routes/verifications');
const licenseRoutes = require('./routes/licenses');
const revenueRoutes = require('./routes/revenue');

app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/tracks', trackRoutes);
app.use('/api/v1', contributorRoutes);
app.use('/api/v1/verifications', verificationRoutes);
app.use('/api/v1/licenses', licenseRoutes);
app.use('/api/v1/revenue', revenueRoutes);

// 404 handler
app.use((req, res) => {
    res.status(404).json({
        success: false,
        error: {
            code: 'NOT_FOUND',
            message: 'Endpoint not found'
        }
    });
});

// Error handler
app.use((err, req, res, next) => {
    console.error('Error:', err);
    
    res.status(err.status || 500).json({
        success: false,
        error: {
            code: err.code || 'INTERNAL_ERROR',
            message: err.message || 'An unexpected error occurred',
            ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
        }
    });
});

// Start server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`🚀 Consigliary API running on port ${PORT}`);
    console.log(`📝 Environment: ${process.env.NODE_ENV}`);
    console.log(`🔗 Health check: http://localhost:${PORT}/health`);
});

module.exports = app;
