const axios = require('axios');

// Configuration
const API_BASE_URL = 'https://consigliary-production.up.railway.app/api/v1';
const TEST_USER = {
    email: 'test@consigliary.com',
    password: 'password123'
};

// Sample TikTok URLs for testing (use real ones)
const SAMPLE_TIKTOK_URL = 'https://www.tiktok.com/@username/video/1234567890'; // Replace with real URL

async function testTikTokDownload() {
    try {
        console.log('🧪 Testing TikTok Download Functionality\n');
        
        // Step 1: Login to get token
        console.log('1️⃣ Logging in...');
        const loginResponse = await axios.post(`${API_BASE_URL}/auth/login`, {
            email: TEST_USER.email,
            password: TEST_USER.password
        });
        
        const token = loginResponse.data.data.accessToken;
        console.log('✅ Login successful\n');
        
        // Step 2: Test TikTok download
        console.log('2️⃣ Downloading TikTok audio...');
        console.log(`URL: ${SAMPLE_TIKTOK_URL}\n`);
        
        const downloadResponse = await axios.post(
            `${API_BASE_URL}/tracks/download-tiktok`,
            {
                url: SAMPLE_TIKTOK_URL,
                title: 'Test TikTok Audio',
                artistName: 'Test Artist'
            },
            {
                headers: {
                    'Authorization': `Bearer ${token}`,
                    'Content-Type': 'application/json'
                },
                timeout: 120000 // 2 minute timeout
            }
        );
        
        console.log('✅ TikTok download successful!\n');
        console.log('📊 Response:');
        console.log(JSON.stringify(downloadResponse.data, null, 2));
        
        // Step 3: Verify track was created
        console.log('\n3️⃣ Verifying track in database...');
        const trackId = downloadResponse.data.data.track.id;
        
        const trackResponse = await axios.get(
            `${API_BASE_URL}/tracks/${trackId}`,
            {
                headers: {
                    'Authorization': `Bearer ${token}`
                }
            }
        );
        
        console.log('✅ Track verified in database\n');
        console.log('🎵 Track Details:');
        console.log(`- ID: ${trackResponse.data.data.track.id}`);
        console.log(`- Title: ${trackResponse.data.data.track.title}`);
        console.log(`- Artist: ${trackResponse.data.data.track.artist_name}`);
        console.log(`- Duration: ${trackResponse.data.data.track.duration}s`);
        console.log(`- Audio URL: ${trackResponse.data.data.track.audio_file_url}`);
        console.log(`- Fingerprint ID: ${trackResponse.data.data.track.acrcloud_fingerprint_id || 'N/A'}`);
        
        console.log('\n✨ All tests passed! TikTok download is working correctly.');
        
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

// Run the test
console.log('═══════════════════════════════════════════════════════');
console.log('  TikTok Download Functionality Test');
console.log('═══════════════════════════════════════════════════════\n');

testTikTokDownload();
