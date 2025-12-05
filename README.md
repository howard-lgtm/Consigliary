# Consigliary iOS App

## 🎯 Quick Setup (5 Minutes)

### Step 1: Create Xcode Project

1. **Open Xcode**
2. **File → New → Project** (⌘⇧N)
3. **Select Template**:
   - Platform: **iOS**
   - Template: **App**
   - Click **Next**

4. **Configure Project**:
   - Product Name: `Consigliary`
   - Team: Select your Apple ID
   - Organization Identifier: `com.htdstudio`
   - Interface: **SwiftUI** ⚠️ CRITICAL
   - Language: **Swift** ⚠️ CRITICAL
   - Storage: None (uncheck everything)
   - Click **Next**

5. **Save Location**:
   - Navigate to: `/Users/howardduffy/Desktop/`
   - Create new folder: `ConsigliaryXcode`
   - Click **Create**

### Step 2: Add Swift Files

1. In Xcode, **delete** the default `ContentView.swift` (Move to Trash)
2. **Right-click** on the `Consigliary` folder (yellow folder in sidebar)
3. Select **"Add Files to Consigliary..."**
4. Navigate to `/Users/howardduffy/Desktop/Consigliary/`
5. **Select ALL these files** (⌘A or hold ⌘ and click each):
   - ConsigliaryApp.swift
   - ContentView.swift
   - OnboardingView.swift
   - DashboardView.swift
   - SummaryView.swift
   - ActivityView.swift
   - MonetizationView.swift
   - AccountView.swift
   - SplitSheetView.swift
   - ContractAnalyzerView.swift

6. ✅ **Check "Copy items if needed"**
7. ✅ **Check "Add to targets: Consigliary"**
8. Click **Add**

### Step 3: Run the App

1. **Select Simulator**: iPhone 15 Pro (or any iPhone)
2. **Press ⌘R** or click the Play button ▶️
3. Wait for build (~30 seconds first time)
4. **App launches!** 🎉

## 📱 What You'll See

### Onboarding (4 Screens)
1. "You're Always in Control" - Shield icon
2. "24/7 Rights Monitoring" - Eye icon
3. "AI-Powered Intelligence" - Sparkles icon
4. "Revenue Opportunities" - Dollar icon

### Dashboard (4 Tabs)
1. **Summary** - Monitoring stats, deals, quick actions
2. **Activity** - Live unauthorized use detection feed
3. **Monetization** - Revenue breakdown ($1,247 demo)
4. **Account** - User profile and settings

### Features
- **Split Sheet Creator** - Add contributors, validate percentages
- **Contract Analyzer** - AI-powered contract analysis (demo mode)

## 🎨 Design System

- **Background**: Black (#000000)
- **Cards**: Dark Gray (#1C1C1E)
- **Primary**: Neon Green (#32D74B)
- **Secondary**: Cyan (#64D2FF)
- **Warning**: Yellow (#FFD60A)
- **Danger**: Red (#FF453A)

## 🐛 Troubleshooting

### Build Errors
- **Clean Build Folder**: Product → Clean Build Folder (⌘⇧K)
- **Restart Xcode**
- Make sure all files are added to the target

### "Cannot find type 'OnboardingView'"
- Check that ALL 10 Swift files are in the project
- Verify files are checked in the target membership

### Simulator Issues
- Use iPhone 15 Pro for best performance
- Or deploy to your real iPhone for testing

## 📱 Test on Your iPhone

1. Connect iPhone via USB
2. Trust your Mac (on iPhone if prompted)
3. Select your iPhone in Xcode
4. Press ⌘R
5. On iPhone: Settings → General → VPN & Device Management
6. Trust your developer certificate
7. Open the app!

## 🚀 Next Steps

- Test all features
- Take screenshots for pitch deck
- Deploy to TestFlight for beta testing
- Add backend API integration
- Implement real authentication

## 📊 File Structure

```
Consigliary/
├── ConsigliaryApp.swift          # App entry point
├── ContentView.swift              # Main router
├── OnboardingView.swift           # 4-step onboarding
├── DashboardView.swift            # Tab view container
├── SummaryView.swift              # Summary tab
├── ActivityView.swift             # Live activity feed
├── MonetizationView.swift         # Revenue tracking
├── AccountView.swift              # Account settings
├── SplitSheetView.swift           # Split sheet creator
└── ContractAnalyzerView.swift     # AI contract analysis
```

## ✅ Checklist

- [ ] Xcode project created
- [ ] All 10 Swift files added
- [ ] App builds successfully
- [ ] Tested in simulator
- [ ] Tested on real iPhone
- [ ] Screenshots taken
- [ ] Ready for investor demos

---

**Built for independent artists by HTD Studio**
