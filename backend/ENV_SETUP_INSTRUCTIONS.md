# 🔧 .env File Setup Instructions

## 📋 Step-by-Step Guide

### Step 1: Open Railway Dashboard
1. Go to: https://railway.app/project/453302b8-7e05-4d17-bf94-651434fed5eb
2. Click on your backend service (should be named "Consigliary" or similar)
3. Click the **"Variables"** tab

You'll see a list of environment variables with their values.

---

### Step 2: Open the Template File
```bash
cd /Users/howardduffy/Desktop/Consigliary/backend
code .env.template
# or
nano .env.template
# or
open -a TextEdit .env.template
```

---

### Step 3: Copy Variables One by One

**In Railway Dashboard**, find each variable and copy its value:

#### 1. DATABASE_URL
- **Railway**: Find `DATABASE_URL` → Click to reveal → Copy the value
- **Template**: Replace `PASTE_HERE` with the copied value
- Example: `postgresql://postgres:password@hostname:5432/railway`

#### 2. JWT_SECRET
- **Railway**: Find `JWT_SECRET` → Copy
- **Template**: Replace `PASTE_HERE`

#### 3. REFRESH_TOKEN_SECRET
- **Railway**: Find `REFRESH_TOKEN_SECRET` → Copy
- **Template**: Replace `PASTE_HERE`

#### 4. AWS_ACCESS_KEY_ID
- **Railway**: Find `AWS_ACCESS_KEY_ID` → Copy
- **Template**: Replace `PASTE_HERE`
- Example: `AKIAIOSFODNN7EXAMPLE`

#### 5. AWS_SECRET_ACCESS_KEY
- **Railway**: Find `AWS_SECRET_ACCESS_KEY` → Copy
- **Template**: Replace `PASTE_HERE`
- Example: `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY`

#### 6. ACRCLOUD_ACCESS_KEY
- **Railway**: Find `ACRCLOUD_ACCESS_KEY` → Copy
- **Template**: Replace `PASTE_HERE`

#### 7. ACRCLOUD_ACCESS_SECRET
- **Railway**: Find `ACRCLOUD_ACCESS_SECRET` → Copy
- **Template**: Replace `PASTE_HERE`

---

### Step 4: Save as .env

**Important**: You need to rename the file from `.env.template` to `.env`

```bash
# Option A: Rename in terminal
mv .env.template .env

# Option B: Save As in your editor
# File → Save As → Change name to ".env"
```

---

### Step 5: Verify the File

```bash
# Check if .env exists
ls -la .env

# View first few lines (without showing secrets)
head -20 .env
```

You should see:
```
NODE_ENV=development
PORT=3000
DATABASE_URL=postgresql://...
JWT_SECRET=your-actual-secret
...
```

**NOT:**
```
DATABASE_URL=PASTE_HERE  ← This means you didn't paste the values!
```

---

### Step 6: Test the Backend

**Terminal 1:**
```bash
cd /Users/howardduffy/Desktop/Consigliary/backend
npm start
```

**Expected output:**
```
Server running on port 3000
Database connected
```

**Terminal 2:**
```bash
cd /Users/howardduffy/Desktop/Consigliary/backend
./scripts/test-verification.sh
```

---

## 🎯 Quick Reference

**Files:**
- `.env.template` = Template with PASTE_HERE placeholders
- `.env` = Your actual file with real values (gitignored)

**What to copy from Railway:**
1. DATABASE_URL
2. JWT_SECRET
3. REFRESH_TOKEN_SECRET
4. AWS_ACCESS_KEY_ID
5. AWS_SECRET_ACCESS_KEY
6. ACRCLOUD_ACCESS_KEY
7. ACRCLOUD_ACCESS_SECRET

**What's already filled in:**
- NODE_ENV, PORT, API_VERSION
- AWS_S3_BUCKET, AWS_REGION
- ACRCLOUD_HOST
- FRONTEND_URL, IOS_APP_BUNDLE_ID
- Rate limiting settings

---

## 🐛 Troubleshooting

### "Cannot find .env file"
```bash
# Make sure you renamed it
mv .env.template .env
```

### "Database connection failed"
- Check `DATABASE_URL` is correct
- Make sure you copied the full value (it's long!)

### "Still says PASTE_HERE"
- You forgot to replace the placeholders
- Open `.env` and replace each `PASTE_HERE` with actual values from Railway

---

## 📸 Visual Guide

**Railway Dashboard:**
```
┌─────────────────────────────────────┐
│ Variables                           │
├─────────────────────────────────────┤
│ DATABASE_URL                        │
│ postgresql://postgres:pass@host...  │ ← Copy this
│                                     │
│ JWT_SECRET                          │
│ abc123xyz789...                     │ ← Copy this
│                                     │
│ AWS_ACCESS_KEY_ID                   │
│ AKIAIOSFODNN7EXAMPLE                │ ← Copy this
└─────────────────────────────────────┘
```

**Your .env file:**
```
DATABASE_URL=postgresql://postgres:pass@host...  ← Paste here
JWT_SECRET=abc123xyz789...                       ← Paste here
AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE           ← Paste here
```

---

© 2025 HTDSTUDIO AB
