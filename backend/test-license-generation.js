const axios = require('axios');

const API_BASE = 'https://consigliary-production.up.railway.app/api/v1';

async function testLicenseGeneration() {
    try {
        console.log('🧪 Testing License Generation System\n');
        
        // Step 1: Login
        console.log('1️⃣ Logging in...');
        const loginRes = await axios.post(`${API_BASE}/auth/login`, {
            email: 'test@consigliary.com',
            password: 'password123'
        });
        const token = loginRes.data.data.accessToken;
        console.log('✅ Logged in\n');
        
        // Step 2: Get a track
        console.log('2️⃣ Fetching tracks...');
        const tracksRes = await axios.get(`${API_BASE}/tracks`, {
            headers: { 'Authorization': `Bearer ${token}` }
        });
        
        const tracks = tracksRes.data.data.tracks;
        if (tracks.length === 0) {
            console.log('⚠️  No tracks found. Please upload a track first.');
            return;
        }
        
        const track = tracks[0];
        console.log(`✅ Using track: "${track.title}" by ${track.artist_name}\n`);
        
        // Step 3: Get a verification (optional)
        console.log('3️⃣ Fetching verifications...');
        const verificationsRes = await axios.get(`${API_BASE}/verifications`, {
            headers: { 'Authorization': `Bearer ${token}` }
        });
        
        const verifications = verificationsRes.data.data?.verifications || [];
        const verification = verifications.length > 0 ? verifications[0] : null;
        
        if (verification) {
            console.log(`✅ Using verification: ${verification.video_title}\n`);
        } else {
            console.log('⚠️  No verifications found, generating license without verification\n');
        }
        
        // Step 4: Generate license
        console.log('4️⃣ Generating license...');
        const licenseData = {
            trackId: track.id,
            verificationId: verification?.id,
            licenseeName: 'Test Content Creator',
            licenseeEmail: 'creator@example.com',
            licenseePlatform: verification?.platform || 'YouTube',
            licenseeChannelUrl: verification?.channel_url || 'https://youtube.com/@testchannel',
            licenseFee: 250.00,
            currency: 'USD',
            territory: 'Worldwide',
            duration: 'Perpetual',
            exclusivity: 'non-exclusive'
        };
        
        const licenseRes = await axios.post(
            `${API_BASE}/licenses`,
            licenseData,
            {
                headers: { 'Authorization': `Bearer ${token}` },
                timeout: 30000
            }
        );
        
        console.log('✅ License generated successfully!\n');
        console.log('📊 License Details:');
        console.log(`   ID: ${licenseRes.data.data.license.id}`);
        console.log(`   Status: ${licenseRes.data.data.license.status}`);
        console.log(`   Fee: ${licenseRes.data.data.license.currency} $${licenseRes.data.data.license.license_fee}`);
        console.log(`   PDF URL: ${licenseRes.data.data.pdfUrl}\n`);
        
        // Step 5: Verify license was created
        console.log('5️⃣ Verifying license in database...');
        const licenseId = licenseRes.data.data.license.id;
        
        const getLicenseRes = await axios.get(
            `${API_BASE}/licenses/${licenseId}`,
            {
                headers: { 'Authorization': `Bearer ${token}` }
            }
        );
        
        console.log('✅ License verified in database\n');
        
        // Step 6: List all licenses
        console.log('6️⃣ Listing all licenses...');
        const allLicensesRes = await axios.get(`${API_BASE}/licenses`, {
            headers: { 'Authorization': `Bearer ${token}` }
        });
        
        console.log(`✅ Found ${allLicensesRes.data.data.licenses.length} total licenses\n`);
        
        console.log('🎉 All tests passed! License generation system is working perfectly!');
        console.log('\n📄 You can download the PDF from:');
        console.log(licenseRes.data.data.pdfUrl);
        
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

console.log('═══════════════════════════════════════════════════════');
console.log('  License Generation System Test');
console.log('═══════════════════════════════════════════════════════\n');

testLicenseGeneration();
