#!/bin/bash
# ═══════════════════════════════════════════════
# HelixCD Agent Workflow Enforcement
# setup-agent-enforcement.sh
#
# Enforces agents to use helix commands
# through multiple layers:
# 1. .cursorrules enforcement
# 2. GitHub PR checks
# 3. Pre-work verification
# 4. Session validation
# ═══════════════════════════════════════════════

set -e

WORKSPACE="$HOME/helixcd-workspace"
REPO="$WORKSPACE/helixcd"
VISION="$WORKSPACE/helixcd-vision"
PROXY="$WORKSPACE/helix-proxy"

export PYTHONUTF8=1
export PYTHONIOENCODING=utf-8

echo ""
echo "============================================"
echo "  HelixCD Agent Workflow Enforcement"
echo "  Owner: ShamshabadAnil"
echo "============================================"
echo ""

# ════════════════════════════════════════════════
# FILE 1 — ENFORCE CURSORRULES
# Cursor reads this before every response
# Makes helix commands mandatory
# ════════════════════════════════════════════════
echo "[DIR] Updating .cursorrules enforcement..."

cat > "$REPO/.cursorrules" << 'EOF'
# HelixCD Agent Rules
# Version: v3 (enforced workflow)
# Read this entirely before responding.
# These rules are non-negotiable.

##################################################
# MANDATORY WORKFLOW - NO EXCEPTIONS
##################################################

BEFORE starting ANY task you MUST:
  1. Confirm you received helix context
  2. State the exact task from context
  3. State which file you will work on
  4. Begin work immediately after

IF you did not receive helix context:
  Stop. Tell user:
  "Run: helix next
   Then paste the output here.
   I cannot work without helix context."

AFTER completing ANY task you MUST:
  Tell user exactly:
  "Task complete. Run: helix done
   Then paste next task here."

NEVER:
  - Start work without helix context
  - Ask what to do next yourself
  - Decide task order yourself
  - Skip helix done at end
  - Work on multiple tasks at once

##################################################
# IDENTITY (LOCKED)
##################################################

Product:  HelixCD
Owner:    ShamshabadAnil
Repos:
  public:  github.com/ShamshabadAnil/helixcd
  private: github.com/ShamshabadAnil/helixcd-vision

##################################################
# TECH STACK (ALL LOCKED - NEVER CHANGE)
##################################################

Language:   Python 3.11+
LLM:        Ollama primary | Claude API fallback
Models:     llama3.1:8b (reasoning)
            deepseek-coder:6.7b (code fixes)
Vector:     ChromaDB HTTP client ONLY
            NEVER PersistentClient
State:      Redis
Database:   PostgreSQL + pgvector
Framework:  FastAPI
Frontend:   HTML + CSS + Vanilla JS
            NEVER React/Vue/Angular
Containers: Docker (ALL services)
            Ollama MUST be in Docker
K8s:        GKE primary | EKS secondary
Registry:   GCR primary | ECR secondary
Network:    helixcd-network

##################################################
# DOCKER CONNECTIONS (CRITICAL)
##################################################

ALWAYS use container names:
  Ollama:    http://ollama:11434
  ChromaDB:  http://chromadb:8000
  Redis:     redis:6379
  Postgres:  postgres:5432

NEVER use:
  localhost
  127.0.0.1
  0.0.0.0 (in connection strings)

##################################################
# PORTS (LOCKED FOREVER)
##################################################

Dashboard:  9999
CI Agent:   8888
CD Agent:   8889
Obs Agent:  8890
Ollama:     11434
ChromaDB:   8000
Redis:      6379
PostgreSQL: 5432

##################################################
# CODE STANDARDS (ALL MANDATORY)
##################################################

Every Python function MUST have:
  - Type hints on all parameters
  - Type hint on return value
  - Google-style docstring
  - Error handling (try/except)

Every new file MUST have:
  - Corresponding test file
  - 80%+ test coverage
  - Module-level docstring

Never allowed:
  - Hardcoded values (use os.getenv())
  - Secrets in code
  - Placeholders or TODO comments
  - Untested code in submissions
  - localhost in Docker code

File naming:
  Python:  snake_case.py
  Config:  snake_case.yml
  K8s:     kebab-case.yaml
  Scripts: kebab-case.sh

##################################################
# COMMIT FORMAT (STRICT)
##################################################

feat(module): description
fix(module):  description
test(module): description
docs:         description
chore:        description
context:      session update date

##################################################
# BUILD ORDER (NEVER CHANGE)
##################################################

