---
file:       .github/AGENT_GUIDE.md
repo:       helixcd (PUBLIC)
owner:      ShamshabadAnil
version:    v1.0
created:    2025-01-15
updated:    2025-01-15
purpose:    Guide for all contributors
            using AI agents to work
            on HelixCD codebase.
            Read before using ANY AI tool.
---

# HelixCD — AI Agent Guide
## For All Contributors

═══════════════════════════════════════════════════
WELCOME
═══════════════════════════════════════════════════

This guide tells you exactly how to use
AI tools (Claude, Cursor, Copilot, Grok,
GPT etc) when contributing to HelixCD.

Following this guide ensures:
✅ Your work is consistent with everyone else
✅ You don't duplicate work already done
✅ Your PRs get approved faster
✅ AI agents follow our exact standards
✅ No wasted effort or context

Not following this guide means:
❌ Your PR will likely be rejected
❌ You may duplicate completed work
❌ Code won't match our standards
❌ Owner has to rewrite your code

Read this entire guide before
touching any code or AI tool.

═══════════════════════════════════════════════════
PART 1 — BEFORE YOU START ANYTHING
═══════════════════════════════════════════════════

## Step 1: Read These Files (in order)

1. This file (AGENT_GUIDE.md)
   You are reading it now ✅

2. AGENT_CONTEXT_PUBLIC.md
   Root of this repo
   Full technical context of HelixCD

3. AI_RULES.md
   Root of this repo
   Non-negotiable rules for all agents

4. Relevant design document
   Ask ShamshabadAnil for access to
   helixcd-vision repo (private)
   Read the doc for your specific task

5. CONTRIBUTING.md
   Root of this repo
   PR and contribution process

## Step 2: Check What Is Available

Open a GitHub Issue for your task:
github.com/ShamshabadAnil/helixcd/issues

Check if your task already exists:
→ If it exists and is assigned → STOP
  Someone else is doing this
  Comment on issue if you want to help

→ If it exists and is unassigned → claim it
  Comment: "I am working on this"
  Wait for owner to assign to you

→ If it does not exist → create it
  Use the issue template
  Wait for owner to approve and assign

Never start work without a GitHub Issue.
Never start work without owner assignment.

## Step 3: Get Design Doc Access

Message ShamshabadAnil:
"I am working on Issue #{number}
 Task: {task name}
 I need access to the relevant
 design doc in helixcd-vision"

Owner will share the specific doc.
Read it completely before writing code.
Your code must match the design exactly.

═══════════════════════════════════════════════════
PART 2 — SETTING UP YOUR AI AGENT
═══════════════════════════════════════════════════

## For Cursor (Recommended)

Step 1: Open helixcd repo in Cursor
  cursor.sh → Open from GitHub
  → ShamshabadAnil/helixcd

Step 2: .cursorrules auto-loads
  Cursor reads .cursorrules automatically
  All HelixCD standards are pre-loaded
  You do not need to paste rules manually

Step 3: Open AI chat (CMD + L)
  Paste this at start of session:

"I am contributing to HelixCD.
 I have read AGENT_GUIDE.md,
 AGENT_CONTEXT_PUBLIC.md and
 AI_RULES.md.

 My task: {task description}
 GitHub Issue: #{number}
 Design doc: {doc name from vision repo}

 Design doc content:
 {paste relevant design doc here}

 Help me implement {specific file}
 following all HelixCD standards
 defined in .cursorrules."

Step 4: Cursor implements following
  Your exact standards automatically.

## For Claude (claude.ai)

Step 1: Open new conversation

Step 2: Paste this at start:

"I am contributing to HelixCD
 (github.com/ShamshabadAnil/helixcd).

 Read these files first:

 === AGENT_CONTEXT_PUBLIC.md ===
 {paste entire file content}

 === AI_RULES.md ===
 {paste entire file content}

 === DESIGN DOC ===
 {paste relevant design doc}

 My task: {task description}
 Issue: #{number}

 Help me implement {specific file}
 following all HelixCD standards."

Step 3: Claude follows your standards.

## For GitHub Copilot

