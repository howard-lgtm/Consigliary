# iOS-Backend Integration Checklist

**Project**: Consigliary  
**Date**: December 14, 2025  
**Status**: Pre-Integration Planning

---

## 📋 Overview

This document outlines the integration points between the iOS app and backend API, including code changes needed, testing procedures, and rollout strategy.

---

## 🔗 Integration Points

### 1. Authentication Flow

**Current State**: Mock authentication in `AppState`  
**Backend Endpoint**: `/api/auth/*`

**iOS Changes Needed**:

```swift
// Create new file: NetworkManager.swift
class NetworkManager: ObservableObject {
    static let shared = NetworkManager()
    private let baseURL = "https://api.consigliary.com/api/v1"
    
    @Published var accessToken: String?
    @Published var refreshToken: String?
    
    func login(email: String, password: String) async throws -> User {
        // POST /api/auth/login
    }
    
    func register(email: String, password: String, name: String) async throws -> User {
        // POST /api/auth/register
    }
    
    func refreshAccessToken() async throws {
        // POST /api/auth/refresh
    }
    
    func logout() async throws {
        // POST /api/auth/logout
    }
}
```

**Files to Modify**:
- [ ] Create `NetworkManager.swift`
- [ ] Create `AuthService.swift`
- [ ] Update `AppState.swift` to use real authentication
- [ ] Add Keychain storage for tokens (use `KeychainAccess` library)

**Testing**:
- [ ] Test login with valid credentials
- [ ] Test login with invalid credentials
- [ ] Test token refresh on 401 errors
- [ ] Test logout clears tokens

---

### 2. Track Management

**Current State**: Mock data in `AppData.swift`  
**Backend Endpoints**: `/api/tracks/*`

**iOS Changes Needed**:

```swift
// Create new file: TrackService.swift
class TrackService {
    static let shared = TrackService()
    
    func fetchTracks() async throws -> [Track] {
        // GET /api/tracks
    }
    
    func createTrack(_ track: Track) async throws -> Track {
        // POST /api/tracks
    }
    
    func updateTrack(_ track: Track) async throws -> Track {
        // PUT /api/tracks/:id
    }
    
    func deleteTrack(id: UUID) async throws {
        // DELETE /api/tracks/:id
    }
    
    func importTrackFromURL(_ url: String) async throws -> Track {
        // POST /api/tracks/import
        // Body: { "platformUrl": url }
    }
    
    func syncTrackAnalytics(id: UUID) async throws -> Track {
        // POST /api/tracks/:id/sync
    }
}
```

**Files to Modify**:
- [ ] Create `TrackService.swift`
- [ ] Update `Track` model to match backend schema
- [ ] Update `AppData.swift` to fetch from API instead of mock data
- [ ] Update `AddTrackView.swift` to call `TrackService.createTrack()`
- [ ] Update `importFromURL()` in `AddTrackView.swift` to call API

**Track Model Updates**:
```swift
struct Track: Identifiable, Codable {
    let id: UUID
    let userId: UUID
    var title: String
    var artistName: String
    var duration: String
    var releaseDate: String
    
    // Metadata
    var isrcCode: String?
    var upcCode: String?
    var copyrightOwner: String
    var copyrightYear: String
    var publisher: String
    var copyrightRegNumber: String?
    var proAffiliation: String
    
    // Platform Links
    var spotifyUrl: String?
    var appleMusicUrl: String?
    var soundcloudUrl: String?
    var spotifyTrackId: String?
    var appleMusicTrackId: String?
    
    // DRM & Licensing
    var drmStatus: String
    var licenseType: String
    var territory: String
    
    // Master File
    var masterFileLocation: String
    var masterFileUrl: String?
    var copyrightCertificateUrl: String?
    
    // Analytics
    var streams: Int
    var revenue: Double
    var lastSyncedAt: Date?
    
    // Contributors
    var contributors: [Contributor]
    
    // Metadata
    var createdAt: Date
    var updatedAt: Date
}
```

**Testing**:
- [ ] Test fetching tracks list
- [ ] Test creating new track
- [ ] Test updating track
- [ ] Test deleting track
- [ ] Test Quick Import with Spotify URL
- [ ] Test Quick Import with Apple Music URL
- [ ] Test Quick Import with SoundCloud URL
- [ ] Test Quick Import error handling

---

### 3. Activity Monitoring

**Current State**: Mock data in `AppData.swift`  
**Backend Endpoints**: `/api/activities/*`

**iOS Changes Needed**:

