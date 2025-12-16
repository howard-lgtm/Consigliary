const AWS = require('aws-sdk');

// Configure AWS S3
const s3 = new AWS.S3({
  accessKeyId: process.env.AWS_ACCESS_KEY_ID,
  secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  region: process.env.AWS_REGION || 'eu-north-1'
});

const BUCKET_NAME = process.env.AWS_S3_BUCKET || 'consigliary-audio-files';

/**
 * Upload audio file to S3
 * @param {Buffer} fileBuffer - Audio file buffer
 * @param {string} userId - User ID
 * @param {string} trackId - Track ID
 * @param {string} fileName - Original file name
 * @returns {Promise<{url: string, key: string}>}
 */
async function uploadAudioFile(fileBuffer, userId, trackId, fileName) {
  const fileExtension = fileName.split('.').pop().toLowerCase();
  const key = `users/${userId}/tracks/${trackId}/original.${fileExtension}`;
  
  const params = {
    Bucket: BUCKET_NAME,
    Key: key,
    Body: fileBuffer,
    ContentType: getContentType(fileExtension),
    ServerSideEncryption: 'AES256'
  };

  try {
    const result = await s3.upload(params).promise();
    return {
      url: result.Location,
      key: result.Key,
      bucket: result.Bucket
    };
  } catch (error) {
    console.error('S3 upload error:', error);
    throw new Error(`Failed to upload file to S3: ${error.message}`);
  }
}

/**
 * Get audio file from S3
 * @param {string} key - S3 object key
 * @returns {Promise<Buffer>}
 */
async function getAudioFile(key) {
  const params = {
    Bucket: BUCKET_NAME,
    Key: key
  };

  try {
    const result = await s3.getObject(params).promise();
    return result.Body;
  } catch (error) {
    console.error('S3 download error:', error);
    throw new Error(`Failed to download file from S3: ${error.message}`);
  }
}

/**
 * Delete audio file from S3
 * @param {string} key - S3 object key
 * @returns {Promise<void>}
 */
async function deleteAudioFile(key) {
  const params = {
    Bucket: BUCKET_NAME,
    Key: key
  };

  try {
    await s3.deleteObject(params).promise();
  } catch (error) {
    console.error('S3 delete error:', error);
    throw new Error(`Failed to delete file from S3: ${error.message}`);
  }
}

/**
 * Generate pre-signed URL for temporary access
 * @param {string} key - S3 object key
 * @param {number} expiresIn - Expiration time in seconds (default: 1 hour)
 * @returns {Promise<string>}
 */
async function getSignedUrl(key, expiresIn = 3600) {
  const params = {
    Bucket: BUCKET_NAME,
    Key: key,
    Expires: expiresIn
  };

  try {
    return await s3.getSignedUrlPromise('getObject', params);
  } catch (error) {
    console.error('S3 signed URL error:', error);
    throw new Error(`Failed to generate signed URL: ${error.message}`);
  }
}

/**
 * Upload extracted audio sample (for verification)
 * @param {Buffer} audioBuffer - Audio sample buffer
 * @param {string} verificationId - Verification ID
 * @returns {Promise<{url: string, key: string}>}
 */
async function uploadAudioSample(audioBuffer, verificationId) {
  const key = `samples/${verificationId}.mp3`;
  
  const params = {
    Bucket: BUCKET_NAME,
    Key: key,
    Body: audioBuffer,
    ContentType: 'audio/mpeg',
    ServerSideEncryption: 'AES256'
  };

  try {
    const result = await s3.upload(params).promise();
    return {
      url: result.Location,
      key: result.Key
    };
  } catch (error) {
    console.error('S3 sample upload error:', error);
    throw new Error(`Failed to upload sample to S3: ${error.message}`);
  }
}

/**
 * Get content type based on file extension
 * @param {string} extension - File extension
 * @returns {string}
 */
function getContentType(extension) {
  const contentTypes = {
    'mp3': 'audio/mpeg',
    'wav': 'audio/wav',
    'flac': 'audio/flac',
    'm4a': 'audio/mp4',
    'aac': 'audio/aac',
    'ogg': 'audio/ogg'
  };
  
  return contentTypes[extension.toLowerCase()] || 'application/octet-stream';
}

/**
 * Test S3 connection
 * @returns {Promise<boolean>}
 */
async function testConnection() {
  try {
    await s3.headBucket({ Bucket: BUCKET_NAME }).promise();
    console.log(`✅ S3 connection successful: ${BUCKET_NAME}`);
    return true;
  } catch (error) {
    console.error('❌ S3 connection failed:', error.message);
    return false;
  }
}

module.exports = {
  uploadAudioFile,
  getAudioFile,
  deleteAudioFile,
  getSignedUrl,
  uploadAudioSample,
  testConnection
};
