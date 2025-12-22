#!/bin/bash

# 🧪 Verification System Test Script
# Tests the verification endpoint locally before Railway deployment

set -e

echo "🧪 Consigliary Verification System Test"
echo "========================================"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
API_URL="http://localhost:3000"
TEST_EMAIL="test@consigliary.com"
TEST_PASSWORD="password123"
TEST_VIDEO_URL="https://www.youtube.com/watch?v=dQw4w9WgXcQ"

# Check if server is running
echo "📡 Checking if backend server is running..."
if ! curl -s "${API_URL}/health" > /dev/null 2>&1; then
    echo -e "${RED}❌ Backend server is not running!${NC}"
    echo ""
    echo "Please start the server first:"
    echo "  cd /Users/howardduffy/Desktop/Consigliary/backend"
    echo "  npm start"
    echo ""
    exit 1
fi
echo -e "${GREEN}✅ Backend server is running${NC}"
echo ""

# Test 1: Health Check
echo "Test 1: Health Check"
echo "--------------------"
HEALTH_RESPONSE=$(curl -s "${API_URL}/health")
echo "Response: ${HEALTH_RESPONSE}"
if echo "${HEALTH_RESPONSE}" | grep -q '"status":"ok"'; then
    echo -e "${GREEN}✅ PASS${NC}"
else
    echo -e "${RED}❌ FAIL${NC}"
    exit 1
fi
echo ""

# Test 2: Authentication
echo "Test 2: Authentication"
echo "----------------------"
echo "Logging in as ${TEST_EMAIL}..."
AUTH_RESPONSE=$(curl -s -X POST "${API_URL}/api/v1/auth/login" \
    -H "Content-Type: application/json" \
    -d "{\"email\":\"${TEST_EMAIL}\",\"password\":\"${TEST_PASSWORD}\"}")

ACCESS_TOKEN=$(echo "${AUTH_RESPONSE}" | grep -o '"accessToken":"[^"]*"' | cut -d'"' -f4)

if [ -z "${ACCESS_TOKEN}" ]; then
    echo -e "${RED}❌ FAIL - Could not get access token${NC}"
    echo "Response: ${AUTH_RESPONSE}"
    exit 1
fi
echo -e "${GREEN}✅ PASS - Got access token${NC}"
echo "Token: ${ACCESS_TOKEN:0:20}..."
echo ""

# Test 3: YouTube Audio Extraction
echo "Test 3: YouTube Audio Extraction (Critical Test)"
echo "-------------------------------------------------"
echo "Video URL: ${TEST_VIDEO_URL}"
echo "This will take 30-60 seconds..."
echo ""

START_TIME=$(date +%s)

VERIFICATION_RESPONSE=$(curl -s -X POST "${API_URL}/api/v1/verifications" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -d "{\"videoUrl\":\"${TEST_VIDEO_URL}\"}")

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo "Response: ${VERIFICATION_RESPONSE}"
echo "Duration: ${DURATION} seconds"
echo ""

# Check if successful
if echo "${VERIFICATION_RESPONSE}" | grep -q '"success":true'; then
    echo -e "${GREEN}✅ PASS - Verification completed successfully${NC}"
    
    # Extract verification details
    VERIFICATION_ID=$(echo "${VERIFICATION_RESPONSE}" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
    STATUS=$(echo "${VERIFICATION_RESPONSE}" | grep -o '"status":"[^"]*"' | head -1 | cut -d'"' -f4)
    PLATFORM=$(echo "${VERIFICATION_RESPONSE}" | grep -o '"platform":"[^"]*"' | head -1 | cut -d'"' -f4)
    
    echo ""
    echo "Verification Details:"
    echo "  ID: ${VERIFICATION_ID}"
    echo "  Status: ${STATUS}"
    echo "  Platform: ${PLATFORM}"
    
    # Check for match result
    if echo "${VERIFICATION_RESPONSE}" | grep -q '"matched":true'; then
        echo -e "  ${GREEN}Match Found!${NC}"
    elif echo "${VERIFICATION_RESPONSE}" | grep -q '"matched":false'; then
        echo -e "  ${YELLOW}No Match Found (expected for non-fingerprinted tracks)${NC}"
    fi
    
else
    echo -e "${RED}❌ FAIL - Verification failed${NC}"
    
    # Try to extract error message
    ERROR_MSG=$(echo "${VERIFICATION_RESPONSE}" | grep -o '"message":"[^"]*"' | cut -d'"' -f4)
    if [ ! -z "${ERROR_MSG}" ]; then
        echo "Error: ${ERROR_MSG}"
    fi
    
    echo ""
    echo "Common Issues:"
    echo "  1. ytdl-core outdated → npm install ytdl-core@latest"
    echo "  2. FFmpeg not found → Check FFmpeg installation"
    echo "  3. AWS credentials → Check .env file"
    echo "  4. ACRCloud credentials → Check .env file"
    echo ""
    exit 1
fi

echo ""
echo "========================================"
echo -e "${GREEN}🎉 All Tests Passed!${NC}"
echo "========================================"
echo ""
echo "Next Steps:"
echo "  1. Check S3 bucket for uploaded audio sample"
echo "  2. Add FFmpeg to Railway (see RAILWAY_FFMPEG_SETUP.md)"
echo "  3. Deploy to production"
echo "  4. Test production endpoint"
echo ""