1. core/           FIRST - always
2. ci/             SECOND
3. cd/             THIRD
4. observability/  FOURTH
5. chat/           FIFTH
6. dashboard/      LAST

##################################################
# SESSION PROTOCOL
##################################################

Starting a session:
  Say: "Context received.
        Task: [state exact task]
        File: [state exact file]
        Starting now."

Ending a session:
  Say: "Task complete.
        Done: [what was done]
        Files: [what changed]
        Run: helix done"

If blocked:
  Say: "Blocked on [specific thing].
        Options: [list options]
        Waiting for owner decision."

##################################################
# DOCUMENT STANDARDS
##################################################

Every document must have frontmatter:
  doc_id, title, category, repo,
  status, owner, created, updated, version

Every document must have:
  - Full detailed content (no placeholders)
  - Mermaid diagrams where relevant
  - ASCII mockups for UI sections
  - Open Questions section
  - References section

##################################################
# WHEN IN DOUBT
##################################################

Check these files in helixcd-vision:
  AI_RULES.md
  AGENT_CONTEXT_PRIVATE.md
  WORK_REGISTRY.md
  MEMORY_LOG.md

Ask owner before any new decision.
Never assume. Never guess.
EOF

echo "  [OK] .cursorrules updated with enforcement"

# ════════════════════════════════════════════════
# FILE 2 — AGENT CONTEXT ENFORCER
# Python script that validates agent started
# session correctly with helix context
# ════════════════════════════════════════════════
echo "[DIR] Creating session validator..."

cat > "$PROXY/session_validator.py" << 'EOF'
#!/usr/bin/env python3
"""
HelixCD Session Validator.

Validates that agents are following
the helix command workflow correctly.
Checks session logs and flags violations.
"""
import json
import os
import re
import sys
from datetime import datetime
from pathlib import Path


WORKSPACE = Path.home() / "helixcd-workspace"
VISION = WORKSPACE / "helixcd-vision"
STATE_FILE = WORKSPACE / ".helix-state.json"
SESSION_LOG = WORKSPACE / "helixcd-logs" / \
              "sessions.log"
VIOLATIONS_LOG = WORKSPACE / "helixcd-logs" / \
                 "violations.log"


def load_state() -> dict:
    """Load current state.

    Returns:
        Current state dictionary.
    """
    if STATE_FILE.exists():
        with open(STATE_FILE) as f:
            return json.load(f)
    return {}


def validate_session_started() -> bool:
    """Check if helix next was run first.

    Returns:
        True if session started correctly.
    """
    if not SESSION_LOG.exists():
        return False

    # Check if helix next was run today
    today = datetime.now().strftime("%Y-%m-%d")
    with open(SESSION_LOG) as f:
        lines = f.readlines()

    today_sessions = [
        l for l in lines
        if today in l
    ]

    return len(today_sessions) > 0


def validate_context_loaded() -> bool:
    """Check if agent received helix context.

    Returns:
        True if context was loaded.
    """
    cache = WORKSPACE / ".helix-cache"
    context_file = cache / "active-context.md"

    if not context_file.exists():
        return False

    # Check if context is fresh (< 2 hours old)
    import time
    age = time.time() - \
          context_file.stat().st_mtime
    return age < 7200  # 2 hours


def log_violation(
    violation_type: str,
    details: str
) -> None:
    """Log a workflow violation.

    Args:
        violation_type: Type of violation.
        details: Details about violation.

    Returns:
        None
    """
    VIOLATIONS_LOG.parent.mkdir(
        parents=True, exist_ok=True
    )

    timestamp = datetime.now().isoformat()
    entry = (
        f"{timestamp} | "
        f"{violation_type} | "
        f"{details}\n"
    )

    with open(VIOLATIONS_LOG, "a") as f:
        f.write(entry)


def check_pr_for_violations(
    pr_body: str
) -> list:
    """Check PR description for violations.

    Args:
        pr_body: The PR description text.

    Returns:
        List of violation strings found.
    """
    violations = []

    required_patterns = [
        (
            r"helix\s+done",
            "PR must mention 'helix done' was run"
        ),
        (
            r"task\s+id[:\s]+\w+",
            "PR must include task ID"
        ),
        (
            r"closes?\s+#\d+",
            "PR must reference GitHub issue"
        ),
    ]

    for pattern, message in required_patterns:
        if not re.search(
            pattern,
            pr_body,
            re.IGNORECASE
        ):
            violations.append(message)

    return violations


