---
file:       AI_RULES.md
repo:       helixcd-vision (PRIVATE)
            helixcd (PUBLIC) — copy exact
owner:      ShamshabadAnil
updater:    ShamshabadAnil only
version:    v1.0
created:    2025-01-15
updated:    2025-01-15
applies_to: ALL AI agents working on HelixCD
            Claude, Grok, Cursor, GPT, Gemini
            Any AI tool used on this project
---

# HelixCD — AI Agent Rules
## Non-Negotiable. No Exceptions. Ever.
## Every agent reads this before doing anything.

═══════════════════════════════════════════════════
RULE 0 — STARTUP PROTOCOL
═══════════════════════════════════════════════════

Before doing ANYTHING in any session:

Step 1: Read AI_RULES.md (this file) fully
Step 2: Read AGENT_CONTEXT_PRIVATE.md (private repo)
        OR AGENT_CONTEXT_PUBLIC.md (public repo)
Step 3: Read last 3 entries in MEMORY_LOG.md
Step 4: Check WORK_REGISTRY.md for task status
Step 5: Confirm readiness to owner:

Say exactly this:
"I have read:
 ✅ AI_RULES.md
 ✅ AGENT_CONTEXT_{version}.md
 ✅ MEMORY_LOG.md (last 3 entries)
 ✅ WORK_REGISTRY.md

 Last session summary: {one line}
 Current task: {task name}
 Ready to continue."

If you skip ANY of steps 1-4:
→ You WILL duplicate work
→ You WILL break standards
→ You WILL undo decisions
→ Owner WILL reject output
→ Work WILL be wasted

═══════════════════════════════════════════════════
RULE 1 — IDENTITY RULES
═══════════════════════════════════════════════════

## Product Identity (ALL LOCKED)

✅ ALWAYS use exact names:
   Product:    "HelixCD" (capital H, capital CD)
   CI Agent:   "HelixCD CI Agent"
   CD Agent:   "HelixCD CD Agent"
   Obs Agent:  "HelixCD Observability Agent"
   Chat:       "HelixCD Chat Engine"
   Owner:      "ShamshabadAnil"
   License:    "MIT License"

❌ NEVER:
   Write "Helix" alone (always "HelixCD")
   Write "helix-cd" (always "HelixCD")
   Write "helixcd" in prose (always "HelixCD")
   Suggest renaming the product
   Suggest rebranding
   Create new sub-product names
   Add co-owners or co-founders
   Change the license type
   Suggest a different license

## Repository Identity (LOCKED)
Public:  github.com/ShamshabadAnil/helixcd
Private: github.com/ShamshabadAnil/helixcd-vision

❌ NEVER suggest moving to org account
❌ NEVER suggest making private repo public
❌ NEVER suggest merging the two repos

═══════════════════════════════════════════════════
RULE 2 — TECHNOLOGY RULES
═══════════════════════════════════════════════════

## Tech Stack Is Locked
Do not suggest alternatives.
Do not question these choices.
Do not add new technologies
without explicit owner approval.

LOCKED STACK:
Language:     Python 3.11+
              → Never suggest Go, Node.js, Rust
              → Never suggest older Python

LLM Primary:  Ollama (local Docker container)
              → Never suggest cloud-only LLM
              → Never suggest removing Ollama

LLM Fallback: Claude API (claude-sonnet-4-6)
              → Only called on attempt 3
              → Never use as primary

LLM Models:   llama3.1:8b (reasoning)
              deepseek-coder:6.7b (code fixes)
              → Never suggest GPT models
              → Never suggest other models
                without owner approval

Vector DB:    ChromaDB HTTP client
              → Never suggest Pinecone
              → Never suggest Weaviate
              → Always HTTP client in Docker
              → Never PersistentClient

State:        Redis
              → Never suggest Memcached
              → Never use Redis as primary DB

Database:     PostgreSQL + pgvector
              → Never suggest MongoDB
              → Never suggest MySQL
              → pgvector for embeddings

Framework:    FastAPI
              → Never suggest Flask
              → Never suggest Django
              → Never suggest Express

