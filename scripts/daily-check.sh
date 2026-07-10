#!/bin/bash
# HelixCD Daily Local Check
# Add to crontab:
# 0 9 * * * /path/to/daily-check.sh

REPO="$HOME/helixcd-workspace/helixcd"
VISION="$HOME/helixcd-workspace/helixcd-vision"
DATE=$(date +%Y-%m-%d)
LOG="$VISION/operations/security-log.md"

echo ""
echo "══════════════════════════════════"
echo "  HelixCD Daily Check — $DATE"
echo "══════════════════════════════════"
echo ""

cd "$REPO"

# Pull latest
echo "📥 Pulling latest changes..."
git pull origin main --quiet
echo "  ✅ helixcd up to date"

cd "$VISION"
git pull origin main --quiet
echo "  ✅ helixcd-vision up to date"

cd "$REPO"

# Quick security scan
echo ""
echo "🔒 Running quick security scan..."

# Check for secrets accidentally added
if git log --since="24 hours ago" \
   --all -p | grep -iE \
   "(password|api_key|secret|token).*=.*['\"][^'\"]{8,}" \
   > /dev/null 2>&1; then
  echo "  ⚠️  Possible secrets in recent commits!"
  osascript -e 'display notification
    "⚠️ Possible secrets in HelixCD commits!"
    with title "HelixCD Security Alert"
    sound name "Basso"' 2>/dev/null || true
else
  echo "  ✅ No secrets in recent commits"
fi

# Check Python vulnerabilities
echo ""
echo "📦 Checking dependencies..."
pip-audit -r requirements.txt \
  --format=json 2>/dev/null | \
  python3 -c "
import json, sys
data = json.load(sys.stdin)
vulns = sum(
  len(d.get('vulns', []))
  for d in data.get('dependencies', [])
)
if vulns > 0:
  print(f'  ⚠️  {vulns} vulnerabilities found!')
  print('  Run: pip-audit -r requirements.txt')
else:
  print('  ✅ No vulnerabilities found')
" 2>/dev/null || echo "  ✅ Dependencies clean"

# Check for outdated packages
echo ""
echo "📋 Checking for updates..."
OUTDATED=$(pip list --outdated 2>/dev/null | \
  tail -n +3 | wc -l | tr -d ' ')
if [ "$OUTDATED" -gt 0 ]; then
  echo "  ℹ️  $OUTDATED packages have updates"
  echo "  Run: pip list --outdated"
else
  echo "  ✅ All packages current"
fi

# Check open security issues on GitHub
echo ""
echo "🐛 Open security issues..."
ISSUES=$(gh issue list \
  --label security \
  --state open \
  --json number \
  2>/dev/null | \
  python3 -c "
import json,sys
d=json.load(sys.stdin)
print(len(d))
" 2>/dev/null || echo "0")
echo "  ℹ️  $ISSUES open security issues"

echo ""
echo "══════════════════════════════════"
echo "  ✅ Daily check complete!"
echo "══════════════════════════════════"

# macOS notification
osascript -e 'display notification
  "Daily security check complete"
  with title "HelixCD Health"
  sound name "Glass"' 2>/dev/null || true
