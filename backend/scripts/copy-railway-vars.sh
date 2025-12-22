#!/bin/bash

# 📋 Copy Railway Variables to .env
# Converts Railway variables output to .env format

set -e

echo "📋 Railway Variables → .env Converter"
echo "======================================"
echo ""

BACKEND_DIR="/Users/howardduffy/Desktop/Consigliary/backend"
ENV_FILE="${BACKEND_DIR}/.env"
RAILWAY_VARS="${BACKEND_DIR}/.env.railway"

# Check if Railway variables file exists
if [ ! -f "${RAILWAY_VARS}" ]; then
    echo "❌ Railway variables file not found: ${RAILWAY_VARS}"
    echo ""
    echo "First, export Railway variables:"
    echo "  railway variables > .env.railway"
    echo ""
    exit 1
fi

echo "✅ Found Railway variables file"
echo ""

# Check if .env already exists
if [ -f "${ENV_FILE}" ]; then
    echo "⚠️  .env file already exists!"
    read -p "Do you want to overwrite it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
fi

# Create .env with local development settings
cat > "${ENV_FILE}" << EOF
# Server Configuration
NODE_ENV=development
PORT=3000
API_VERSION=v1

# Frontend URL (for CORS)
FRONTEND_URL=http://localhost:3000
IOS_APP_BUNDLE_ID=com.htdstudio.consigliary

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100

EOF

# Append Railway variables (filtering out some production-only vars)
echo "# Production Variables from Railway" >> "${ENV_FILE}"
grep -E "^(DATABASE_URL|JWT_SECRET|REFRESH_TOKEN_SECRET|AWS_|ACRCLOUD_)" "${RAILWAY_VARS}" >> "${ENV_FILE}" || true

echo "✅ Created .env file with Railway variables"
echo ""
echo "📝 Review the file:"
echo "  cat ${ENV_FILE}"
echo ""
echo "🧪 Test the verification system:"
echo "  npm start  # Terminal 1"
echo "  ./scripts/test-verification.sh  # Terminal 2"
echo ""
