# ACRCloud Setup Guide for Consigliary

## Overview
ACRCloud provides audio fingerprinting technology to identify music in videos. We'll use it to verify if unauthorized videos contain your tracks.

---

## Step 1: Create ACRCloud Account

1. **Go to:** https://console.acrcloud.com/signup
2. **Sign up** with your email
3. **Verify email** and log in

---

## Step 2: Create a Project

1. **Dashboard:** https://console.acrcloud.com
2. **Click "Audio & Video Recognition"**
3. **Create New Project:**
   - **Project Name:** Consigliary
   - **Project Type:** Audio & Video Recognition
   - **Bucket Type:** ACRCloud Music (default)
   - **Region:** Europe West 1 (closest to Sweden)

---

## Step 3: Get API Credentials

After creating the project, you'll see:

```
Host: identify-eu-west-1.acrcloud.com
Access Key: [YOUR_ACCESS_KEY]
Access Secret: [YOUR_ACCESS_SECRET]
```

**Save these credentials** - you'll need them for Railway environment variables.

---

## Step 4: Add Credentials to Railway

1. **Go to Railway:** https://railway.app/project/453302b8-7e05-4d17-bf94-651434fed5eb
2. **Click "Consigliary" service**
3. **Click "Variables" tab**
4. **Verify these variables exist:**
   - `ACRCLOUD_HOST` = identify-eu-west-1.acrcloud.com
   - `ACRCLOUD_ACCESS_KEY` = [your access key]
   - `ACRCLOUD_ACCESS_SECRET` = [your access secret]

---

## Step 5: Understanding ACRCloud Workflow

### For Track Upload (Fingerprinting):
```
1. User uploads audio file → Backend
2. Backend sends audio to ACRCloud
3. ACRCloud creates fingerprint
4. Backend stores fingerprint ID in database
```

### For Verification (Matching):
```
1. User pastes YouTube URL → Backend
2. Backend extracts audio from video
3. Backend sends audio to ACRCloud
4. ACRCloud matches against fingerprints
5. Backend returns match result (confidence %)
```

---

## Step 6: Free Tier Limits

- **5,000 queries/month** (free)
- **$0.002 per query** after free tier
- **98% accuracy** for music recognition
- **2-second response time**

### Estimated Usage:
- **Beta (20 users):** ~500 queries/month (well within free tier)
- **Month 2 (100 users):** ~2,500 queries/month (still free)
- **Month 3 (300 users):** ~7,500 queries/month (~$5/month cost)

---

## Step 7: Test API Connection

Once credentials are in Railway, test with:

```bash
cd /Users/howardduffy/Desktop/Consigliary/backend
railway run node scripts/test-acrcloud.js
```

---

## API Documentation

**Official Docs:** https://docs.acrcloud.com/audio-fingerprinting-api

**Key Endpoints:**
- **Identify:** POST https://identify-eu-west-1.acrcloud.com/v1/identify
- **Add Track:** POST https://api-eu-west-1.acrcloud.com/v1/buckets/{bucket_id}/files

---

## Next Steps After Setup

1. ✅ Account created
2. ✅ Project created
3. ✅ Credentials added to Railway
4. ⏳ Test API connection
5. ⏳ Implement track fingerprinting
6. ⏳ Implement video verification

---

**Estimated Setup Time:** 10 minutes