Step 1: Open helixcd in VS Code or Cursor
  .cursorrules auto-loads
  Copilot reads it automatically

Step 2: Add comment at top of file:
  # HelixCD standards apply
  # See .cursorrules for details
  # See AGENT_CONTEXT_PUBLIC.md

Step 3: Copilot suggests code following
  your standards automatically.

## For Any Other AI Tool

Start every session with:
"Read these rules before helping:
 [paste AI_RULES.md]
 [paste AGENT_CONTEXT_PUBLIC.md]
 [paste relevant design doc]

 Follow these standards exactly.
 No exceptions."

═══════════════════════════════════════════════════
PART 3 — WORKING ON YOUR TASK
═══════════════════════════════════════════════════

## What AI Can Help You With
✅ Implementing code from design docs
✅ Writing unit tests for your code
✅ Fixing bugs in your code
✅ Writing docstrings and type hints
✅ Reviewing your own code
✅ Suggesting improvements to your PR

## What AI Cannot Decide For You
❌ Architecture decisions
   → those are in design docs already
❌ Tech stack choices
   → locked, see AI_RULES.md
❌ New dependencies
   → need owner approval first
❌ Changes to core/ library
   → owner only
❌ Port changes
   → locked forever
❌ Naming conventions
   → locked in AI_RULES.md

## If AI Suggests Something Wrong
AI may sometimes suggest things that
violate our standards. If AI suggests:

→ Using React, Vue or any JS framework
  REJECT it. We use plain HTML/JS only.

→ Using localhost in Docker
  REJECT it. Use container names.

→ Changing the tech stack
  REJECT it. Stack is locked.

→ Skipping tests
  REJECT it. Tests always required.

→ Using PersistentClient for ChromaDB
  REJECT it. Always use HttpClient.

→ Installing Ollama on macOS
  REJECT it. Docker only.

When AI suggests something wrong:
Tell it: "This violates HelixCD rules.
         Read AI_RULES.md section {X}.
         Suggest an alternative that
         follows our standards."

## Code Quality Checklist
Before submitting any AI-generated code:

□ Python 3.11+ syntax only
□ PEP8 compliant (run: flake8 .)
□ Type hints on ALL functions
□ Docstrings on ALL functions
□ No hardcoded values
□ No secrets or credentials
□ No localhost (use container names)
□ Tests written (min 80% coverage)
□ Tests passing (run: pytest)
□ No placeholder or TODO comments
□ Error handling on external calls
□ Follows naming conventions

═══════════════════════════════════════════════════
PART 4 — SUBMITTING YOUR WORK
═══════════════════════════════════════════════════

## Branch Strategy

Never push to main directly.
Never push to develop directly.
Always work on feature branch.

Create your branch:
```bash
# From develop branch
git checkout develop
git pull origin develop
git checkout -b feature/{your-task-name}

# Examples:
git checkout -b feature/ci-python-stack-detection
git checkout -b fix/cd-gke-auth-timeout
git checkout -b docs/update-getting-started
```

## Commit Format (strict)

Every commit must follow this format:
type(module): short description
Longer description if needed.
Explain WHY not WHAT.
Closes #{issue-number}

Types:
feat     → new feature
fix      → bug fix
test     → adding tests
docs     → documentation
chore    → maintenance
refactor → code restructure
perf     → performance

Examples:
feat(ci): add Python stack detection
Detects Python projects via presence of
requirements.txt, Pipfile, or pyproject.toml.
Runs pytest as test runner automatically.
Closes #42
fix(cd): handle GKE auth token expiry
GKE auth tokens expire after 1 hour.
Added automatic re-authentication when
401 response received from cluster.
Closes #67

## PR Requirements

Before creating PR ensure:
□ All tests pass locally
   pytest --cov=. --cov-report=term
□ Coverage above 80%
□ No flake8 errors
   flake8 . --max-line-length=79
□ Branch is up to date with develop
   git rebase develop
□ Commits are clean and logical
□ No merge commits (use rebase)

## Creating Your PR

Go to:
github.com/ShamshabadAnil/helixcd/pulls

