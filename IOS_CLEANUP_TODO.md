# iOS Cleanup - Remaining Build Issues

**Date**: December 17, 2025  
**Status**: Partial fixes applied, ~1-2 remaining errors

---

## ✅ Fixed Issues

1. **Duplicate Type Definitions**
   - Created `Models/` directory with shared models
   - Moved `Contributor` and `SplitSheet` to shared models
   - Removed duplicates from `AppData.swift` and `SplitSheetView.swift`

2. **Service Type Conformance**
   - Added `Combine` imports to all service files
   - Fixed `ObservableObject` conformance
   - Replaced `[String: Any]` with proper `Encodable` structs
   - Renamed conflicting `DeleteResponse` types

3. **Async/Await Issues**
   - Wrapped async calls in `Task {}` blocks in:
     - `VerificationView.swift`
     - `ContributorManagementView.swift`

4. **Model Property Mismatches**
   - Updated `SplitSheetPDFGenerator` to use `splitPercentage` instead of `percentage`
   - Fixed `track.title` access in PDF generator
   - Unwrapped optional `role` property

5. **View Model Separation**
   - Created `ContributorViewModel` for `SplitSheetView`
   - Separated UI models from API models

---

## ❌ Remaining Issues

### 1. TrackDetailView UUID Conversion
**File**: `TrackDetailView.swift:236`  
**Error**: `cannot convert value of type 'UUID' to expected argument type 'String'`

**Likely Cause**: View using local `Track` model with `UUID` id, but API expects `String` id.

**Fix**: Update `TrackDetailView` to use `TrackService.Track` or convert UUID to String.

### 2. Potential Additional Type Mismatches
May be 1-2 more similar issues in other view files.

---

## 📋 Cleanup Plan

**Estimated Time**: 30-60 minutes

1. **Fix TrackDetailView**
   - Check which Track model is being used
   - Update to use `TrackService.Track` or add UUID conversion

2. **Search for Remaining Errors**
   ```bash
   xcodebuild build 2>&1 | grep "error:"
   ```

3. **Final Build Verification**
   - Clean build directory
   - Build for simulator
   - Verify no errors

4. **Test Audio Upload**
   - Run app in simulator
   - Navigate to Add Track
   - Select audio file
   - Verify upload works end-to-end

---

## 🎯 Success Criteria

- ✅ App builds successfully
- ✅ No compilation errors
- ✅ Audio upload flow works in simulator
- ✅ Track creation with audio file succeeds

---

## 📝 Notes

**Why We Paused:**
- Audio upload backend is complete and tested ✅
- Audio upload iOS code is fully implemented ✅
- Only build errors blocking testing (not missing features)
- Backend work (Week 3 Day 3) can proceed independently

**When to Resume:**
- Schedule dedicated iOS cleanup session
- Or before comprehensive iOS testing
- Or before App Store submission prep

---

© 2025 HTDSTUDIO AB
