# Consigliary MVP Roadmap - Bootstrapped Approach

**Version**: 1.0 (Bootstrapped)  
**Date**: December 14, 2025  
**Strategy**: Proven Revenue First, Scale Later  
**Timeline**: 8 Weeks  
**Budget**: $500 Initial Investment

---

## 🎯 Strategic Decision: Option 2 (Proven Revenue Model)

**Chosen Path**: Build user-directed license generation tool first, validate revenue model, then add automation.

**Why This Approach:**
- ✅ Minimal upfront investment ($500 vs. $10,000)
- ✅ Fast time-to-market (8 weeks vs. 12+ weeks)
- ✅ Low operational costs ($100/month vs. $5,000/month)
- ✅ Validates core value proposition (license generation)
- ✅ Builds revenue before expanding features
- ✅ Keeps original vision intact for future iterations

---

## 📋 Phase 1: MVP Core (Weeks 1-8)

### **Product Vision Statement**
*"Consigliary helps musicians monetize unauthorized usage of their music by providing professional licensing tools and payment tracking."*

### **Core User Flow**
```
1. Artist uploads their tracks → ACR fingerprinting
2. Artist discovers unauthorized usage (YouTube/TikTok/Instagram)
3. Artist pastes video URL into app
4. App verifies match using ACRCloud (2 seconds)
5. App generates professional license invoice (PDF)
6. App sends invoice via email to infringer
7. App tracks payment status via Stripe
8. If no payment: App provides DMCA takedown template
```

---

## 🏗️ Technical Architecture (Simplified)

### **Frontend**
- **iOS App** (Already built with SwiftUI)
- Existing UI components ready to connect

### **Backend Stack**
- **Framework**: Node.js + Express (simple, fast)
- **Database**: PostgreSQL (Heroku free tier → $7/mo when needed)
- **File Storage**: AWS S3 (pay-as-you-go, ~$5/mo)
- **Hosting**: Railway.app (free tier → $5/mo when needed)

### **Third-Party Services**
- **ACRCloud**: Audio fingerprinting ($0.002/query, 2,000 free/month)
- **Stripe**: Payment processing (2.9% + $0.30 per transaction)
- **SendGrid**: Email delivery (100 emails/day free → $15/mo)
- **YouTube Data API**: Video metadata only (free tier sufficient)

---

## 📅 8-Week Implementation Timeline

### **Week 1: Foundation**
**Goal**: Core infrastructure setup

**Backend Tasks**:
- [ ] Set up Railway.app project
- [ ] PostgreSQL database schema
  - Users table
  - Tracks table
  - Verifications table (URL, match result, status)
  - Licenses table (invoice data, payment status)
- [ ] User authentication (JWT)
- [ ] Basic API structure

**iOS Tasks**:
- [ ] Create NetworkManager.swift
- [ ] Create AuthService.swift
- [ ] Add Keychain storage for tokens
- [ ] Test login/register flow

**Deliverable**: Users can create accounts and log in

---

### **Week 2: Track Management**
**Goal**: Users can upload and manage their tracks

**Backend Tasks**:
- [ ] ACRCloud integration
  - Generate fingerprints on upload
  - Store fingerprint IDs in database
- [ ] S3 integration for audio files
- [ ] Track CRUD endpoints
  - POST /api/tracks (upload)
  - GET /api/tracks (list)
  - PUT /api/tracks/:id (update metadata)
  - DELETE /api/tracks/:id (delete)

**iOS Tasks**:
- [ ] Create TrackService.swift
- [ ] Update Track model with backend fields
- [ ] Connect AddTrackView to API
- [ ] Test track upload flow

**Deliverable**: Users can upload tracks and see them in My Tracks

---

### **Week 3: Verification Engine**
**Goal**: Users can verify unauthorized usage

**Backend Tasks**:
- [ ] URL verification endpoint
  - POST /api/verify
  - Extract audio from YouTube/TikTok/Instagram URL
  - Query ACRCloud with extracted audio
  - Return match result (confidence, track info)
- [ ] youtube-dl integration for audio extraction
- [ ] ffmpeg for audio format conversion
- [ ] Store verification results

**iOS Tasks**:
- [ ] Add "Verify Usage" screen
  - URL input field
  - Platform detection (YouTube/TikTok/Instagram)
  - Loading state during verification
  - Match result display
- [ ] Create VerificationService.swift
- [ ] Test verification flow

