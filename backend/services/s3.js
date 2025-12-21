const { S3Client, PutObjectCommand, GetObjectCommand, DeleteObjectCommand, HeadBucketCommand } = require('@aws-sdk/client-s3');
const { Upload } = require('@aws-sdk/lib-storage');
const { getSignedUrl } = require('@aws-sdk/s3-request-presigner');

// Configure AWS S3 Client
const s3Client = new S3Client({
  region: process.env.AWS_REGION || 'eu-north-1',
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY
  }
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
    const upload = new Upload({
      client: s3Client,
      params: params
    });

    const result = await upload.done();
    const url = `https://${params.Bucket}.s3.${process.env.AWS_REGION || 'eu-north-1'}.amazonaws.com/${params.Key}`;
    
    return {
      url: url,
      key: params.Key,
      bucket: params.Bucket
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
    const command = new GetObjectCommand(params);
    const result = await s3Client.send(command);
    
    // Convert stream to buffer
    const chunks = [];
    for await (const chunk of result.Body) {
      chunks.push(chunk);
    }
    return Buffer.concat(chunks);
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
    const command = new DeleteObjectCommand(params);
    await s3Client.send(command);
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
async function getPresignedUrl(key, expiresIn = 3600) {
  const params = {
    Bucket: BUCKET_NAME,
    Key: key
  };

  try {
    const command = new GetObjectCommand(params);
    return await getSignedUrl(s3Client, command, { expiresIn });
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
    const upload = new Upload({
      client: s3Client,
      params: params
    });

    await upload.done();
    const url = `https://${params.Bucket}.s3.${process.env.AWS_REGION || 'eu-north-1'}.amazonaws.com/${params.Key}`;
    
    return {
      url: url,
      key: params.Key
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
    const command = new HeadBucketCommand({ Bucket: BUCKET_NAME });
    await s3Client.send(command);
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
  getSignedUrl: getPresignedUrl,
  uploadAudioSample,
  testConnection
};
