# Consigliary Legal Pages

This directory contains the legal documents required for App Store submission.

## Files

- `privacy-policy.html` - Privacy Policy (GDPR & CCPA compliant)
- `terms-of-service.html` - Terms of Service (ESIGN Act compliant)
- `support.html` - Support page with contact information

## Hosting on GitHub Pages

### Quick Setup (5 minutes)

1. **Create a new GitHub repository**:
   ```bash
   # From this directory
   cd /Users/howardduffy/Desktop/Consigliary/legal-pages
   git init
   git add .
   git commit -m "Add legal pages for Consigliary"
   ```

2. **Create GitHub repo** (on github.com):
   - Go to https://github.com/new
   - Name: `consigliary-legal`
   - Public repository
   - Don't initialize with README

3. **Push to GitHub**:
   ```bash
   git remote add origin https://github.com/YOUR-USERNAME/consigliary-legal.git
   git branch -M main
   git push -u origin main
   ```

4. **Enable GitHub Pages**:
   - Go to repository Settings → Pages
   - Source: Deploy from branch
   - Branch: `main` / `root`
   - Save

5. **Your URLs will be**:
   - Privacy: `https://YOUR-USERNAME.github.io/consigliary-legal/privacy-policy.html`
   - Terms: `https://YOUR-USERNAME.github.io/consigliary-legal/terms-of-service.html`
   - Support: `https://YOUR-USERNAME.github.io/consigliary-legal/support.html`

## Alternative: Use Your Domain

If you have `consigliary.com` or `htdstudio.net`:

1. Upload these files to your web hosting
2. URLs would be:
   - `https://consigliary.com/privacy`
   - `https://consigliary.com/terms`
   - `https://consigliary.com/support`

## Update iOS App

After hosting, update `Info.plist` in your iOS app:

```xml
<key>NSPrivacyPolicyURL</key>
<string>https://YOUR-USERNAME.github.io/consigliary-legal/privacy-policy.html</string>
<key>NSTermsOfServiceURL</key>
<string>https://YOUR-USERNAME.github.io/consigliary-legal/terms-of-service.html</string>
```

## Contact Information

All pages use: `info@htdstudio.net`

Additional emails referenced:
- Support: `support@htdstudio.net`
- Billing: `billing@htdstudio.net`
- Privacy: `privacy@htdstudio.net`
- Legal: `legal@htdstudio.net`
- Feedback: `feedback@htdstudio.net`

---

© 2025 HTDSTUDIO AB