```swift
// Create new file: ActivityService.swift
class ActivityService {
    static let shared = ActivityService()
    
    func fetchActivities() async throws -> [Activity] {
        // GET /api/activities
    }
    
    func sendTakedown(activityId: UUID) async throws {
        // POST /api/activities/:id/takedown
    }
    
    func generateLicense(activityId: UUID, amount: Double) async throws -> License {
        // POST /api/activities/:id/license
    }
    
    func markAsReviewed(activityId: UUID) async throws {
        // PUT /api/activities/:id/review
    }
    
    func dismissActivity(activityId: UUID) async throws {
        // DELETE /api/activities/:id
    }
}
```

**Files to Modify**:
- [ ] Create `ActivityService.swift`
- [ ] Update `Activity` model to match backend schema
- [ ] Update `ActivityView.swift` to fetch from API
- [ ] Update `handleTakedown()` in `AppData.swift` to call API
- [ ] Update `generateLicensePDF()` to call API

**Testing**:
- [ ] Test fetching activities
- [ ] Test sending takedown notice
- [ ] Test generating license
- [ ] Test dismissing activity

---

### 4. Revenue Tracking

**Current State**: Mock data in `AppData.swift`  
**Backend Endpoints**: `/api/revenue/*`

**iOS Changes Needed**:

```swift
// Create new file: RevenueService.swift
class RevenueService {
    static let shared = RevenueService()
    
    func fetchRevenueEvents() async throws -> [RevenueEvent] {
        // GET /api/revenue
    }
    
    func fetchRevenueSummary() async throws -> RevenueSummary {
        // GET /api/revenue/summary
    }
    
    func createRevenueEvent(_ event: RevenueEvent) async throws -> RevenueEvent {
        // POST /api/revenue
    }
    
    func exportRevenue(format: String) async throws -> URL {
        // GET /api/revenue/export?format=csv
    }
}
```

**Files to Modify**:
- [ ] Create `RevenueService.swift`
- [ ] Update `MonetizationView.swift` to fetch from API
- [ ] Update `completeLicense()` in `AppData.swift` to call API

**Testing**:
- [ ] Test fetching revenue events
- [ ] Test revenue summary calculations
- [ ] Test creating manual revenue entry
- [ ] Test CSV export

---

### 5. Contract Analysis

**Current State**: Demo scenarios in `AppData.swift`  
**Backend Endpoints**: `/api/contracts/*`

**iOS Changes Needed**:

```swift
// Create new file: ContractService.swift
class ContractService {
    static let shared = ContractService()
    
    func uploadContract(fileData: Data, fileName: String) async throws -> ContractAnalysis {
        // POST /api/contracts/analyze
        // Multipart form data
    }
    
    func fetchAnalyses() async throws -> [ContractAnalysis] {
        // GET /api/contracts
    }
    
    func fetchAnalysis(id: UUID) async throws -> ContractAnalysis {
        // GET /api/contracts/:id
    }
    
    func deleteAnalysis(id: UUID) async throws {
        // DELETE /api/contracts/:id
    }
}
```

**Files to Modify**:
- [ ] Create `ContractService.swift`
- [ ] Update `ContractAnalyzerView.swift` to upload to API
- [ ] Add polling or WebSocket for analysis progress
- [ ] Update `ContractAnalysis` model to match backend

**Testing**:
- [ ] Test uploading PDF contract
- [ ] Test uploading DOC/DOCX contract
- [ ] Test analysis progress updates
- [ ] Test viewing completed analysis

---

### 6. File Upload

**Current State**: Local file picker only  
**Backend Endpoints**: `/api/files/upload`

**iOS Changes Needed**:

```swift
// Create new file: FileService.swift
class FileService {
    static let shared = FileService()
    
    func uploadFile(data: Data, fileName: String, fileType: String) async throws -> FileUploadResponse {
        // POST /api/files/upload
        // Returns: { "fileUrl": "https://...", "fileId": "uuid" }
    }
    
    func deleteFile(id: UUID) async throws {
        // DELETE /api/files/:id
    }
    
    func getSignedURL(fileId: UUID) async throws -> URL {
        // GET /api/files/:id/signed-url
        // Returns temporary download URL
    }
}

struct FileUploadResponse: Codable {
    let fileUrl: String
    let fileId: UUID
}
```

**Files to Modify**:
- [ ] Create `FileService.swift`
- [ ] Update `AddTrackView.swift` to upload copyright certificates
- [ ] Update `ContractAnalyzerView.swift` to upload contracts
- [ ] Add upload progress indicators

**Testing**:
- [ ] Test uploading PDF
- [ ] Test uploading images
- [ ] Test file size limits (10MB)
- [ ] Test upload progress
- [ ] Test signed URL download

---

### 7. License Generation

**Current State**: Local PDF generation  
**Backend Endpoints**: `/api/licenses/*`

**iOS Changes Needed**:

