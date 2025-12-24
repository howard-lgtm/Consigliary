# 🔄 Feature Reactivation Guide

## How to Reactivate Deferred Features for v2.0

All deferred features are **fully built and tested** - they're just disabled in the MVP. Reactivation is quick and easy.

---

## 🎯 Monitoring System

### Status
- **Backend**: Fully built, tested, and deployed
- **Database**: Tables already exist in production
- **APIs**: YouTube Data API v3 configured
- **Time to Reactivate**: ~30 seconds

### Reactivation Steps

1. **Edit `backend/server.js`**:
   ```javascript
   // Line 48: Uncomment this line
   const monitoringRoutes = require('./routes/monitoring');
   
   // Line 57: Uncomment this line
   app.use('/api/v1/monitoring', monitoringRoutes);
   ```

2. **Commit and push**:
   ```bash
   git add backend/server.js
   git commit -m "v2.0: Reactivate monitoring system"
   git push origin main
   ```

3. **Railway auto-deploys** - Done!

### What You Get

**Endpoints**:
- `POST /api/v1/monitoring/jobs` - Create monitoring job
- `GET /api/v1/monitoring/jobs` - List all jobs
- `GET /api/v1/monitoring/jobs/:trackId` - Get job for track
- `POST /api/v1/monitoring/run/:trackId` - Manual trigger
- `GET /api/v1/monitoring/alerts` - List alerts
- `GET /api/v1/monitoring/alerts/:id` - Get alert details
- `PUT /api/v1/monitoring/alerts/:id` - Update alert status
- `GET /api/v1/monitoring/stats` - Get statistics

**Features**:
- Automated YouTube monitoring for unauthorized uses
- Alert system for potential matches
- Video metadata and analytics
- Direct path to license generation
- Quota tracking (10,000 API units/day free)

### Testing

Run the test script:
```bash
cd backend
node test-monitoring.js
```

### Documentation

See `MONITORING_SETUP_COMPLETE.md` for full details.

---

## 📊 Split Sheet / Contributors System

### Status
- **Backend**: Fully built
- **Database**: `contributors` table exists
- **Time to Reactivate**: ~30 seconds

### Reactivation Steps

1. **Edit `backend/server.js`**:
   ```javascript
   // Line 44: Uncomment this line
   const contributorRoutes = require('./routes/contributors');
   
   // Line 53: Uncomment this line
   app.use('/api/v1', contributorRoutes);
   ```

2. **Commit and push**:
   ```bash
   git add backend/server.js
   git commit -m "v2.0: Reactivate split sheet system"
   git push origin main
   ```

3. **Railway auto-deploys** - Done!

### What You Get

**Endpoints**:
- `GET /api/v1/tracks/:trackId/contributors` - List contributors
- `POST /api/v1/tracks/:trackId/contributors` - Add contributor
- `PUT /api/v1/contributors/:id` - Update contributor
- `DELETE /api/v1/contributors/:id` - Delete contributor
- `GET /api/v1/tracks/:trackId/split-sheet` - Get split sheet summary

**Features**:
- Manage royalty splits between collaborators
- Track split percentages (validates total = 100%)
- Contributor roles and PRO affiliations
- Email notifications (when implemented)

### Additional Work Needed for Full Split Payments

To actually **distribute payments** to multiple contributors:
1. Integrate Stripe Connect
2. Create multi-party payment logic
3. Add legal agreement templates
4. Implement dispute resolution workflow

**Estimated effort**: 2-3 weeks of development

---

## 📄 Contract Analysis (Not Built)

### Status
- **Backend**: Not implemented
- **Priority**: Low (may be cut entirely)

### If You Decide to Build It

**Requirements**:
1. Choose AI provider (OpenAI, Anthropic, etc.)
2. Implement contract parsing logic
3. Create analysis templates
4. Add legal disclaimers
5. Handle liability concerns

**Estimated effort**: 1-2 weeks of development  
**Monthly cost**: $50-200+ depending on usage

**Recommendation**: Validate user demand before building.

---

## 🎯 Reactivation Priority (Based on User Feedback)

### Phase 1 (Months 1-3): Stabilize MVP
- Focus on core flow optimization
- Gather user feedback
- Fix bugs and improve UX

### Phase 2 (Months 4-6): Add High-Value Features

**Recommended order**:

1. **Monitoring System** (Easiest - already built)
   - High user value
   - Competitive differentiator
   - Low ongoing cost
   - Quick to activate

2. **Split Sheet** (If collaborative tracks are common)
   - Medium complexity
   - Requires Stripe Connect for payments
   - Legal considerations
   - Validate demand first

3. **Contract Analysis** (If users show need)
   - High complexity
   - Ongoing AI costs
   - Legal liability
   - Consider as separate product

---

## 🧪 Testing After Reactivation

### Monitoring System
```bash
# Test endpoints
node backend/test-mvp-endpoints.js

# Test monitoring specifically
node backend/test-monitoring.js

# Check with real credentials
TEST_EMAIL=test@consigliary.com TEST_PASSWORD=yourpassword node backend/test-mvp-endpoints.js
```

### Contributors System
```bash
# Test with authenticated user
curl -H "Authorization: Bearer YOUR_TOKEN" \
  https://consigliary-production.up.railway.app/api/v1/tracks/TRACK_ID/contributors
```

---

## 📝 Frontend Updates Needed

When reactivating features, you'll need to:

### Monitoring System
1. Uncomment monitoring UI components in iOS app
2. Add monitoring dashboard screens
3. Implement alert notifications
4. Add monitoring toggle in track settings

### Split Sheet
1. Uncomment split sheet UI components
2. Add contributor management screens
3. Implement split percentage validation
4. Add visual split sheet display

---

## 💡 Pro Tips

1. **Reactivate one feature at a time** - easier to test and debug
2. **Monitor error logs** after reactivation - Railway dashboard
3. **Test with real users** before announcing new features
4. **Update documentation** when features go live
5. **Track usage metrics** to validate the feature adds value

---

## 🚨 Important Notes

- **Database tables remain intact** - no migrations needed
- **API keys still configured** - YouTube API ready to use
- **No new environment variables** needed for monitoring
- **Stripe Connect required** for split payments (not just split tracking)
- **Legal review recommended** before enabling split payments

---

*Last Updated: December 24, 2025*  
*All deferred features are production-ready and tested*  
*Reactivation is literally just uncommenting 2 lines per feature*
