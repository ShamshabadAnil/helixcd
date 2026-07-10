#!/bin/bash
# HelixCD Weekly Context Update
# Add to crontab:
# 0 10 * * 1 /path/to/weekly-update.sh

REPO="$HOME/helixcd-workspace/helixcd"
VISION="$HOME/helixcd-workspace/helixcd-vision"
DATE=$(date +%Y-%m-%d)
WEEK=$(date +%V)

echo ""
echo "══════════════════════════════════════"
echo "  HelixCD Weekly Update — Week $WEEK"
echo "  Date: $DATE"
echo "══════════════════════════════════════"
echo ""

# Pull latest both repos
echo "📥 Pulling latest changes..."
cd "$REPO" && git pull --quiet
cd "$VISION" && git pull --quiet
echo "  ✅ Both repos updated"

# Count completed work
echo ""
echo "📊 Progress this week..."
DOCS_DONE=$(grep -c "🔵\|🟢" \
  "$VISION/WORK_REGISTRY.md" 2>/dev/null \
  || echo "0")
TOTAL=181
PERCENT=$((DOCS_DONE * 100 / TOTAL))

echo "  Tasks completed: $DOCS_DONE / $TOTAL"
echo "  Progress: $PERCENT%"

# Check for stale branches
echo ""
echo "🌿 Checking stale branches..."
cd "$REPO"
STALE=$(git branch -r \
  --sort=-committerdate \
  --format='%(refname:short) %(committerdate:relative)' \
  2>/dev/null | grep -v "main\|develop\|HEAD" | \
  grep -E "weeks|months" | head -5 || true)

if [ -n "$STALE" ]; then
  echo "  ⚠️  Stale branches found:"
  echo "$STALE" | while read branch date; do
    echo "    $branch ($date)"
  done
else
  echo "  ✅ No stale branches"
fi

# Check PR status
echo ""
echo "🔀 Open PRs..."
PRS=$(gh pr list \
  --state open \
  --json number,title,createdAt \
  2>/dev/null | python3 -c "
import json,sys
from datetime import datetime,timezone
prs = json.load(sys.stdin)
print(f'  Open PRs: {len(prs)}')
for pr in prs:
  print(f'  #{pr[\"number\"]}: {pr[\"title\"][:50]}')
" 2>/dev/null || echo "  ℹ️  gh CLI not configured")
echo "$PRS"

# Remind to update context
echo ""
echo "📝 Context update checklist:"
echo "  □ Update AGENT_CONTEXT_PRIVATE.md"
echo "    Section 5 (current status)"
echo "    Section 6 (last session)"
echo "    Section 7 (current task)"
echo ""
echo "  □ Update MEMORY_LOG.md"
echo "    Add this week's sessions"
echo ""
echo "  □ Update WORK_REGISTRY.md"
echo "    Mark completed tasks"
echo ""
echo "  □ Review security issues"
echo "    Check GitHub issues"
echo "    Fix critical ones"

echo ""
echo "══════════════════════════════════════"
echo "  ✅ Weekly update complete!"
echo "══════════════════════════════════════"

# macOS notification
osascript -e "display notification
  \"Week $WEEK review ready. $DOCS_DONE/$TOTAL tasks done.\"
  with title \"HelixCD Weekly\"
  sound name \"Ping\"" 2>/dev/null || true
