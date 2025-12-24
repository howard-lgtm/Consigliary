# 🚀 Deploy Legal Pages to GitHub Pages

## Quick Start (5 minutes)

### Step 1: Create GitHub Repository

1. Go to: https://github.com/new
2. Repository name: `consigliary-legal`
3. Description: `Legal pages for Consigliary iOS app`
4. **Public** (required for GitHub Pages)
5. **DO NOT** initialize with README
6. Click "Create repository"

### Step 2: Push Code to GitHub

GitHub will show you commands. Use these instead:

```bash
cd /Users/howardduffy/Desktop/Consigliary/legal-pages
git remote add origin https://github.com/YOUR-USERNAME/consigliary-legal.git
git branch -M main
git push -u origin main
```

Replace `YOUR-USERNAME` with your GitHub username (probably `howard-lgtm`).

### Step 3: Enable GitHub Pages

1. Go to repository Settings (gear icon)
2. Scroll to "Pages" in left sidebar
3. Under "Source":
   - Branch: `main`
   - Folder: `/ (root)`
4. Click "Save"
5. Wait 1-2 minutes for deployment

### Step 4: Get Your URLs

Your pages will be available at:

```
https://YOUR-USERNAME.github.io/consigliary-legal/privacy-policy.html
https://YOUR-USERNAME.github.io/consigliary-legal/terms-of-service.html
https://YOUR-USERNAME.github.io/consigliary-legal/support.html
```

Example (if username is `howard-lgtm`):
```
https://howard-lgtm.github.io/consigliary-legal/privacy-policy.html
https://howard-lgtm.github.io/consigliary-legal/terms-of-service.html
https://howard-lgtm.github.io/consigliary-legal/support.html
```

---

## What's Included

✅ **privacy-policy.html** - GDPR & CCPA compliant
✅ **terms-of-service.html** - ESIGN Act compliant  
✅ **support.html** - Contact and FAQ page
✅ **index.html** - Landing page with links to all documents

All pages use: `info@htdstudio.net`

---

## After Deployment

Once your pages are live, you need to update your iOS app's `Info.plist`:

1. Open Xcode
2. Open `Consigliary/Info.plist`
3. Add these keys:

```xml
<key>NSPrivacyPolicyURL</key>
<string>https://YOUR-USERNAME.github.io/consigliary-legal/privacy-policy.html</string>

<key>NSTermsOfServiceURL</key>
<string>https://YOUR-USERNAME.github.io/consigliary-legal/terms-of-service.html</string>
```

Or add via Xcode GUI:
- Right-click Info.plist → Open As → Source Code
- Add the XML above before the closing `</dict>` tag

---

## Troubleshooting

**Pages not loading?**
- Wait 2-3 minutes after enabling GitHub Pages
- Check Settings → Pages shows "Your site is live at..."
- Verify repository is Public

**404 error?**
- Make sure you're using the full URL with `.html` extension
- Check the branch is `main` not `master`
- Verify files are in root directory (not in a subfolder)

**Need to update content?**
- Edit the HTML files locally
- Commit and push changes
- GitHub Pages updates automatically (1-2 min delay)

---

## Alternative: Custom Domain

If you own `consigliary.com`:

1. Add a `CNAME` file to the repository:
   ```
   legal.consigliary.com
   ```

2. Add DNS record at your domain registrar:
   ```
   Type: CNAME
   Name: legal
   Value: YOUR-USERNAME.github.io
   ```

3. In GitHub Settings → Pages:
   - Custom domain: `legal.consigliary.com`
   - Enforce HTTPS: ✅

Your URLs would become:
- `https://legal.consigliary.com/privacy-policy.html`
- `https://legal.consigliary.com/terms-of-service.html`
- `https://legal.consigliary.com/support.html`

---

## Next Steps

After deploying:

1. ✅ Test all three URLs in a browser
2. ✅ Update iOS Info.plist with URLs
3. ✅ Commit and push iOS changes
4. ✅ Ready for TestFlight submission!

---

**Questions?** Email: info@htdstudio.net
