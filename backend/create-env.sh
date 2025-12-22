#!/bin/bash

# Simple .env creator - Just paste Railway variables when prompted

echo "🔧 Simple .env File Creator"
echo "============================"
echo ""
echo "I'll ask you for each value. Just copy from Railway and paste here."
echo ""
echo "Open Railway in your browser:"
echo "https://railway.app/project/453302b8-7e05-4d17-bf94-651434fed5eb"
echo "→ Click your backend service → Variables tab"
echo ""
read -p "Press Enter when ready..."
echo ""

# Create .env file
cat > .env << 'HEADER'
# Local Development Environment
NODE_ENV=development
PORT=3000
API_VERSION=v1
FRONTEND_URL=http://localhost:3000
IOS_APP_BUNDLE_ID=com.htdstudio.consigliary
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100

HEADER

echo "📋 Now paste each value from Railway:"
echo ""

# DATABASE_URL
echo -n "1. DATABASE_URL: "
read DATABASE_URL
echo "DATABASE_URL=$DATABASE_URL" >> .env

# JWT_SECRET
echo -n "2. JWT_SECRET: "
read JWT_SECRET
echo "JWT_SECRET=$JWT_SECRET" >> .env

# REFRESH_TOKEN_SECRET
echo -n "3. REFRESH_TOKEN_SECRET: "
read REFRESH_TOKEN_SECRET
echo "REFRESH_TOKEN_SECRET=$REFRESH_TOKEN_SECRET" >> .env

# JWT_EXPIRES_IN
echo "JWT_EXPIRES_IN=15m" >> .env
echo "REFRESH_TOKEN_EXPIRES_IN=30d" >> .env

# AWS credentials
echo -n "4. AWS_ACCESS_KEY_ID: "
read AWS_ACCESS_KEY_ID
echo "AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID" >> .env

echo -n "5. AWS_SECRET_ACCESS_KEY: "
read AWS_SECRET_ACCESS_KEY
echo "AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY" >> .env

echo "AWS_S3_BUCKET=consigliary-audio-files" >> .env
echo "AWS_REGION=eu-north-1" >> .env

# ACRCloud
echo "ACRCLOUD_HOST=identify-eu-west-1.acrcloud.com" >> .env

echo -n "6. ACRCLOUD_ACCESS_KEY: "
read ACRCLOUD_ACCESS_KEY
echo "ACRCLOUD_ACCESS_KEY=$ACRCLOUD_ACCESS_KEY" >> .env

echo -n "7. ACRCLOUD_ACCESS_SECRET: "
read ACRCLOUD_ACCESS_SECRET
echo "ACRCLOUD_ACCESS_SECRET=$ACRCLOUD_ACCESS_SECRET" >> .env

echo ""
echo "✅ .env file created!"
echo ""
echo "🧪 Test it:"
echo "  npm start"
echo ""