Click: New Pull Request
Base: develop (NOT main)
Compare: your feature branch

PR Title format:
feat(ci): add Python stack detection

PR Description template:
What This PR Does
Brief description of changes.
Why
Explain the problem this solves.
How To Test
Steps to verify the changes work.
Checklist

 Tests written and passing
 Coverage above 80%
 No flake8 errors
 Type hints on all functions
 Docstrings on all functions
 No hardcoded values
 No secrets in code
 Follows naming conventions
 Design doc followed exactly
 I have signed the CLA

Related Issue
Closes #{number}
Design Doc Referenced
{doc name from helixcd-vision}
## After Submitting PR

Wait for owner review.
Do NOT merge your own PR.
Do NOT approve your own PR.
Respond to review comments promptly.
Make requested changes on same branch.
Push updates → PR auto-updates.

Owner (ShamshabadAnil) will:
→ Review your code
→ Request changes if needed
→ Approve when ready
→ Merge to develop
→ You get credit in CHANGELOG

═══════════════════════════════════════════════════
PART 5 — MODULE ASSIGNMENTS
═══════════════════════════════════════════════════

## Who Works On What

HelixCD has assigned modules.
Work only on your assigned module.
Do NOT touch other modules without
explicit permission from owner.

Core Library (core/):
  Owner: ShamshabadAnil only
  Reason: All agents depend on this
  Status: Not open to contributors yet

CI Agent (ci/):
  Lead: Friend 1
  Open to: CI Specialist contributors
  Ask owner before contributing here

CD Agent (cd/):
  Lead: Friend 2
  Open to: CD Specialist contributors
  Ask owner before contributing here

Observability (observability/):
  Lead: Friend 3
  Open to: Observability contributors
  Ask owner before contributing here

Dashboard (dashboard/):
  Lead: Friend 4
  Open to: Frontend contributors
  Ask owner before contributing here

Infrastructure (docker/ k8s/ scripts/):
  Lead: Friend 5
  Open to: DevOps contributors
  Ask owner before contributing here

Examples (examples/):
  Open to: All contributors
  Good first contribution

Documentation (docs/):
  Open to: All contributors
  Good first contribution

Tests (tests/):
  Open to: All contributors
  Always welcome

## Good First Issues
Look for issues labeled:
  good first issue
  help wanted
  documentation
  examples

These are safe starting points
that don't require deep knowledge
of the full system.

═══════════════════════════════════════════════════
PART 6 — AI AGENT HANDOFF PROCESS
═══════════════════════════════════════════════════

## If You Use Multiple AI Tools

Sometimes you start with Claude
and continue with Cursor or Grok.
Here is how to hand off correctly.

## Session Handoff Template

At end of Claude session ask:
"Give me a handoff summary I can
 use to continue in Cursor."

Claude will give you:
HELIXCD SESSION HANDOFF
─────────────────────────
Task:     {task name}
File:     {file being worked on}
Status:   {what is done so far}
Code so far:
{paste current code}
Next step:
{exactly what needs to happen next}
Standards reminder:

Python 3.11+
Type hints required
Tests required
No localhost in Docker
In Cursor paste:
"Continue this HelixCD session:
 [paste handoff summary]

 Follow .cursorrules standards.
 Continue from where Claude left off."

## Multi-Session Rule
Keep sessions focused.
One session = one file or one function.
Don't try to do everything in one session.
Small focused sessions = better output.

═══════════════════════════════════════════════════
PART 7 — COMMUNICATION
═══════════════════════════════════════════════════

## Where To Ask Questions

GitHub Discussions (preferred):
github.com/ShamshabadAnil/helixcd/discussions
→ Technical questions
→ Design clarifications
→ Architecture questions
→ Getting started help

GitHub Issues:
github.com/ShamshabadAnil/helixcd/issues
→ Bug reports
→ Feature requests
→ Task tracking only

Discord (community):
{invite link — coming soon}
→ General chat
→ Quick questions
→ Progress updates

Direct to owner:
GitHub: @ShamshabadAnil
→ Access to helixcd-vision docs
→ Module assignment requests
→ Architecture decisions
→ Urgent issues only