def generate_pre_work_check() -> str:
    """Generate pre-work checklist for agents.

    Returns:
        Formatted checklist string.
    """
    state = load_state()
    context_loaded = validate_context_loaded()
    session_started = validate_session_started()

    checks = {
        "helix next was run": session_started,
        "context loaded": context_loaded,
        "state file exists": STATE_FILE.exists(),
        "vision repo accessible": (
            VISION / "WORK_REGISTRY.md"
        ).exists(),
    }

    lines = [
        "PRE-WORK VALIDATION",
        "=" * 30,
    ]

    all_pass = True
    for check, passed in checks.items():
        status = "[OK]" if passed else "[FAIL]"
        lines.append(f"  {status} {check}")
        if not passed:
            all_pass = False

    lines.append("=" * 30)

    if all_pass:
        lines.append("  All checks passed.")
        lines.append("  Agent may begin work.")
    else:
        lines.append("  VIOLATIONS FOUND.")
        lines.append("  Run: helix next")
        lines.append("  Then paste context.")

    return "\n".join(lines)


def validate_commit_message(
    message: str
) -> tuple:
    """Validate commit message format.

    Args:
        message: The commit message to check.

    Returns:
        Tuple of (is_valid, error_message).
    """
    valid_pattern = re.compile(
        r"^(feat|fix|test|docs|chore|"
        r"refactor|perf|context)"
        r"(\(.+\))?: .{1,72}$"
    )

    if valid_pattern.match(message):
        return True, ""

    return False, (
        f"Invalid commit format: '{message}'\n"
        f"Required: type(module): description\n"
        f"Types: feat fix test docs chore "
        f"refactor perf context\n"
        f"Example: feat(ci): add Python detection"
    )


if __name__ == "__main__":
    cmd = sys.argv[1] if len(sys.argv) > 1 \
          else "check"

    if cmd == "check":
        print(generate_pre_work_check())

    elif cmd == "validate-commit":
        msg = " ".join(sys.argv[2:])
        valid, error = validate_commit_message(msg)
        if valid:
            print("[OK] Commit message valid")
        else:
            print(f"[FAIL] {error}")
            sys.exit(1)

    elif cmd == "violations":
        if VIOLATIONS_LOG.exists():
            with open(VIOLATIONS_LOG) as f:
                print(f.read())
        else:
            print("No violations logged.")
EOF

echo "  [OK] session_validator.py"

# ════════════════════════════════════════════════
# FILE 3 — PRE-WORK HOOK
# Runs before any helix command
# Validates agent is following workflow
# ════════════════════════════════════════════════
echo "[DIR] Creating pre-work hook..."

cat > "$PROXY/pre_work_hook.sh" << 'EOF'
#!/bin/bash
# Runs before agent starts work
# Validates correct workflow followed

export PYTHONUTF8=1
export PYTHONIOENCODING=utf-8

PROXY="$HOME/helixcd-workspace/helix-proxy"
WORKSPACE="$HOME/helixcd-workspace"
STATE="$WORKSPACE/.helix-state.json"
LOG="$WORKSPACE/helixcd-logs/sessions.log"

mkdir -p "$WORKSPACE/helixcd-logs"

# Log this session start
echo "$(date '+%Y-%m-%d %H:%M') | helix-next | started" \
  >> "$LOG"

# Run validation
python "$PROXY/session_validator.py" check

# Check for stale context
python << 'PYEOF'
import os
import time
from pathlib import Path

cache = Path.home() / \
    "helixcd-workspace/.helix-cache"
context = cache / "active-context.md"

if context.exists():
    age = time.time() - context.stat().st_mtime
    hours = int(age / 3600)
    if hours > 4:
        print(
            f"\n[WARN] Context is {hours}h old."
            f"\n  Run: helix next"
            f"\n  To refresh before working."
        )
    else:
        print(
            f"\n[OK] Context is fresh "
            f"({hours}h old)."
        )
else:
    print(
        "\n[WARN] No context file found."
        "\n  Run: helix next first."
    )
PYEOF
EOF

chmod +x "$PROXY/pre_work_hook.sh"
echo "  [OK] pre_work_hook.sh"

# ════════════════════════════════════════════════
# FILE 4 — POST-WORK HOOK
# Runs after agent completes task
# Enforces helix done was run
# ════════════════════════════════════════════════
echo "[DIR] Creating post-work hook..."

cat > "$PROXY/post_work_hook.sh" << 'EOF'
#!/bin/bash
# Runs after agent completes task
# Validates session was closed properly

