# Archive & Upload Instructions

## ✅ Pre-Archive Checklist Complete

- ✅ Demo mode disabled
- ✅ All code committed to GitHub
- ✅ Clean build completed
- ✅ Screenshots ready on Desktop
- ✅ Legal documents prepared

---

## 📦 Create Archive (Using Xcode)

### **Step 1: Open Project in Xcode**

```bash
open /Users/howardduffy/Desktop/Consigliary/Consigliary/Consigliary.xcodeproj
```

### **Step 2: Select Destination**

1. In Xcode toolbar (top), click the device selector
2. Select **"Any iOS Device (arm64)"**
   - NOT a simulator
   - NOT "My Mac"
   - Must be "Any iOS Device"

### **Step 3: Create Archive**

1. Menu: **Product → Archive**
2. Wait for build to complete (2-5 minutes)
3. Xcode Organizer will open automatically

---

## ✅ Validate Archive

### **In Xcode Organizer:**

1. Select your **Consigliary** archive (should be at top)
2. Click **"Validate App"** button (right side)
3. Select your team: **HTDSTUDIO AB (A33AU765BV)**
4. Click **"Next"**
5. Select **"Automatically manage signing"**
6. Click **"Next"**
7. Wait for validation (1-2 minutes)
8. Should see ✅ **"Consigliary.ipa has been successfully validated"**

**If validation fails:**
- Read error message carefully
- Common issues:
  - Missing icons → Check Assets.xcassets
  - Signing issue → Xcode → Preferences → Accounts → Download Profiles
  - Capabilities → Check project settings

---

## 📤 Upload to App Store Connect

### **In Xcode Organizer:**

1. Click **"Distribute App"** button
2. Select **"App Store Connect"**
3. Click **"Next"**
4. Select **"Upload"**
5. Click **"Next"**
6. Select your team: **HTDSTUDIO AB**
7. Click **"Next"**
8. Select signing options:
   - ✅ **"Automatically manage signing"** (recommended)
   - ✅ **"Upload your app's symbols"** (for crash reports)
   - ✅ **"Manage Version and Build Number"** (optional)
9. Click **"Next"**
10. Review summary
11. Click **"Upload"**
12. Wait for upload (5-15 minutes depending on connection)

**Success Message:**
"Consigliary.ipa has been successfully uploaded to App Store Connect"

---

## ⏳ Wait for Processing

### **What Happens Next:**

1. **Upload Complete** - You'll see confirmation in Xcode
2. **Processing Begins** - Apple processes your build (10-30 min)
3. **Email Notification** - You'll receive email when ready
4. **Available in TestFlight** - Build appears in App Store Connect

### **Check Status:**

1. Go to https://appstoreconnect.apple.com
2. Click **"My Apps"**
3. Select **"Consigliary"** (or create it if first upload)
4. Click **"TestFlight"** tab
5. Look for your build under **"iOS Builds"**

**Status will show:**
- 🔄 **"Processing"** - Wait (can take up to 30 min)
- ⚠️ **"Processing Failed"** - Check email for error details
- ✅ **"Ready to Submit"** - Success! Build is ready

---

## 🏪 Set Up App Store Connect (First Time)

### **If App Doesn't Exist Yet:**

1. Go to https://appstoreconnect.apple.com
2. Click **"My Apps"** → **"+"** → **"New App"**
3. Fill in:
   - **Platform:** iOS
   - **Name:** Consigliary
   - **Primary Language:** English (U.S.)
   - **Bundle ID:** com.htdstudio.Consigliary
   - **SKU:** CONSIGLIARY-001
   - **User Access:** Full Access
4. Click **"Create"**

### **Add App Information:**

1. **Category:**
   - Primary: **Music**
   - Secondary: **Productivity**

2. **Privacy Policy URL:**
   - `https://consigliary.app/privacy-policy.html`
   - (Activate GitHub Pages first if not done)

3. **App Description:** (See TESTFLIGHT_DEPLOYMENT_CHECKLIST.md)

4. **Keywords:**
   ```
   music rights, contract analysis, split sheet, music business, royalties, sync license, music producer, songwriter, music management, AI music
   ```

5. **Support URL:**
   - `https://consigliary.app` or
   - `mailto:howard@htdstudio.net`

---

