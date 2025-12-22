# Consigliary Monitoring System

## Overview

The monitoring system automatically scans YouTube (and eventually TikTok/Instagram) for unauthorized uses of your music. It uses the YouTube Data API to search for videos, then can optionally verify matches using ACRCloud audio fingerprinting.

## Architecture

### Phase 1: Smart Monitoring (Current Implementation)

```
┌─────────────────────────────────────────────────────────────┐
│                     Monitoring Flow                          │
└─────────────────────────────────────────────────────────────┘

1. Artist uploads track → Fingerprint stored
2. Artist enables monitoring → Job created
3. Scheduler runs periodically → Searches YouTube
4. Potential matches found → Alerts created
5. Artist reviews alerts → Verifies/dismisses
6. Artist generates license → Invoice sent
```

### Database Schema

**monitoring_jobs** - Tracks monitoring configuration per track
- Frequency: daily, weekly, monthly
- Platforms: YouTube, TikTok, Instagram
- Search terms: artist name, track title, custom keywords
- Status: active, paused, error

**monitoring_alerts** - Stores potential matches
- Video metadata (title, channel, views, etc.)
- Match confidence score
- Status: new, reviewed, verified, dismissed, licensed
- Links to verifications and licenses

**monitoring_stats** - Aggregated statistics
- Scans performed
- Matches found
- Revenue generated

## API Endpoints

### Monitoring Jobs

**POST /api/v1/monitoring/jobs**
Create or update monitoring job for a track
```json
{
  "trackId": "uuid",
  "enabled": true,
  "frequency": "weekly",
  "platforms": ["YouTube"]
}
```

**GET /api/v1/monitoring/jobs**
List all monitoring jobs

**GET /api/v1/monitoring/jobs/:trackId**
Get monitoring job for specific track

**POST /api/v1/monitoring/run/:trackId**
Manually trigger monitoring for a track

### Alerts

**GET /api/v1/monitoring/alerts**
List all alerts with filtering
- Query params: `status`, `trackId`, `limit`, `offset`

**GET /api/v1/monitoring/alerts/:id**
Get single alert details

**PUT /api/v1/monitoring/alerts/:id**
Update alert status
```json
{
  "status": "reviewed",
  "notes": "Verified match, sending license"
}
```

### Statistics

**GET /api/v1/monitoring/stats**
Get monitoring statistics
- Query params: `trackId`, `period` (default: 30d)

## YouTube API Configuration

### Setup

1. Create project in [Google Cloud Console](https://console.cloud.google.com)
2. Enable YouTube Data API v3
3. Create API key (no OAuth needed for search)
4. Add to Railway environment variables:
   ```
   YOUTUBE_API_KEY=your_api_key_here
   ```

### Quota Management

**Free Tier**: 10,000 units/day

**Cost per operation:**
- Search: 100 units
- Video details: 1 unit per video

**Example usage:**
- 50 searches/day = 5,000 units
- 500 video details = 500 units
- **Total**: 5,500 units/day (within free tier)

**Paid tier**: $0.05 per 1,000 units after free tier

### Best Practices

1. **Batch requests**: Get multiple video details in one call
2. **Cache results**: Store video metadata to avoid re-fetching
3. **Smart scheduling**: Run weekly instead of daily
4. **Filter results**: Skip artist's own channel
5. **Monitor quota**: Track usage in `youtubeMonitor.getQuotaInfo()`

## Monitoring Workflow

### For Artists

1. **Enable Monitoring**
   - Upload track to Consigliary
   - Enable monitoring in track settings
   - System creates monitoring job

2. **Receive Alerts**
   - Weekly email digest of new matches
   - Dashboard shows pending alerts
   - Click to review video details

3. **Review & Action**
   - Watch video to confirm match
   - Click "Verify" to run audio fingerprinting
   - Generate license if confirmed
   - Dismiss if false positive

4. **Track Revenue**
   - See potential revenue from views
   - Track licensed vs unlicensed uses
   - Monitor compliance

### Automated Process

**Scheduler runs every hour:**
```javascript
const scheduler = require('./jobs/monitoringScheduler');
scheduler.start(60); // Check every 60 minutes
```

**For each due job:**
1. Search YouTube for track
2. Get video statistics
3. Filter out artist's own videos
4. Create alerts for new matches
5. Update job status
6. Send notification if alerts found

## Testing

### Manual Test

```bash
# Run migration to create tables
psql $DATABASE_URL -f backend/database/migrations/001_add_monitoring_tables.sql

# Test the monitoring system
node backend/test-monitoring.js
```

### Expected Output

```
🧪 Testing Monitoring System
========================================

1️⃣ Logging in...
✅ Logged in

2️⃣ Fetching tracks...
✅ Found track: "Your Track" by Artist Name

3️⃣ Creating monitoring job...
✅ Monitoring job created

4️⃣ Running monitoring...
✅ Monitoring complete!

📊 Results:
   Videos found: 15
   New alerts: 8
   Quota used: 115 units

5️⃣ Fetching alerts...
✅ Found 8 new alerts:

   1. Someone's Video Using Your Song
      Channel: Random Creator
      Views: 125,000
      Confidence: 50.0%

🎉 Monitoring System Test Complete!
```

## Cost Analysis

### Monthly Costs (1,000 tracks monitored weekly)

**YouTube API:**
- 1,000 tracks × 4 weeks = 4,000 searches
- 4,000 × 100 units = 400,000 units
- 400,000 - 300,000 (free tier × 30 days) = 100,000 paid units
- 100,000 × $0.05/1,000 = **$5/month**

**ACRCloud (optional verification):**
- ~100 verifications/month
- 100 × $0.02 = **$2/month**

**Total**: ~$7/month for 1,000 tracks

### Revenue Model

**Charge artists:**
- Free tier: 1 track monitored
- Pro ($9.99/mo): 10 tracks monitored
- Enterprise ($49.99/mo): Unlimited tracks

**Break-even**: ~15 Pro users or 3 Enterprise users

## Future Enhancements

### Phase 2: Enhanced Monitoring
- TikTok API integration
- Instagram API integration
- Automatic audio verification for high-confidence matches
- Email notifications with alert digest
- Mobile push notifications

### Phase 3: Platform Partnerships
- YouTube Content ID integration
- Facebook Rights Manager
- TikTok Commercial Music Library
- Automated monetization

### Phase 4: Advanced Features
- Trend analysis (which platforms, which creators)
- Revenue forecasting
- Automated licensing (pre-approved rates)
- Bulk license generation
- Creator whitelist/blacklist

## Environment Variables

Add to Railway:

```bash
# YouTube API
YOUTUBE_API_KEY=your_youtube_api_key

# Optional: For future TikTok integration
TIKTOK_API_KEY=your_tiktok_api_key
TIKTOK_API_SECRET=your_tiktok_api_secret
```

## Scheduler Setup

### Development
```javascript
// In server.js
if (process.env.NODE_ENV === 'production') {
  const scheduler = require('./jobs/monitoringScheduler');
  scheduler.start(60); // Check every hour
}
```

### Production (Railway)
The scheduler runs automatically when the server starts. Monitor logs:
```bash
railway logs
```

Look for:
```
🚀 Starting monitoring scheduler (checking every 60 minutes)
⏰ Checking for scheduled monitoring jobs...
📊 Found 5 jobs to run
✅ Scheduled jobs completed
```

## Support

For issues or questions:
1. Check Railway logs for errors
2. Verify YouTube API key is set
3. Check quota usage: `youtubeMonitor.getQuotaInfo()`
4. Test manually: `node test-monitoring.js`
