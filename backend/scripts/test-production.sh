#!/bin/bash

# Test Production Verification System
# Tests the verification endpoint on Railway production

API_URL="https://consigliary-production.up.railway.app/api/v1"
TEST_EMAIL="test@consigliary.com"
TEST_PASSWORD="password123"
TEST_VIDEO="https://www.youtube.com/watch?v=dQw4w9WgXcQ"

echo "🧪 Testing Production Verification System"
echo "=========================================="
echo ""
echo "API URL: $API_URL"
echo ""

# Test 1: Health Check
echo "Test 1: Health Check"
echo "--------------------"
HEALTH_RESPONSE=$(curl -s "$API_URL/../health")
echo "Response: $HEALTH_RESPONSE"

if echo "$HEALTH_RESPONSE" | grep -q '"status":"ok"'; then
    echo "✅ PASS"
else
    echo "❌ FAIL - Health check failed"
    exit 1
fi
echo ""

# Test 2: Authentication
echo "Test 2: Authentication"
echo "----------------------"
echo "Logging in as $TEST_EMAIL..."

LOGIN_RESPONSE=$(curl -s -X POST "$API_URL/auth/login" \
    -H "Content-Type: application/json" \
    -d "{\"email\":\"$TEST_EMAIL\",\"password\":\"$TEST_PASSWORD\"}")

TOKEN=$(echo "$LOGIN_RESPONSE" | grep -o '"accessToken":"[^"]*"' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
    echo "❌ FAIL - Could not get access token"
    echo "Response: $LOGIN_RESPONSE"
    exit 1
fi

echo "✅ PASS - Got access token"
echo "Token: ${TOKEN:0:20}..."
echo ""

# Test 3: Verification
echo "Test 3: YouTube Verification (Production)"
echo "-----------------------------------------"
echo "Video URL: $TEST_VIDEO"
echo "This will take 30-60 seconds..."
echo ""

START_TIME=$(date +%s)

VERIFY_RESPONSE=$(curl -s -X POST "$API_URL/verifications" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -d "{\"videoUrl\":\"$TEST_VIDEO\"}")

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo "Response: $VERIFY_RESPONSE"
echo ""
echo "Duration: $DURATION seconds"
echo ""

if echo "$VERIFY_RESPONSE" | grep -q '"success":true'; then
    echo "✅ PASS - Verification completed successfully"
    echo ""
    echo "Verification Details:"
    echo "$VERIFY_RESPONSE" | grep -o '"id":"[^"]*"' | head -1
    echo "$VERIFY_RESPONSE" | grep -o '"platform":"[^"]*"'
    
    if echo "$VERIFY_RESPONSE" | grep -q '"matched":true'; then
        echo "Match Found!"
        echo "$VERIFY_RESPONSE" | grep -o '"title":"[^"]*"'
        echo "$VERIFY_RESPONSE" | grep -o '"artist":"[^"]*"'
        echo "$VERIFY_RESPONSE" | grep -o '"confidence":[0-9]*'
    fi
else
    echo "❌ FAIL - Verification failed"
    ERROR=$(echo "$VERIFY_RESPONSE" | grep -o '"message":"[^"]*"' | cut -d'"' -f4)
    echo "Error: $ERROR"
    exit 1
fi

echo ""
echo "=========================================="
echo "🎉 Production Tests Passed!"
echo "=========================================="
