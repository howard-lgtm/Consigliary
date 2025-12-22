#!/bin/bash

# 🚂 Quick Railway Setup Script
# Links Railway service and exports variables

set -e

echo "🚂 Railway Quick Setup"
echo "====================="
echo ""

cd /Users/howardduffy/Desktop/Consigliary/backend

# Check if railway CLI is installed
if ! command -v railway &> /dev/null; then
    echo "❌ Railway CLI not found!"
    echo ""
    echo "Install it with:"
    echo "  npm install -g @railway/cli"
    echo "  # or"
    echo "  brew install railway"
    echo ""
    exit 1
fi

echo "✅ Railway CLI found"
echo ""

# Check if already linked
if railway status &> /dev/null; then
    echo "✅ Already linked to Railway project"
    echo ""
else
    echo "🔗 Linking to Railway project..."
    echo "   Select: howard-lgtm's Projects > Consigliary"
    echo ""
    railway link
    echo ""
fi

# Export variables to file
echo "📥 Fetching Railway variables..."
railway variables > .env.railway.tmp

echo "✅ Variables saved to .env.railway.tmp"
echo ""
echo "Now you can:"
echo "  1. Review variables: cat .env.railway.tmp"
echo "  2. Copy to .env: ./scripts/setup-local-env.sh"
echo "  3. Or manually copy values to .env"
echo ""
