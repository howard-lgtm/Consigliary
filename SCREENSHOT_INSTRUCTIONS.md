# 📸 Screenshot Instructions for App Store

## Current Status: DEMO MODE ENABLED ✅

The app is now loaded with realistic demo data for taking screenshots.

---

## What's Included in Demo Mode:

### **Tracks (5 tracks)**
- Midnight Drive - 125K streams, $3,847.50 revenue
- Ocean Waves - 87.5K streams, $2,156.75 revenue
- City Lights - 156K streams, $4,523.25 revenue
- Sunrise Session - 62K streams, $1,892.00 revenue
- Neon Dreams - 198K streams, $5,234.50 revenue

### **Revenue Events (10 events)**
- Total Revenue: ~$17,500
- Mix of streaming, sync licenses, and performance rights
- Realistic dates and descriptions

### **Activities (4 items)**
- YouTube, TikTok, Instagram platforms
- Various artists using your tracks
- Mix of new and pending statuses

### **Deals (3 opportunities)**
- Netflix Series sync license - $15,000
- Spotify Originals feature - $8,500
- Nike commercial - $25,000

---

## How to Take Screenshots:

### **1. Run on Your iPhone**
```bash
# In Xcode:
# 1. Connect your iPhone 14 Pro
# 2. Select your device as destination
# 3. Click Run (▶️)
```

### **2. Recommended Screenshots**

**Home/Dashboard:**
- Shows overview stats and recent activity
- Highlights revenue tracking

**My Tracks:**
- Shows 5 demo tracks with streams and revenue
- Professional track management view

**Revenue View:**
- Total revenue display
- Revenue breakdown by source
- Recent revenue events

**Activity Monitoring:**
- Shows detected uses of your music
- Platform variety (YouTube, TikTok, Instagram)
- Action buttons (License, Takedown, Ignore)

**Deal Scout:**
- Shows potential opportunities
- Deal values and status
- Professional deal cards

**License Agreement:**
- Show the license creation form
- Professional PDF generation

### **3. Screenshot Tips**

- Use **iPhone 14 Pro** for best resolution
- Take screenshots in **portrait mode**
- Capture **clean UI** without notifications
- Show **realistic data** (not empty states)
- Include **key features** that differentiate the app

---

## After Screenshots: DISABLE DEMO MODE

### **CRITICAL: Before Archiving for TestFlight**

1. Open `DemoData.swift`
2. Change line 6:
   ```swift
   let ENABLE_DEMO_DATA = false // ⚠️ SET TO FALSE BEFORE ARCHIVE
   ```
3. Build and verify app is empty
4. Archive for TestFlight

---

## Quick Disable Command:

```bash
# Open the file
open /Users/howardduffy/Desktop/Consigliary/Consigliary/Consigliary/DemoData.swift

# Change line 6 from:
let ENABLE_DEMO_DATA = true

# To:
let ENABLE_DEMO_DATA = false
```

Then rebuild and archive.

---

## Verification Checklist:

**Before Screenshots:**
- [x] Demo data enabled (`ENABLE_DEMO_DATA = true`)
- [x] App shows 5 tracks
- [x] Revenue shows ~$17,500
- [x] Activities show 4 items
- [x] Deals show 3 opportunities

**After Screenshots (Before Archive):**
- [ ] Demo data disabled (`ENABLE_DEMO_DATA = false`)
- [ ] App shows empty state
- [ ] Clean build successful
- [ ] Ready for TestFlight archive

---

## Notes:

- Demo data is **local only** - not sent to backend
- Each beta tester will start with **empty app**
- Demo mode is for **marketing screenshots only**
- **Must disable** before TestFlight submission

---

*Created: December 25, 2025*
*Status: Demo mode active for screenshots*
