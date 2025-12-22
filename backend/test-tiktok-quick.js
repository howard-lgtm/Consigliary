const axios = require('axios');

const API_BASE = 'https://consigliary-production.up.railway.app/api/v1';

// Use a popular TikTok video - replace with a real one
const TIKTOK_URL = 'https://www.tiktok.com/@scout2015/video/6718335390845095173';

async function testTikTok() {
    try {
        console.log('🧪 Testing TikTok Download\n');
        
        // Step 1: Login
        console.log('1️⃣ Logging in...');
        const loginRes = await axios.post(`${API_BASE}/auth/login`, {
            email: 'test@consigliary.com',
            password: 'password123'
        });
        const token = loginRes.data.data.accessToken;
        console.log('✅ Logged in\n');
        
        // Step 2: Download TikTok
        console.log('2️⃣ Downloading TikTok audio...');
        console.log(`URL: ${TIKTOK_URL}\n`);
        
        const downloadRes = await axios.post(
            `${API_BASE}/tracks/download-tiktok`,
            { url: TIKTOK_URL },
            {
                headers: { 'Authorization': `Bearer ${token}` },
                timeout: 120000
            }
        );
        
        console.log('✅ Download successful!\n');
        console.log('📊 Result:');
        console.log(JSON.stringify(downloadRes.data, null, 2));
        
    } catch (error) {
        console.error('\n❌ Test failed:');
        if (error.response) {
            console.error('Status:', error.response.status);
            console.error('Error:', JSON.stringify(error.response.data, null, 2));
        } else {
            console.error('Error:', error.message);
        }
        process.exit(1);
    }
}

testTikTok();
