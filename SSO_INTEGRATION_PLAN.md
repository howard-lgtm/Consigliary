# SSO Integration Plan - Week 6/7

**Date**: December 22, 2025  
**Priority**: High (Required for App Store)  
**Timeline**: 2-3 days implementation

---

## 🎯 Why SSO?

### User Experience
- **Faster onboarding** - One-tap login
- **No password management** - Users don't need to remember credentials
- **Trust factor** - Users trust major platforms
- **Cross-device sync** - Seamless experience

### Business Requirements
- **Apple Sign In** - **REQUIRED** for App Store if you offer any other social login
- **Spotify OAuth** - Natural fit for music platform (users already have accounts)
- **Google Sign In** - Broad reach, many users prefer it

---

## 🏗️ Implementation Priority

### Phase 1: Apple Sign In (REQUIRED - Week 6)
**Why First:**
- Required by Apple App Store guidelines
- Native iOS integration (easiest to implement)
- Best UX on iOS devices

**Implementation:**
- Backend: Add Apple OAuth endpoints
- iOS: Use AuthenticationServices framework
- 2-3 hours implementation

### Phase 2: Spotify OAuth (Week 6)
**Why Second:**
- Perfect fit for music platform
- Users already have Spotify accounts
- We already have Spotify API credentials

**Implementation:**
- Backend: Add Spotify OAuth flow
- iOS: Use Spotify iOS SDK or web flow
- 3-4 hours implementation

### Phase 3: Google Sign In (Week 7)
**Why Third:**
- Broad user base
- Many users prefer Google
- Good fallback option

**Implementation:**
- Backend: Add Google OAuth endpoints
- iOS: Use Google Sign In SDK
- 3-4 hours implementation

---

## 📋 Technical Requirements

### Backend (Node.js/Express)

**New Dependencies:**
```json
{
  "apple-signin-auth": "^1.7.6",
  "passport": "^0.7.0",
  "passport-spotify": "^2.0.0",
  "passport-google-oauth20": "^2.0.0"
}
```

**New Routes:**
```
POST /api/v1/auth/apple
POST /api/v1/auth/spotify
POST /api/v1/auth/google
POST /api/v1/auth/social/callback
```

**Database Schema Update:**
```sql
ALTER TABLE users ADD COLUMN apple_id VARCHAR(255) UNIQUE;
ALTER TABLE users ADD COLUMN spotify_id VARCHAR(255) UNIQUE;
ALTER TABLE users ADD COLUMN google_id VARCHAR(255) UNIQUE;
ALTER TABLE users ADD COLUMN auth_provider VARCHAR(50);
ALTER TABLE users ADD COLUMN profile_image_url TEXT;
```

### iOS App

**New Dependencies:**
```swift
// Apple Sign In - Built-in
import AuthenticationServices

// Spotify SDK
// https://github.com/spotify/ios-sdk

// Google Sign In
// https://developers.google.com/identity/sign-in/ios
```

**New Services:**
```
Services/
├── AppleAuthService.swift
├── SpotifyAuthService.swift
└── GoogleAuthService.swift
```

---

## 🔐 Apple Sign In Implementation

### Backend

```javascript
// routes/auth.js
const appleSignin = require('apple-signin-auth');

router.post('/apple', async (req, res) => {
  try {
    const { identityToken, user } = req.body;
    
    // Verify Apple token
    const appleUser = await appleSignin.verifyIdToken(identityToken, {
      audience: process.env.APPLE_CLIENT_ID,
      ignoreExpiration: false
    });
    
    // Find or create user
    let dbUser = await query(
      'SELECT * FROM users WHERE apple_id = $1',
      [appleUser.sub]
    );
    
    if (dbUser.rows.length === 0) {
      // Create new user
      dbUser = await query(
        `INSERT INTO users (id, email, name, apple_id, auth_provider)
         VALUES ($1, $2, $3, $4, 'apple') RETURNING *`,
        [uuidv4(), appleUser.email, user?.fullName, appleUser.sub]
      );
    }
    
    // Generate JWT tokens
    const accessToken = generateAccessToken(dbUser.rows[0]);
    const refreshToken = generateRefreshToken(dbUser.rows[0]);
    
    res.json({
      success: true,
      data: {
        user: dbUser.rows[0],
        accessToken,
        refreshToken
      }
    });
  } catch (error) {
    res.status(401).json({ success: false, error: error.message });
  }
});
```

### iOS

```swift
// Services/AppleAuthService.swift
import AuthenticationServices

class AppleAuthService: NSObject {
    static let shared = AppleAuthService()
    
    func signInWithApple(presentationAnchor: ASPresentationAnchor) async throws -> AuthResponse {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
        
        // Wait for callback...
        // Send to backend /api/v1/auth/apple
    }
}
```

### Configuration Required

**Apple Developer:**
1. Enable "Sign in with Apple" capability in Xcode
2. Register App ID with Sign in with Apple
3. Create Service ID for backend
4. Get Client ID and Team ID

