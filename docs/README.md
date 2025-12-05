# Consigliary Legal Documents

This directory contains the legal documents for Consigliary, hosted via GitHub Pages.

## 📄 Documents

- **Privacy Policy** - [privacy-policy.html](privacy-policy.html)
- **Terms of Service** - [terms-of-service.html](terms-of-service.html)
- **End User License Agreement** - [eula.html](eula.html)

## 🌐 GitHub Pages Setup

### Step 1: Push to GitHub

```bash
cd /Users/howardduffy/Desktop/Consigliary
git init
git add .
git commit -m "Initial commit with legal documents"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/consigliary.git
git push -u origin main
```

### Step 2: Enable GitHub Pages

1. Go to your repository on GitHub
2. Click **Settings**
3. Scroll to **Pages** section (left sidebar)
4. Under **Source**, select:
   - Branch: `main`
   - Folder: `/docs`
5. Click **Save**

### Step 3: Custom Domain (consigliary.app)

1. In GitHub Pages settings, add custom domain: `consigliary.app`
2. In your domain registrar (where you bought consigliary.app):
   - Add a **CNAME** record pointing to: `YOUR_USERNAME.github.io`
   - Or add **A** records pointing to GitHub's IPs:
     - 185.199.108.153
     - 185.199.109.153
     - 185.199.110.153
     - 185.199.111.153

### Step 4: Verify

After DNS propagates (5-30 minutes), your legal documents will be available at:

- https://consigliary.app/privacy-policy.html
- https://consigliary.app/terms-of-service.html
- https://consigliary.app/eula.html

## 🔗 URLs for App Store Connect

Use these URLs in your App Store Connect submission:

- **Privacy Policy URL**: `https://consigliary.app/privacy-policy.html`
- **Terms of Service URL**: `https://consigliary.app/terms-of-service.html`
- **EULA URL**: `https://consigliary.app/eula.html`

## 📱 In-App Links

The app already includes in-app versions of these documents in the Account settings.

## ✅ Checklist

- [ ] Push code to GitHub
- [ ] Enable GitHub Pages
- [ ] Configure custom domain
- [ ] Wait for DNS propagation
- [ ] Verify URLs work
- [ ] Add URLs to App Store Connect
- [ ] Test links in app

---

© 2024 HTDSTUDIO AB
