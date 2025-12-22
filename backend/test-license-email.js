const axios = require('axios');

const API_URL = 'https://consigliary-production.up.railway.app/api/v1';

async function testLicenseEmailFlow() {
    console.log('🧪 Testing Complete License + Email Flow\n');
    console.log('========================================\n');

    try {
        // Step 1: Login
        console.log('1️⃣ Logging in...');
        const loginResponse = await axios.post(`${API_URL}/auth/login`, {
            email: 'test@consigliary.com',
            password: 'password123'
        });
        
        const token = loginResponse.data.data.accessToken;
        console.log('✅ Logged in successfully\n');

        // Step 2: Get user's tracks
        console.log('2️⃣ Fetching tracks...');
        const tracksResponse = await axios.get(`${API_URL}/tracks`, {
            headers: { Authorization: `Bearer ${token}` }
        });
        
        const tracks = tracksResponse.data.data.tracks;
        if (tracks.length === 0) {
            console.log('❌ No tracks found. Please upload a track first.');
            return;
        }
        
        const track = tracks[0];
        console.log(`✅ Found ${tracks.length} tracks`);
        console.log(`   Using: "${track.title}" by ${track.artist_name}`);
        console.log(`   Track ID: ${track.id}\n`);

        // Step 3: Get verifications (optional, for verification_id)
        console.log('3️⃣ Checking verifications...');
        const verificationsResponse = await axios.get(`${API_URL}/verifications`, {
            headers: { Authorization: `Bearer ${token}` }
        });
        
        const verifications = verificationsResponse.data.data;
        const verification = verifications.find(v => v.track_id === track.id);
        
        if (verification) {
            console.log(`✅ Found verification for this track (ID: ${verification.id})\n`);
        } else {
            console.log('⚠️  No verification found (optional)\n');
        }

        // Step 4: Generate license with email
        console.log('4️⃣ Generating license and sending email...');
        console.log('   Licensee: Test Licensee');
        console.log('   Email: howard@htdstudio.net');
        console.log('   Fee: $99.99\n');
        
        const licenseData = {
            trackId: track.id,
            verificationId: verification ? verification.id : null,
            licenseeName: 'Test Licensee',
            licenseeEmail: 'howard@htdstudio.net', // Your verified SendGrid email
            licenseePlatform: 'YouTube',
            licenseeChannelUrl: 'https://youtube.com/@testchannel',
            licenseFee: 99.99,
            currency: 'USD',
            territory: 'Worldwide',
            duration: 'Perpetual',
            exclusivity: 'non-exclusive',
            sendEmail: true // This triggers email sending
        };

        const licenseResponse = await axios.post(`${API_URL}/licenses`, licenseData, {
            headers: { Authorization: `Bearer ${token}` }
        });

        const license = licenseResponse.data.data;
        console.log('✅ License generated successfully!');
        console.log(`   License ID: ${license.id}`);
        console.log(`   PDF URL: ${license.pdfUrl}`);
        console.log(`   Status: ${license.status}`);
        
        if (license.stripeInvoiceUrl) {
            console.log(`   Stripe Invoice: ${license.stripeInvoiceUrl}`);
        }
        
        if (license.emailSent) {
            console.log('   ✅ Email sent successfully!');
        } else {
            console.log('   ⚠️  Email not sent (check logs)');
        }

        console.log('\n========================================');
        console.log('🎉 Test Complete!\n');
        console.log('Next Steps:');
        console.log('  1. Check your email (howard@htdstudio.net)');
        console.log('  2. Verify PDF is accessible');
        console.log('  3. Check Stripe dashboard for invoice');
        console.log('  4. Test payment webhook (optional)');
        console.log('');

    } catch (error) {
        console.error('\n❌ Test Failed!');
        if (error.response) {
            console.error('Status:', error.response.status);
            console.error('Error:', JSON.stringify(error.response.data, null, 2));
        } else {
            console.error('Error:', error.message);
        }
        process.exit(1);
    }
}

testLicenseEmailFlow();
