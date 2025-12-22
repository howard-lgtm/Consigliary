const axios = require('axios');

const API_BASE = 'https://consigliary-production.up.railway.app/api/v1';

async function testMonitoring() {
  try {
    console.log('🧪 Testing Monitoring System\n');
    console.log('========================================\n');

    // Step 1: Login
    console.log('1️⃣ Logging in...');
    const loginRes = await axios.post(`${API_BASE}/auth/login`, {
      email: 'test@consigliary.com',
      password: 'password123'
    });
    const token = loginRes.data.data.accessToken;
    console.log('✅ Logged in\n');

    // Step 2: Get tracks
    console.log('2️⃣ Fetching tracks...');
    const tracksRes = await axios.get(`${API_BASE}/tracks`, {
      headers: { Authorization: `Bearer ${token}` }
    });
    
    const tracks = tracksRes.data.data.tracks;
    if (tracks.length === 0) {
      console.log('❌ No tracks found. Upload a track first.');
      return;
    }
    
    const track = tracks[0];
    console.log(`✅ Found track: "${track.title}" by ${track.artist_name}\n`);

    // Step 3: Create monitoring job
    console.log('3️⃣ Creating monitoring job...');
    const jobRes = await axios.post(
      `${API_BASE}/monitoring/jobs`,
      {
        trackId: track.id,
        enabled: true,
        frequency: 'weekly',
        platforms: ['YouTube']
      },
      { headers: { Authorization: `Bearer ${token}` } }
    );
    console.log('✅ Monitoring job created\n');
    console.log(JSON.stringify(jobRes.data, null, 2));

    // Step 4: Run monitoring manually
    console.log('\n4️⃣ Running monitoring (this may take 30-60 seconds)...');
    const monitorRes = await axios.post(
      `${API_BASE}/monitoring/run/${track.id}`,
      {},
      { 
        headers: { Authorization: `Bearer ${token}` },
        timeout: 120000
      }
    );
    
    console.log('✅ Monitoring complete!\n');
    console.log('📊 Results:');
    console.log(`   Videos found: ${monitorRes.data.data.videosFound}`);
    console.log(`   New alerts: ${monitorRes.data.data.newAlerts}`);
    console.log(`   Quota used: ${monitorRes.data.data.quotaUsed} units\n`);

    // Step 5: Get alerts
    if (monitorRes.data.data.newAlerts > 0) {
      console.log('5️⃣ Fetching alerts...');
      const alertsRes = await axios.get(
        `${API_BASE}/monitoring/alerts?status=new&limit=5`,
        { headers: { Authorization: `Bearer ${token}` } }
      );
      
      console.log(`✅ Found ${alertsRes.data.data.alerts.length} new alerts:\n`);
      
      alertsRes.data.data.alerts.forEach((alert, i) => {
        console.log(`   ${i + 1}. ${alert.video_title}`);
        console.log(`      Channel: ${alert.channel_name}`);
        console.log(`      Views: ${alert.view_count?.toLocaleString() || 'N/A'}`);
        console.log(`      URL: ${alert.video_url}`);
        console.log(`      Confidence: ${(alert.confidence_score * 100).toFixed(1)}%\n`);
      });
    }

    // Step 6: Get statistics
    console.log('6️⃣ Fetching monitoring statistics...');
    const statsRes = await axios.get(
      `${API_BASE}/monitoring/stats`,
      { headers: { Authorization: `Bearer ${token}` } }
    );
    
    console.log('✅ Statistics:\n');
    console.log(JSON.stringify(statsRes.data.data, null, 2));

    console.log('\n========================================');
    console.log('🎉 Monitoring System Test Complete!\n');

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

testMonitoring();
