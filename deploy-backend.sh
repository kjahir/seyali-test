#!/bin/bash
set -e
MESSAGE="${1:-Update backend}"
echo "🔧 Deploying backend only..."
git add backend/ render.yaml .github/
git commit -m "$MESSAGE" || echo "No changes to commit"
git push origin main
echo "✅ Backend deployment triggered!"
