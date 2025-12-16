const crypto = require('crypto');
const https = require('https');

// ACRCloud credentials from screenshot
const config = {
  host: 'identify-eu-west-1.acrcloud.com',
  access_key: '357869f932ac3c674d474d51585baa',
  access_secret: 'e2gxN0FDWEGfxBB3CqvaVacXiVvhH4so1QulPfY0'
};

function buildStringToSign(method, uri, accessKey, dataType, signatureVersion, timestamp) {
  return [method, uri, accessKey, dataType, signatureVersion, timestamp].join('\n');
}

function sign(string, accessSecret) {
  return crypto.createHmac('sha1', accessSecret)
    .update(Buffer.from(string, 'utf-8'))
    .digest()
    .toString('base64');
}

async function testACRCloud() {
  console.log('🧪 Testing ACRCloud Connection\n');
  console.log('Host:', config.host);
  console.log('Access Key:', config.access_key.substring(0, 10) + '...\n');

  const timestamp = new Date().getTime();
  const stringToSign = buildStringToSign(
    'POST',
    '/v1/identify',
    config.access_key,
    'audio',
    '1',
    timestamp.toString()
  );

  const signature = sign(stringToSign, config.access_secret);

  // Create a simple test request (will fail without audio, but tests connection)
  const postData = JSON.stringify({
    access_key: config.access_key,
    data_type: 'audio',
    signature_version: '1',
    signature: signature,
    sample_bytes: 0,
    timestamp: timestamp
  });

  const options = {
    hostname: config.host,
    port: 443,
    path: '/v1/identify',
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Content-Length': Buffer.byteLength(postData)
    }
  };

  return new Promise((resolve, reject) => {
    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => { data += chunk; });
      res.on('end', () => {
        console.log('Response Status:', res.statusCode);
        console.log('Response:', data.substring(0, 200));
        
        if (res.statusCode === 200 || res.statusCode === 400) {
          console.log('\n✅ ACRCloud connection successful!');
          console.log('(400 error expected without audio sample - connection is working)');
        } else {
          console.log('\n❌ Unexpected response from ACRCloud');
        }
        resolve();
      });
    });

    req.on('error', (e) => {
      console.error('\n❌ Connection failed:', e.message);
      reject(e);
    });

    req.write(postData);
    req.end();
  });
}

testACRCloud().catch(console.error);
