#!/bin/bash

echo "🧪 Production Verification Test"
echo "================================"
echo ""

# Get token
echo "1. Authenticating..."
TOKEN=$(curl -s -X POST https://consigliary-production.up.railway.app/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@consigliary.com","password":"password123"}' | jq -r '.data.accessToken')

if [ -z "$TOKEN" ] || [ "$TOKEN" = "null" ]; then
  echo "❌ Authentication failed"
  exit 1
fi

echo "✅ Authenticated"
echo ""

# Test verification
echo "2. Testing verification (60 second timeout)..."
echo "   Video: https://www.youtube.com/watch?v=dQw4w9WgXcQ"
echo ""

RESULT=$(curl -s -X POST https://consigliary-production.up.railway.app/api/v1/verifications \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"videoUrl":"https://www.youtube.com/watch?v=dQw4w9WgXcQ"}' \
  -m 60)

echo "$RESULT" | jq .

if echo "$RESULT" | jq -e '.success == true' > /dev/null 2>&1; then
  echo ""
  echo "✅ SUCCESS!"
else
  echo ""
  echo "⚠️  Check result above"
fi
