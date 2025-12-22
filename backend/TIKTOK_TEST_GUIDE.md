# 🎵 TikTok Download API - Test Guide

## Quick Test with cURL

### 1. Login to get access token
```bash
curl -X POST https://consigliary-production.up.railway.app/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@consigliary.com",
    "password": "password123"
  }'
```

**Save the `accessToken` from the response.**

### 2. Download TikTok Audio
```bash
curl -X POST https://consigliary-production.up.railway.app/api/v1/tracks/download-tiktok \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN_HERE" \
  -d '{
    "url": "https://www.tiktok.com/@username/video/1234567890",
    "title": "Optional Custom Title",
    "artistName": "Optional Custom Artist"
  }'
```

**Replace:**
- `YOUR_ACCESS_TOKEN_HERE` with the token from step 1
- The TikTok URL with a real one

### 3. Expected Response
```json
{
  "success": true,
  "data": {
    "track": {
      "id": "uuid",
      "title": "TikTok Audio",
      "artist_name": "Artist Name",
      "duration": 30,
      "audio_file_url": "https://s3.amazonaws.com/...",
      "acrcloud_fingerprint_id": "...",
      ...
    },
    "audioUrl": "https://s3.amazonaws.com/...",
    "fingerprintId": "...",
    "metadata": {
      "title": "Original TikTok Title",
      "author": "TikTok Creator",
      "duration": 30,
      ...
    }
  },
  "message": "TikTok audio downloaded and track created successfully"
}
```

## What Happens Behind the Scenes

1. **Download**: Uses `yt-dlp` to download audio from TikTok
2. **Convert**: Converts to MP3 format
3. **Upload**: Uploads to AWS S3
4. **Fingerprint**: Generates ACRCloud audio fingerprint
5. **Store**: Creates track record in database
6. **Return**: Returns complete track data

## Supported TikTok URL Formats

- `https://www.tiktok.com/@username/video/1234567890`
- `https://vm.tiktok.com/ABC123/` (short links)
- `https://www.tiktok.com/v/1234567890`

## Error Handling

### Invalid URL
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "TikTok URL is required"
  }
}
```

### Download Failed
```json
{
  "success": false,
  "error": {
    "code": "TIKTOK_DOWNLOAD_ERROR",
    "message": "Failed to download TikTok audio: Video unavailable"
  }
}
```

### Unauthorized
```json
{
  "success": false,
  "error": {
    "code": "UNAUTHORIZED",
    "message": "Invalid or expired token"
  }
}
```

## Testing Tips

1. **Use Public Videos**: Make sure the TikTok video is public
2. **Check Network**: Download may take 30-60 seconds
3. **Verify S3**: Check that audio file appears in S3 bucket
4. **Check Database**: Verify track is created with correct metadata

## Troubleshooting

### "yt-dlp is not installed"
- Check Dockerfile has `python3-venv` and `yt-dlp` installed
- Verify venv is in PATH: `ENV PATH="/opt/venv/bin:$PATH"`

### "Video unavailable"
- Video may be private or deleted
- Try a different TikTok URL
- Check if TikTok is blocking the server IP

### "Timeout"
- Video may be too large
- Network may be slow
- Try a shorter video

## Next Steps

After successful test:
1. ✅ Verify audio file in S3 bucket
2. ✅ Check ACRCloud fingerprint was generated
3. ✅ Test with iOS app
4. ✅ Add to production documentation

---

**Production Endpoint**: `https://consigliary-production.up.railway.app/api/v1/tracks/download-tiktok`

**Test User**: `test@consigliary.com` / `password123`
