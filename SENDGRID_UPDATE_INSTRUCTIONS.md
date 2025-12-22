# SendGrid HTTP API Update Instructions

**Issue**: Railway is blocking SMTP port 587, causing email timeouts.

**Solution**: Switch from SMTP to SendGrid HTTP API.

---

## Files Changed

### 1. `backend/services/email.js`
- Changed from `nodemailer` SMTP to `@sendgrid/mail` HTTP API
- All email sending now uses SendGrid's REST API instead of SMTP

### 2. `backend/package.json`
- Added `"@sendgrid/mail": "^8.1.0"` to dependencies

---

## Manual Deployment Steps

Since git push is blocked by credentials in history, deploy manually:

### Option 1: Railway CLI (Recommended)

```bash
cd /Users/howardduffy/Desktop/Consigliary/backend

# Install Railway CLI if not installed
npm install -g @railway/cli

# Login to Railway
railway login

# Link to your project
railway link

# Deploy
railway up
```

### Option 2: Direct File Edit in Railway Dashboard

1. Go to Railway dashboard
2. Click on backend service
3. Go to "Deployments" → Latest deployment → "View Logs"
4. Use Railway's file editor to update:
   - `services/email.js` (copy from local)
   - `package.json` (add @sendgrid/mail dependency)
5. Trigger redeploy

### Option 3: Fresh Git Branch

```bash
# Create new branch without history
git checkout --orphan clean-main
git add backend/services/email.js backend/package.json
git commit -m "Update to SendGrid HTTP API"
git push -f origin clean-main:main
```

---

## Verify Deployment

After deployment, test with:

```bash
node backend/test-license-email.js
```

Expected output:
```
✅ License generated successfully!
✅ Email sent successfully!
```

Check your email at: howard@htdstudio.net

---

## What Changed in email.js

**Before (SMTP):**
```javascript
const nodemailer = require('nodemailer');
this.transporter = nodemailer.createTransport({
  host: 'smtp.sendgrid.net',
  port: 587,
  ...
});
await this.transporter.sendMail(mailOptions);
```

**After (HTTP API):**
```javascript
const sgMail = require('@sendgrid/mail');
sgMail.setApiKey(process.env.SENDGRID_API_KEY);
await sgMail.send(msg);
```

---

## Environment Variables (Already Set)

✅ `SENDGRID_API_KEY` - Already in Railway
✅ `SENDGRID_FROM_EMAIL` - Already in Railway  
✅ `STRIPE_SECRET_KEY` - Already in Railway

---

**The changes are ready locally. Just need to deploy to Railway!**
