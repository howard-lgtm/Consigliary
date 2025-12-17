# iOS Build Issues - To Be Fixed

**Date**: December 16, 2025  
**Status**: Build errors blocking iOS app compilation

---

## Issue Summary

The iOS app has **duplicate type definitions** across multiple files causing Swift compilation errors. These are pre-existing structural issues not related to the audio upload feature.

## Specific Problems

### 1. Duplicate Type Definitions

**`Contributor` struct** defined in:
- `Services/ContributorService.swift`
- `ContributorManagementView.swift`
- `SplitSheetView.swift`
- `Services/TrackService.swift`

**`SplitSheet` struct** defined in:
- `Services/ContributorService.swift`
- `SplitSheetView.swift`

### 2. Codable Conformance Errors

Multiple response structs failing `Codable` conformance due to the duplicate type definitions:
- `ContributorResponse`
- `ContributorsResponse`
- `SplitSheetResponse`

### 3. ObservableObject Conformance

`ContributorService` not properly conforming to `ObservableObject` protocol (likely due to cascading errors from above).

---

## Root Cause

The codebase has types defined in multiple places:
1. Service files define request/response models
2. View files redefine the same models locally
3. Swift compiler can't resolve which definition to use

---

## Solution Required

### Option A: Centralized Models (Recommended)
Create a `Models/` directory with shared model files:
```
Consigliary/Models/
├── Contributor.swift
├── SplitSheet.swift
├── Track.swift
├── Verification.swift
└── ...
```

Then remove duplicate definitions from service and view files.

### Option B: Namespace Models
Keep models in service files but import them in views:
```swift
// In views, use:
import ContributorService

// Reference as:
ContributorService.Contributor
```

---

## Partial Fixes Applied

✅ Fixed `[String: Any]` dictionary issues in:
- `ContributorService.swift` - Created proper `Encodable` request structs
- `VerificationService.swift` - Created proper `Encodable` request structs

✅ Renamed conflicting types:
- `DeleteResponse` → `ContributorDeleteResponse`
- `DeleteResponse` → `VerificationDeleteResponse`

❌ Still need to resolve duplicate model definitions

---

## Impact

**Audio Upload Feature:**
- ✅ Backend: Fully working (tested with curl)
- ✅ iOS Code: Complete and implemented
- ❌ iOS Build: Cannot compile due to unrelated errors
- ⏳ iOS Testing: Blocked until build issues resolved

**Other Features:**
- All iOS features blocked from testing
- Backend development can continue unaffected

---

## Recommended Next Steps

1. **Create Models directory** with shared model definitions
2. **Move model structs** from service files to Models/
3. **Update imports** in all files using these models
4. **Remove duplicate definitions** from view files
5. **Test build** to verify all errors resolved
6. **Test audio upload** end-to-end in iOS app

**Estimated Time**: 30-60 minutes

---

## Workaround for Development

Continue backend development (Week 3 Day 3+) while iOS build issues remain. The audio upload backend is proven working and ready for iOS integration once build is fixed.

---

© 2025 HTDSTUDIO AB