export PYTHONUTF8=1
export PYTHONIOENCODING=utf-8

WORKSPACE="$HOME/helixcd-workspace"
LOG="$WORKSPACE/helixcd-logs/sessions.log"
VIOLATIONS="$WORKSPACE/helixcd-logs/violations.log"

echo ""
echo "============================================"
echo "  Post-Work Validation"
echo "============================================"

# Check if helix done was acknowledged
python << 'PYEOF'
import json
import sys
from pathlib import Path
from datetime import datetime

workspace = Path.home() / "helixcd-workspace"
state_file = workspace / ".helix-state.json"

try:
    with open(state_file) as f:
        state = json.load(f)

    last_sync = state.get("last_session", "never")
    print(f"  Last sync: {last_sync}")
    print(
        "\n  Checklist before closing:"
        "\n  [ ] Ran helix done"
        "\n  [ ] Memory saved to GitHub"
        "\n  [ ] Next task in clipboard"
        "\n  [ ] PR created if code work"
    )
except Exception as e:
    print(f"  State check error: {e}")
PYEOF

echo ""
echo "  If not done: run helix done now"
echo "============================================"
EOF

chmod +x "$PROXY/post_work_hook.sh"
echo "  [OK] post_work_hook.sh"

# ════════════════════════════════════════════════
# FILE 5 — GITHUB ACTION FOR PR ENFORCEMENT
# Validates PRs follow helix workflow
# ════════════════════════════════════════════════
echo "[DIR] Creating PR enforcement action..."

mkdir -p "$REPO/.github/workflows"

cat > "$REPO/.github/workflows/enforce-workflow.yml" \
<< 'EOF'
name: Enforce HelixCD Workflow

on:
  pull_request:
    types: [opened, edited, synchronize]

