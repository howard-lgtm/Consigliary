# 🎯 Consigliary MVP Backend Audit

## Current Backend Status

### ✅ MVP-Ready Routes (Keep Active)

#### 1. Authentication (`/api/v1/auth`)
- User registration, login, password reset
- JWT token management
- **Status**: Essential for MVP ✅

#### 2. Tracks (`/api/v1/tracks`)
- Upload, list, update, delete tracks
- Track metadata management
- Audio file handling via S3
- **Status**: Essential for MVP ✅

#### 3. Verifications (`/api/v1/verifications`)
- ACRCloud integration for track verification
- Verification status tracking
- **Status**: Essential for MVP ✅

#### 4. Licenses (`/api/v1/licenses`)
- Generate license agreements (PDF)
- License purchase flow
- S3 storage for PDFs
- Email delivery via SendGrid
- **Status**: Essential for MVP ✅

#### 5. Revenue (`/api/v1/revenue`)
- Revenue tracking and analytics
- Artist dashboard data
- **Status**: Essential for MVP ✅

#### 6. Webhooks (`/webhooks`)
- Stripe webhook handling
- Payment status updates
- **Status**: Essential for MVP ✅

---

### ⚠️ Non-MVP Routes (Defer to v2.0)

#### 1. Monitoring (`/api/v1/monitoring`) - **DEFER**
**Current Endpoints**:
- `POST /jobs` - Create monitoring job
- `GET /jobs` - List monitoring jobs
- `GET /jobs/:trackId` - Get job for track
- `POST /run/:trackId` - Manual trigger
- `GET /alerts` - List alerts
- `GET /alerts/:id` - Get alert details
- `PUT /alerts/:id` - Update alert status
- `GET /stats` - Get statistics

**Why Defer**:
- Not essential for core licensing flow
- Adds complexity to MVP
- Backend is complete and can be reactivated quickly
- Better positioned as v2.0 feature

**Action Required**: Comment out in `server.js`

#### 2. Contributors (`/api/v1/contributors`) - **DEFER**
**Current Endpoints**:
- `GET /tracks/:trackId/contributors` - List contributors
- `POST /tracks/:trackId/contributors` - Add contributor
- `PUT /contributors/:id` - Update contributor
- `DELETE /contributors/:id` - Delete contributor
- `GET /tracks/:trackId/split-sheet` - Get split sheet summary

**Why Defer**:
- Split sheet functionality is v2.0 feature
- Most indie artists own 100% initially
- Requires Stripe Connect for payment splitting
- Legal complexity

**Action Required**: Comment out in `server.js`

---

## 📋 Recommended Actions

### Step 1: Disable Non-MVP Routes

Edit `backend/server.js` to comment out:
```javascript
// const contributorRoutes = require('./routes/contributors');
// const monitoringRoutes = require('./routes/monitoring');

// app.use('/api/v1', contributorRoutes);
// app.use('/api/v1/monitoring', monitoringRoutes);
```

### Step 2: Keep Database Tables

**Do NOT drop these tables** - they're already created and won't hurt:
- `monitoring_jobs`
- `monitoring_alerts`
- `monitoring_stats`
- `contributors`

Keeping them allows easy reactivation in v2.0.

### Step 3: Document API for Frontend

Create clear API documentation for MVP endpoints only:
- Auth endpoints
- Track management
- Verification flow
- License generation
- Revenue tracking

---

## 🔍 License Agreement Analysis

### Current Implementation ✅

The license system is **already MVP-ready**:

1. **PDF Generation** (`services/licensePDF.js`)
   - Generates professional license PDFs
   - Includes all necessary legal terms
   - Customizable per license

2. **S3 Storage** (`services/s3.js`)
   - Uploads PDFs to AWS S3
   - Generates pre-signed URLs (7-day validity)
   - Secure file access

3. **Email Delivery** (`services/email.js`)
   - SendGrid integration
   - Sends license invoices to licensees
   - Includes PDF attachment link

4. **Stripe Integration** (`services/stripe.js`)
   - Creates invoices for payment
   - Webhook handling for payment status
   - Revenue tracking

### What's Working
- ✅ License creation with track details
- ✅ PDF generation and S3 upload
- ✅ Email delivery to licensee
- ✅ Stripe invoice creation
- ✅ Payment tracking
- ✅ License status management

### No Changes Needed
The license system is **production-ready** for MVP. It's simple, functional, and covers all essential use cases.

---

## 📊 Backend Complexity Assessment

