# Backend Requirements - Consigliary App

**Document Version**: 1.0  
**Date**: December 14, 2025  
**Status**: Pre-Development Planning

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Data Models](#data-models)
3. [API Endpoints](#api-endpoints)
4. [Authentication & Security](#authentication--security)
5. [Third-Party Integrations](#third-party-integrations)
6. [File Storage](#file-storage)
7. [Real-Time Features](#real-time-features)
8. [Priority Implementation Order](#priority-implementation-order)

---

## Overview

Consigliary is a music rights management and monitoring platform for artists. The backend needs to support:
- Track metadata management with industry-standard identifiers
- Platform monitoring (Spotify, Apple Music, SoundCloud, TikTok, Instagram, YouTube)
- Copyright and DRM documentation
- Revenue tracking and reporting
- Contract analysis and licensing
- Split sheet management

---

## Data Models

### 1. User Model

```json
{
  "id": "uuid",
  "email": "string",
  "name": "string",
  "artistName": "string",
  "profileImage": "url",
  "createdAt": "timestamp",
  "subscription": {
    "plan": "free|pro|enterprise",
    "status": "active|cancelled|expired",
    "expiresAt": "timestamp"
  },
  "preferences": {
    "notifications": "boolean",
    "autoMonitoring": "boolean"
  }
}
```

### 2. Track Model (Enhanced)

**Current iOS Fields:**
- `id`: UUID
- `title`: String
- `streams`: Int
- `revenue`: Double
- `contributors`: [Contributor]

**Required Backend Fields:**
```json
{
  "id": "uuid",
  "userId": "uuid",
  "title": "string",
  "artistName": "string",
  "duration": "string (MM:SS)",
  "releaseDate": "string (YYYY)",
  
  // Metadata
  "isrcCode": "string (12 chars)",
  "upcCode": "string (optional)",
  "copyrightOwner": "string",
  "copyrightYear": "string",
  "publisher": "string",
  "copyrightRegNumber": "string (optional)",
  "proAffiliation": "ASCAP|BMI|SESAC|GMR|Not Registered",
  
  // Platform Links
  "spotifyUrl": "url (optional)",
  "appleMusicUrl": "url (optional)",
  "soundcloudUrl": "url (optional)",
  "spotifyTrackId": "string (optional)",
  "appleMusicTrackId": "string (optional)",
  
  // DRM & Licensing
  "drmStatus": "Protected|Unprotected|Watermarked",
  "licenseType": "All Rights Reserved|Creative Commons|Public Domain|Custom License",
  "territory": "Worldwide|North America|Europe|Asia|Custom",
  
  // Master File
  "masterFileLocation": "Cloud Storage|Personal Archive|Studio Archive|Distribution Platform",
  "masterFileUrl": "url (optional)",
  "copyrightCertificateUrl": "url (optional)",
  
  // Analytics
  "streams": "integer",
  "revenue": "decimal",
  "lastSyncedAt": "timestamp",
  
  // Contributors
  "contributors": [
    {
      "name": "string",
      "role": "string",
      "splitPercentage": "decimal",
      "email": "string (optional)",
      "proAffiliation": "string (optional)"
    }
  ],
  
  // Metadata
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

### 3. Activity Model

```json
{
  "id": "uuid",
  "userId": "uuid",
  "trackId": "uuid",
  "platform": "TikTok|Instagram|YouTube|Facebook|Twitter",
  "contentUrl": "url",
  "contentType": "video|audio|post",
  "uploaderUsername": "string",
  "uploaderProfileUrl": "url",
  "detectedAt": "timestamp",
  "status": "new|reviewed|licensed|takedown_sent|resolved",
  "requiresManualReview": "boolean",
  "confidence": "decimal (0-1)",
  "thumbnail": "url",
  "views": "integer (optional)",
  "engagement": "integer (optional)"
}
```

### 4. Revenue Event Model

```json
{
  "id": "uuid",
  "userId": "uuid",
  "trackId": "uuid (optional)",
  "source": "streaming|syncLicense|performanceRights|mechanicalRights|licensing",
  "amount": "decimal",
  "currency": "USD|EUR|GBP",
  "date": "timestamp",
  "description": "string",
  "platform": "string (optional)",
  "paymentStatus": "pending|paid|processing",
  "metadata": "json (flexible)"
}
```

### 5. Contract Analysis Model

```json
{
  "id": "uuid",
  "userId": "uuid",
  "contractName": "string",
  "contractType": "string",
  "uploadedAt": "timestamp",
  "fileUrl": "url",
  "status": "analyzing|completed|failed",
  "fairnessScore": "decimal (1-10)",
  "redFlags": [
    {
      "title": "string",
      "description": "string",
      "severity": "high|medium|low"
    }
  ],
  "recommendations": ["string"],
  "plainEnglishSummary": "string"
}
```

### 6. License Agreement Model

```json
{
  "id": "uuid",
  "userId": "uuid",
  "trackId": "uuid",
  "activityId": "uuid (optional)",
  "licenseeEmail": "string",
  "licenseeName": "string",
  "licenseFee": "decimal",
  "currency": "USD|EUR|GBP",
  "territory": "string",
  "duration": "string",
  "exclusivity": "exclusive|non-exclusive",
  "generatedAt": "timestamp",
  "signedAt": "timestamp (optional)",
  "pdfUrl": "url",
  "status": "draft|sent|signed|expired"
}
```

### 7. Split Sheet Model

```json
{
  "id": "uuid",
  "userId": "uuid",
  "trackId": "uuid",
  "trackTitle": "string",
  "contributors": [
    {
      "name": "string",
      "role": "string",
      "splitPercentage": "decimal",
      "email": "string",
      "proAffiliation": "string",
      "signedAt": "timestamp (optional)"
    }
  ],
  "createdAt": "timestamp",
  "pdfUrl": "url",
  "status": "draft|pending_signatures|completed"
}
```

---

## API Endpoints

### Authentication

```
POST   /api/auth/register
POST   /api/auth/login
POST   /api/auth/logout
POST   /api/auth/refresh
POST   /api/auth/forgot-password
POST   /api/auth/reset-password
GET    /api/auth/me
```

### Tracks

```
GET    /api/tracks                    # List user's tracks
POST   /api/tracks                    # Create new track
GET    /api/tracks/:id                # Get track details
PUT    /api/tracks/:id                # Update track
DELETE /api/tracks/:id                # Delete track
POST   /api/tracks/import             # Import from platform URL
GET    /api/tracks/:id/analytics      # Get track analytics
POST   /api/tracks/:id/sync           # Sync platform data
```

**POST /api/tracks/import** - Priority Endpoint
```json
Request:
{
  "platformUrl": "https://open.spotify.com/track/abc123"
}

Response:
{
  "success": true,
  "track": {
    "title": "Midnight Dreams",
    "artistName": "Artist Name",
    "duration": "3:45",
    "releaseDate": "2024",
    "isrcCode": "USRC12345678",
    "spotifyUrl": "https://open.spotify.com/track/abc123",
    "spotifyTrackId": "abc123",
    "albumArt": "url",
    "previewUrl": "url"
  }
}
```

### Activities (Monitoring)

```
GET    /api/activities                # List detected activities
GET    /api/activities/:id            # Get activity details
POST   /api/activities/:id/takedown   # Send DMCA takedown
POST   /api/activities/:id/license    # Generate license agreement
PUT    /api/activities/:id/review     # Mark as reviewed
DELETE /api/activities/:id            # Dismiss activity
```

### Revenue

```
GET    /api/revenue                   # List revenue events
GET    /api/revenue/summary           # Get revenue summary
GET    /api/revenue/export            # Export revenue data (CSV)
POST   /api/revenue                   # Create manual revenue entry
```

### Contracts

```
GET    /api/contracts                 # List analyzed contracts
POST   /api/contracts/analyze         # Upload and analyze contract
GET    /api/contracts/:id             # Get analysis results
DELETE /api/contracts/:id             # Delete contract
```

### Licenses

```
GET    /api/licenses                  # List generated licenses
POST   /api/licenses                  # Generate new license
GET    /api/licenses/:id              # Get license details
GET    /api/licenses/:id/pdf          # Download PDF
POST   /api/licenses/:id/send         # Send to licensee
```

### Split Sheets

```
GET    /api/split-sheets              # List split sheets
POST   /api/split-sheets              # Create split sheet
GET    /api/split-sheets/:id          # Get split sheet details
GET    /api/split-sheets/:id/pdf      # Download PDF
POST   /api/split-sheets/:id/send     # Send to contributors
```

### Platform Integration

```
POST   /api/platforms/spotify/auth    # OAuth with Spotify
POST   /api/platforms/apple/auth      # OAuth with Apple Music
GET    /api/platforms/spotify/tracks  # Fetch user's Spotify tracks
GET    /api/platforms/apple/tracks    # Fetch user's Apple Music tracks
```

### File Upload

```
POST   /api/files/upload              # Upload file (contracts, certificates)
DELETE /api/files/:id                 # Delete file
```

---

## Authentication & Security

### Authentication Method
- **JWT (JSON Web Tokens)** for stateless authentication
- Access token (short-lived, 15 min)
- Refresh token (long-lived, 30 days)

### Security Requirements
1. **HTTPS only** - All API calls must use TLS/SSL
2. **Rate limiting** - Prevent abuse (100 requests/min per user)
3. **Input validation** - Sanitize all user inputs
4. **CORS** - Whitelist iOS app bundle ID
5. **API versioning** - `/api/v1/...` for future compatibility

### Sensitive Data
- Store passwords with **bcrypt** (cost factor 12+)
- Encrypt file URLs with signed URLs (expiring)
- Never log sensitive data (passwords, tokens)

---

## Third-Party Integrations

### 1. Spotify API (Priority)
**Purpose**: Import track metadata, fetch analytics

**Required Scopes**:
- `user-library-read` - Access user's saved tracks
- `user-read-recently-played` - Track listening history

**Endpoints Needed**:
- `GET /v1/tracks/{id}` - Get track details
- `GET /v1/me/tracks` - Get user's saved tracks
- `GET /v1/audio-features/{id}` - Get audio analysis

**Rate Limits**: 180 requests per minute

### 2. Apple Music API
**Purpose**: Import track metadata

**Authentication**: Developer Token + User Token

**Endpoints Needed**:
- `GET /v1/catalog/{storefront}/songs/{id}` - Get song details
- `GET /v1/me/library/songs` - Get user's library

### 3. SoundCloud API
**Purpose**: Import track metadata

**Authentication**: OAuth 2.0

**Endpoints Needed**:
- `GET /tracks/{id}` - Get track details
- `GET /me/tracks` - Get user's tracks

### 4. Content ID / Monitoring Services
**Options**:
- **Audible Magic** - Audio fingerprinting
- **ACRCloud** - Audio recognition
- **YouTube Content ID** - YouTube monitoring

**Purpose**: Detect unauthorized usage across platforms

### 5. Payment Processing
**Options**:
- **Stripe** - Handle license payments
- **PayPal** - Alternative payment method

### 6. File Storage
**Options**:
- **AWS S3** - Scalable file storage
- **Cloudflare R2** - Cost-effective alternative
- **Google Cloud Storage** - Alternative

**Use Cases**:
- Contract PDFs
- Copyright certificates
- Generated license agreements
- Split sheet PDFs

### 7. Email Service
**Options**:
- **SendGrid** - Transactional emails
- **AWS SES** - Cost-effective alternative

**Use Cases**:
- License agreement delivery
- Split sheet distribution
- Activity alerts
- Payment notifications

---

## File Storage

### Storage Structure
```
/users/{userId}/
  /tracks/{trackId}/
    /certificates/
      - copyright_cert.pdf
    /licenses/
      - license_{timestamp}.pdf
  /contracts/
    - contract_{id}.pdf
  /split-sheets/
    - split_sheet_{id}.pdf
```

### File Upload Requirements
- **Max file size**: 10MB for contracts, 5MB for certificates
- **Allowed formats**: PDF, DOC, DOCX for contracts
- **Virus scanning**: Required before storage
- **Signed URLs**: Expire after 1 hour for downloads

---

## Real-Time Features

### WebSocket Connections (Optional Phase 2)
**Use Cases**:
- Live activity monitoring updates
- Real-time revenue notifications
- Contract analysis progress

**Technology**: Socket.io or native WebSockets

---

## Priority Implementation Order

### Phase 1: Core Infrastructure (Week 1)
1. ✅ User authentication (register, login, JWT)
2. ✅ Database setup (PostgreSQL or MongoDB)
3. ✅ File storage setup (S3 or equivalent)
4. ✅ Basic API structure and error handling

### Phase 2: Track Management (Week 1-2)
1. ✅ Track CRUD operations
2. ✅ **Spotify API integration** (import track metadata)
3. ✅ Apple Music API integration
4. ✅ SoundCloud API integration
5. ✅ File upload for copyright certificates

### Phase 3: Monitoring & Activities (Week 2-3)
1. ✅ Activity detection (mock data initially)
2. ✅ DMCA takedown workflow
3. ✅ License generation
4. ✅ Integration with monitoring service (Audible Magic/ACRCloud)

### Phase 4: Revenue & Analytics (Week 3)
1. ✅ Revenue tracking
2. ✅ Analytics dashboard data
3. ✅ Export functionality

### Phase 5: Contracts & Split Sheets (Week 4)
1. ✅ Contract upload and storage
2. ✅ AI contract analysis (OpenAI/Claude API)
3. ✅ Split sheet generation
4. ✅ PDF generation service

### Phase 6: Polish & Optimization (Week 4+)
1. ✅ Rate limiting
2. ✅ Caching (Redis)
3. ✅ Performance optimization
4. ✅ Monitoring and logging

---

## Database Schema Recommendations

### PostgreSQL (Recommended)
**Pros**:
- ACID compliance
- Strong relational data support
- Excellent for financial data (revenue)
- JSON support for flexible fields

**Tables**:
- `users`
- `tracks`
- `activities`
- `revenue_events`
- `contracts`
- `licenses`
- `split_sheets`
- `contributors`

### MongoDB (Alternative)
**Pros**:
- Flexible schema
- Good for rapidly changing data models
- Easy horizontal scaling

**Collections**:
- Same as PostgreSQL tables

---

## Environment Variables

```bash
# Database
DATABASE_URL=postgresql://user:pass@host:5432/consigliary
REDIS_URL=redis://localhost:6379

# JWT
JWT_SECRET=your-secret-key
JWT_EXPIRES_IN=15m
REFRESH_TOKEN_EXPIRES_IN=30d

# File Storage
AWS_ACCESS_KEY_ID=your-key
AWS_SECRET_ACCESS_KEY=your-secret
AWS_S3_BUCKET=consigliary-files
AWS_REGION=us-east-1

# Spotify
SPOTIFY_CLIENT_ID=your-client-id
SPOTIFY_CLIENT_SECRET=your-secret

# Apple Music
APPLE_MUSIC_TEAM_ID=your-team-id
APPLE_MUSIC_KEY_ID=your-key-id
APPLE_MUSIC_PRIVATE_KEY=your-private-key

# SoundCloud
SOUNDCLOUD_CLIENT_ID=your-client-id
SOUNDCLOUD_CLIENT_SECRET=your-secret

# Email
SENDGRID_API_KEY=your-api-key
FROM_EMAIL=noreply@consigliary.com

# AI Services
OPENAI_API_KEY=your-api-key

# Monitoring
AUDIBLE_MAGIC_API_KEY=your-api-key
```

---

## API Response Format

### Success Response
```json
{
  "success": true,
  "data": { /* response data */ },
  "message": "Optional success message"
}
```

### Error Response
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Human-readable error message",
    "details": { /* optional field-specific errors */ }
  }
}
```

### Error Codes
- `VALIDATION_ERROR` - Invalid input data
- `UNAUTHORIZED` - Authentication required
- `FORBIDDEN` - Insufficient permissions
- `NOT_FOUND` - Resource not found
- `RATE_LIMIT_EXCEEDED` - Too many requests
- `INTERNAL_ERROR` - Server error

---

## Testing Requirements

### Unit Tests
- All API endpoints
- Data validation
- Business logic

### Integration Tests
- Third-party API integrations
- File upload/download
- Payment processing

### Load Testing
- 1000 concurrent users
- Response time < 200ms for read operations
- Response time < 500ms for write operations

---

## Monitoring & Logging

### Logging Service
**Options**: Datadog, New Relic, Sentry

**Log Levels**:
- `ERROR` - Critical errors requiring immediate attention
- `WARN` - Potential issues
- `INFO` - Important events (user registration, track creation)
- `DEBUG` - Detailed debugging information

### Metrics to Track
- API response times
- Error rates
- Active users
- Track imports per day
- Revenue processed
- File storage usage

---

## Deployment

### Recommended Stack
- **Backend**: Node.js (Express) or Python (FastAPI)
- **Database**: PostgreSQL on AWS RDS
- **Cache**: Redis on AWS ElastiCache
- **File Storage**: AWS S3
- **Hosting**: AWS EC2, Heroku, or Railway
- **CDN**: CloudFlare

### CI/CD
- GitHub Actions for automated testing
- Automatic deployment on merge to `main`
- Staging environment for testing

---

## Notes for iOS Team

### API Base URL
- **Development**: `http://localhost:3000/api/v1`
- **Staging**: `https://staging-api.consigliary.com/api/v1`
- **Production**: `https://api.consigliary.com/api/v1`

### Headers Required
```
Authorization: Bearer {access_token}
Content-Type: application/json
X-App-Version: 1.0.0
X-Platform: iOS
```

### Error Handling
- Always check `success` field in response
- Display `error.message` to users
- Log `error.code` and `error.details` for debugging

### Offline Support
- Cache track data locally
- Queue API requests when offline
- Sync when connection restored

---

## Questions for Backend Team

1. **Database preference**: PostgreSQL or MongoDB?
2. **Hosting preference**: AWS, Heroku, Railway, or other?
3. **AI service for contract analysis**: OpenAI GPT-4 or Claude?
4. **Monitoring service preference**: Audible Magic, ACRCloud, or custom?
5. **Timeline**: Can Phase 1-2 be completed in Week 1?

---

**End of Document**
