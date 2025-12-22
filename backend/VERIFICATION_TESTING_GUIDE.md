# 🧪 Verification System Testing Guide

**Date**: December 20, 2025  
**Purpose**: Local testing of URL verification before Railway deployment

---

## 🎯 Testing Objective

Validate the verification flow works end-to-end locally before fixing Railway production issues.

**Critical Blockers Identified:**
- ❌ FFmpeg missing in Railway production
- ⚠️ ytdl-core v4.11.5 potentially outdated
- ❌ Never tested end-to-end

---

## 📋 Prerequisites

### ✅ Already Installed
- [x] FFmpeg v7.1.1 (`/opt/homebrew/bin/ffmpeg`)
- [x] Node.js >= 18.0.0
- [x] Backend dependencies (`npm install` completed)

### ⚙️ Required Environment Variables

You need to create `/Users/howardduffy/Desktop/Consigliary/backend/.env` with these values from Railway:

```bash
# Server Configuration
NODE_ENV=development
PORT=3000
API_VERSION=v1

# Database (use Railway production DB for testing)
DATABASE_URL=<from Railway>

# JWT Authentication (use Railway values)
JWT_SECRET=<from Railway>
JWT_EXPIRES_IN=15m
REFRESH_TOKEN_SECRET=<from Railway>
REFRESH_TOKEN_EXPIRES_IN=30d

# AWS S3 (use Railway values)
AWS_ACCESS_KEY_ID=<from Railway>
AWS_SECRET_ACCESS_KEY=<from Railway>
AWS_S3_BUCKET=consigliary-audio-files
AWS_REGION=eu-north-1

# ACRCloud (use Railway values)
ACRCLOUD_HOST=identify-eu-west-1.acrcloud.com
ACRCLOUD_ACCESS_KEY=<from Railway>
ACRCLOUD_ACCESS_SECRET=<from Railway>

# Frontend URL (for CORS)
FRONTEND_URL=http://localhost:3000
IOS_APP_BUNDLE_ID=com.htdstudio.consigliary

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
```

**To get Railway values:**
```bash
cd /Users/howardduffy/Desktop/Consigliary/backend
railway link  # Select: howard-lgtm's Projects > Consigliary
railway variables
```

---

## 🧪 Test Plan

### Test 1: Backend Server Startup
```bash
cd /Users/howardduffy/Desktop/Consigliary/backend
npm start
```

**Expected Output:**
```
Server running on port 3000
Database connected
✅ Health check: http://localhost:3000/health
```

**Verify:**
```bash
curl http://localhost:3000/health
```

---

### Test 2: Authentication (Get Test Token)
```bash
# Login as test user
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@consigliary.com",
    "password": "password123"
  }'
```

**Expected Response:**
```json
{
  "success": true,
  "accessToken": "eyJhbGc...",
  "refreshToken": "eyJhbGc...",
  "user": {...}
}
```

**Save the accessToken for next tests!**

---

### Test 3: YouTube Audio Extraction (Critical Test)

**Test Video:** Use a short, popular video (e.g., Rick Astley - Never Gonna Give You Up)
- URL: `https://www.youtube.com/watch?v=dQw4w9WgXcQ`
- Duration: 3:33 (will extract first 30 seconds)

```bash
# Replace <TOKEN> with your accessToken from Test 2
curl -X POST http://localhost:3000/api/v1/verifications \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <TOKEN>" \
  -d '{
    "videoUrl": "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
  }'
```

**What to Watch For:**

1. **Console logs should show:**
   ```
   📹 Extracting audio from YouTube video: dQw4w9WgXcQ
   📊 Video metadata: Never Gonna Give You Up by Rick Astley
   ✅ Audio extraction complete
   📦 Audio buffer size: XXXXX bytes
   ✅ Audio sample uploaded to S3: https://...
   ```

2. **Potential Failures:**
   - `ytdl-core` error → YouTube API changed (need to upgrade)
   - FFmpeg error → Check FFmpeg path
   - S3 upload error → Check AWS credentials
   - ACRCloud error → Check ACRCloud credentials

