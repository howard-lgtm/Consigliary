require('dotenv').config();
const AWS = require('aws-sdk');

console.log('Testing S3 Connection...\n');

// Log configuration (without secrets)
console.log('Configuration:');
console.log('- AWS_REGION:', process.env.AWS_REGION);
console.log('- AWS_S3_BUCKET:', process.env.AWS_S3_BUCKET);
console.log('- AWS_ACCESS_KEY_ID:', process.env.AWS_ACCESS_KEY_ID ? `${process.env.AWS_ACCESS_KEY_ID.substring(0, 8)}...` : 'NOT SET');
console.log('- AWS_SECRET_ACCESS_KEY:', process.env.AWS_SECRET_ACCESS_KEY ? 'SET (hidden)' : 'NOT SET');
console.log('');

const s3 = new AWS.S3({
  accessKeyId: process.env.AWS_ACCESS_KEY_ID,
  secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  region: process.env.AWS_REGION || 'eu-north-1'
});

const BUCKET_NAME = process.env.AWS_S3_BUCKET || 'consigliary-audio-files';

async function testS3() {
  try {
    console.log(`Testing bucket: ${BUCKET_NAME}`);
    
    // Test 1: Check if bucket exists
    console.log('\n1. Testing bucket access...');
    await s3.headBucket({ Bucket: BUCKET_NAME }).promise();
    console.log('✅ Bucket exists and is accessible');
    
    // Test 2: List objects (just to verify read permission)
    console.log('\n2. Testing list objects...');
    const listResult = await s3.listObjectsV2({ 
      Bucket: BUCKET_NAME,
      MaxKeys: 5
    }).promise();
    console.log(`✅ Can list objects. Found ${listResult.KeyCount} objects (showing max 5)`);
    
    // Test 3: Try to upload a small test file
    console.log('\n3. Testing upload...');
    const testKey = `test/connection-test-${Date.now()}.txt`;
    const uploadResult = await s3.upload({
      Bucket: BUCKET_NAME,
      Key: testKey,
      Body: Buffer.from('Test upload from Consigliary backend'),
      ContentType: 'text/plain'
    }).promise();
    console.log('✅ Upload successful:', uploadResult.Location);
    
    // Test 4: Delete the test file
    console.log('\n4. Testing delete...');
    await s3.deleteObject({
      Bucket: BUCKET_NAME,
      Key: testKey
    }).promise();
    console.log('✅ Delete successful');
    
    console.log('\n✅ All S3 tests passed!');
    return true;
  } catch (error) {
    console.error('\n❌ S3 test failed:');
    console.error('Error code:', error.code);
    console.error('Error message:', error.message);
    console.error('Status code:', error.statusCode);
    
    if (error.code === 'SignatureDoesNotMatch') {
      console.error('\n⚠️  This usually means:');
      console.error('   - AWS_SECRET_ACCESS_KEY is incorrect');
      console.error('   - AWS_ACCESS_KEY_ID is incorrect');
      console.error('   - System time is significantly off');
    }
    
    return false;
  }
}

testS3().then(success => {
  process.exit(success ? 0 : 1);
});
