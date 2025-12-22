const axios = require('axios');

const API_BASE = 'https://consigliary-production.up.railway.app/api/v1';

// Test with a YouTube video
const TEST_VIDEO_URL = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ'; // Rick Astley - Never Gonna Give You Up

async function testVerification() {
    try {
        console.log('🧪 Testing Verification Flow\n');
        
        // Step 1: Login
        console.log('1️⃣ Logging in...');
        const loginRes = await axios.post(`${API_BASE}/auth/login`, {
            email: 'test@consigliary.com',
            password: 'password123'
        });
        const token = loginRes.data.data.accessToken;
        console.log('✅ Logged in\n');
        
        // Step 2: Get user's tracks
        console.log('2️⃣ Fetching tracks...');
        const tracksRes = await axios.get(`${API_BASE}/tracks`, {
            headers: { 'Authorization': `Bearer ${token}` }
        });
        
        const tracks = tracksRes.data.data.tracks;
        console.log(`✅ Found ${tracks.length} tracks\n`);
        
        if (tracks.length === 0) {
            console.log('⚠️  No tracks found. Upload a track first.');
            return;
        }
        
        // Use the most recent track (the TikTok one we just created)
        const testTrack = tracks[0];
        console.log(`📊 Testing with track: "${testTrack.title}"`);
        console.log(`   Fingerprint ID: ${testTrack.acrcloud_fingerprint_id}\n`);
        
        // Step 3: Verify the same TikTok URL
        console.log('3️⃣ Running verification...');
        console.log(`   URL: ${TEST_VIDEO_URL}\n`);
        
        const verifyRes = await axios.post(
            `${API_BASE}/verifications`,
            {
                videoUrl: TEST_VIDEO_URL,
                trackId: testTrack.id
            },
            {
                headers: { 'Authorization': `Bearer ${token}` },
                timeout: 120000
            }
        );
        
        console.log('✅ Verification complete!\n');
        console.log('📊 Result:');
        console.log(JSON.stringify(verifyRes.data, null, 2));
        
        // Check if it matched
        const verification = verifyRes.data.data;
        const matchDetails = verification.matchDetails;
        
        if (matchDetails && matchDetails.matched) {
            console.log('\n🎉 SUCCESS! Audio matched in ACRCloud!');
            console.log(`   Track: "${matchDetails.title}" by ${matchDetails.artist}`);
            console.log(`   Confidence: ${matchDetails.confidence}%`);
            console.log(`   Album: ${matchDetails.album}`);
        } else {
            console.log('\n⚠️  No match found in ACRCloud database');
        }
        
        if (verification.track_id) {
            console.log(`\n📌 Linked to your track: ${testTrack.title}`);
        }
        
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

testVerification();
