#!/bin/bash
echo "📊 Deployment Status:"
echo ""
if command -v gh >/dev/null 2>&1; then
    gh run list --limit 5 --repo kjahir/seyali-test
    echo ""
    echo "💡 To watch live: gh run watch"
else
    echo "View at: https://github.com/kjahir/seyali-test/actions"
fi
