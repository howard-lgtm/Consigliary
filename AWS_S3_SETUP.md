# ✅ AWS S3 Setup Complete

**Date**: December 15, 2025  
**Status**: Ready for Week 3 Day 2

---

## 🎯 What Was Configured

### **1. AWS Account**
- Account created: Consigliary
- Region: Europe (Stockholm) `eu-north-1`
- Free tier: US$100 credits + 12 months free

### **2. S3 Bucket**
- **Bucket name**: `consigliary-audio-files`
- **Region**: `eu-north-1` (Europe Stockholm)
- **Access**: Private (Block all public access)
- **Purpose**: Store user-uploaded audio files for fingerprinting

### **3. IAM User**
- **Username**: `consigliary-api`
- **Permissions**: AmazonS3FullAccess
- **Access type**: Programmatic (API keys only, no console access)
- **Purpose**: Backend API access to S3 bucket

### **4. Access Keys Generated**
- **Access Key ID**: `AKIAXLJX745ZAIQE76MX`
- **Secret Access Key**: (stored securely in Railway)
- **Use case**: Application running outside AWS

---

## 🔐 Railway Environment Variables Added

```bash
AWS_ACCESS_KEY_ID=AKIAXLJX745ZAIQE76MX
AWS_SECRET_ACCESS_KEY=***************************
AWS_S3_BUCKET=consigliary-audio-files
AWS_REGION=eu-north-1
```

**Note**: Backend will automatically pick up these variables on next deployment.

---

## 📊 S3 Pricing (Free Tier)

**First 12 months free:**
- 5 GB standard storage
- 20,000 GET requests
- 2,000 PUT requests

**After free tier:**
- Storage: ~$0.023 per GB/month
- PUT/POST: $0.005 per 1,000 requests
- GET: $0.0004 per 1,000 requests

**Estimated monthly cost for MVP**: $1-5 (well within budget)

---

## 🚀 Ready for Week 3 Day 2

**Next steps:**
1. Add audio file picker to AddTrackView
2. Implement S3 upload in backend
3. Send audio to ACRCloud for fingerprinting
4. Store S3 URL and fingerprint ID in database

**Backend code needed:**
- S3 upload service (`backend/services/s3.js`)
- Audio upload endpoint (`POST /api/v1/tracks/:id/upload-audio`)
- Integration with ACRCloud service

**iOS code needed:**
- File picker in AddTrackView
- Audio upload to backend
- Progress indicator during upload

---

## 📝 S3 Bucket Structure (Planned)

```
consigliary-audio-files/
├── users/
│   └── {user_id}/
│       └── tracks/
│           └── {track_id}/
│               ├── original.mp3
│               └── fingerprint.json
```

**File naming convention:**
- Original audio: `users/{user_id}/tracks/{track_id}/original.{ext}`
- Fingerprint data: `users/{user_id}/tracks/{track_id}/fingerprint.json`

---

## 🔒 Security Best Practices

✅ **Implemented:**
- Private bucket (no public access)
- IAM user with minimal permissions (S3 only)
- Access keys stored in Railway environment variables
- Keys never committed to git

✅ **Recommended for production:**
- Enable S3 bucket versioning
- Enable S3 bucket logging
- Set up lifecycle policies (delete old files after 90 days)
- Use pre-signed URLs for temporary access
- Implement file size limits (max 50MB per file)

---

## 🧪 Testing S3 Connection

**Backend test (Week 3 Day 2):**
```javascript
const AWS = require('aws-sdk');

const s3 = new AWS.S3({
  accessKeyId: process.env.AWS_ACCESS_KEY_ID,
  secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  region: process.env.AWS_REGION
});

// Test upload
const params = {
  Bucket: process.env.AWS_S3_BUCKET,
  Key: 'test/hello.txt',
  Body: 'Hello from Consigliary!',
  ContentType: 'text/plain'
};

s3.upload(params, (err, data) => {
  if (err) {
    console.error('S3 upload failed:', err);
  } else {
    console.log('S3 upload success:', data.Location);
  }
});
```

---

## 📚 AWS Resources

**Documentation:**
- [S3 Developer Guide](https://docs.aws.amazon.com/s3/)
- [IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
- [AWS SDK for Node.js](https://docs.aws.amazon.com/sdk-for-javascript/)

**Useful AWS CLI commands:**
```bash
# List buckets
aws s3 ls

# List files in bucket
aws s3 ls s3://consigliary-audio-files/

# Upload file
aws s3 cp file.mp3 s3://consigliary-audio-files/test/

# Download file
aws s3 cp s3://consigliary-audio-files/test/file.mp3 ./
```

---

## ✅ Setup Checklist

- [x] AWS account created
- [x] S3 bucket created (`consigliary-audio-files`)
- [x] IAM user created (`consigliary-api`)
- [x] Access keys generated
- [x] Credentials added to Railway
- [x] Backend ready for S3 integration
- [ ] S3 upload service implemented (Week 3 Day 2)
- [ ] Audio upload endpoint created (Week 3 Day 2)
- [ ] iOS file picker added (Week 3 Day 2)
- [ ] End-to-end audio upload tested (Week 3 Day 2)

---

**Status**: 🟢 **READY FOR WEEK 3 DAY 2**

© 2025 HTDSTUDIO AB. All rights reserved.