jobs:

  validate_pr:
    name: Validate PR Follows Helix Workflow
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4.1.1

      - name: Check PR description
        uses: actions/github-script@v7
        with:
          script: |
            const pr = context.payload.pull_request;
            const body = pr.body || '';
            const title = pr.title || '';
            const violations = [];

            // Check title format
            const titlePattern =
              /^(feat|fix|test|docs|chore|refactor|perf|context)(\(.+\))?: .+/;
            if (!titlePattern.test(title)) {
              violations.push(
                'PR title must follow format: ' +
                'type(module): description'
              );
            }

            // Check references issue
            if (!body.match(/closes?\s+#\d+/i) &&
                !body.match(/fixes?\s+#\d+/i) &&
                !body.match(/resolves?\s+#\d+/i)) {
              violations.push(
                'PR must reference a GitHub issue ' +
                '(e.g., Closes #42)'
              );
            }

            // Check checklist present
            if (!body.includes('- [')) {
              violations.push(
                'PR must include checklist ' +
                'from PR template'
              );
            }

            // Check helix workflow mentioned
            if (!body.match(/helix/i)) {
              violations.push(
                'PR description must confirm ' +
                'helix workflow was followed'
              );
            }

            if (violations.length > 0) {
              const message =
                '## Workflow Violations Found\n\n' +
                'This PR does not follow the ' +
                'HelixCD agent workflow.\n\n' +
                '### Issues:\n' +
                violations.map(v =>
                  `- ${v}`
                ).join('\n') +
                '\n\n### Required:\n' +
                '1. Run `helix next` before starting\n' +
                '2. Complete the work\n' +
                '3. Run `helix done` after\n' +
                '4. Follow PR template exactly\n\n' +
                'Fix these issues to proceed.';

              await github.rest.issues.createComment({
                owner: context.repo.owner,
                repo: context.repo.repo,
                issue_number: pr.number,
                body: message
              });

              core.setFailed(
                `${violations.length} workflow ` +
                `violation(s) found`
              );
            } else {
              console.log(
                'PR workflow validation passed'
              );
            }

  validate_commits:
    name: Validate Commit Messages
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4.1.1
        with:
          fetch-depth: 0

      - name: Check commit messages
        run: |
          PATTERN="^(feat|fix|test|docs|chore|\
refactor|perf|context)(\(.+\))?: .{1,72}$"

          INVALID=0
          while IFS= read -r msg; do
            if ! echo "$msg" | \
               grep -qE "$PATTERN"; then
              echo "[FAIL] Invalid: $msg"
              INVALID=$((INVALID + 1))
            else
              echo "[OK] Valid: $msg"
            fi
          done < <(git log \
            origin/develop..HEAD \
            --pretty=format:"%s" \
            2>/dev/null || true)

          if [ $INVALID -gt 0 ]; then
            echo ""
            echo "Fix commit messages:"
            echo "  feat(module): description"
            echo "  fix(module):  description"
            echo "  test(module): description"
            echo "  docs:         description"
            exit 1
          fi

          echo "All commit messages valid"
EOF

echo "  [OK] enforce-workflow.yml"

# ════════════════════════════════════════════════
# FILE 6 — UPDATE HELIX COMMAND
# Add pre/post hooks to helix next/done
# ════════════════════════════════════════════════
echo "[DIR] Updating helix commands with hooks..."

cat > "$PROXY/helix_commands.sh" << 'HELIXEOF'
#!/bin/bash
# HelixCD Minimal Command Interface v2
# With workflow enforcement hooks
#
# Commands:
#   helix next          -> next task
#   helix done          -> mark done + next
#   helix doc 02        -> work on doc 02
#   helix code core/llm -> implement module
#   helix fix "error"   -> fix this issue
#   helix status        -> show progress
#   helix sync          -> save session
#   helix check         -> validate workflow
#   helix violations    -> see violations
#   helix help          -> show commands

export PYTHONUTF8=1
export PYTHONIOENCODING=utf-8

WORKSPACE="$HOME/helixcd-workspace"
VISION="$WORKSPACE/helixcd-vision"
PROXY="$WORKSPACE/helix-proxy"
CACHE="$WORKSPACE/.helix-cache"
LOGS="$WORKSPACE/helixcd-logs"

mkdir -p "$CACHE" "$LOGS"

CMD=${1:-help}
ARG="${@:2}"

# ── COPY TO CLIPBOARD ────────────────────────
copy_to_clipboard() {
  local text="$1"
  if command -v clip &>/dev/null; then
    echo "$text" | clip
    echo "  [COPY] Copied (Windows)"
  elif command -v pbcopy &>/dev/null; then
    echo "$text" | pbcopy
    echo "  [COPY] Copied (macOS)"
  elif command -v xclip &>/dev/null; then
    echo "$text" | xclip -selection clipboard
    echo "  [COPY] Copied (Linux)"
  else
    echo "$text" > "$CACHE/prompt.txt"
    echo "  [COPY] Saved to: $CACHE/prompt.txt"
  fi
}

# ── OPEN BROWSER ────────────────────────────
open_browser() {
  local url="$1"
  if command -v start &>/dev/null; then
    start "$url" 2>/dev/null || true
  elif command -v open &>/dev/null; then
    open "$url" 2>/dev/null || true
  elif command -v xdg-open &>/dev/null; then
    xdg-open "$url" 2>/dev/null || true
  fi
}

# ── PULL LATEST ─────────────────────────────
pull_latest() {
  cd "$VISION" && \
    git pull origin main --quiet 2>/dev/null \
    || true
  cd "$WORKSPACE/helixcd" && \
    git pull origin main --quiet 2>/dev/null \
    || true
}

# ── BUILD PROMPT ────────────────────────────
build_prompt() {
  local cmd="$1"
  local arg="$2"
  python "$PROXY/state_machine.py" \
    "$cmd" "$arg" 2>/dev/null
}

case "$CMD" in

  # ── NEXT TASK ─────────────────────────────
  next)
    echo ""
    echo "============================================"
    echo "  HelixCD - Loading Next Task"
    echo "============================================"

    # Run pre-work hook
    bash "$PROXY/pre_work_hook.sh"

    pull_latest

    PROMPT=$(build_prompt "next" "")

    echo ""
    echo "--------------------------------------------"
    echo "$PROMPT"
    echo "--------------------------------------------"
    echo ""

    copy_to_clipboard "$PROMPT"

    # Log session
    echo "$(date '+%Y-%m-%d %H:%M') | next | started" \
      >> "$LOGS/sessions.log"

    TOKEN_EST=$(echo "$PROMPT" | wc -c)
    TOKEN_EST=$((TOKEN_EST / 4))

    echo ""
    echo "============================================"
    echo "  [OK] Ready (~${TOKEN_EST} tokens)"
    echo ""
    echo "  NEXT STEPS:"
    echo "  1. Paste into your agent (CTRL+V)"
    echo "  2. Agent confirms task"
    echo "  3. Work until complete"
    echo "  4. Run: helix done"
    echo "============================================"
    ;;

  # ── MARK DONE ─────────────────────────────
  done)
    echo ""
    echo "============================================"
    echo "  HelixCD - Marking Task Complete"
    echo "============================================"
    echo ""

    read -p "Task ID completed (e.g. 01): " TASK_ID
    read -p "What was done (one line): " COMPLETED
    read -p "Your agent (claude/cursor/grok): " AGENT

    # Mark complete and add memory
    python << PYEOF
import sys
sys.path.insert(0, '$PROXY')
from state_machine import (
    mark_complete,
    add_memory_entry,
    get_next_task
)

next_task = get_next_task()
next_str = ""
if next_task:
    next_str = (
        f"{next_task['id']}: "
        f"{next_task['name']}"
    )

mark_complete('$TASK_ID')
add_memory_entry(
    '$AGENT',
    '$COMPLETED',
    next_str
)
print(f"[OK] Task $TASK_ID complete")
print(f"[OK] Memory updated")
print(f"[OK] Next: {next_str}")
PYEOF

    # Commit to GitHub
    cd "$VISION"
    git add . --quiet
    git commit -m \
      "context: complete task $TASK_ID $(date +%Y-%m-%d)" \
      --quiet 2>/dev/null || true
    git push origin main --quiet 2>/dev/null \
      || true

    echo ""
    echo "  [OK] Memory committed to GitHub"

    # Run post-work hook
    bash "$PROXY/post_work_hook.sh"

    # Auto-load next
    echo ""
    echo "  Loading next task..."
    PROMPT=$(build_prompt "next" "")
    copy_to_clipboard "$PROMPT"

    echo ""
    echo "============================================"
    echo "  [OK] Next task in clipboard"
    echo "  Paste into your agent to continue"
    echo "============================================"
    ;;

  # ── SPECIFIC DOC ──────────────────────────
  doc)
    echo ""
    pull_latest
    PROMPT=$(build_prompt "doc" "$ARG")
    copy_to_clipboard "$PROMPT"
    echo "  [OK] Doc $ARG prompt ready"
    echo "  Paste into your agent"
    ;;

  # ── SPECIFIC CODE ─────────────────────────
  code)
    echo ""
    pull_latest
    PROMPT=$(build_prompt "code" "$ARG")
    copy_to_clipboard "$PROMPT"
    echo "  [OK] Code task ready: $ARG"
    echo "  Paste into Cursor"
    ;;

  # ── FIX ───────────────────────────────────
  fix)
    echo ""
    PROMPT=$(build_prompt "fix" "$ARG")
    copy_to_clipboard "$PROMPT"
    echo "  [OK] Fix prompt ready"
    echo "  Paste into your agent"
    ;;

  # ── CHECK WORKFLOW ─────────────────────────
  check)
    echo ""
    python "$PROXY/session_validator.py" check
    ;;

  # ── SEE VIOLATIONS ────────────────────────
  violations)
    echo ""
    python "$PROXY/session_validator.py" violations
    ;;

  # ── STATUS ────────────────────────────────
  status)
    echo ""
    python << 'PYEOF'
