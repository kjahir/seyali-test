#!/bin/bash
set -e
MESSAGE="${1:-Quick deploy}"
echo "🚀 Deploying everything..."
git add .
git commit -m "$MESSAGE" || echo "No changes to commit"
git push origin main
echo ""
echo "✅ Deployment triggered!"
echo "📊 Check status: https://github.com/kjahir/seyali-test/actions"
