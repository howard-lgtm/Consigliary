# 🚀 MVP Deployment Instructions

## Issue: Git Push Blocked by Secret Scanning

GitHub's secret scanning has detected AWS credentials in old commits (specifically commit `915c44b`). This prevents pushing to the repository.

## Solution: Manual Railway Deployment

Since Railway is connected to GitHub and auto-deploys from the `main` branch, we have two options:

### Option 1: Manual File Update via Railway Dashboard (Recommended)

1. Go to Railway dashboard: https://railway.app
2. Select the Consigliary project
3. Click on the backend service
4. Go to "Variables" tab and ensure all environment variables are set
5. Use Railway CLI to deploy directly (bypassing GitHub)

### Option 2: Railway CLI Direct Deploy

```bash
# Install Railway CLI (if not installed)
npm install -g @railway/cli

# Login to Railway
railway login

# Link to your project
railway link

# Deploy directly from local files
railway up
```

This bypasses GitHub entirely and deploys directly from your local machine.

### Option 3: Fix Git History (Advanced - Not Recommended)

This requires rewriting git history to remove the secrets, which is complex and risky:

```bash
# Use BFG Repo Cleaner or git filter-branch
# NOT RECOMMENDED - can break Railway's git connection
```

---

## Files Changed for MVP

### `backend/server.js`
**Lines 44, 48, 53, 57**: Commented out monitoring and contributor routes

```javascript
// const contributorRoutes = require('./routes/contributors'); // Deferred to v2.0 - Split Sheet feature
// const monitoringRoutes = require('./routes/monitoring'); // Deferred to v2.0 - Monitoring System feature

// app.use('/api/v1', contributorRoutes); // Deferred to v2.0
// app.use('/api/v1/monitoring', monitoringRoutes); // Deferred to v2.0
```

### `backend/test-mvp-endpoints.js` (New File)
Test script to verify MVP endpoints are working and deferred endpoints return 404.

---

## Manual Deployment Steps

### Step 1: Copy Updated server.js to Railway

If using Railway dashboard:
1. Open Railway project
2. Navigate to backend service
3. Open file editor (if available)
4. Update `server.js` with the commented-out routes

### Step 2: Trigger Redeploy

Railway should auto-deploy when files change. If not:
1. Go to Deployments tab
2. Click "Deploy" button
3. Wait for build to complete

### Step 3: Verify Deployment

Run the test script:
```bash
node backend/test-mvp-endpoints.js
```

Expected results:
- Health check: ✅ 200 OK
- MVP endpoints: ❌ 401 (requires auth) - **This is correct**
- Monitoring endpoints: ✅ 404 (not found) - **This is what we want**
- Contributor endpoints: ✅ 404 (not found) - **This is what we want**

---

## Alternative: Create New Repository

If Railway deployment continues to fail:

1. Create a new GitHub repository
2. Copy only the necessary files (exclude .env backups)
3. Connect Railway to the new repository
4. Deploy fresh

---

## Current Status

- ✅ Local changes committed to `main` branch
- ❌ Cannot push to GitHub (secret scanning block)
- ⏳ Need to deploy via Railway CLI or manual update
- ⏳ Need to verify deployment with test script

---

## Next Steps After Deployment

1. Run `node backend/test-mvp-endpoints.js` to verify
2. Test with authenticated user (set TEST_EMAIL and TEST_PASSWORD env vars)
3. Update frontend to remove monitoring/contributor UI
4. Continue with MVP checklist

---

*Created: December 23, 2025*
*Issue: Git history contains AWS secrets in backup files*
*Solution: Deploy via Railway CLI or manual dashboard update*