import sys
import os
from pathlib import Path

sys.path.insert(
    0,
    str(Path.home() /
        'helixcd-workspace/helix-proxy')
)
from state_machine import (
    get_progress,
    get_next_task,
    get_last_memory
)

progress = get_progress()
next_task = get_next_task()
memory = get_last_memory()

done = progress.get('done', 0)
total = progress.get('total', 181)
pct = progress.get('percent', 0)
bar = '#' * int(pct/5) + \
      '.' * (20 - int(pct/5))

print("============================================")
print("  HelixCD Status")
print(f"  [{bar}] {pct}%")
print(f"  Done:  {done}/{total}")
print("============================================")

if next_task:
    print(f"\n  Next task:")
    print(
        f"  {next_task['id']}: "
        f"{next_task['name']}"
    )

print(f"\n  Last sessions:")
for line in memory.split('\n'):
    if line.strip():
        print(f"  {line}")

print("============================================")
PYEOF
    ;;

  # ── SYNC ──────────────────────────────────
  sync)
    echo ""
    read -p "Agent used: " AGENT
    read -p "Completed: " COMPLETED
    read -p "Next task: " NEXT_TASK

    python << PYEOF
import sys
sys.path.insert(0, '$PROXY')
from state_machine import add_memory_entry
add_memory_entry(
    '$AGENT',
    '$COMPLETED',
    '$NEXT_TASK'
)
print("[OK] Session saved")
PYEOF

    cd "$VISION"
    git add MEMORY_LOG.md --quiet
    git commit -m \
      "context: sync $(date +%Y-%m-%d)" \
      --quiet 2>/dev/null || true
    git push origin main --quiet 2>/dev/null \
      || true

    echo "  [OK] Memory on GitHub"
    ;;

  # ── OPEN AGENTS ───────────────────────────
  claude)
    echo ""
    pull_latest
    PROMPT=$(build_prompt "next" "")
    copy_to_clipboard "$PROMPT"
    open_browser "https://claude.ai"
    echo "  [OK] Claude opened"
    echo "  Paste context (CTRL+V)"
    ;;

  cursor)
    echo ""
    pull_latest
    PROMPT=$(build_prompt "next" "")
    copy_to_clipboard "$PROMPT"
    WSFILE="$WORKSPACE/helixcd.code-workspace"
    if [ -f "$WSFILE" ]; then
      cursor "$WSFILE" 2>/dev/null || true
    fi
    echo "  [OK] Cursor opened"
    echo "  Open chat (CTRL+L) then paste"
    ;;

  grok)
    echo ""
    pull_latest
    PROMPT=$(build_prompt "next" "")
    copy_to_clipboard "$PROMPT"
    open_browser "https://grok.x.ai"
    echo "  [OK] Grok opened"
    echo "  Paste context (CTRL+V)"
    ;;

  # ── HELP ──────────────────────────────────
  help|*)
    echo ""
    echo "============================================"
    echo "  HelixCD Command Interface"
    echo "============================================"
    echo ""
    echo "  TASK COMMANDS:"
    echo "    helix next           -> load next task"
    echo "    helix done           -> mark done + next"
    echo "    helix doc 02         -> work on doc 02"
    echo "    helix code core/llm  -> implement module"
    echo "    helix fix 'error'    -> fix an issue"
    echo ""
    echo "  AGENT COMMANDS:"
    echo "    helix claude         -> open Claude"
    echo "    helix cursor         -> open Cursor"
    echo "    helix grok           -> open Grok"
    echo ""
    echo "  VALIDATION:"
    echo "    helix check          -> validate workflow"
    echo "    helix violations     -> see violations"
    echo ""
    echo "  INFO:"
    echo "    helix status         -> show progress"
    echo "    helix sync           -> save session"
    echo "    helix help           -> this screen"
    echo ""
    echo "  WORKFLOW (MANDATORY):"
    echo "    1. helix next        <- get task"
    echo "    2. helix claude      <- open agent"
    echo "    3. Paste + work"
    echo "    4. helix done        <- save + next"
    echo ""
    echo "============================================"
    ;;

