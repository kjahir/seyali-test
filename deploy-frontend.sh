#!/bin/bash
set -e
MESSAGE="${1:-Update frontend}"
echo "💅 Deploying frontend only..."
git add frontend/ vercel.json .github/
git commit -m "$MESSAGE" || echo "No changes to commit"
git push origin main
echo "✅ Frontend deployment triggered!"