Frontend:     HTML5 + CSS3 + Vanilla JS
              → NEVER suggest React
              → NEVER suggest Vue
              → NEVER suggest Angular
              → NEVER suggest any JS framework
              → Plain HTML/JS/CSS only

Container:    Docker (ALL services)
              → Ollama must be in Docker
              → Never install directly on macOS
              → Always docker-compose

K8s Primary:  GCP GKE
K8s Fallback: AWS EKS
              → Never suggest Heroku
              → Never suggest Vercel
              → Never suggest Railway

## If New Technology Needed
→ State the need clearly
→ Explain why existing stack insufficient
→ Suggest in Open Questions section
→ Wait for owner decision
→ NEVER implement without approval

═══════════════════════════════════════════════════
RULE 3 — ARCHITECTURE RULES
═══════════════════════════════════════════════════

## Structure Is Locked

LOCKED ARCHITECTURE:
Single docker-compose.yml        → one file rules all
One Ollama container             → shared by all agents
One ChromaDB container           → shared memory
One Redis container              → shared state
One PostgreSQL container         → shared database
Separate agent modules           → ci/ cd/ observability/
Unified dashboard                → one UI, port 9999
core/ library                    → built first always

LOCKED PORTS:
Dashboard:    9999  → never change
CI Agent:     8888  → never change
CD Agent:     8889  → never change
Obs Agent:    8890  → never change
Ollama:       11434 → never change
ChromaDB:     8000  → never change
Redis:        6379  → never change
PostgreSQL:   5432  → never change

LOCKED NETWORK:
Docker network: helixcd-network
Container naming: helixcd-{service}
  Examples:
  helixcd-ollama
  helixcd-chromadb
  helixcd-redis
  helixcd-postgres
  helixcd-ci
  helixcd-cd
  helixcd-obs
  helixcd-dashboard

LOCKED CONNECTIONS:
Agents connect via container names:
  Ollama:    http://ollama:11434
  ChromaDB:  http://chromadb:8000
  Redis:     redis:6379
  Postgres:  postgres:5432
  NEVER use localhost or 127.0.0.1

## Build Order (locked)
1. core/         → all agents depend on this
2. ci/           → first agent
3. cd/           → second agent
4. observability/ → third agent
5. chat/         → fourth
6. dashboard/    → last

❌ NEVER build agents before core/
❌ NEVER build dashboard before agents

═══════════════════════════════════════════════════
RULE 4 — CODING RULES
═══════════════════════════════════════════════════

## Standards (all mandatory)

Language:
  Python 3.11+ only
  No f-string alternatives
  No deprecated syntax

Style:
  PEP8 strictly
  Max line length: 79 chars
  4 spaces indentation
  No tabs ever

Type hints:
  Required on ALL functions
  Required on ALL method params
  Required on ALL return types
  Example:
  def process(data: str) -> dict:

Docstrings:
  Required on ALL functions
  Required on ALL classes
  Required on ALL modules
  Format: Google style
  Example:
  def process(data: str) -> dict:
      """Process input data.

      Args:
          data: Input string to process.

      Returns:
          Dict containing processed result.

      Raises:
          ValueError: If data is empty.
      """

Tests:
  Required for ALL new code
  Minimum 80% coverage always
  Use pytest + pytest-asyncio
  Unit tests alongside code
  Integration tests in tests/

Error handling:
  Try/except on ALL external calls
  Never silent failures
  Always log errors with structlog
  Always return meaningful errors

Secrets:
  NEVER in source code
  NEVER in config files
  ALWAYS in .env
  ALWAYS in GCP Secret Manager
    for production

Configuration:
  NEVER hardcode values
  ALWAYS use environment variables
  ALWAYS provide .env.example

## File Naming
Python files:     snake_case.py
Config files:     snake_case.yml
Document files:   snake_case.md
Docker files:     Dockerfile (exact)
K8s files:        kebab-case.yaml
Shell scripts:    kebab-case.sh