### Current State
| Component | Status | Complexity | MVP Ready |
|-----------|--------|------------|-----------|
| Auth | Active | Low | ✅ Yes |
| Tracks | Active | Medium | ✅ Yes |
| Verifications | Active | Medium | ✅ Yes |
| Licenses | Active | Medium | ✅ Yes |
| Revenue | Active | Low | ✅ Yes |
| Webhooks | Active | Medium | ✅ Yes |
| Monitoring | Active | High | ❌ Defer |
| Contributors | Active | Medium | ❌ Defer |

### After MVP Cleanup
| Component | Status | Complexity | MVP Ready |
|-----------|--------|------------|-----------|
| Auth | Active | Low | ✅ Yes |
| Tracks | Active | Medium | ✅ Yes |
| Verifications | Active | Medium | ✅ Yes |
| Licenses | Active | Medium | ✅ Yes |
| Revenue | Active | Low | ✅ Yes |
| Webhooks | Active | Medium | ✅ Yes |
| Monitoring | **Disabled** | High | ⏸️ v2.0 |
| Contributors | **Disabled** | Medium | ⏸️ v2.0 |

---

## 🎯 MVP Feature Set (Final)

### Core User Flows

#### 1. Artist Onboarding
```
Register → Login → Upload Track → Verify Track → Track Ready
```

#### 2. License Generation
```
Track Verified → Create License → Generate PDF → Send Email → Track Payment
```

#### 3. Revenue Tracking
```
License Paid → Update Revenue → Artist Dashboard → View Analytics
```

### API Endpoints (MVP Only)

**Authentication**
- `POST /api/v1/auth/register`
- `POST /api/v1/auth/login`
- `POST /api/v1/auth/forgot-password`
- `POST /api/v1/auth/reset-password`

**Tracks**
- `GET /api/v1/tracks` - List tracks
- `POST /api/v1/tracks` - Upload track
- `GET /api/v1/tracks/:id` - Get track details
- `PUT /api/v1/tracks/:id` - Update track
- `DELETE /api/v1/tracks/:id` - Delete track

**Verifications**
- `POST /api/v1/verifications` - Create verification
- `GET /api/v1/verifications/:id` - Get verification status

**Licenses**
- `POST /api/v1/licenses` - Generate license
- `GET /api/v1/licenses` - List licenses
- `GET /api/v1/licenses/:id` - Get license details
- `PUT /api/v1/licenses/:id` - Update license status

**Revenue**
- `GET /api/v1/revenue` - Get revenue summary

**Webhooks**
- `POST /webhooks/stripe` - Stripe payment webhooks

---

## 💰 Cost Analysis (MVP vs Full)

### Current Monthly Costs (All Features Active)
- Railway hosting: ~$5-20
- AWS S3: ~$1-5
- ACRCloud: Free tier (3,000 verifications/month)
- SendGrid: Free tier (100 emails/day)
- Stripe: 2.9% + $0.30 per transaction
- YouTube API: Free tier (10,000 units/day)
- **Total**: ~$6-25/month + transaction fees

### MVP Monthly Costs (Monitoring Disabled)
- Railway hosting: ~$5-20
- AWS S3: ~$1-5
- ACRCloud: Free tier (3,000 verifications/month)
- SendGrid: Free tier (100 emails/day)
- Stripe: 2.9% + $0.30 per transaction
- ~~YouTube API~~: Not used
- **Total**: ~$6-25/month + transaction fees

**Savings**: Minimal cost savings, but significant complexity reduction.

---

## 🚀 Deployment Readiness

### Backend Status: ✅ MVP-Ready

**What's Working**:
- ✅ All core endpoints tested
- ✅ Database schema complete
- ✅ External services integrated (S3, ACRCloud, Stripe, SendGrid)
- ✅ Error handling implemented
- ✅ Authentication & authorization working
- ✅ CORS configured for mobile app

**What Needs Cleanup**:
- ⚠️ Disable monitoring routes
- ⚠️ Disable contributor routes
- ⚠️ Update API documentation
- ⚠️ Remove monitoring scheduler from production

**Estimated Time**: 30 minutes

---

## 📝 Next Steps

### Immediate (Today)
1. ✅ Document v2.0 features
2. ⏳ Disable monitoring routes in `server.js`
3. ⏳ Disable contributor routes in `server.js`
4. ⏳ Test core MVP endpoints
5. ⏳ Create MVP API documentation

### This Week
1. Frontend: Remove monitoring UI components
2. Frontend: Remove split sheet UI components
3. Frontend: Focus on core flows (upload, verify, license)
4. Testing: End-to-end MVP flow testing
5. Documentation: User guides for MVP features

### Before App Store Launch
1. Security audit
2. Performance testing
3. Error monitoring setup (Sentry?)
4. Analytics integration
5. App Store assets and submission

---

*Last Updated: December 23, 2025*
*Status: Ready for MVP cleanup*
