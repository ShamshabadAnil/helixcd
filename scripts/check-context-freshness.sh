#!/bin/bash
# HelixCD Context Freshness Checker
# Alerts when context files are stale
# Run automatically or manually

VISION="$HOME/helixcd-workspace/helixcd-vision"
DATE=$(date +%Y-%m-%d)
MAX_DAYS_CONTEXT=7
MAX_DAYS_MEMORY=3
MAX_DAYS_REGISTRY=7

echo ""
echo "🔍 HelixCD Context Freshness Check"
echo "   Date: $DATE"
echo "════════════════════════════════════"
echo ""

ISSUES=0

check_freshness() {
  local file=$1
  local max_days=$2
  local name=$3

  if [ ! -f "$file" ]; then
    echo "  ❌ $name: FILE NOT FOUND"
    ISSUES=$((ISSUES + 1))
    return
  fi

  # Get file age in days
  if [[ "$OSTYPE" == "darwin"* ]]; then
    MODIFIED=$(stat -f %m "$file")
  else
    MODIFIED=$(stat -c %Y "$file")
  fi
  NOW=$(date +%s)
  AGE_SECONDS=$((NOW - MODIFIED))
  AGE_DAYS=$((AGE_SECONDS / 86400))

  if [ $AGE_DAYS -gt $max_days ]; then
    echo "  ⚠️  $name: $AGE_DAYS days old"
    echo "      (max: $max_days days)"
    echo "      Last updated: $(date -r $MODIFIED \
         +%Y-%m-%d 2>/dev/null || \
         date -d @$MODIFIED +%Y-%m-%d)"
    ISSUES=$((ISSUES + 1))
  else
    echo "  ✅ $name: $AGE_DAYS days old (fresh)"
  fi
}

# Check all context files
check_freshness \
  "$VISION/AGENT_CONTEXT_PRIVATE.md" \
  $MAX_DAYS_CONTEXT \
  "AGENT_CONTEXT_PRIVATE"

check_freshness \
  "$VISION/MEMORY_LOG.md" \
  $MAX_DAYS_MEMORY \
  "MEMORY_LOG"

check_freshness \
  "$VISION/WORK_REGISTRY.md" \
  $MAX_DAYS_REGISTRY \
  "WORK_REGISTRY"

# Check if MEMORY_LOG has recent entries
echo ""
echo "📋 MEMORY_LOG recent entries:"
RECENT=$(grep "^## SESSION_" \
  "$VISION/MEMORY_LOG.md" 2>/dev/null | \
  head -3 || echo "None found")
echo "  $RECENT"

# Check WORK_REGISTRY progress
echo ""
echo "📊 WORK_REGISTRY progress:"
DONE=$(grep -c "🔵\|🟢" \
  "$VISION/WORK_REGISTRY.md" 2>/dev/null \
  || echo "0")
IN_PROGRESS=$(grep -c "🟡" \
  "$VISION/WORK_REGISTRY.md" 2>/dev/null \
  || echo "0")
NOT_STARTED=$(grep -c "🔴" \
  "$VISION/WORK_REGISTRY.md" 2>/dev/null \
  || echo "0")

echo "  ✅ Done:        $DONE"
echo "  🟡 In progress: $IN_PROGRESS"
echo "  🔴 Not started: $NOT_STARTED"

echo ""
echo "════════════════════════════════════"

if [ $ISSUES -gt 0 ]; then
  echo "  ⚠️  $ISSUES context file(s) need update"
  echo "  Update before next AI session!"

  # macOS notification
  osascript -e "display notification
    \"$ISSUES context files are stale!
     Update before AI session.\"
    with title \"HelixCD Context Alert\"
    sound name \"Basso\"" 2>/dev/null || true
else
  echo "  ✅ All context files fresh"
  echo "  Ready for AI session!"

  osascript -e "display notification
    \"All context files are fresh\"
    with title \"HelixCD Context\"
    sound name \"Glass\"" 2>/dev/null || true
fi
echo "════════════════════════════════════"