**Environment Variables:**
```
APPLE_CLIENT_ID=com.htdstudio.consigliary
APPLE_TEAM_ID=YOUR_TEAM_ID
APPLE_KEY_ID=YOUR_KEY_ID
APPLE_PRIVATE_KEY=path/to/AuthKey.p8
```

---

## 🎵 Spotify OAuth Implementation

### Backend

```javascript
// routes/auth.js
const passport = require('passport');
const SpotifyStrategy = require('passport-spotify').Strategy;

passport.use(new SpotifyStrategy({
    clientID: process.env.SPOTIFY_CLIENT_ID,
    clientSecret: process.env.SPOTIFY_CLIENT_SECRET,
    callbackURL: `${process.env.API_URL}/auth/spotify/callback`
  },
  async (accessToken, refreshToken, expires_in, profile, done) => {
    // Find or create user
    let user = await query(
      'SELECT * FROM users WHERE spotify_id = $1',
      [profile.id]
    );
    
    if (user.rows.length === 0) {
      user = await query(
        `INSERT INTO users (id, email, name, spotify_id, auth_provider, profile_image_url)
         VALUES ($1, $2, $3, $4, 'spotify', $5) RETURNING *`,
        [uuidv4(), profile.emails[0].value, profile.displayName, profile.id, profile.photos[0]]
      );
    }
    
    return done(null, user.rows[0]);
  }
));

router.get('/spotify', passport.authenticate('spotify', {
  scope: ['user-read-email', 'user-read-private']
}));

router.get('/spotify/callback', 
  passport.authenticate('spotify', { session: false }),
  (req, res) => {
    // Generate JWT tokens
    const accessToken = generateAccessToken(req.user);
    const refreshToken = generateRefreshToken(req.user);
    
    // Redirect to app with tokens
    res.redirect(`consigliary://auth?token=${accessToken}&refresh=${refreshToken}`);
  }
);
```

### iOS

```swift
// Services/SpotifyAuthService.swift
import SafariServices

class SpotifyAuthService {
    static let shared = SpotifyAuthService()
    
    func signInWithSpotify(from viewController: UIViewController) {
        let authURL = "\(API_BASE_URL)/auth/spotify"
        guard let url = URL(string: authURL) else { return }
        
        let safari = SFSafariViewController(url: url)
        viewController.present(safari, animated: true)
    }
    
    // Handle callback in AppDelegate
    func handleCallback(url: URL) -> AuthResponse? {
        // Parse tokens from URL
        // Save to Keychain
    }
}
```

---

## 🔍 Google Sign In Implementation

### Backend

```javascript
// routes/auth.js
const { OAuth2Client } = require('google-auth-library');
const client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

router.post('/google', async (req, res) => {
  try {
    const { idToken } = req.body;
    
    // Verify Google token
    const ticket = await client.verifyIdToken({
      idToken,
      audience: process.env.GOOGLE_CLIENT_ID
    });
    
    const payload = ticket.getPayload();
    
    // Find or create user
    let user = await query(
      'SELECT * FROM users WHERE google_id = $1',
      [payload.sub]
    );
    
    if (user.rows.length === 0) {
      user = await query(
        `INSERT INTO users (id, email, name, google_id, auth_provider, profile_image_url)
         VALUES ($1, $2, $3, $4, 'google', $5) RETURNING *`,
        [uuidv4(), payload.email, payload.name, payload.sub, payload.picture]
      );
    }
    
    // Generate JWT tokens
    const accessToken = generateAccessToken(user.rows[0]);
    const refreshToken = generateRefreshToken(user.rows[0]);
    
    res.json({
      success: true,
      data: { user: user.rows[0], accessToken, refreshToken }
    });
  } catch (error) {
    res.status(401).json({ success: false, error: error.message });
  }
});
```

### iOS

```swift
// Services/GoogleAuthService.swift
import GoogleSignIn

class GoogleAuthService {
    static let shared = GoogleAuthService()
    