```swift
// Create new file: LicenseService.swift
class LicenseService {
    static let shared = LicenseService()
    
    func generateLicense(data: LicenseAgreementData) async throws -> License {
        // POST /api/licenses
    }
    
    func fetchLicenses() async throws -> [License] {
        // GET /api/licenses
    }
    
    func downloadLicensePDF(id: UUID) async throws -> URL {
        // GET /api/licenses/:id/pdf
    }
    
    func sendLicense(id: UUID, email: String) async throws {
        // POST /api/licenses/:id/send
    }
}
```

**Files to Modify**:
- [ ] Create `LicenseService.swift`
- [ ] Update `LicenseAgreementView.swift` to use API
- [ ] Keep local PDF generation as fallback
- [ ] Add email sending functionality

**Testing**:
- [ ] Test generating license
- [ ] Test downloading PDF
- [ ] Test sending via email

---

### 8. Split Sheets

**Current State**: Local PDF generation  
**Backend Endpoints**: `/api/split-sheets/*`

**iOS Changes Needed**:

```swift
// Create new file: SplitSheetService.swift
class SplitSheetService {
    static let shared = SplitSheetService()
    
    func createSplitSheet(data: SplitSheet) async throws -> SplitSheet {
        // POST /api/split-sheets
    }
    
    func fetchSplitSheets() async throws -> [SplitSheet] {
        // GET /api/split-sheets
    }
    
    func downloadPDF(id: UUID) async throws -> URL {
        // GET /api/split-sheets/:id/pdf
    }
    
    func sendToContributors(id: UUID) async throws {
        // POST /api/split-sheets/:id/send
    }
}
```

**Files to Modify**:
- [ ] Create `SplitSheetService.swift`
- [ ] Update `SplitSheetView.swift` to use API
- [ ] Keep local PDF generation as fallback

**Testing**:
- [ ] Test creating split sheet
- [ ] Test downloading PDF
- [ ] Test sending to contributors

---

## 🔐 Security Implementation

### Keychain Storage

```swift
// Add KeychainAccess via SPM
// https://github.com/kishikawakatsumi/KeychainAccess

import KeychainAccess

class KeychainManager {
    static let shared = KeychainManager()
    private let keychain = Keychain(service: "com.htdstudio.Consigliary")
    
    func saveAccessToken(_ token: String) {
        keychain["accessToken"] = token
    }
    
    func getAccessToken() -> String? {
        return keychain["accessToken"]
    }
    
    func saveRefreshToken(_ token: String) {
        keychain["refreshToken"] = token
    }
    
    func getRefreshToken() -> String? {
        return keychain["refreshToken"]
    }
    
    func clearTokens() {
        try? keychain.removeAll()
    }
}
```

### Network Request Headers

```swift
extension URLRequest {
    mutating func addAuthHeaders() {
        if let token = KeychainManager.shared.getAccessToken() {
            setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        setValue("application/json", forHTTPHeaderField: "Content-Type")
        setValue("1.0.0", forHTTPHeaderField: "X-App-Version")
        setValue("iOS", forHTTPHeaderField: "X-Platform")
    }
}
```

---

## 📱 Offline Support

### Core Data Setup

```swift
// Create CoreData model for offline caching
// Entities:
// - CachedTrack
// - CachedActivity
// - CachedRevenueEvent
// - PendingRequest (for queued API calls)

class OfflineManager {
    static let shared = OfflineManager()
    
    func cacheTracks(_ tracks: [Track]) {
        // Save to Core Data
    }
    
    func getCachedTracks() -> [Track] {
        // Fetch from Core Data
    }
    
    func queueRequest(endpoint: String, method: String, body: Data?) {
        // Save to PendingRequest entity
    }
    
    func syncPendingRequests() async {
        // Execute queued requests when online
    }
}
```

### Network Reachability

```swift
// Add Network framework
import Network

class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()
    private let monitor = NWPathMonitor()
    
    @Published var isConnected = true
    
    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: DispatchQueue.global())
    }
}
```

---

## 🧪 Testing Strategy

### Unit Tests

```swift
// Create test files:
// - NetworkManagerTests.swift
// - TrackServiceTests.swift
// - ActivityServiceTests.swift
// - AuthServiceTests.swift

class TrackServiceTests: XCTestCase {
    func testFetchTracks() async throws {
        // Mock API response
        // Test parsing
        // Test error handling
    }
    
    func testImportFromSpotifyURL() async throws {
        // Test valid URL
        // Test invalid URL
        // Test network error
    }
}
```

### Integration Tests

```swift
// Test full flows:
// - Login → Fetch Tracks → Display
// - Create Track → Upload Certificate → Save
// - Quick Import → Auto-fill → Save
```

---

## 📦 Dependencies to Add

### Swift Package Manager

Add these packages to Xcode:

1. **KeychainAccess** - Secure token storage
   - URL: `https://github.com/kishikawakatsumi/KeychainAccess`