## Response Time Expectations
GitHub Discussions: 24-48 hours
GitHub Issues: 24-48 hours
PR Reviews: 48-72 hours
Discord: best effort

## What Makes A Good Question
Bad:  "It doesn't work"
Good: "I am implementing ci/stack_detector.py
       following design doc 16.
       Getting error: {error message}
       Code: {relevant code}
       Expected: {what should happen}
       Actual: {what is happening}"

Always include:
→ What you are working on
→ What you have tried
→ Exact error message
→ Relevant code snippet
→ Expected vs actual behavior

═══════════════════════════════════════════════════
PART 8 — RECOGNITION
═══════════════════════════════════════════════════

## How Contributors Are Credited

CHANGELOG.md:
  Every merged PR listed
  Your GitHub username credited

README.md:
  Contributors section
  Listed after 3+ merged PRs

Release notes:
  Major contributions highlighted
  Feature credited to author

Core contributors:
  After consistent contribution
  Listed as core team member
  Given additional repo permissions

## Contributor Levels

Level 1: Contributor
  Requirements: 1+ merged PR
  Perks: Listed in CHANGELOG

Level 2: Regular Contributor
  Requirements: 5+ merged PRs
  Perks: Listed in README

Level 3: Core Contributor
  Requirements: 10+ merged PRs
               Consistent quality
               Owner invitation
  Perks: Read access to helixcd-vision
         Listed as core team member
         Input on roadmap discussions

Level 4: Module Maintainer
  Requirements: Owner assignment
  Perks: Review PRs in your module
         Merge PRs in your module
         Direct line to owner

═══════════════════════════════════════════════════
PART 9 — RULES SUMMARY
═══════════════════════════════════════════════════

## Quick Rules Reference

Always:
✅ Read context before working
✅ Check for existing issue first
✅ Work on feature/* branch
✅ Write tests with code
✅ Follow naming conventions
✅ Add type hints everywhere
✅ Add docstrings everywhere
✅ Sign CLA on first PR
✅ Wait for owner to merge

Never:
❌ Push to main directly
❌ Merge your own PR
❌ Use React/Vue/Angular
❌ Use localhost in Docker
❌ Skip writing tests
❌ Leave placeholder code
❌ Hardcode values
❌ Put secrets in code
❌ Change tech stack
❌ Start without GitHub Issue

═══════════════════════════════════════════════════
PART 10 — GETTING HELP
═══════════════════════════════════════════════════

## Stuck? Here Is What To Do

Step 1: Re-read the design doc
  Most answers are in the design doc.
  Read it again carefully.

Step 2: Check existing code
  Look at similar files in the repo.
  Follow the same patterns.

Step 3: Ask your AI agent
  Paste context files + design doc.
  Ask specific question.

Step 4: GitHub Discussions
  Post your specific question.
  Include all relevant details.

Step 5: Discord
  Ask in community channel.
  Someone may have faced same issue.

Step 6: Tag owner
  Last resort only.
  @ShamshabadAnil in the issue.
  Include everything you have tried.

## Most Common Mistakes

Mistake 1: Starting without reading context
Fix: Read AGENT_CONTEXT_PUBLIC.md first

Mistake 2: Using wrong ChromaDB client
Fix: Always use HttpClient not PersistentClient
     client = chromadb.HttpClient(
         host="chromadb", port=8000)

Mistake 3: Using localhost in Docker
Fix: Use container name
     http://ollama:11434 not localhost:11434

Mistake 4: Missing type hints
Fix: Every function parameter and return
     def process(data: str) -> dict:

Mistake 5: Missing docstrings
Fix: Every function needs Google-style doc
     """Brief description.
     Args: ...
     Returns: ...
     """

Mistake 6: Skipping tests
Fix: Write test file alongside your code
     tests/unit/test_{your_module}.py

Mistake 7: Hardcoded values
Fix: Use environment variables
     os.getenv("OLLAMA_HOST", "http://ollama:11434")

Mistake 8: Wrong commit format
Fix: feat(module): description
     NOT "fixed stuff" or "updates"