## 🧪 Configure TestFlight

### **Step 1: Wait for Build to Process**

- Check email for "Your build has been processed" notification
- Or check App Store Connect → TestFlight tab

### **Step 2: Add Test Information**

1. Go to **TestFlight** tab
2. Click your build
3. Add **"What to Test"**:

```
Welcome to Consigliary Private Beta!

Please test these key features:

1. CONTRACT ANALYSIS
   - Upload a PDF contract
   - Review AI analysis and fairness score
   - Check red flags and recommendations

2. SPLIT SHEET GENERATOR
   - Create a new split sheet
   - Add multiple contributors
   - Generate and share PDF

3. LICENSE AGREEMENTS
   - Create a custom license
   - Review generated PDF
   - Share via email

4. REVENUE TRACKING
   - View sample revenue data
   - Check different revenue sources
   - Explore top tracks

Please report any bugs or issues to howard@htdstudio.net

Thank you for testing!
```

### **Step 3: Create Beta Group**

1. Click **"External Testing"** (left sidebar)
2. Click **"+"** to create new group
3. Name: **"Private Beta Group"**
4. Add your build
5. Click **"Add Testers"**
6. Enter email addresses (including your IP attorney)
7. Click **"Add"**

### **Step 4: Submit for Beta App Review**

**Required for External Testing:**

1. Click **"Submit for Review"**
2. Fill in:
   - **Beta App Description:** (See checklist)
   - **Feedback Email:** howard@htdstudio.net
   - **Demo Account:**
     - Username: demo@consigliary.app
     - Password: [Create one]
   - **Notes:** Testing instructions
3. Click **"Submit"**
4. Wait for approval (usually 24-48 hours)

---

## 📧 Invite Your IP Attorney

### **After Beta Approved:**

Send email:

```
Subject: Consigliary Private Beta - TestFlight Invitation

Hi [Name],

Great news! Consigliary is ready for private beta testing, and I'd love your professional feedback.

You'll receive a TestFlight invitation email shortly. Here's how to get started:

1. Install TestFlight from the App Store (if you don't have it already)
2. Open the invitation email on your iPhone
3. Tap "View in TestFlight"
4. Install Consigliary

WHAT TO TEST:
• Contract Analysis - Upload a music contract and review the AI insights
• Split Sheet Generator - Create ownership agreements
• License Agreements - Generate sync licenses
• Overall user experience

I'm especially interested in your thoughts on the contract analysis accuracy and legal recommendations.

Please send feedback to howard@htdstudio.net or reply to this email.

Looking forward to your insights!

Best,
Howard
```

---

## 🎯 Success Checklist

- [ ] Archive created successfully
- [ ] Validation passed
- [ ] Upload to App Store Connect complete
- [ ] Build processing finished
- [ ] App Store Connect configured
- [ ] TestFlight set up
- [ ] Beta App Review submitted
- [ ] Beta testers invited
- [ ] IP attorney notified

---

## 🚨 Troubleshooting

### **"No accounts with App Store Connect access"**
- Xcode → Preferences → Accounts
- Sign in with Apple ID
- Download manual profiles

### **"Failed to create provisioning profile"**
- Check Bundle ID matches in App Store Connect
- Ensure certificates are valid
- Try "Automatically manage signing"

### **"Upload failed"**
- Check internet connection
- Try again (sometimes temporary)
- Use Xcode Organizer (not command line)

### **"Processing" stuck for hours**
- Normal: Can take up to 30 minutes
- If > 2 hours: Contact Apple Support
- Check for email from Apple about issues

### **Beta Review Rejected**
- Provide working demo account
- Add clear testing instructions
- Ensure all features work
- Resubmit with fixes

---

## 📞 Need Help?

**Apple Resources:**
- App Store Connect: https://appstoreconnect.apple.com
- Developer Support: https://developer.apple.com/support/
- TestFlight Guide: https://developer.apple.com/testflight/

**Your Support:**
- Email: howard@htdstudio.net
- Beta Feedback: howard@htdstudio.net

---

## 🚀 You're Ready!

Everything is prepared for a smooth deployment. Follow these steps carefully, and you'll have your private beta running soon.

**Good luck with your TestFlight launch!** 🎉

---

© 2024 HTDSTUDIO AB