**Deliverable**: Users can paste URL and verify if it uses their music

---

### **Week 4: License Generation**
**Goal**: Generate professional license invoices

**Backend Tasks**:
- [ ] License generation endpoint
  - POST /api/licenses
  - Generate PDF invoice (use existing LicenseAgreementPDFGenerator logic)
  - Store license in database
  - Return PDF URL
- [ ] License templates
  - Standard license agreement
  - Customizable terms (price, territory, duration)
  - Legal disclaimer
- [ ] Email integration (SendGrid)
  - Send invoice to infringer
  - Include payment link
  - Track email opens/clicks

**iOS Tasks**:
- [ ] Add "Generate License" flow
  - Pre-fill data from verification
  - User sets license fee
  - User sets terms (territory, duration)
  - Preview PDF before sending
- [ ] Create LicenseService.swift
- [ ] Test license generation and email

**Deliverable**: Users can generate and send license invoices

---

### **Week 5: Payment Tracking**
**Goal**: Track license payments via Stripe

**Backend Tasks**:
- [ ] Stripe integration
  - Create Stripe invoice when license generated
  - Webhook for payment status updates
  - Update license status in database
- [ ] Payment tracking endpoints
  - GET /api/licenses/:id/status
  - GET /api/licenses (filter by status)
- [ ] Revenue calculation
  - Track paid licenses
  - Calculate total revenue
  - Generate revenue events

**iOS Tasks**:
- [ ] Update License views to show payment status
- [ ] Add payment tracking to Revenue view
- [ ] Real-time status updates
- [ ] Test payment flow (Stripe test mode)

**Deliverable**: Users can track which licenses have been paid

---

### **Week 6: iOS Integration & Polish**
**Goal**: Connect all iOS features to backend

**Backend Tasks**:
- [ ] API documentation (Swagger/Postman)
- [ ] Error handling improvements
- [ ] Rate limiting (prevent abuse)
- [ ] Logging and monitoring

**iOS Tasks**:
- [ ] Connect all remaining views to API
- [ ] Add offline support (Core Data caching)
- [ ] Add loading states and error messages
- [ ] Polish UI/UX
- [ ] Add analytics events

**Deliverable**: Fully functional iOS app connected to backend

---

### **Week 7: Testing & Bug Fixes**
**Goal**: Ensure stability and reliability

**Tasks**:
- [ ] End-to-end testing
  - Upload track → Verify URL → Generate license → Track payment
- [ ] Edge case testing
  - Invalid URLs
  - Low-quality audio
  - False positives
  - Network errors
- [ ] Performance testing
  - Verification speed
  - PDF generation speed
  - API response times
- [ ] Security audit
  - Authentication vulnerabilities
  - SQL injection prevention
  - XSS prevention
  - API rate limiting

**Deliverable**: Stable, tested MVP ready for beta users

---

### **Week 8: Beta Launch**
**Goal**: Launch to 10-20 beta users

**Tasks**:
- [ ] Deploy to production
  - Railway.app production environment
  - Production database
  - Production Stripe account
- [ ] Beta user onboarding
  - Send invitations
  - Provide documentation
  - Set up support channel (email/Discord)
- [ ] Monitor usage
  - Track key metrics
  - Gather feedback
  - Fix critical bugs
- [ ] Iterate based on feedback

**Deliverable**: Live MVP with paying beta users

---

## 💰 Cost Breakdown

