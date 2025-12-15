const jwt = require('jsonwebtoken');
const { query } = require('../config/database');

// Verify JWT token
const authenticateToken = async (req, res, next) => {
    try {
        const authHeader = req.headers['authorization'];
        const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

        if (!token) {
            return res.status(401).json({
                success: false,
                error: {
                    code: 'UNAUTHORIZED',
                    message: 'Access token required'
                }
            });
        }

        // Verify token
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        
        // Check if user still exists
        const result = await query(
            'SELECT id, email, name, artist_name, subscription_plan FROM users WHERE id = $1',
            [decoded.userId]
        );

        if (result.rows.length === 0) {
            return res.status(401).json({
                success: false,
                error: {
                    code: 'UNAUTHORIZED',
                    message: 'User not found'
                }
            });
        }

        // Attach user to request
        req.user = result.rows[0];
        next();
    } catch (error) {
        if (error.name === 'JsonWebTokenError') {
            return res.status(401).json({
                success: false,
                error: {
                    code: 'UNAUTHORIZED',
                    message: 'Invalid token'
                }
            });
        }
        
        if (error.name === 'TokenExpiredError') {
            return res.status(401).json({
                success: false,
                error: {
                    code: 'TOKEN_EXPIRED',
                    message: 'Token expired'
                }
            });
        }

        console.error('Auth middleware error:', error);
        return res.status(500).json({
            success: false,
            error: {
                code: 'INTERNAL_ERROR',
                message: 'Authentication failed'
            }
        });
    }
};

// Check subscription tier
const requireSubscription = (requiredPlan) => {
    return (req, res, next) => {
        const plans = ['free', 'pro', 'enterprise'];
        const userPlanIndex = plans.indexOf(req.user.subscription_plan);
        const requiredPlanIndex = plans.indexOf(requiredPlan);

        if (userPlanIndex < requiredPlanIndex) {
            return res.status(403).json({
                success: false,
                error: {
                    code: 'SUBSCRIPTION_REQUIRED',
                    message: `This feature requires ${requiredPlan} subscription`,
                    requiredPlan
                }
            });
        }

        next();
    };
};

module.exports = {
    authenticateToken,
    requireSubscription
};
