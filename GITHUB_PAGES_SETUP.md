# GitHub Pages Setup Guide for Consigliary

This guide will help you host your legal documents on **consigliary.app** using GitHub Pages.

---

## 📋 Prerequisites

- [ ] GitHub account
- [ ] Git installed on your Mac
- [ ] Domain **consigliary.app** registered
- [ ] Access to domain DNS settings

---

## 🚀 Step-by-Step Setup

### Step 1: Create GitHub Repository

1. Go to https://github.com/new
2. Repository name: `consigliary` (or `consigliary-legal`)
3. Description: "Legal documents for Consigliary app"
4. Set to **Public** (required for free GitHub Pages)
5. Click **Create repository**

---

### Step 2: Push Your Code to GitHub

Open Terminal and run these commands:

```bash
# Navigate to your project
cd /Users/howardduffy/Desktop/Consigliary

# Initialize git (if not already done)
git init

# Add all files
git add .

# Commit
git commit -m "Add legal documents and app code"

# Add your GitHub repository as remote
# Replace YOUR_USERNAME with your GitHub username
git remote add origin https://github.com/YOUR_USERNAME/consigliary.git

# Push to GitHub
git branch -M main
git push -u origin main
```

**Note:** You'll need to authenticate with GitHub. Use a Personal Access Token if prompted.

---

### Step 3: Enable GitHub Pages

1. Go to your repository on GitHub
2. Click **Settings** (top menu)
3. Click **Pages** (left sidebar)
4. Under **Source**:
   - Branch: Select `main`
   - Folder: Select `/docs`
5. Click **Save**

GitHub will show: "Your site is ready to be published at `https://YOUR_USERNAME.github.io/consigliary/`"

Wait 1-2 minutes for the site to build.

---

### Step 4: Test GitHub Pages

Visit: `https://YOUR_USERNAME.github.io/consigliary/`

You should see your legal documents landing page.

Test these URLs:
- `https://YOUR_USERNAME.github.io/consigliary/privacy-policy.html`
- `https://YOUR_USERNAME.github.io/consigliary/terms-of-service.html`
- `https://YOUR_USERNAME.github.io/consigliary/eula.html`

---

### Step 5: Configure Custom Domain (consigliary.app)

#### In GitHub:

1. Still in **Settings → Pages**
2. Under **Custom domain**, enter: `consigliary.app`
3. Click **Save**
4. Check **Enforce HTTPS** (wait for SSL certificate)

#### In Your Domain Registrar:

You need to add DNS records. The exact steps depend on your registrar (Namecheap, GoDaddy, etc.).

**Option A: CNAME Record (Recommended)**

Add a **CNAME** record:
- **Host/Name**: `@` or leave blank (for root domain)
- **Value/Points to**: `YOUR_USERNAME.github.io`
- **TTL**: 3600 (or automatic)

**Option B: A Records (Alternative)**

Add **4 A records** pointing to GitHub's IPs:
- **Host/Name**: `@`
- **Value**: 
  - `185.199.108.153`
  - `185.199.109.153`
  - `185.199.110.153`
  - `185.199.111.153`
- **TTL**: 3600

**For www subdomain (optional):**

Add a **CNAME** record:
- **Host/Name**: `www`
- **Value/Points to**: `YOUR_USERNAME.github.io`

---

### Step 6: Wait for DNS Propagation

DNS changes can take **5 minutes to 48 hours** to propagate globally.

Check status:
```bash
# Check if DNS is propagated
dig consigliary.app

# Or use online tool
# https://dnschecker.org
```

---

### Step 7: Verify Your Site

Once DNS propagates, visit:
- https://consigliary.app
- https://consigliary.app/privacy-policy.html
- https://consigliary.app/terms-of-service.html
- https://consigliary.app/eula.html

All should load with HTTPS (🔒 padlock in browser).

---

## 📱 Update App Store Connect

Once your site is live, add these URLs to App Store Connect:

1. **Privacy Policy URL**: `https://consigliary.app/privacy-policy.html`
2. **Terms of Service URL**: `https://consigliary.app/terms-of-service.html`
3. **Support URL**: `https://consigliary.app`

---

## 🔧 Troubleshooting

### "Site not found" error
- Wait longer for DNS propagation
- Check DNS records are correct
- Verify GitHub Pages is enabled

### "Not Secure" warning
- Wait for GitHub to provision SSL certificate (up to 24 hours)
- Make sure "Enforce HTTPS" is checked in GitHub Pages settings

### Custom domain not working
- Verify CNAME file was created in your repo (GitHub does this automatically)
- Check DNS records with `dig consigliary.app`
- Try clearing browser cache

### Need to update documents
1. Edit files in `/docs` folder
2. Commit and push to GitHub:
   ```bash
   git add docs/
   git commit -m "Update legal documents"
   git push
   ```
3. Changes appear in 1-2 minutes

---

## 📞 Need Help?

**GitHub Pages Documentation**: https://docs.github.com/en/pages

**Common DNS Registrars:**
- Namecheap: https://www.namecheap.com/support/knowledgebase/article.aspx/319/2237/how-can-i-set-up-an-a-address-record-for-my-domain/
- GoDaddy: https://www.godaddy.com/help/add-an-a-record-19238
- Cloudflare: https://developers.cloudflare.com/dns/manage-dns-records/how-to/create-dns-records/

---

## ✅ Final Checklist

- [ ] GitHub repository created
- [ ] Code pushed to GitHub
- [ ] GitHub Pages enabled (from /docs folder)
- [ ] Custom domain configured (consigliary.app)
- [ ] DNS records added at domain registrar
- [ ] DNS propagated (site loads at consigliary.app)
- [ ] HTTPS enabled (🔒 padlock shows)
- [ ] All legal document URLs work
- [ ] URLs added to App Store Connect

---

**You're all set!** Your legal documents are now professionally hosted and ready for App Store submission.

© 2024 HTDSTUDIO AB
