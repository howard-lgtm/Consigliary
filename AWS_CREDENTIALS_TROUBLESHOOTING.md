# AWS Credentials Troubleshooting Guide

## Current Issue
Getting "SignatureDoesNotMatch" error when uploading to S3 from Railway production.

## Diagnostic Steps

### 1. Verify IAM User and Access Keys

**Go to AWS IAM Console:**
https://console.aws.amazon.com/iam/home?region=us-east-1#/users

**Steps:**
1. Click on "Users" in the left sidebar
2. Find the IAM user that should have S3 access
3. Click on the user name
4. Go to "Security credentials" tab
5. Check "Access keys" section

**What to verify:**
- Is there an active access key?
- Does the Access Key ID match what's in Railway? (`AWS_ACCESS_KEY_ID`)
- When was it created? (If very old, might need to rotate)

### 2. Check IAM User Permissions

**In the same IAM user page:**
1. Go to "Permissions" tab
2. Check if the user has S3 permissions

**Required permissions:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::consigliary-audio-files",
        "arn:aws:s3:::consigliary-audio-files/*"
      ]
    }
  ]
}
```

### 3. Verify S3 Bucket Exists in Correct Region

**Go to S3 Console:**
https://s3.console.aws.amazon.com/s3/buckets/consigliary-audio-files

**What to check:**
- Does the bucket exist?
- Is it in `eu-north-1` region?
- What are the bucket permissions?

### 4. Create New Access Keys (If Needed)

**If credentials are wrong or expired:**
1. Go to IAM → Users → [Your User] → Security credentials
2. Under "Access keys", click "Create access key"
3. Choose "Application running outside AWS"
4. Copy the Access Key ID and Secret Access Key
5. Update Railway environment variables:
   - `AWS_ACCESS_KEY_ID`: [New Access Key ID]
   - `AWS_SECRET_ACCESS_KEY`: [New Secret Access Key]

### 5. Test Credentials Locally

**Create a test file:** `backend/scripts/test-aws-credentials.js`

```javascript
const AWS = require('aws-sdk');

// Use the credentials from Railway
const credentials = {
  accessKeyId: 'YOUR_ACCESS_KEY_ID',
  secretAccessKey: 'YOUR_SECRET_ACCESS_KEY',
  region: 'eu-north-1'
};

const s3 = new AWS.S3(credentials);

async function testCredentials() {
  try {
    // Test 1: List buckets
    console.log('Testing AWS credentials...\n');
    const buckets = await s3.listBuckets().promise();
    console.log('✅ Credentials valid! Found buckets:', buckets.Buckets.map(b => b.Name));
    
    // Test 2: Check specific bucket
    const bucketName = 'consigliary-audio-files';
    await s3.headBucket({ Bucket: bucketName }).promise();
    console.log(`✅ Bucket "${bucketName}" exists and is accessible`);
    
    // Test 3: Try to upload a test file
    await s3.putObject({
      Bucket: bucketName,
      Key: 'test/credentials-test.txt',
      Body: 'Test from credentials check',
      ContentType: 'text/plain'
    }).promise();
    console.log('✅ Upload test successful');
    
    // Clean up
    await s3.deleteObject({
      Bucket: bucketName,
      Key: 'test/credentials-test.txt'
    }).promise();
    console.log('✅ All tests passed!');
    
  } catch (error) {
    console.error('❌ Error:', error.message);
    console.error('Error code:', error.code);
  }
}

testCredentials();
```

## Common Issues & Solutions

### Issue 1: "SignatureDoesNotMatch"
**Cause:** Wrong secret access key
**Solution:** Generate new access keys in IAM and update Railway

### Issue 2: "InvalidAccessKeyId"
**Cause:** Wrong access key ID or key doesn't exist
**Solution:** Verify the access key ID in IAM matches Railway

### Issue 3: "AccessDenied"
**Cause:** IAM user doesn't have S3 permissions
**Solution:** Attach S3 policy to IAM user (see permissions above)

### Issue 4: "NoSuchBucket"
**Cause:** Bucket doesn't exist or wrong region
**Solution:** Create bucket in eu-north-1 or update region in Railway

## Quick Fix Checklist

- [ ] Verify IAM user exists
- [ ] Check access keys are active
- [ ] Confirm access key ID matches Railway
- [ ] Verify IAM user has S3 permissions
- [ ] Confirm bucket exists in eu-north-1
- [ ] Test credentials locally
- [ ] Update Railway if credentials changed
- [ ] Wait for Railway to redeploy (~2 minutes)
- [ ] Test upload endpoint again

## Railway Environment Variables to Update

After fixing AWS credentials, update these in Railway:

```
AWS_ACCESS_KEY_ID=AKIA...
AWS_SECRET_ACCESS_KEY=...
AWS_REGION=eu-north-1
AWS_S3_BUCKET=consigliary-audio-files
```

---

**Next Steps After Fixing:**
1. Railway will auto-redeploy when you save env vars
2. Wait 1-2 minutes for deployment
3. Test the upload endpoint with curl
4. Verify file appears in S3 bucket

© 2025 HTDSTUDIO AB
