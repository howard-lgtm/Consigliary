# Consigliary Backend API

**Version**: 1.0.0 (MVP - Week 1)  
**Framework**: Node.js + Express  
**Database**: PostgreSQL

---

## 🚀 Quick Start

### Prerequisites
- Node.js 18+ installed
- PostgreSQL 14+ installed (or Railway.app account)
- ACRCloud account (for Week 2+)
- Stripe account (for Week 4+)

### Installation

```bash
# 1. Install dependencies
cd backend
npm install

# 2. Set up environment variables
cp .env.example .env
# Edit .env with your actual credentials

# 3. Set up database
# Option A: Local PostgreSQL
createdb consigliary
psql consigliary < database/schema.sql

# Option B: Railway.app (recommended)
# - Create new project on railway.app
# - Add PostgreSQL service
# - Copy DATABASE_URL to .env
# - Run schema.sql in Railway dashboard

# 4. Start development server
npm run dev
```

Server will start on `http://localhost:3000`

---

## 📋 Week 1 Status

### ✅ Completed
- [x] Project structure
- [x] Database schema (all tables)
- [x] User authentication (JWT)
- [x] Auth endpoints (register, login, refresh, logout)
- [x] Track CRUD endpoints (list, create, update, delete)
- [x] Middleware (auth, error handling)
- [x] CORS configuration

### 🔄 In Progress
- [ ] Deploy to Railway.app
- [ ] Test all endpoints
- [ ] iOS integration

### ⏳ Coming Next (Week 2)
- [ ] ACRCloud integration
- [ ] Audio file upload to S3
- [ ] Track fingerprinting

---

## 🔗 API Endpoints

### Authentication

#### POST /api/v1/auth/register
Register new user

**Request:**
```json
{
  "email": "artist@example.com",
  "password": "securepassword123",
  "name": "John Doe",
  "artistName": "DJ John"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "uuid",
      "email": "artist@example.com",
      "name": "John Doe",
      "artistName": "DJ John",
      "subscriptionPlan": "free"
    },
    "accessToken": "jwt-token",
    "refreshToken": "refresh-token"
  }
}
```

#### POST /api/v1/auth/login
Login existing user

**Request:**
```json
{
  "email": "artist@example.com",
  "password": "securepassword123"
}
```

**Response:** Same as register

#### POST /api/v1/auth/refresh
Refresh access token

**Request:**
```json
{
  "refreshToken": "refresh-token"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "accessToken": "new-jwt-token"
  }
}
```

#### POST /api/v1/auth/logout
Logout user

**Headers:** `Authorization: Bearer {accessToken}`

**Request:**
```json
{
  "refreshToken": "refresh-token"
}
```

#### GET /api/v1/auth/me
Get current user

**Headers:** `Authorization: Bearer {accessToken}`