    func signInWithGoogle(presenting viewController: UIViewController) async throws -> AuthResponse {
        let config = GIDConfiguration(clientID: GOOGLE_CLIENT_ID)
        GIDSignIn.sharedInstance.configuration = config
        
        let result = try await GIDSignIn.sharedInstance.signIn(
            withPresenting: viewController
        )
        
        guard let idToken = result.user.idToken?.tokenString else {
            throw AuthError.noToken
        }
        
        // Send to backend
        let response: AuthResponse = try await NetworkManager.shared.request(
            endpoint: "/auth/google",
            method: .post,
            body: ["idToken": idToken]
        )
        
        return response
    }
}
```

---

## 🎨 Updated Login UI

### LoginView.swift

```swift
struct LoginView: View {
    var body: some View {
        VStack(spacing: 20) {
            // Logo and title
            
            // SSO Buttons
            Button(action: { signInWithApple() }) {
                HStack {
                    Image(systemName: "apple.logo")
                    Text("Continue with Apple")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .foregroundColor(.black)
                .cornerRadius(12)
            }
            
            Button(action: { signInWithSpotify() }) {
                HStack {
                    Image("spotify-icon")
                    Text("Continue with Spotify")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(hex: "1DB954"))
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            
            Button(action: { signInWithGoogle() }) {
                HStack {
                    Image("google-icon")
                    Text("Continue with Google")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .foregroundColor(.black)
                .cornerRadius(12)
            }
            
            Divider()
            
            // Email/Password option
            Text("Or continue with email")
                .foregroundColor(.gray)
            
            // Existing email/password fields
        }
    }
}
```

---

## 📊 Implementation Timeline

### Day 1: Apple Sign In (4-5 hours)
- [ ] Set up Apple Developer configuration
- [ ] Backend: Add Apple OAuth endpoint
- [ ] iOS: Implement AppleAuthService
- [ ] Update LoginView UI
- [ ] Test on device
- [ ] Update database schema

### Day 2: Spotify OAuth (4-5 hours)
- [ ] Backend: Add Spotify OAuth flow
- [ ] iOS: Implement SpotifyAuthService
- [ ] Handle OAuth callbacks
- [ ] Update LoginView UI
- [ ] Test complete flow

### Day 3: Google Sign In (4-5 hours)
- [ ] Set up Google Cloud Console
- [ ] Backend: Add Google OAuth endpoint
- [ ] iOS: Implement GoogleAuthService
- [ ] Update LoginView UI
- [ ] Test all three SSO methods
- [ ] Polish and error handling

---

## 🔒 Security Considerations

### Token Validation
- Always verify tokens server-side
- Check token expiration
- Validate audience/client ID
- Use HTTPS only

### User Privacy
- Request minimal scopes
- Explain why you need permissions
- Allow users to disconnect accounts
- GDPR compliance (data deletion)

### Error Handling
- Graceful fallback to email/password
- Clear error messages
- Retry logic for network issues
- Log SSO failures for debugging

---

## ✅ Testing Checklist

### Apple Sign In
- [ ] First-time login creates user
- [ ] Returning user logs in correctly
- [ ] Email is captured properly
- [ ] Name is captured (if provided)
- [ ] Token refresh works
- [ ] Logout and re-login works

### Spotify OAuth
- [ ] OAuth flow completes
- [ ] User profile fetched
- [ ] Email captured
- [ ] Profile image saved
- [ ] Callback handled correctly
- [ ] Works on physical device

### Google Sign In
- [ ] Google login flow works
- [ ] User data captured
- [ ] Profile image saved
- [ ] Token validation works
- [ ] Multiple accounts handled

---

## 📝 Environment Variables Needed

```bash
# Apple Sign In
APPLE_CLIENT_ID=com.htdstudio.consigliary
APPLE_TEAM_ID=YOUR_TEAM_ID
APPLE_KEY_ID=YOUR_KEY_ID
APPLE_PRIVATE_KEY_PATH=/path/to/AuthKey.p8

# Spotify OAuth (already have)
SPOTIFY_CLIENT_ID=b80e380a5278421dbea39468aaadf443
SPOTIFY_CLIENT_SECRET=c5c3fe98402c45f69081f5c7f732c7b5

# Google Sign In
GOOGLE_CLIENT_ID=YOUR_GOOGLE_CLIENT_ID.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=YOUR_GOOGLE_CLIENT_SECRET

# OAuth Callback
API_URL=https://consigliary-production.up.railway.app
```

---

## 🎯 Success Metrics

**After SSO Implementation:**
- 50%+ of new users use SSO (target)
- Faster onboarding (< 30 seconds)
- Reduced password reset requests
- Higher conversion rate
- Better user retention

---

## 📚 Resources

### Apple Sign In
- [Apple Documentation](https://developer.apple.com/sign-in-with-apple/)
- [Backend Integration Guide](https://developer.apple.com/documentation/sign_in_with_apple/sign_in_with_apple_rest_api)

### Spotify OAuth
- [Spotify Web API](https://developer.spotify.com/documentation/web-api/tutorials/code-flow)
- [iOS SDK](https://github.com/spotify/ios-sdk)

### Google Sign In
- [Google Identity](https://developers.google.com/identity/sign-in/ios)
- [iOS Integration](https://developers.google.com/identity/sign-in/ios/start-integrating)

---

## 🚀 Next Steps (Tomorrow)

1. **Prioritize Apple Sign In** (App Store requirement)
2. **Set up Apple Developer configuration**
3. **Implement backend Apple OAuth endpoint**
4. **Add AppleAuthService to iOS**
5. **Test on physical device**

**Then move to Spotify and Google in Week 7.**

---

**SSO will dramatically improve onboarding and is required for App Store submission!**

© 2025 HTDSTUDIO AB. All rights reserved.