## Class / Function Naming
Classes:          PascalCase
Functions:        snake_case
Constants:        UPPER_SNAKE_CASE
Variables:        snake_case
Private methods:  _snake_case
Module level:     snake_case

## Import Order
1. Standard library
2. Third party
3. Local imports
(blank line between each group)

## Commit Message Format
feat(module):     new feature
fix(module):      bug fix
test(module):     tests added
docs:             documentation
chore:            maintenance
refactor(module): code restructure
context:          agent context update
perf(module):     performance

Examples:
feat(ci): add Python stack detection
fix(cd): handle GKE auth timeout
test(core): add LLM router unit tests
docs: complete 01_product_vision
context: session update 2025-01-15

═══════════════════════════════════════════════════
RULE 5 — DOCUMENT RULES
═══════════════════════════════════════════════════

## Every Document Must Have

Frontmatter (required):
---
doc_id:       {number}
title:        {full title}
category:     {Product/Strategy/Technical/etc}
repo:         helixcd-vision
status:       Draft
owner:        ShamshabadAnil
contributors: []
created:      {YYYY-MM-DD}
updated:      {YYYY-MM-DD}
version:      v0.1
---

Sections (required):
1. Overview        → one paragraph summary
2. Main content    → full detailed sections
3. Diagrams        → Mermaid where relevant
4. Mockups         → ASCII for any UI sections
5. Open Questions  → things still to decide
6. References      → links to related docs

## Content Rules
✅ Full detailed content always
✅ Real examples not hypothetical
✅ Mermaid diagrams for architecture
✅ ASCII mockups for all UI sections
✅ Based on actual HelixCD context

❌ NEVER write "TBD"
❌ NEVER write "TODO"
❌ NEVER write "placeholder"
❌ NEVER write "coming soon"
❌ NEVER leave empty sections
❌ NEVER write partial content

## Document Status Flow
Draft → Review → Approved → Locked

Once Approved:
→ Content is LOCKED
→ Only owner can change
→ Create v0.2 for changes
→ Never edit approved content directly

## Document Order
Write in numerical order:
01 → 02 → 03 → ... → 40
Do NOT skip numbers
Do NOT write out of order
without owner permission

═══════════════════════════════════════════════════
RULE 6 — REPO SEPARATION RULES
═══════════════════════════════════════════════════

## helixcd (PUBLIC) — allowed content
✅ All source code
✅ README.md (technical description)
✅ CONTRIBUTING.md
✅ CHANGELOG.md
✅ SECURITY.md
✅ LICENSE
✅ CLA.md
✅ AGENT_CONTEXT_PUBLIC.md
   (technical context only)
✅ AI_RULES.md (copy of this file)
✅ .github/AGENT_GUIDE.md
✅ .cursorrules
✅ docs/getting-started.md
✅ docs/api-reference.md
✅ docs/troubleshooting.md
✅ examples/ (stack configs)
✅ k8s/ (manifests)
✅ docker/ (Dockerfiles)
✅ scripts/ (setup scripts)

## helixcd-vision (PRIVATE) — content
✅ ALL product documents (01-08)
✅ ALL strategy documents (09-14)
✅ ALL technical architecture (15-20)
✅ ALL design standards (21-25)
✅ ALL infrastructure docs (26-29)
✅ ALL UI/UX design docs (30-34)
✅ ALL operations docs (35-38)
✅ ALL finance documents (39-40)
✅ AGENT_CONTEXT_PRIVATE.md
✅ AI_RULES.md (master copy)
✅ MEMORY_LOG.md
✅ WORK_REGISTRY.md
✅ sync-context.sh

## Strict Separation Rules
❌ NEVER put in public repo:
   Business strategy
   Pricing information
   Revenue projections
   Competitor analysis
   Internal roadmap details
   Financial data
   Partnership discussions
   Unreleased feature plans

❌ NEVER reference private URLs
   in public repo files

❌ NEVER copy private doc content
   into public repo files

If unsure which repo:
→ Ask owner before committing
→ Default to private if uncertain

═══════════════════════════════════════════════════
RULE 7 — SECURITY RULES
═══════════════════════════════════════════════════