### **Initial Investment (One-Time)**
| Item | Cost |
|------|------|
| Domain name (consigliary.com) | $12/year |
| SSL certificate | Free (Let's Encrypt) |
| Development tools | Free (VS Code, Postman) |
| **Total Initial** | **$12** |

### **Monthly Operating Costs (MVP Scale)**
| Service | Free Tier | Paid (if needed) |
|---------|-----------|------------------|
| **Railway.app** | $5 credit/month | $5/month |
| **PostgreSQL** | Included in Railway | $0 |
| **AWS S3** | 5GB free | ~$5/month |
| **ACRCloud** | 2,000 queries/month | $0.002/query after |
| **SendGrid** | 100 emails/day | $15/month (40K emails) |
| **Stripe** | Free | 2.9% + $0.30 per transaction |
| **YouTube API** | 10,000 units/day | Free (metadata only) |
| **Total Monthly** | **~$10/month** | **~$100/month** (at scale) |

### **Revenue Model**
| Tier | Price | Features |
|------|-------|----------|
| **Free** | $0 | 5 verifications/month, 2 license generations |
| **Pro** | $19/month | Unlimited verifications, unlimited licenses, payment tracking |
| **Commission** | 10% | Optional: Take 10% of collected license fees |

### **Break-Even Analysis**
- **Operating cost**: $100/month
- **Break-even**: 6 Pro users ($19 × 6 = $114)
- **Profitable at**: 10 Pro users ($190/month revenue)
- **Target (Month 3)**: 50 Pro users ($950/month revenue)

---

## 🎯 Success Metrics (First 3 Months)

### **Month 1 (Beta)**
- [ ] 20 beta users signed up
- [ ] 100+ tracks uploaded
- [ ] 50+ verifications performed
- [ ] 10+ licenses generated
- [ ] 2-3 licenses paid ($500-$1,500 collected)

### **Month 2 (Early Adopters)**
- [ ] 100 total users
- [ ] 10 Pro subscribers ($190/month revenue)
- [ ] 500+ verifications
- [ ] 50+ licenses generated
- [ ] 10+ licenses paid ($5,000+ collected)

### **Month 3 (Growth)**
- [ ] 300 total users
- [ ] 50 Pro subscribers ($950/month revenue)
- [ ] 2,000+ verifications
- [ ] 200+ licenses generated
- [ ] 50+ licenses paid ($25,000+ collected)

---

## 🚀 Phase 2: Automation (Weeks 9-16)

**Only proceed if Phase 1 metrics are met:**
- ✅ 50+ Pro subscribers
- ✅ $950+/month recurring revenue
- ✅ 20%+ license payment conversion rate
- ✅ Positive user feedback

### **Phase 2 Features**
1. **Limited Automated Scanning**
   - User specifies 1-3 "high-risk" channels to monitor
   - Weekly scans of those channels only
   - Budget: $50/month for YouTube API

2. **Bulk URL Processing**
   - Upload CSV of URLs
   - Batch verification (10-100 URLs at once)
   - Bulk license generation

3. **Analytics Dashboard**
   - Which platforms have most infringement
   - Which tracks are most infringed
   - License payment conversion rates

4. **DMCA Automation**
   - Auto-generate DMCA takedown if license unpaid after 30 days
   - Track takedown status
   - Integration with platform takedown forms

---

## 🎨 Phase 3: Scale (Months 4-6)

**Only proceed if Phase 2 metrics are met:**
- ✅ 200+ Pro subscribers
- ✅ $3,800+/month recurring revenue
- ✅ Proven ROI on automated scanning

### **Phase 3 Features**
1. **Full Automated Hunting**
   - AI-powered channel discovery
   - Broad YouTube scanning (budget: $500/month)
   - TikTok scraping (no official API)
   - Instagram scraping

2. **Enterprise Features**
   - Multi-user accounts (for labels)
   - White-label option
   - API access for integrations
   - Advanced reporting

3. **International Expansion**
   - Multi-language support
   - International payment methods
   - Regional legal templates

---

## 🔄 Path to Original Vision

**Your original vision is still intact.** We're just building it in stages:

### **Original Vision: "Rights Recovery Hunter"**
✅ **Hunter** - Coming in Phase 2 (automated scanning)  
✅ **Social** - MVP supports YouTube/TikTok/Instagram (user-directed)  
✅ **Carrot** - MVP core feature (license generation)

### **Iteration Path**
```
Phase 1 (Weeks 1-8): User-Directed Tool
  ↓
Phase 2 (Weeks 9-16): Limited Automation
  ↓
Phase 3 (Months 4-6): Full Automated Hunting
  ↓
Phase 4 (Year 2): Enterprise Scale
```

**The difference:** We're proving the **monetization model** (Carrot) before investing in expensive **hunting infrastructure**. This is smart bootstrapping.

---

## 🛡️ Risk Mitigation

### **Risk #1: Low License Payment Conversion**
**Mitigation:**
- Start with beta users who have real infringement issues
- Provide templates and guidance for effective invoicing
- Test different pricing strategies ($50, $100, $200)
- Add "success stories" to encourage adoption

### **Risk #2: Technical Complexity**
**Mitigation:**
- Use proven technologies (Node.js, PostgreSQL, ACRCloud)
- Start with simple features, iterate
- Extensive testing before launch
- Have rollback plan for each deployment

### **Risk #3: User Acquisition**
**Mitigation:**
- Leverage existing network (IP attorneys, musicians)
- Content marketing (blog posts, case studies)
- Social media presence (TikTok, Instagram)
- Referral program (free month for referrals)

---

## 📝 Next Steps (This Week)

### **Immediate Actions**
1. **Backend Setup** (Day 1-2)
   - [ ] Create Railway.app account
   - [ ] Set up PostgreSQL database
   - [ ] Initialize Node.js project
   - [ ] Set up Git repository

2. **ACRCloud Setup** (Day 3)
   - [ ] Sign up for ACRCloud account
   - [ ] Test fingerprinting API
   - [ ] Verify accuracy with sample tracks

3. **iOS Preparation** (Day 4-5)
   - [ ] Create service layer files (empty)
   - [ ] Add KeychainAccess via SPM
   - [ ] Set up environment configuration
   - [ ] Update Track model

4. **Documentation** (Day 6-7)
   - [ ] API specification document
   - [ ] Database schema diagram
   - [ ] User flow diagrams
   - [ ] Beta testing plan

---

## 💡 Key Principles for Bootstrapped Success

1. **Ship Fast, Iterate Faster**
   - Don't wait for perfection
   - Get feedback early
   - Improve based on real usage

2. **Focus on Revenue**
   - Every feature must support monetization
   - Track conversion metrics obsessively
   - Optimize for paying users

3. **Keep Costs Low**
   - Use free tiers aggressively
   - Only pay for what you need
   - Automate to reduce manual work

4. **Build Trust**
   - Be transparent about limitations
   - Provide excellent support
   - Deliver on promises

5. **Stay Lean**
   - No unnecessary features
   - No premature optimization
   - No scope creep

---

## 🎯 Vision Alignment Check

**Original Vision**: "Rights Recovery Hunter" that finds unauthorized usage and converts it to revenue.

**MVP Approach**: Tool that helps artists monetize unauthorized usage they find themselves.

**Future State**: Automated hunter that finds usage AND helps monetize it.

**Alignment**: ✅ **100% aligned.** We're building the same product, just in a financially sustainable order.

---

## 📞 Support & Questions

**Technical Questions**: Review `BACKEND_REQUIREMENTS.md` and `IOS_BACKEND_INTEGRATION.md`

**Strategic Questions**: This document

**Implementation Questions**: Weekly check-ins during 8-week build

---

## ✅ Pre-Launch Checklist

Before launching to beta users:

**Technical**
- [ ] All API endpoints tested and documented
- [ ] iOS app connects to production backend
- [ ] ACRCloud integration working reliably
- [ ] Stripe test payments successful
- [ ] Email delivery working
- [ ] Error handling complete
- [ ] Security audit passed

**Business**
- [ ] Pricing finalized
- [ ] Terms of Service written
- [ ] Privacy Policy written
- [ ] Support email set up (support@consigliary.com)
- [ ] Beta user list ready (20 people)
- [ ] Onboarding documentation complete

**Legal**
- [ ] License agreement template reviewed by lawyer
- [ ] DMCA takedown template reviewed
- [ ] Terms of Service reviewed
- [ ] Privacy Policy compliant (GDPR, CCPA)

---

## 🚀 Launch Day Plan

**Week 8, Day 1: Soft Launch**
- Send invitations to 10 beta users
- Monitor for critical bugs
- Provide white-glove support

**Week 8, Day 3: Expand Beta**
- If no critical issues, invite 10 more users
- Gather feedback via survey
- Track key metrics

**Week 8, Day 7: Review & Iterate**
- Analyze usage data
- Prioritize bug fixes
- Plan Week 9 improvements

---

## 📈 Long-Term Vision (12 Months)

**Month 12 Goals:**
- 1,000+ total users
- 300+ Pro subscribers ($5,700/month revenue)
- Automated scanning operational
- TikTok/Instagram support added
- Break-even or profitable
- Ready for seed funding (if desired)

**Exit Options:**
1. **Bootstrap to profitability** - Keep 100% ownership
2. **Raise seed round** - $500K-$1M to accelerate growth
3. **Acquisition** - Sell to music tech company (Spotify, SoundCloud, DistroKid)

---

**The path is clear. The timeline is realistic. The costs are manageable. Let's build this.** 🎵

---

**Document Version**: 1.0  
**Last Updated**: December 14, 2025  
**Status**: Ready to Execute

© 2025 HTDSTUDIO AB. All rights reserved.
