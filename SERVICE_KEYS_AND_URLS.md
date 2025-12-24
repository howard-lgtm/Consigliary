# Consigliary - Service Keys & URLs Reference

**Last Updated**: December 23, 2025

This document contains all service URLs, API keys, credentials, and configuration details for the Consigliary platform.

---

## 🚀 Production Environment

### Railway (Backend Hosting)
- **Dashboard**: https://railway.app/project/453302b8-7e05-4d17-bf94-651434fed5eb
- **Production API**: https://consigliary-production.up.railway.app
- **Health Check**: https://consigliary-production.up.railway.app/health
- **API Base**: https://consigliary-production.up.railway.app/api/v1

### PostgreSQL Database
- **Provider**: Railway PostgreSQL
- **Connection**: Via `DATABASE_URL` environment variable
- **Region**: US
- **SSL**: Disabled for internal Railway connections

---

## 🔑 API Keys & Credentials

### 1. YouTube Data API v3
- **Console**: https://console.cloud.google.com
- **Project**: Consigliary (Project ID: gen-lang-client-0466839778)
- **API Key**: `AIzaSyDrAT27istdBYLoYLI-HEVLUydgRKzBctw`
- **Restrictions**: YouTube Data API v3 only
- **Quota**: 10,000 units/day (free tier)
- **Environment Variable**: `YOUTUBE_API_KEY`

### 2. ACRCloud (Audio Fingerprinting)
- **Dashboard**: https://console.acrcloud.com
- **API Endpoint**: https://identify-eu-west-1.acrcloud.com/v1/identify
- **Environment Variables**:
  - `ACRCLOUD_HOST`: identify-eu-west-1.acrcloud.com
  - `ACRCLOUD_ACCESS_KEY`: [Your ACRCloud access key]
  - `ACRCLOUD_ACCESS_SECRET`: [Your ACRCloud secret]

### 3. AWS S3 (File Storage)
- **Console**: https://console.aws.amazon.com/s3
- **Bucket Name**: `consigliary-audio-files`
- **Region**: `eu-north-1` (Stockholm)
- **Bucket URL**: https://s3.eu-north-1.amazonaws.com/consigliary-audio-files
- **Environment Variables**:
  - `AWS_ACCESS_KEY_ID`: [Your AWS access key]
  - `AWS_SECRET_ACCESS_KEY`: [Your AWS secret key]
  - `AWS_REGION`: eu-north-1
  - `AWS_S3_BUCKET`: consigliary-audio-files

### 4. Stripe (Payments)
- **Dashboard**: https://dashboard.stripe.com
- **Environment Variables**:
  - `STRIPE_SECRET_KEY`: [Your Stripe secret key]
  - `STRIPE_WEBHOOK_SECRET`: [Your Stripe webhook secret]
- **Webhook Endpoint**: https://consigliary-production.up.railway.app/api/v1/webhooks/stripe

### 5. SendGrid (Email)
- **Dashboard**: https://app.sendgrid.com
- **Environment Variables**:
  - `SENDGRID_API_KEY`: [Your SendGrid API key]
  - `SENDGRID_FROM_EMAIL`: [Your verified sender email]

---

## 🧪 Test Credentials

### Test User Account
- **Email**: test@consigliary.com
- **Password**: password123
- **User ID**: 17529e8e-4757-44e1-85a7-4c3ddab71823

### Test Track
- **Title**: "Pigs Blood and Chalk"
- **Artist**: Fila Brazillia
- **Track ID**: 3076d3ca-d007-4e20-991f-d6578e7bdece

---

## 📡 API Endpoints

### Authentication
```
POST   /api/v1/auth/register
POST   /api/v1/auth/login
POST   /api/v1/auth/refresh
GET    /api/v1/auth/me
```

### Tracks
```
POST   /api/v1/tracks
GET    /api/v1/tracks
GET    /api/v1/tracks/:id
PUT    /api/v1/tracks/:id
DELETE /api/v1/tracks/:id
```

### Verifications
```
POST   /api/v1/verifications
GET    /api/v1/verifications
GET    /api/v1/verifications/:id
PUT    /api/v1/verifications/:id
```

### Licenses
```
POST   /api/v1/licenses
GET    /api/v1/licenses
GET    /api/v1/licenses/:id
POST   /api/v1/licenses/:id/send
```

### Monitoring (NEW)
```
POST   /api/v1/monitoring/jobs
GET    /api/v1/monitoring/jobs
GET    /api/v1/monitoring/jobs/:trackId
POST   /api/v1/monitoring/run/:trackId
GET    /api/v1/monitoring/alerts
GET    /api/v1/monitoring/alerts/:id
PUT    /api/v1/monitoring/alerts/:id
GET    /api/v1/monitoring/stats
```

### Setup/Admin
```
POST   /api/v1/setup/migrate
GET    /api/v1/setup/status
```

### Webhooks
```
POST   /api/v1/webhooks/stripe
```

---

## 🌐 External Service URLs

### YouTube
- **API Documentation**: https://developers.google.com/youtube/v3
- **Search Endpoint**: https://www.googleapis.com/youtube/v3/search
- **Videos Endpoint**: https://www.googleapis.com/youtube/v3/videos

### ACRCloud
- **Documentation**: https://docs.acrcloud.com
- **Identify Endpoint**: https://identify-eu-west-1.acrcloud.com/v1/identify

### AWS S3
- **Documentation**: https://docs.aws.amazon.com/s3
- **Console**: https://s3.console.aws.amazon.com/s3/buckets/consigliary-audio-files

### Stripe
- **Documentation**: https://stripe.com/docs/api
- **Dashboard**: https://dashboard.stripe.com
- **Test Mode**: https://dashboard.stripe.com/test