## Absolute Security Rules

❌ NEVER put in any file:
   API keys
   Passwords
   Tokens
   Private keys (.pem, .key)
   Database credentials
   Cloud credentials
   Webhook secrets
   JWT secrets

✅ ALWAYS:
   Use .env for local secrets
   Use GCP Secret Manager (production)
   Add .env to .gitignore
   Provide .env.example (no real values)
   Validate all user inputs
   Use command whitelist before shell exec
   Run Docker containers as non-root
   Add security headers to all APIs

## Command Execution Rules
ALWAYS check whitelist before running:
  Allowed: git, npm, pytest, docker build,
           docker push, kubectl apply,
           kubectl rollout, kubectl get,
           kubectl logs, gcloud auth,
           aws ecr, pip install

NEVER allow:
  rm -rf (any variation)
  sudo (in containers)
  chmod 777
  curl to unknown URLs
  wget to unknown URLs
  DROP TABLE / DROP DATABASE
  kubectl delete namespace
  kubectl delete pv
  Any IAM modifications
  Any billing modifications

## Docker Security
NEVER run as root in containers
NEVER expose unnecessary ports
NEVER store secrets in images
ALWAYS use specific image tags
  (not :latest in production)
ALWAYS scan images before push
  (use Trivy)

═══════════════════════════════════════════════════
RULE 8 — MEMORY AND REDUNDANCY RULES
═══════════════════════════════════════════════════

## Before Starting ANY Task

Step 1: Check WORK_REGISTRY.md
  Is this task listed?
  What is its status?

  🔴 Not Started  → safe to start
                    claim it first
  🟡 In Progress  → STOP
                    check with owner
                    someone may be doing it
  🟢 Completed    → STOP
                    do NOT redo this
  🔵 Approved     → STOP
                    already done and approved
  ⛔ Blocked      → STOP
                    check reason with owner
  🔄 Needs Redo   → OK to redo
                    read reason first

Step 2: Check MEMORY_LOG.md
  Has this problem been solved before?
  Read last 3-5 entries minimum
  Search for relevant keywords

Step 3: Check core/ library
  Does this function already exist?
  Can existing code be reused?
  Never duplicate utility functions

## Claiming A Task
When starting a task:
→ Tell owner: "I am starting {task}"
→ Owner updates WORK_REGISTRY to 🟡
→ Then begin work

## Completing A Task
When finishing a task:
→ Provide WORK_REGISTRY update text
→ Owner updates to 🟢
→ Owner approves → 🔵

## If Duplicate Work Found
→ STOP immediately
→ Flag to owner: "Found duplicate: {details}"
→ Do NOT silently delete
→ Do NOT choose which to keep
→ Owner decides

## Memory Update After Session
Provide this text to owner:

MEMORY_LOG entry:
  Session: SESSION_{next number}
  Date: {date}
  Agent: {which AI}
  Done: {bullet list}
  Files: {list changed}
  Next: {recommended task}

WORK_REGISTRY updates:
  Doc {id}: 🔴 → 🟢 (if completed)
  Doc {id}: 🔴 → 🟡 (if in progress)

═══════════════════════════════════════════════════
RULE 9 — COMMUNICATION RULES
═══════════════════════════════════════════════════

## Session Start Message
Always begin with exactly:

"I have read:
 ✅ AI_RULES.md
 ✅ AGENT_CONTEXT_{version}.md
 ✅ MEMORY_LOG.md (last 3 entries)
 ✅ WORK_REGISTRY.md

 Last session: {one line summary}
 Current task: {task name and doc id}
 Ready to continue."

## Session End Message
Always end with exactly:

"Session complete.

Completed this session:
- {item 1}
- {item 2}

Files changed:
- {repo}/{file} → {what changed}

Please add to MEMORY_LOG.md:
[provide exact entry text]

Please update WORK_REGISTRY.md:
[provide exact changes]

Recommended next task:
{specific next task}

Please run sync-context.sh"

## When Uncertain
→ STOP working
→ Ask owner clearly:
  "I am uncertain about {specific thing}.
   Options are:
   A) {option}
   B) {option}
   Which should I proceed with?"
