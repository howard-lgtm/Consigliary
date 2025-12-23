const axios = require('axios');

const BASE_URL = process.env.API_URL || 'https://consigliary-production.up.railway.app';

const colors = {
    reset: '\x1b[0m',
    green: '\x1b[32m',
    red: '\x1b[31m',
    yellow: '\x1b[33m',
    blue: '\x1b[34m'
};

const log = {
    success: (msg) => console.log(`${colors.green}✅ ${msg}${colors.reset}`),
    error: (msg) => console.log(`${colors.red}❌ ${msg}${colors.reset}`),
    info: (msg) => console.log(`${colors.blue}ℹ️  ${msg}${colors.reset}`),
    warning: (msg) => console.log(`${colors.yellow}⚠️  ${msg}${colors.reset}`)
};

let authToken = null;
let testUserId = null;

async function testEndpoint(name, method, endpoint, data = null, requiresAuth = false) {
    try {
        const config = {
            method,
            url: `${BASE_URL}${endpoint}`,
            headers: {}
        };

        if (requiresAuth && authToken) {
            config.headers['Authorization'] = `Bearer ${authToken}`;
        }

        if (data) {
            config.data = data;
        }

        const response = await axios(config);
        log.success(`${name}: ${response.status} ${response.statusText}`);
        return { success: true, data: response.data };
    } catch (error) {
        if (error.response) {
            log.error(`${name}: ${error.response.status} - ${error.response.data?.error?.message || error.message}`);
            return { success: false, status: error.response.status, error: error.response.data };
        } else {
            log.error(`${name}: ${error.message}`);
            return { success: false, error: error.message };
        }
    }
}

async function runTests() {
    console.log('\n' + '='.repeat(60));
    log.info(`Testing Consigliary MVP API: ${BASE_URL}`);
    console.log('='.repeat(60) + '\n');

    // 1. Health Check
    console.log('📋 BASIC CONNECTIVITY');
    console.log('-'.repeat(60));
    await testEndpoint('Health Check', 'GET', '/health');
    console.log();

    // 2. Test MVP Endpoints (should work)
    console.log('✅ MVP ENDPOINTS (Should be accessible)');
    console.log('-'.repeat(60));
    
    // Auth endpoints (no token needed for these)
    await testEndpoint('Auth - Login (no credentials)', 'POST', '/api/v1/auth/login', {
        email: 'test@example.com',
        password: 'wrongpassword'
    });
    
    // Protected endpoints (should return 401 without token)
    await testEndpoint('Tracks - List (no auth)', 'GET', '/api/v1/tracks');
    await testEndpoint('Licenses - List (no auth)', 'GET', '/api/v1/licenses');
    await testEndpoint('Revenue - Get (no auth)', 'GET', '/api/v1/revenue');
    console.log();

    // 3. Test Deferred Endpoints (should return 404)
    console.log('❌ DEFERRED ENDPOINTS (Should return 404)');
    console.log('-'.repeat(60));
    
    const deferredEndpoints = [
        { name: 'Monitoring - Stats', endpoint: '/api/v1/monitoring/stats' },
        { name: 'Monitoring - Jobs', endpoint: '/api/v1/monitoring/jobs' },
        { name: 'Monitoring - Alerts', endpoint: '/api/v1/monitoring/alerts' },
        { name: 'Contributors - List', endpoint: '/api/v1/tracks/test-track-id/contributors' },
        { name: 'Split Sheet', endpoint: '/api/v1/tracks/test-track-id/split-sheet' }
    ];

    for (const { name, endpoint } of deferredEndpoints) {
        const result = await testEndpoint(name, 'GET', endpoint);
        if (result.status === 404) {
            log.success(`${name}: Correctly disabled (404)`);
        } else if (result.status === 401) {
            log.warning(`${name}: Still active (requires auth)`);
        } else {
            log.error(`${name}: Unexpected status ${result.status}`);
        }
    }
    console.log();

    // 4. Test with real credentials (if provided)
    if (process.env.TEST_EMAIL && process.env.TEST_PASSWORD) {
        console.log('🔐 AUTHENTICATED TESTS');
        console.log('-'.repeat(60));
        
        const loginResult = await testEndpoint(
            'Login with test credentials',
            'POST',
            '/api/v1/auth/login',
            {
                email: process.env.TEST_EMAIL,
                password: process.env.TEST_PASSWORD
            }
        );

        if (loginResult.success && loginResult.data.data?.token) {
            authToken = loginResult.data.data.token;
            log.success('Authentication successful');

            // Test authenticated endpoints
            await testEndpoint('Tracks - List (authenticated)', 'GET', '/api/v1/tracks', null, true);
            await testEndpoint('Licenses - List (authenticated)', 'GET', '/api/v1/licenses', null, true);
            await testEndpoint('Revenue - Get (authenticated)', 'GET', '/api/v1/revenue', null, true);
            
            // Verify deferred endpoints still return 404 even with auth
            log.info('Verifying deferred endpoints return 404 even with authentication:');
            const monitoringResult = await testEndpoint(
                'Monitoring - Stats (authenticated)',
                'GET',
                '/api/v1/monitoring/stats',
                null,
                true
            );
            if (monitoringResult.status === 404) {
                log.success('Monitoring correctly disabled even with auth');
            } else {
                log.error('Monitoring still accessible with auth!');
            }
        }
        console.log();
    } else {
        log.info('Skipping authenticated tests (set TEST_EMAIL and TEST_PASSWORD to run)');
        console.log();
    }

    // Summary
    console.log('='.repeat(60));
    log.info('Test Summary:');
    console.log('- MVP endpoints should return 401 (unauthorized) without token');
    console.log('- Deferred endpoints should return 404 (not found)');
    console.log('- Health check should return 200 (ok)');
    console.log('='.repeat(60) + '\n');
}

// Run tests
runTests().catch(error => {
    log.error(`Test suite failed: ${error.message}`);
    process.exit(1);
});
