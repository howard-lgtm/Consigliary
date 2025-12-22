#!/bin/bash

# 🔧 Local Environment Setup Script
# Creates .env file from Railway variables

set -e

echo "🔧 Consigliary Local Environment Setup"
echo "======================================="
echo ""

BACKEND_DIR="/Users/howardduffy/Desktop/Consigliary/backend"
ENV_FILE="${BACKEND_DIR}/.env"

# Check if .env already exists
if [ -f "${ENV_FILE}" ]; then
    echo "⚠️  .env file already exists!"
    read -p "Do you want to overwrite it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
    rm "${ENV_FILE}"
fi

echo "This script will help you create a .env file for local testing."
echo "You'll need to get these values from Railway."
echo ""
echo "To get Railway variables, run in another terminal:"
echo "  cd ${BACKEND_DIR}"
echo "  railway link"
echo "  railway variables"
echo ""
read -p "Press Enter when you're ready to continue..."
echo ""

# Create .env file
cat > "${ENV_FILE}" << 'EOF'
# Server Configuration
NODE_ENV=development
PORT=3000
API_VERSION=v1

# Database (from Railway)
DATABASE_URL=

# JWT Authentication (from Railway)
JWT_SECRET=
JWT_EXPIRES_IN=15m
REFRESH_TOKEN_SECRET=
REFRESH_TOKEN_EXPIRES_IN=30d

# AWS S3 (from Railway)
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_S3_BUCKET=consigliary-audio-files
AWS_REGION=eu-north-1

# ACRCloud (from Railway)
ACRCLOUD_HOST=identify-eu-west-1.acrcloud.com
ACRCLOUD_ACCESS_KEY=
ACRCLOUD_ACCESS_SECRET=

# Frontend URL (for CORS)
FRONTEND_URL=http://localhost:3000
IOS_APP_BUNDLE_ID=com.htdstudio.consigliary

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
EOF

echo "✅ Created .env template at: ${ENV_FILE}"
echo ""
echo "📝 Now you need to fill in these values from Railway:"
echo ""
echo "  1. DATABASE_URL"
echo "  2. JWT_SECRET"
echo "  3. REFRESH_TOKEN_SECRET"
echo "  4. AWS_ACCESS_KEY_ID"
echo "  5. AWS_SECRET_ACCESS_KEY"
echo "  6. ACRCLOUD_ACCESS_KEY"
echo "  7. ACRCLOUD_ACCESS_SECRET"
echo ""
echo "Open the file in your editor:"
echo "  code ${ENV_FILE}"
echo "  # or"
echo "  nano ${ENV_FILE}"
echo ""
echo "Then run the verification test:"
echo "  npm start  # In one terminal"
echo "  ./scripts/test-verification.sh  # In another terminal"
echo ""