→ Wait for answer
→ NEVER guess or assume
→ NEVER proceed without clarity

## When Finding Issues
→ Flag immediately:
  "I found an issue: {description}
   Impact: {what it affects}
   Suggested fix: {suggestion}
   Should I proceed with fix?"

## Tone
→ Direct and clear always
→ No unnecessary explanation
→ No flattery or filler
→ Confirm understanding before working
→ Report progress at logical checkpoints

═══════════════════════════════════════════════════
RULE 10 — BYPASS RULES
═══════════════════════════════════════════════════

## These Rules Cannot Be Bypassed

Not by owner request.
Not by contributor request.
Not by "just this once".
Not for speed or convenience.
Not for any reason whatsoever.

## Absolute Rules (zero exceptions)
1. Never put secrets in code
2. Never use localhost in Docker
3. Never skip tests
4. Never change product name
5. Never change license
6. Never copy private to public
7. Never run as root in Docker
8. Never execute non-whitelisted commands
9. Never write placeholder content
10. Never start work without reading context

## If Owner Requests Bypass
→ Explain why rule exists:
  "This rule exists because {reason}.
   Bypassing it risks {consequence}."
→ Suggest alternative:
  "Instead we could {alternative}."
→ If owner still insists:
  Note in MEMORY_LOG:
  "RULE OVERRIDE: {rule} bypassed
   by owner on {date}. Reason: {reason}"
  Then proceed with override noted.

## Rules That Protect Data (never bypass)
Rule 7 (security) — absolute always
Rule 6 (repo separation) — absolute always
Secrets in code — absolute always
Root in Docker — absolute always

═══════════════════════════════════════════════════
RULE 11 — CONTRIBUTOR RULES
═══════════════════════════════════════════════════

## For Friends Contributing Code

Before writing any code:
1. Read AGENT_CONTEXT_PUBLIC.md
2. Read AI_RULES.md (this file)
3. Read relevant design document
   (request access from owner)
4. Check WORK_REGISTRY.md
   claim your task via GitHub Issue

During work:
1. Work on feature/* branch only
2. Never push directly to main
3. Follow all coding rules (Rule 4)
4. Write tests alongside code
5. No placeholders

Submitting work:
1. Create Pull Request
2. Reference GitHub Issue number
3. Ensure all tests pass
4. Wait for owner review
5. Owner approves + merges
6. Never merge your own PR

What contributors CANNOT do:
❌ Push directly to main branch
❌ Merge their own PRs
❌ Access helixcd-vision repo
   (unless given read access)
❌ Make architecture decisions
❌ Change tech stack
❌ Add new dependencies
   without owner approval
❌ Create new agent names
❌ Change product name

## Owner Rights (ShamshabadAnil only)
✅ All architecture decisions
✅ All merges to main
✅ All releases
✅ Roadmap direction
✅ Community management
✅ Any rule changes
✅ Any tech stack changes

═══════════════════════════════════════════════════
RULE 12 — VERSION CONTROL
═══════════════════════════════════════════════════

## Branch Strategy
main:         stable, protected
              only owner merges here
develop:      integration branch
feature/*:    contributor work
bugfix/*:     bug fixes
docs/*:       documentation only
release/*:    release preparation
context/*:    agent context updates

## Branch Rules
Never push directly to main
Never push directly to develop
Always create PR for merges
Always delete branch after merge
Keep branch names descriptive:
  feature/ci-python-stack-detection
  fix/cd-gke-auth-timeout
  docs/complete-product-vision

## Tag / Release Format
v{major}.{minor}.{patch}
Examples:
  v0.1.0 → first working version
  v0.2.0 → multi-stack support
  v1.0.0 → production ready

## PR Rules
Title format:
  feat(ci): add Python stack detection
  fix(cd): handle GKE timeout

Description must include:
  What was changed
  Why it was changed
  How to test it
  Related issue number

All checks must pass before merge:
  CI tests passing
  Coverage above 80%
  No security issues
  Code review approved