**Expected Response (Success):**
```json
{
  "success": true,
  "verification": {
    "id": "...",
    "status": "confirmed" or "disputed",
    "platform": "YouTube",
    "videoTitle": "Never Gonna Give You Up",
    "channelName": "Rick Astley",
    "matchResult": {
      "matched": true/false,
      "confidence": 95,
      "title": "...",
      "artist": "..."
    }
  }
}
```

**Expected Response (Failure):**
```json
{
  "success": false,
  "message": "Verification failed",
  "error": "..."
}
```

---

### Test 4: Verify S3 Upload

Check if audio sample was uploaded:
```bash
# Check S3 bucket
open https://s3.console.aws.amazon.com/s3/buckets/consigliary-audio-files
```

Look for file: `verification-samples/<verification-id>.mp3`

---

### Test 5: ACRCloud Matching with Your Track

**Goal:** Upload one of your tracks (Leonids or Slow Light) to ACRCloud, then verify it matches.

**Step 1: Get your track audio file**
```bash
# List your tracks
curl http://localhost:3000/api/v1/tracks \
  -H "Authorization: Bearer <TOKEN>"
```

**Step 2: Upload track to ACRCloud**
- Go to: https://console.acrcloud.com
- Navigate to your bucket
- Upload audio file manually
- Note the ACR ID

**Step 3: Test verification with a video containing your track**
```bash
curl -X POST http://localhost:3000/api/v1/verifications \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <TOKEN>" \
  -d '{
    "videoUrl": "<URL_WITH_YOUR_TRACK>",
    "trackId": "<YOUR_TRACK_ID>"
  }'
```

---

## 🐛 Debugging Common Issues

### Issue 1: ytdl-core Error
```
Error: Status code: 410
```

**Solution:** Upgrade ytdl-core
```bash
npm install ytdl-core@latest
# OR switch to yt-dlp
npm install yt-dlp-wrap
```

### Issue 2: FFmpeg Not Found
```
Error: Cannot find ffmpeg
```

**Solution:** Set FFmpeg path explicitly in `audioExtractor.js`:
```javascript
ffmpeg.setFfmpegPath('/opt/homebrew/bin/ffmpeg');
```

### Issue 3: ACRCloud "No Match Found"
```json
{
  "matched": false,
  "message": "No match found in ACRCloud database"
}
```

**This is EXPECTED** if the video doesn't contain music in ACRCloud's database.
- Test with popular songs (Rick Astley, etc.)
- Or upload your own tracks to ACRCloud first

### Issue 4: S3 Upload Fails
```
Error: Access Denied
```

**Solution:** Check AWS credentials and bucket permissions

---

## ✅ Success Criteria

**Local testing is successful if:**
1. ✅ Backend starts without errors
2. ✅ YouTube audio extraction completes
3. ✅ Audio sample uploads to S3
4. ✅ ACRCloud returns a response (match or no match)
5. ✅ Verification record created in database

**If all 5 pass → Ready to fix Railway production**

---

## 🚀 Next Steps After Local Testing

### If Tests Pass ✅
1. Add FFmpeg to Railway (see RAILWAY_FFMPEG_SETUP.md)
2. Deploy to production
3. Test production endpoint
4. Update iOS app to use real verification

### If Tests Fail ❌
1. Debug and fix issues locally
2. Update code as needed
3. Re-test until passing
4. Then proceed to Railway deployment

---

## 📊 Test Results Template

```
Date: ___________
Tester: ___________

[ ] Test 1: Backend Startup - PASS/FAIL
    Notes: ___________

[ ] Test 2: Authentication - PASS/FAIL
    Token: ___________

[ ] Test 3: YouTube Extraction - PASS/FAIL
    Video: ___________
    Error (if any): ___________
    
[ ] Test 4: S3 Upload - PASS/FAIL
    File URL: ___________
    
[ ] Test 5: ACRCloud Match - PASS/FAIL
    Match Result: ___________

Overall Status: PASS/FAIL
Time Taken: ___________
Issues Found: ___________
```

---

© 2025 HTDSTUDIO AB
