# 🔗 Consigliary Project URLs

**Last Updated**: December 15, 2025

---

## 🚀 Production Services

### **Backend API**
- **Production URL**: https://consigliary-production.up.railway.app
- **Health Check**: https://consigliary-production.up.railway.app/health
- **API Base**: https://consigliary-production.up.railway.app/api/v1

### **Railway (Hosting)**
- **Dashboard**: https://railway.app/dashboard
- **Project**: https://railway.app/project/453302b8-7e05-4d17-bf94-651434fed5eb
- **Service**: Consigliary (production environment)
- **Database**: PostgreSQL (managed by Railway)

### **AWS Services**
- **Console**: https://console.aws.amazon.com
- **Account ID**: 5053-1296-2418
- **Account Name**: Consigliary
- **Region**: Europe (Stockholm) eu-north-1
- **S3 Bucket**: consigliary-audio-files
- **S3 Console**: https://s3.console.aws.amazon.com/s3/buckets/consigliary-audio-files
- **IAM Console**: https://console.aws.amazon.com/iam

### **ACRCloud**
- **Dashboard**: https://console.acrcloud.com
- **Project**: Consigliary
- **Bucket**: ACRCloud Music
- **Host**: identify-eu-west-1.acrcloud.com
- **Plan**: Free tier (5,000 requests/month)

---

## 📚 Documentation & Resources

### **GitHub Repository**
- **Repo**: (Not yet created - to be set up)
- **Backend**: /Users/howardduffy/Desktop/Consigliary/backend
- **iOS App**: /Users/howardduffy/Desktop/Consigliary/Consigliary

### **Project Documentation**
- **Backend Requirements**: BACKEND_REQUIREMENTS.md
- **iOS Integration Guide**: IOS_BACKEND_INTEGRATION.md
- **MVP Roadmap**: MVP_ROADMAP_BOOTSTRAPPED.md
- **Week 1 Complete**: WEEK1_COMPLETE.md
- **Week 2 Complete**: WEEK2_COMPLETE.md
- **Week 3 Day 1 Complete**: WEEK3_DAY1_COMPLETE.md
- **AWS S3 Setup**: AWS_S3_SETUP.md
- **Session Summary**: SESSION_SUMMARY_DEC14.md
- **Progress Report**: PROJECT_PROGRESS_REPORT.md
- **Beta Testing Guide**: BETA_TESTING_GUIDE.md

---

## 🔐 Authentication & Credentials

### **Test User Account**
- **Email**: test@consigliary.com
- **Password**: password123
- **User ID**: 6178d183-fcd0-4f06-995d-23047099ecf9

### **Railway Environment Variables**
- Database: DATABASE_URL, DATABASE_PUBLIC_URL
- JWT: JWT_SECRET, JWT_EXPIRES_IN, REFRESH_TOKEN_SECRET, REFRESH_TOKEN_EXPIRES_IN
- ACRCloud: ACRCLOUD_HOST, ACRCLOUD_ACCESS_KEY, ACRCLOUD_ACCESS_SECRET
- AWS S3: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_S3_BUCKET, AWS_REGION
- API: API_VERSION, FRONTEND_URL, IOS_APP_BUNDLE_ID
- Rate Limiting: RATE_LIMIT_WINDOW_MS, RATE_LIMIT_MAX_REQUESTS

---

## 🛠️ Development Tools

### **Local Development**
- **Backend Port**: 3000
- **Local API**: http://localhost:3000
- **Database**: PostgreSQL (Railway managed)

### **iOS Development**
- **Xcode Project**: /Users/howardduffy/Desktop/Consigliary/Consigliary.xcodeproj
- **Bundle ID**: com.htdstudio.consigliary
- **Simulator**: iPhone 17 Pro Max (iOS 26.1)

---

## 📊 API Endpoints (Production)

### **Authentication**
- POST /api/v1/auth/register
- POST /api/v1/auth/login
- POST /api/v1/auth/refresh
- POST /api/v1/auth/logout
- GET /api/v1/auth/me

### **Tracks**
- GET /api/v1/tracks
- GET /api/v1/tracks/:id
- POST /api/v1/tracks
- PUT /api/v1/tracks/:id
- DELETE /api/v1/tracks/:id

### **Verifications** (Placeholder)
- POST /api/v1/verifications
- GET /api/v1/verifications

### **Licenses** (Placeholder)
- POST /api/v1/licenses
- GET /api/v1/licenses

### **Revenue**
- GET /api/v1/revenue
- GET /api/v1/revenue/summary

---

## 🌐 External Services

### **ACRCloud API**
- **Endpoint**: https://identify-eu-west-1.acrcloud.com/v1/identify
- **Documentation**: https://docs.acrcloud.com

### **AWS S3 API**
- **Endpoint**: https://s3.eu-north-1.amazonaws.com
- **Documentation**: https://docs.aws.amazon.com/s3/

### **Stripe** (Future)
- **Dashboard**: https://dashboard.stripe.com
- **Status**: Not yet configured

### **SendGrid** (Future)
- **Dashboard**: https://app.sendgrid.com
- **Status**: Not yet configured

---

## 📱 App Store (Future)

### **Apple Developer**
- **Account**: (To be set up)
- **App Store Connect**: https://appstoreconnect.apple.com
- **Status**: Not yet submitted

### **TestFlight** (Beta Testing)
- **URL**: (To be generated after App Store Connect setup)
- **Status**: Not yet configured

---

## 💰 Billing & Costs

### **Railway**
- **Billing**: https://railway.app/account/billing
- **Current Cost**: ~$10-20/month
- **Free Trial**: 30 days or $5.00 left

### **AWS**
- **Billing Dashboard**: https://console.aws.amazon.com/billing
- **Free Credits**: US$100.00 remaining
- **Free Tier**: 183 days remaining (until Jun 15, 2026)

### **ACRCloud**
- **Billing**: https://console.acrcloud.com/billing
- **Current Cost**: $0/month (free tier)
- **Free Tier**: 5,000 requests/month

---

## 📞 Support & Help

### **Railway Support**
- **Discord**: https://discord.gg/railway
- **Docs**: https://docs.railway.app

### **AWS Support**
- **Support Center**: https://console.aws.amazon.com/support
- **Docs**: https://docs.aws.amazon.com

### **ACRCloud Support**
- **Email**: support@acrcloud.com
- **Docs**: https://docs.acrcloud.com

---

## 🎯 Quick Access

**Most Used URLs:**
1. Railway Dashboard: https://railway.app/dashboard
2. Production API: https://consigliary-production.up.railway.app
3. AWS Console: https://console.aws.amazon.com
4. ACRCloud Console: https://console.acrcloud.com
5. S3 Bucket: https://s3.console.aws.amazon.com/s3/buckets/consigliary-audio-files

---

**Note**: Keep this file updated as new services are added or URLs change.

© 2025 HTDSTUDIO AB. All rights reserved.
