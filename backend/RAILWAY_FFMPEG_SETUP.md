# 🚂 Railway FFmpeg Setup Guide

**Date**: December 20, 2025  
**Purpose**: Add FFmpeg to Railway production environment

---

## 🎯 Problem

Railway doesn't include FFmpeg by default, causing audio extraction to fail in production:
```
Error: Cannot find ffmpeg
```

---

## ✅ Solution Options

### Option 1: Nixpacks Configuration (Recommended)

Create `nixpacks.toml` in backend root:

```toml
[phases.setup]
nixPkgs = ["ffmpeg"]

[phases.install]
cmds = ["npm ci"]

[phases.build]
cmds = []

[start]
cmd = "npm start"
```

**Pros:**
- Simple configuration
- Railway native support
- Automatic FFmpeg installation

**Cons:**
- Adds ~30 seconds to build time

---

### Option 2: Dockerfile (More Control)

Create `Dockerfile` in backend root:

```dockerfile
FROM node:18-alpine

# Install FFmpeg
RUN apk add --no-cache ffmpeg

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy application files
COPY . .

# Expose port
EXPOSE 3000

# Start application
CMD ["npm", "start"]
```

**Pros:**
- Full control over environment
- Can optimize image size
- Reproducible builds

**Cons:**
- Requires Docker knowledge
- Slightly more complex

---

### Option 3: Buildpack (Alternative)

Use Railway's buildpack system:

1. Go to Railway Dashboard
2. Select your service
3. Settings → Environment
4. Add buildpack: `https://github.com/jonathanong/heroku-buildpack-ffmpeg-latest`

**Pros:**
- No code changes needed
- Quick to implement

**Cons:**
- Less control
- Buildpack may not be maintained

---

## 🚀 Recommended Implementation

**Use Option 1 (nixpacks.toml)** - Best balance of simplicity and reliability.

### Step-by-Step:

1. **Create nixpacks.toml**
   ```bash
   cd /Users/howardduffy/Desktop/Consigliary/backend
   touch nixpacks.toml
   ```

2. **Add configuration** (see Option 1 above)

3. **Commit and push**
   ```bash
   git add nixpacks.toml
   git commit -m "Add FFmpeg support for Railway deployment"
   git push
   ```

4. **Railway auto-deploys** with FFmpeg included

5. **Verify deployment**
   ```bash
   # Check Railway logs
   railway logs
   
   # Test verification endpoint
   curl -X POST https://consigliary-production.up.railway.app/api/v1/verifications \
     -H "Authorization: Bearer <TOKEN>" \
     -H "Content-Type: application/json" \
     -d '{"videoUrl":"https://www.youtube.com/watch?v=dQw4w9WgXcQ"}'
   ```

---

## 🔍 Verification Checklist

After deployment, verify FFmpeg is available:

```bash
# SSH into Railway container (if available)
railway run bash

# Check FFmpeg
which ffmpeg
ffmpeg -version
```

Or check logs for FFmpeg-related errors during audio extraction.

---

## 🐛 Troubleshooting

### Build Fails with nixpacks.toml
- Check TOML syntax
- Ensure file is in backend root
- Try Option 2 (Dockerfile) instead

### FFmpeg Still Not Found
- Check Railway logs for installation errors
- Verify nixpacks.toml is committed
- Try explicit path in code:
  ```javascript
  ffmpeg.setFfmpegPath('/usr/bin/ffmpeg');
  ```

### Increased Build Time
- Normal with FFmpeg installation (~30-60 seconds)
- Consider caching if it becomes an issue

---

## 📊 Expected Build Output

With nixpacks.toml, you should see:

```
[nixpacks] Installing packages: ffmpeg
[nixpacks] ✓ ffmpeg installed
[nixpacks] Installing node dependencies
[nixpacks] ✓ npm ci completed
[nixpacks] Starting application
[nixpacks] ✓ Server running on port 3000
```

---

## 💰 Cost Impact

**None** - FFmpeg is open source and adds minimal overhead:
- Build time: +30-60 seconds
- Image size: +50-100 MB
- Runtime: No performance impact

---

© 2025 HTDSTUDIO AB
