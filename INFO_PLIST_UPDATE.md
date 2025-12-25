# 📱 Update Info.plist with Legal URLs

## Your Live URLs ✅

- **Privacy Policy**: https://howard-lgtm.github.io/Consigliary/legal-pages/privacy-policy.html
- **Terms of Service**: https://howard-lgtm.github.io/Consigliary/legal-pages/terms-of-service.html
- **Support**: https://howard-lgtm.github.io/Consigliary/legal-pages/support.html

---

## How to Add to Xcode

### Method 1: Project Settings (Recommended)

1. **Open Xcode**
2. **Select** the Consigliary project in the navigator
3. **Select** the Consigliary target
4. **Click** the "Info" tab
5. **Click** the "+" button under "Custom iOS Target Properties"
6. **Add these two entries:**

   **Entry 1:**
   - Key: `Privacy Policy URL`
   - Type: `String`
   - Value: `https://howard-lgtm.github.io/Consigliary/legal-pages/privacy-policy.html`

   **Entry 2:**
   - Key: `Terms of Service URL`
   - Type: `String`
   - Value: `https://howard-lgtm.github.io/Consigliary/legal-pages/terms-of-service.html`

### Method 2: Direct Info.plist Edit (Alternative)

If you have an Info.plist file in your project:

1. **Find** `Consigliary/Info.plist` in Xcode
2. **Right-click** → Open As → Source Code
3. **Add** before the closing `</dict>` tag:

```xml
<key>NSPrivacyPolicyURL</key>
<string>https://howard-lgtm.github.io/Consigliary/legal-pages/privacy-policy.html</string>

<key>NSTermsOfServiceURL</key>
<string>https://howard-lgtm.github.io/Consigliary/legal-pages/terms-of-service.html</string>
```

---

## Verify URLs Work

Test in your browser:
- https://howard-lgtm.github.io/Consigliary/legal-pages/privacy-policy.html ✅
- https://howard-lgtm.github.io/Consigliary/legal-pages/terms-of-service.html ✅

---

## After Adding URLs

1. **Build** the app to verify no errors
2. **Commit** the changes:
   ```bash
   cd /Users/howardduffy/Desktop/Consigliary
   git add Consigliary/
   git commit -m "Add Privacy Policy and Terms of Service URLs to Info.plist"
   git push
   ```

3. **You're ready for TestFlight!** 🚀

---

## TestFlight Checklist

- ✅ Backend deployed and tested
- ✅ Legal pages hosted on GitHub Pages
- ✅ Privacy Policy URL added to Info.plist
- ✅ Terms of Service URL added to Info.plist
- ⏳ Archive and upload to App Store Connect

---

**Next Step**: Archive your app in Xcode and upload to TestFlight!