2. **Alamofire** (Optional) - Simplified networking
   - URL: `https://github.com/Alamofire/Alamofire`
   - Alternative: Use native URLSession

3. **SwiftyJSON** (Optional) - JSON parsing
   - URL: `https://github.com/SwiftyJSON/SwiftyJSON`
   - Alternative: Use native Codable

---

## 🚀 Rollout Strategy

### Phase 1: Authentication (Day 1-2)
- [ ] Implement NetworkManager
- [ ] Implement AuthService
- [ ] Add Keychain storage
- [ ] Update login/register flows
- [ ] Test authentication

### Phase 2: Track Management (Day 3-5)
- [ ] Implement TrackService
- [ ] Update Track model
- [ ] Implement Quick Import API call
- [ ] Add offline caching
- [ ] Test all track operations

### Phase 3: Activities & Revenue (Day 6-7)
- [ ] Implement ActivityService
- [ ] Implement RevenueService
- [ ] Update views to use APIs
- [ ] Test monitoring flows

### Phase 4: Files & Documents (Day 8-9)
- [ ] Implement FileService
- [ ] Add file upload progress
- [ ] Implement ContractService
- [ ] Test file operations

### Phase 5: Licenses & Split Sheets (Day 10)
- [ ] Implement LicenseService
- [ ] Implement SplitSheetService
- [ ] Test PDF generation and sending

### Phase 6: Polish & Testing (Day 11-12)
- [ ] Add loading states
- [ ] Add error handling
- [ ] Write unit tests
- [ ] Write integration tests
- [ ] Performance optimization

---

## 🐛 Error Handling

### Error Types

```swift
enum APIError: Error, LocalizedError {
    case unauthorized
    case forbidden
    case notFound
    case validationError(details: [String: String])
    case rateLimitExceeded
    case serverError
    case networkError(Error)
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .unauthorized:
            return "Please log in again"
        case .forbidden:
            return "You don't have permission to perform this action"
        case .notFound:
            return "Resource not found"
        case .validationError(let details):
            return details.values.first ?? "Invalid input"
        case .rateLimitExceeded:
            return "Too many requests. Please try again later"
        case .serverError:
            return "Server error. Please try again"
        case .networkError:
            return "Network error. Please check your connection"
        case .decodingError:
            return "Failed to process response"
        }
    }
}
```

### Error Display

```swift
// Add to views:
@State private var errorMessage: String?
@State private var showingError = false

.alert("Error", isPresented: $showingError) {
    Button("OK") {}
} message: {
    Text(errorMessage ?? "An error occurred")
}
```

---

## 📊 Analytics & Monitoring

### Track These Events

```swift
// Add analytics service (Firebase, Mixpanel, etc.)

enum AnalyticsEvent {
    case userLoggedIn
    case trackCreated
    case trackImported(platform: String)
    case activityDetected
    case takedownSent
    case licenseGenerated
    case contractAnalyzed
    case apiError(endpoint: String, error: String)
}
```

---

## ✅ Pre-Launch Checklist

### Before Connecting to Production API

- [ ] All mock data replaced with API calls
- [ ] Authentication flow tested
- [ ] Token refresh implemented
- [ ] Offline support working
- [ ] Error handling complete
- [ ] Loading states added
- [ ] Unit tests passing
- [ ] Integration tests passing
- [ ] API base URL configurable (dev/staging/prod)
- [ ] Logging implemented
- [ ] Analytics integrated

### Environment Configuration

```swift
// Create Config.swift
enum Environment {
    case development
    case staging
    case production
    
    static var current: Environment {
        #if DEBUG
        return .development
        #else
        return .production
        #endif
    }
    
    var apiBaseURL: String {
        switch self {
        case .development:
            return "http://localhost:3000/api/v1"
        case .staging:
            return "https://staging-api.consigliary.com/api/v1"
        case .production:
            return "https://api.consigliary.com/api/v1"
        }
    }
}
```

---

## 📝 API Response Examples

### Success Response
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "title": "Midnight Dreams",
    ...
  }
}
```

### Error Response
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid track data",
    "details": {
      "title": "Title is required",
      "isrcCode": "Invalid ISRC format"
    }
  }
}
```

---

## 🔄 Migration Plan

### From Mock Data to Real API

1. **Keep mock data as fallback** during development
2. **Add feature flags** to toggle between mock and real API
3. **Gradual rollout** - enable API for beta testers first
4. **Monitor errors** and rollback if needed

```swift
class FeatureFlags {
    static var useRealAPI: Bool {
        UserDefaults.standard.bool(forKey: "useRealAPI")
    }
}

// In services:
func fetchTracks() async throws -> [Track] {
    if FeatureFlags.useRealAPI {
        return try await TrackService.shared.fetchTracks()
    } else {
        return Track.mockData
    }
}
```

---

**End of Integration Checklist**