**Response:**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "uuid",
      "email": "artist@example.com",
      "name": "John Doe",
      "artistName": "DJ John",
      "subscription": {
        "plan": "free",
        "status": "active"
      }
    }
  }
}
```

---

### Tracks

**All track endpoints require authentication header:**
```
Authorization: Bearer {accessToken}
```

#### GET /api/v1/tracks
List user's tracks

**Response:**
```json
{
  "success": true,
  "data": {
    "tracks": [
      {
        "id": "uuid",
        "title": "Midnight Dreams",
        "artist_name": "DJ John",
        "duration": "3:45",
        "isrc_code": "USRC12345678",
        "streams": 125000,
        "revenue": 450.00,
        "created_at": "2025-12-15T10:00:00Z"
      }
    ]
  }
}
```

#### GET /api/v1/tracks/:id
Get track details

**Response:**
```json
{
  "success": true,
  "data": {
    "track": {
      "id": "uuid",
      "title": "Midnight Dreams",
      "artist_name": "DJ John",
      "duration": "3:45",
      "release_date": "2024",
      "isrc_code": "USRC12345678",
      "copyright_owner": "John Doe",
      "pro_affiliation": "ASCAP",
      "spotify_url": "https://open.spotify.com/track/...",
      "contributors": [
        {
          "name": "Jane Producer",
          "role": "Producer",
          "split_percentage": 20.00
        }
      ]
    }
  }
}
```

#### POST /api/v1/tracks
Create new track

**Request:**
```json
{
  "title": "Midnight Dreams",
  "artistName": "DJ John",
  "duration": "3:45",
  "releaseDate": "2024",
  "isrcCode": "USRC12345678",
  "copyrightOwner": "John Doe",
  "copyrightYear": "2024",
  "proAffiliation": "ASCAP",
  "spotifyUrl": "https://open.spotify.com/track/...",
  "drmStatus": "Protected",
  "licenseType": "All Rights Reserved",
  "territory": "Worldwide",
  "contributors": [
    {
      "name": "Jane Producer",
      "role": "Producer",
      "splitPercentage": 20.00,
      "email": "jane@example.com"
    }
  ]
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "track": { /* track object */ }
  },
  "message": "Track created successfully"
}
```

#### PUT /api/v1/tracks/:id
Update track

**Request:** Same fields as POST (all optional)

#### DELETE /api/v1/tracks/:id
Delete track

**Response:**
```json
{
  "success": true,
  "message": "Track deleted successfully"
}
```

---

### Verifications (Coming Week 3)

#### POST /api/v1/verifications
Verify if video uses user's music

**Request:**
```json
{
  "videoUrl": "https://youtube.com/watch?v=...",
  "platform": "YouTube"
}
```

---

### Licenses (Coming Week 4)

#### POST /api/v1/licenses
Generate license agreement

#### GET /api/v1/licenses
List generated licenses

---

### Revenue

#### GET /api/v1/revenue
List revenue events

#### GET /api/v1/revenue/summary
Get revenue summary

---

## 🗄️ Database Schema

### Users
- id (UUID, PK)
- email (unique)
- password_hash
- name
- artist_name
- subscription_plan (free, pro, enterprise)
- created_at, updated_at

### Tracks
- id (UUID, PK)
- user_id (FK → users)
- title, artist_name, duration, release_date
- isrc_code, upc_code, copyright info
- platform URLs (Spotify, Apple Music, SoundCloud)
- DRM status, license type, territory
- ACRCloud fingerprint_id
- streams, revenue
- created_at, updated_at

### Contributors
- id (UUID, PK)
- track_id (FK → tracks)
- name, role, split_percentage
- email, pro_affiliation

### Verifications
- id (UUID, PK)
- user_id (FK → users)
- track_id (FK → tracks)
- platform, video_url, video_id
- match_found, confidence_score
- audio_sample_url (S3)
- status (pending, confirmed, disputed)

### Licenses
- id (UUID, PK)
- user_id, track_id, verification_id
- licensee info (name, email, channel)
- license terms (fee, territory, duration)
- Stripe payment info
- pdf_url
- status (draft, sent, signed, paid)

### Revenue Events
- id (UUID, PK)
- user_id, track_id, license_id
- source, amount, currency
- date, description, platform

---

## 🔐 Security

### JWT Authentication
- Access tokens expire in 15 minutes
- Refresh tokens expire in 30 days
- Tokens stored in database for revocation

### Password Security
- Bcrypt hashing (cost factor 12)
- Minimum 8 characters required
- Email format validation

### API Security
- CORS enabled for iOS app
- Rate limiting (coming Week 6)
- Input validation on all endpoints
- SQL injection prevention (parameterized queries)

---

## 🧪 Testing

```bash
# Run tests (coming Week 7)
npm test

# Test auth endpoints
curl -X POST http://localhost:3000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123","name":"Test User"}'

# Test health check
curl http://localhost:3000/health
```

---

## 🚀 Deployment (Railway.app)

### Step 1: Create Railway Project
1. Go to railway.app
2. Click "New Project"
3. Select "Deploy from GitHub repo"
4. Connect your repository

### Step 2: Add PostgreSQL
1. Click "New" → "Database" → "PostgreSQL"
2. Copy DATABASE_URL from Variables tab

### Step 3: Configure Environment
1. Go to your service → Variables
2. Add all variables from .env.example
3. Set NODE_ENV=production

### Step 4: Deploy
1. Push to main branch
2. Railway auto-deploys
3. Get public URL from Settings → Domains

---

## 📊 Week 1 Checklist

### Backend Setup
- [x] Initialize Node.js project
- [x] Install dependencies
- [x] Create database schema
- [x] Implement authentication
- [x] Create API routes
- [x] Add middleware
- [ ] Deploy to Railway.app
- [ ] Test all endpoints

### iOS Integration (Next)
- [ ] Create NetworkManager.swift
- [ ] Create AuthService.swift
- [ ] Add Keychain storage
- [ ] Test login/register from app

---

## 📝 Notes

- All timestamps in UTC
- All monetary values in USD (decimal 10,2)
- UUIDs for all primary keys
- Soft deletes not implemented (hard deletes for MVP)
- File uploads coming Week 2 (S3 integration)

---

## 🐛 Troubleshooting

### Database Connection Error
```bash
# Check DATABASE_URL format
postgresql://user:password@host:5432/database

# Test connection
psql $DATABASE_URL
```

### JWT Token Error
```bash
# Verify JWT_SECRET is set
echo $JWT_SECRET

# Token expired? Use refresh endpoint
```

### CORS Error
```bash
# Add your iOS app URL to FRONTEND_URL in .env
FRONTEND_URL=http://localhost:3000
```

---

**Week 1 Complete** ✅  
**Next: Week 2 - ACRCloud Integration**