### SendGrid
- **Documentation**: https://docs.sendgrid.com
- **Dashboard**: https://app.sendgrid.com
- **Email Activity**: https://app.sendgrid.com/email_activity

---

## 🔧 Railway Environment Variables

Complete list of environment variables set in Railway:

```bash
# Database
DATABASE_URL=postgresql://...

# AWS S3
AWS_ACCESS_KEY_ID=...
AWS_SECRET_ACCESS_KEY=...
AWS_REGION=eu-north-1
AWS_S3_BUCKET=consigliary-audio-files

# ACRCloud
ACRCLOUD_HOST=identify-eu-west-1.acrcloud.com
ACRCLOUD_ACCESS_KEY=...
ACRCLOUD_ACCESS_SECRET=...

# Stripe
STRIPE_SECRET_KEY=...
STRIPE_WEBHOOK_SECRET=...

# SendGrid
SENDGRID_API_KEY=...
SENDGRID_FROM_EMAIL=...

# YouTube
YOUTUBE_API_KEY=AIzaSyDrAT27istdBYLoYLI-HEVLUydgRKzBctw

# App Config
NODE_ENV=production
PORT=3000
JWT_SECRET=...
```

---

## 📱 iOS App Configuration

### API Base URL
```swift
let API_BASE_URL = "https://consigliary-production.up.railway.app/api/v1"
```

### Required Headers
```swift
Authorization: Bearer {access_token}
Content-Type: application/json
```

---

## 🧪 Testing Scripts

### Backend Tests
```bash
# Test license generation and email
node backend/test-license-email.js

# Test verification system
node backend/test-verification.js

# Test monitoring system
node backend/test-monitoring.js
```

### Manual API Tests
```bash
# Login
curl -X POST https://consigliary-production.up.railway.app/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@consigliary.com","password":"password123"}'

# Get tracks
curl https://consigliary-production.up.railway.app/api/v1/tracks \
  -H "Authorization: Bearer {token}"

# Health check
curl https://consigliary-production.up.railway.app/health
```

---

## 📊 Service Costs

### Current Monthly Costs (Estimated)

| Service | Plan | Cost |
|---------|------|------|
| Railway | Hobby | $5/month |
| PostgreSQL | Railway included | $0 |
| AWS S3 | Pay-as-you-go | ~$1-5/month |
| ACRCloud | Free tier | $0 (up to 3,000 queries) |
| Stripe | Pay-as-you-go | 2.9% + $0.30 per transaction |
| SendGrid | Free tier | $0 (up to 100 emails/day) |
| YouTube API | Free tier | $0 (up to 10,000 units/day) |
| **Total** | | **~$6-10/month** |

### Scaling Costs (1,000 active users)

| Service | Estimated Cost |
|---------|---------------|
| Railway | $20/month (Pro plan) |
| AWS S3 | $20-50/month |
| ACRCloud | $50-100/month |
| Stripe | 2.9% of revenue |
| SendGrid | $15/month (Essentials) |
| YouTube API | $5-20/month |
| **Total** | **~$110-205/month + transaction fees** |

---

## 🔐 Security Notes

### API Key Security
- ✅ All keys stored in Railway environment variables
- ✅ Never committed to git
- ✅ YouTube API key restricted to YouTube Data API v3 only
- ✅ AWS IAM user has minimal required permissions
- ✅ Stripe webhook secret validates webhook signatures

### Best Practices
1. Rotate keys every 90 days
2. Use separate keys for development/production
3. Monitor API usage in dashboards
4. Set up billing alerts
5. Review access logs regularly

---

## 📞 Support & Documentation

### Service Support
- **Railway**: https://railway.app/help
- **AWS**: https://console.aws.amazon.com/support
- **Stripe**: https://support.stripe.com
- **SendGrid**: https://support.sendgrid.com
- **ACRCloud**: support@acrcloud.com
- **Google Cloud**: https://cloud.google.com/support

### Internal Documentation
- `README.md` - Project overview
- `MONITORING_SYSTEM.md` - Monitoring system guide
- `MONITORING_SETUP_COMPLETE.md` - Setup completion summary
- `SENDGRID_UPDATE_INSTRUCTIONS.md` - SendGrid migration guide

---

## 🔄 Quick Reference Commands

### Railway CLI
```bash
# Login
railway login

# Link project
railway link

# View logs
railway logs

# Set environment variable
railway variables --set KEY=value

# Deploy
railway up
```

### Database Migration
```bash
# Run migration via API
curl -X POST https://consigliary-production.up.railway.app/api/v1/setup/migrate

# Check database status
curl https://consigliary-production.up.railway.app/api/v1/setup/status
```

---

## ⚠️ Important Notes

1. **YouTube API Key**: Has a typo-prone format - starts with "AIza" not "Alza"
2. **S3 Pre-signed URLs**: Valid for 7 days, regenerate for long-term access
3. **Stripe Webhooks**: Must be configured in Stripe dashboard
4. **ACRCloud**: Free tier limited to 3,000 identifications/month
5. **SendGrid**: Sender email must be verified before sending

---

## 📝 Changelog

### December 23, 2025
- ✅ Added YouTube Data API v3 integration
- ✅ Created monitoring system database tables
- ✅ Deployed monitoring endpoints to production
- ✅ Configured and tested YouTube API key

### Previous Updates
- ✅ Switched from Nodemailer to SendGrid HTTP API
- ✅ Added S3 pre-signed URLs for license PDFs
- ✅ Implemented verification system with ACRCloud
- ✅ Set up Stripe payment integration
- ✅ Deployed backend to Railway

---

*Keep this document updated as new services are added or keys are rotated.*