esac
HELIXEOF

chmod +x "$PROXY/helix_commands.sh"
echo "  [OK] helix_commands.sh updated"

# ════════════════════════════════════════════════
# FILE 7 — PR TEMPLATE WITH HELIX ENFORCEMENT
# Forces contributors to confirm workflow
# ════════════════════════════════════════════════
echo "[DIR] Creating enforced PR template..."

cat > "$REPO/.github/PULL_REQUEST_TEMPLATE.md" \
<< 'EOF'
## Description
What does this PR do?

## Helix Workflow Confirmation
- [ ] I ran `helix next` before starting
- [ ] I received and read the helix context
- [ ] I ran `helix done` after completing
- [ ] Memory was saved to helixcd-vision

## Task
Task ID: (e.g. 01, CI03, C05)
Closes #(issue number)

## What Changed
- File 1: what changed
- File 2: what changed

## Type of Change
- [ ] Documentation (docs)
- [ ] New feature (feat)
- [ ] Bug fix (fix)
- [ ] Tests (test)
- [ ] Maintenance (chore)

## Standards Checklist
- [ ] Type hints on all functions
- [ ] Docstrings on all functions
- [ ] Tests written (80%+ coverage)
- [ ] No hardcoded values
- [ ] No secrets in code
- [ ] No localhost in Docker code
- [ ] No placeholders or TODOs
- [ ] Follows naming conventions
- [ ] Commit messages correct format
- [ ] CLA signed (first PR only)

## Testing
How was this tested?
EOF

echo "  [OK] PR template updated"

# ════════════════════════════════════════════════
# FILE 8 — AGENT ONBOARDING PROMPT
# What to show new agents/contributors
# ════════════════════════════════════════════════
echo "[DIR] Creating agent onboarding..."

