#!/bin/bash

echo "🔧 AWS Credentials Updater"
echo "=========================="
echo ""
echo "Go to Railway Dashboard:"
echo "https://railway.app/project/453302b8-7e05-4d17-bf94-651434fed5eb"
echo ""
echo "Steps:"
echo "1. Click on your backend service (Consigliary)"
echo "2. Click 'Variables' tab"
echo "3. Copy the AWS credentials"
echo ""
echo "Paste each value when prompted:"
echo ""

# Backup current .env
cp .env .env.backup.aws.$(date +%s)

# Get current .env without AWS vars
grep -v "^AWS_" .env > .env.tmp

# Prompt for AWS credentials
echo -n "AWS_ACCESS_KEY_ID: "
read AWS_ACCESS_KEY_ID

echo -n "AWS_SECRET_ACCESS_KEY: "
read AWS_SECRET_ACCESS_KEY

echo -n "AWS_REGION (press Enter for eu-north-1): "
read AWS_REGION
AWS_REGION=${AWS_REGION:-eu-north-1}

echo -n "AWS_S3_BUCKET (press Enter for consigliary-audio-files): "
read AWS_S3_BUCKET
AWS_S3_BUCKET=${AWS_S3_BUCKET:-consigliary-audio-files}

# Append AWS credentials
cat >> .env.tmp << EOF

AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
AWS_S3_BUCKET=$AWS_S3_BUCKET
AWS_REGION=$AWS_REGION
EOF

# Replace .env
mv .env.tmp .env

echo ""
echo "✅ AWS credentials updated!"
echo ""
echo "Testing S3 connection..."
node -e "
require('dotenv').config();
const s3Service = require('./services/s3');
s3Service.testConnection().then(result => {
  if (result) {
    console.log('✅ S3 connection successful!');
    console.log('');
    console.log('Restart the server:');
    console.log('  npm start');
    console.log('');
    console.log('Then test verification:');
    console.log('  ./scripts/test-verification.sh');
  } else {
    console.log('❌ S3 connection still failing. Check credentials.');
  }
  process.exit(result ? 0 : 1);
});
"
