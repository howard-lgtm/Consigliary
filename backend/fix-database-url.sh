#!/bin/bash

echo "🔧 Database URL Fixer"
echo "===================="
echo ""
echo "The DATABASE_URL in your .env uses Railway's INTERNAL address"
echo "which doesn't work from your local machine."
echo ""
echo "You need the PUBLIC database URL from Railway."
echo ""
echo "Go to Railway Dashboard:"
echo "https://railway.app/project/453302b8-7e05-4d17-bf94-651434fed5eb"
echo ""
echo "1. Click on the PostgreSQL database (not the backend service)"
echo "2. Go to 'Connect' tab"
echo "3. Look for 'DATABASE_PUBLIC_URL' or 'Public Network URL'"
echo "4. Copy the full URL (starts with postgresql://)"
echo ""
read -p "Paste the PUBLIC DATABASE_URL here: " PUBLIC_DB_URL
echo ""

# Backup current .env
cp .env .env.backup

# Replace DATABASE_URL
sed -i '' "s|DATABASE_URL=.*|DATABASE_URL=$PUBLIC_DB_URL|" .env

echo "✅ Updated .env with public DATABASE_URL"
echo ""
echo "Restart the server:"
echo "  npm start"
echo ""
