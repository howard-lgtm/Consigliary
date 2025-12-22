const axios = require('axios');

const API_BASE = process.env.API_BASE || 'https://consigliary-production.up.railway.app/api/v1';
const TEST_USER = {
    email: 'test@consigliary.com',
    password: 'password123'
};

async function testVerificationEndpoint() {
    try {
        console.log('🔐 Step 1: Logging in...');
        console.log(`   API Base: ${API_BASE}`);
        const loginResponse = await axios.post(`${API_BASE}/auth/login`, TEST_USER);
        const token = loginResponse.data.token || loginResponse.data.data?.accessToken;
        console.log('✅ Login successful');
        if (token) {
            console.log(`   Token: ${token.substring(0, 20)}...`);
        } else {
            console.log('   Response:', JSON.stringify(loginResponse.data, null, 2));
        }

        console.log('\n🎵 Step 2: Creating a test verification...');
        console.log('   Using YouTube URL: https://www.youtube.com/watch?v=dQw4w9WgXcQ');
        
        const verificationResponse = await axios.post(
            `${API_BASE}/verifications`,
            {
                videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ'
            },
            {
                headers: {
                    'Authorization': `Bearer ${token}`
                }
            }
        );

        console.log('✅ Verification created successfully!');
        console.log('\n📊 Results:');
        console.log(`   Verification ID: ${verificationResponse.data.data.id}`);
        console.log(`   Platform: ${verificationResponse.data.data.platform}`);
        console.log(`   Video Title: ${verificationResponse.data.data.video_title}`);
        console.log(`   Channel: ${verificationResponse.data.data.channel_name}`);
        console.log(`   Match Found: ${verificationResponse.data.data.match_found}`);
        console.log(`   Confidence: ${verificationResponse.data.data.confidence_score || 'N/A'}`);
        console.log(`   Audio Sample URL: ${verificationResponse.data.data.audio_sample_url || 'N/A'}`);
        console.log(`   Status: ${verificationResponse.data.data.status}`);

        if (verificationResponse.data.matchDetails) {
            console.log('\n🎯 ACRCloud Match Details:');
            console.log(`   Found: ${verificationResponse.data.matchDetails.found}`);
            console.log(`   Track: ${verificationResponse.data.matchDetails.trackTitle || 'N/A'}`);
            console.log(`   Artist: ${verificationResponse.data.matchDetails.artist || 'N/A'}`);
        }

        console.log('\n🎉 Test completed successfully!');

    } catch (error) {
        console.error('❌ Test failed:');
        if (error.response) {
            console.error(`   Status: ${error.response.status}`);
            console.error(`   Message: ${error.response.data.message || error.response.data.error}`);
            console.error(`   Data:`, JSON.stringify(error.response.data, null, 2));
        } else {
            console.error(`   Error: ${error.message}`);
        }
        process.exit(1);
    }
}

testVerificationEndpoint();