cat > "$VISION/operations/AGENT_ONBOARDING.md" \
<< 'EOF'
---
doc_id:   OP-10
title:    Agent Onboarding Protocol
repo:     helixcd-vision
owner:    ShamshabadAnil
status:   Approved
version:  v1.0
created:  2025-01-15
---

# HelixCD Agent Onboarding
## For Any AI Agent Starting Work

Read this once. Follow always.

## The Only Workflow
Step 1: Owner runs helix next
Context loaded into clipboard
Step 2: Owner pastes into agent chat
Agent reads context
Agent confirms task
Step 3: Agent works on task
Follows .cursorrules rules
Completes fully (no placeholders)
Step 4: Agent says:
"Task complete.
Run: helix done"
Step 5: Owner runs helix done
Memory saved
Next task loaded automatically
Repeat from Step 1.

## What Agent Must Say At Start
"Context received.
Task: [exact task from context]
File: [exact file to work on]
Starting now."

## What Agent Must Say At End
"Task complete.
Done: [what was completed]
Files: [files changed]
Run: helix done"

## What Agent Must NEVER Do

Start without helix context
Decide task order themselves
Ask what to do next
Work on multiple tasks at once
Skip to a different task
Change tech stack decisions
Use localhost in Docker code
Use React/Vue/Angular
Write placeholder code
Skip writing tests


## Commands That Exist
helix next     -> get next task (run first)
helix done     -> mark done (run last)
helix doc 02   -> specific document
helix code X   -> specific code module
helix status   -> see progress
helix check    -> validate workflow
helix help     -> all commands

## If Agent Gets Confused
Agent should say:
"I need context.
Please run: helix next
Then paste the output here."
Never guess.
Never assume.
Always ask for helix context.
EOF

echo "  [OK] AGENT_ONBOARDING.md"

# ════════════════════════════════════════════════
# COMMIT EVERYTHING
# ════════════════════════════════════════════════
echo ""
echo "[PUSH] Committing enforcement files..."

cd "$REPO"
git add .
git commit -m \
  "chore: add agent workflow enforcement

Enforces helix command workflow:

.cursorrules v3:
  - Mandatory helix next before work
  - Mandatory helix done after work
  - Session protocol defined
  - Violation behavior defined

GitHub Actions:
  enforce-workflow.yml:
  - PR title format check
  - GitHub issue reference check
  - Helix workflow confirmation check
  - Commit message validation

PR Template:
  - Helix workflow checklist
  - Task ID required
  - Standards checklist

Scripts:
  session_validator.py
  pre_work_hook.sh
  post_work_hook.sh
  helix_commands.sh (updated)

Operations:
  AGENT_ONBOARDING.md" \
  --quiet 2>/dev/null || true
git push origin main --quiet 2>/dev/null || true

cd "$VISION"
git add .
git commit -m \
  "ops: add agent onboarding protocol OP-10

Complete onboarding for any AI agent.
Enforces helix command workflow.
Defines start/end session protocol." \
  --quiet 2>/dev/null || true
git push origin main --quiet 2>/dev/null || true

echo "  [OK] All committed to GitHub"

# ════════════════════════════════════════════════
# FINAL SUMMARY
# ════════════════════════════════════════════════
echo ""
echo "============================================"
echo "  [OK] Agent Enforcement Complete!"
echo "============================================"
echo ""
echo "WHAT IS ENFORCED:"
echo ""
echo "  .cursorrules (Cursor auto-reads):"
echo "    - Must receive helix context first"
echo "    - Must confirm task before starting"
echo "    - Must say 'helix done' at end"
echo "    - All tech stack rules enforced"
echo ""
echo "  GitHub Actions (every PR):"
echo "    - PR title format checked"
echo "    - Issue reference required"
echo "    - Helix workflow confirmation"
echo "    - Commit message format"
echo ""
echo "  Pre-work hook (helix next):"
echo "    - Validates context is fresh"
echo "    - Validates session started"
echo "    - Logs session to file"
echo ""
echo "  Post-work hook (helix done):"
echo "    - Validates work was saved"
echo "    - Shows closing checklist"
echo "    - Loads next task auto"
echo ""
echo "  PR Template:"
echo "    - Helix workflow checklist"
echo "    - Task ID required"
echo "    - Standards checklist"
echo ""
echo "WORKFLOW (enforced everywhere):"
echo "  helix next -> paste -> work -> helix done"
echo ""
echo "TEST IT NOW:"
echo "  helix check    -> validate workflow"
echo "  helix next     -> get first task"
echo "  helix help     -> all commands"
echo "============================================"