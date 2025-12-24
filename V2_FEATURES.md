# 🚀 Consigliary v2.0 Features

## Deferred Features for Post-MVP Release

These features have been intentionally deferred to maintain MVP focus and ensure a stable, focused launch. They will be reconsidered based on user feedback and market validation.

---

## 📋 Feature List

### 1. Split Sheet Management
**Status**: Deferred to v2.0  
**Priority**: Medium  
**Complexity**: High

**Description**:
- Manage royalty splits between collaborators
- Multi-party payment distribution
- Split agreement templates
- Dispute resolution workflow

**Why Deferred**:
- High complexity (Stripe Connect integration required)
- Most indie artists own 100% of tracks initially
- Legal implications need careful consideration
- Better to add when we have revenue to justify dev cost

**Backend Requirements**:
- New tables: `split_agreements`, `split_parties`, `split_payments`
- Stripe Connect integration
- Payment splitting logic
- Notification system for all parties

**Estimated Cost**: Low monthly cost, high development time

---

### 2. Contract Analysis Tool
**Status**: Deferred to v2.0+ (or cut entirely)  
**Priority**: Low  
**Complexity**: Medium

**Description**:
- AI-powered contract analysis
- Highlight key terms and potential issues
- Plain language explanations

**Why Deferred**:
- Unclear value proposition for core licensing flow
- Legal liability concerns
- Requires AI integration (OpenAI API)
- Feature creep - not core to music licensing
- Better suited as standalone product

**Backend Requirements**:
- AI API integration (OpenAI/Anthropic)
- Contract parsing logic
- Storage for analysis results

**Estimated Cost**: $50-200+/month depending on usage

---

### 3. Smart Monitoring System
**Status**: Deferred to v2.0  
**Priority**: High (for v2.0)  
**Complexity**: Medium

**Description**:
- Automated YouTube monitoring for unauthorized uses
- Alert system for potential matches
- Video metadata and analytics
- Direct path to license generation

**Why Deferred**:
- Not essential for core revenue flow (artist → creator → license)
- Adds complexity to MVP
- Ongoing costs (YouTube API quotas)
- Better positioned as "new feature" post-launch
- Backend already built and tested (can be reactivated quickly)

**Backend Requirements** (Already Built):
- ✅ Database tables: `monitoring_jobs`, `monitoring_alerts`, `monitoring_stats`
- ✅ YouTube Data API v3 integration
- ✅ Scheduled job runner
- ✅ Full REST API endpoints

**Estimated Cost**: Low (free tier: 10,000 API units/day)

**Note**: This is the easiest to reactivate since it's already complete.

---

## ✅ MVP Feature Set (For Reference)

### Core Features Only:
1. **User Authentication**
   - Email/password login
   - JWT token management
   - Password reset

2. **Track Management (MyTracks)**
   - Upload audio files
   - Track verification (ACRCloud)
   - Track metadata management
   - Track browsing/search

3. **Licensing System**
   - License purchase flow
   - Stripe payment integration
   - Simple license PDF generation
   - License delivery via email

4. **Artist Dashboard**
   - Revenue tracking
   - Track statistics
   - License history
   - Basic analytics

---

## 📊 Decision Framework for v2.0

Before adding any deferred feature, validate:

1. **User Demand**: Are users actively requesting it?
2. **Revenue Impact**: Will it increase conversions or retention?
3. **Competitive Advantage**: Do competitors have it?
4. **Technical Stability**: Is our core system stable enough?
5. **Resource Availability**: Do we have bandwidth to maintain it?

---

## 🎯 Post-Launch Strategy

### Phase 1 (Months 1-3): Stabilize & Learn
- Focus on core flow optimization
- Gather user feedback
- Fix bugs and improve UX
- Monitor metrics (conversion, retention, revenue)

### Phase 2 (Months 4-6): Strategic Additions
- Prioritize based on user requests
- Consider: Monitoring System (easiest to activate)
- Evaluate: Split Sheet (if collaborative tracks are common)
- Reconsider: Contract Analysis (if users show need)

### Phase 3 (Months 7+): Scale & Differentiate
- Add features that create competitive moat
- Consider platform expansion (web dashboard, etc.)
- Explore new revenue streams

---

## 💡 Future Ideas (Not Yet Scoped)

- Spotify OAuth integration (post-beta, based on feedback)
- Apple Sign In (Week 6, required for App Store)
- Google Sign In (Week 6)
- Web dashboard for artists
- Creator marketplace/discovery
- Bulk licensing for agencies
- White-label licensing platform
- Integration with distribution platforms (DistroKid, CD Baby, etc.)

---

*Last Updated: December 23, 2025*  
*MVP Launch Target: TBD*
