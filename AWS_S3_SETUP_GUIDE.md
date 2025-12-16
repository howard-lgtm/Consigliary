# AWS S3 Setup Guide for Consigliary

## Overview
AWS S3 will store audio files uploaded by users and extracted audio samples from videos for verification.

---

## Current Status

According to PROJECT_URLS.md, you already have:
- ✅ AWS Account: 5053-1296-2418
- ✅ Account Name: Consigliary
- ✅ Region: eu-north-1 (Stockholm)
- ✅ S3 Bucket: consigliary-audio-files
- ✅ Free Credits: $100 remaining
- ✅ Free Tier: 183 days remaining

---

## Step 1: Verify S3 Bucket Exists

1. **Go to:** https://s3.console.aws.amazon.com/s3/buckets/consigliary-audio-files
2. **Verify bucket exists** in eu-north-1 region

If bucket doesn't exist, create it:
- **Bucket name:** consigliary-audio-files
- **Region:** Europe (Stockholm) eu-north-1
- **Block public access:** ON (keep files private)
- **Versioning:** OFF (not needed for MVP)

---

## Step 2: Create IAM User for Backend

1. **Go to IAM Console:** https://console.aws.amazon.com/iam
2. **Users → Add User**
   - **User name:** consigliary-backend
   - **Access type:** Programmatic access (API keys)

3. **Attach Permissions:**
   - Click "Attach policies directly"
   - Search and select: **AmazonS3FullAccess**
   - (For production, use more restrictive policy)

4. **Create User**
5. **Save credentials:**
   - Access Key ID
   - Secret Access Key
   - ⚠️ **Save these now - you can't view secret again!**

---

## Step 3: Configure Bucket CORS (for direct uploads)

1. **Go to bucket:** consigliary-audio-files
2. **Permissions tab → CORS**
3. **Add this configuration:**

```json
[
  {
    "AllowedHeaders": ["*"],
    "AllowedMethods": ["GET", "PUT", "POST", "DELETE"],
    "AllowedOrigins": [
      "https://consigliary-production.up.railway.app",
      "http://localhost:3000"
    ],
    "ExposeHeaders": ["ETag"],
    "MaxAgeSeconds": 3000
  }
]
```

---

## Step 4: Add Credentials to Railway

1. **Go to Railway:** https://railway.app/project/453302b8-7e05-4d17-bf94-651434fed5eb
2. **Click "Consigliary" service**
3. **Variables tab**
4. **Verify/Update these variables:**
   - `AWS_ACCESS_KEY_ID` = [your access key]
   - `AWS_SECRET_ACCESS_KEY` = [your secret key]
   - `AWS_S3_BUCKET` = consigliary-audio-files
   - `AWS_REGION` = eu-north-1

---

## Step 5: Folder Structure

The backend will organize files like this:

```
consigliary-audio-files/
├── tracks/
│   └── {user_id}/
│       └── {track_id}.mp3
├── samples/
│   └── {verification_id}.mp3
└── temp/
    └── {timestamp}.mp3
```

---

## Step 6: Cost Estimation

### Free Tier (12 months):
- **Storage:** 5 GB free
- **Requests:** 20,000 GET, 2,000 PUT per month
- **Data Transfer:** 100 GB out per month

### After Free Tier:
- **Storage:** $0.023 per GB/month (~$0.50/month for 20 GB)
- **Requests:** $0.0004 per 1,000 GET (~$0.40/month)
- **Data Transfer:** $0.09 per GB (~$9/month for 100 GB)

### Estimated Costs:
- **Beta (20 users, 100 tracks):** FREE (within free tier)
- **Month 2 (100 users, 500 tracks):** ~$1-2/month
- **Month 3 (300 users, 2000 tracks):** ~$5-10/month

---

## Step 7: Test S3 Connection

Once credentials are in Railway, test with:

```bash
cd /Users/howardduffy/Desktop/Consigliary/backend
railway run node scripts/test-s3.js
```

---

## Security Best Practices

1. **Never commit AWS keys to Git**
2. **Use environment variables only**
3. **Enable CloudTrail** for audit logging (optional)
4. **Set up bucket lifecycle policies** to delete temp files after 7 days
5. **Consider S3 encryption** (AES-256) for sensitive files

---

## Lifecycle Policy (Optional - Save Costs)

Delete temporary files after 7 days:

1. **Bucket → Management → Lifecycle rules**
2. **Create rule:**
   - **Name:** Delete temp files
   - **Prefix:** temp/
   - **Expiration:** 7 days

---

## Next Steps After Setup

1. ✅ Verify bucket exists
2. ⏳ Create IAM user with S3 access
3. ⏳ Add credentials to Railway
4. ⏳ Configure CORS
5. ⏳ Test S3 connection
6. ⏳ Implement file upload in backend

---

**Estimated Setup Time:** 10 minutes

**Your $100 AWS credits will last:** ~10-12 months at projected usage
