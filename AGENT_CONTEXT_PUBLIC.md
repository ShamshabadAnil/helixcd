---
file:         AGENT_CONTEXT_PUBLIC.md
repo:         helixcd (PUBLIC)
owner:        ShamshabadAnil
updater:      ShamshabadAnil only
version:      v1.0
created:      2025-01-15
updated:      2025-01-15
purpose:      Technical context for all agents
              working on public helixcd repo.
              NO business or strategy info here.
              See helixcd-vision for full context.
---

# HelixCD — Public Agent Context
## Read This Before Working On helixcd Repo

═══════════════════════════════════════════════════
SECTION 1 — PROJECT IDENTITY
═══════════════════════════════════════════════════

Product:        HelixCD
Type:           AI-native CI/CD + Observability
Owner:          ShamshabadAnil
GitHub:         github.com/ShamshabadAnil/helixcd
License:        MIT
Stage:          Documentation phase
                (coding not started yet)

## One Line
"Autonomous pipelines that build, test,
deploy, monitor and fix themselves.
Chat with your logs in plain English."

## Three Pillars
1. HelixCD CI Agent
   Autonomous build + test + security + fix
   Replaces Jenkins / GitLab CI
   Folder: ci/

2. HelixCD CD Agent
   Autonomous deploy + monitor + rollback
   Replaces ArgoCD / Spinnaker
   Folder: cd/

3. HelixCD Observability Agent + Chat Engine
   AI log monitoring + plain English queries
   Replaces Datadog / Grafana + Loki
   Folder: observability/ + chat/

## Core Differentiators
1. Local LLM via Ollama → no data leaves org
2. Autonomous self-healing → fixes own errors
3. Chat with logs → plain English queries
4. All 3 pillars in one → not five tools
5. Free self-hosted → vs $2000-8000/month

═══════════════════════════════════════════════════
SECTION 2 — TECH STACK (ALL LOCKED)
═══════════════════════════════════════════════════

## DO NOT suggest alternatives to any of these

Language:       Python 3.11+
LLM Primary:    Ollama (Docker container)
                → llama3.1:8b for reasoning
                → deepseek-coder:6.7b for code
LLM Fallback:   Claude API claude-sonnet-4-6
                → only on attempt 3
Vector DB:      ChromaDB HTTP client
                → NEVER PersistentClient
                → Always in Docker
State:          Redis
Database:       PostgreSQL + pgvector
Framework:      FastAPI
Frontend:       HTML5 + CSS3 + Vanilla JS
                → NO React, Vue, Angular
                → NO JS frameworks at all
Container:      Docker (ALL services)
                → Ollama in Docker always
                → Never install on macOS
K8s Primary:    GCP GKE
K8s Secondary:  AWS EKS
Registry:       GCR primary, ECR secondary
Network:        helixcd-network (Docker)

## Port Assignments (locked forever)
Dashboard:      9999
CI Agent:       8888
CD Agent:       8889
Obs Agent:      8890
Ollama:         11434
ChromaDB:       8000
Redis:          6379
PostgreSQL:     5432

## Container Names (locked)
helixcd-ollama
helixcd-chromadb
helixcd-redis
helixcd-postgres
helixcd-ci
helixcd-cd
helixcd-obs
helixcd-dashboard

## Service Connections (locked)
Agents ALWAYS connect via container names:
Ollama:     http://ollama:11434
ChromaDB:   http://chromadb:8000
Redis:      redis:6379
Postgres:   postgres:5432
NEVER use localhost or 127.0.0.1

═══════════════════════════════════════════════════
SECTION 3 — ARCHITECTURE
═══════════════════════════════════════════════════

## System Overview
Git Push
↓
HelixCD CI Agent (port 8888)
↓ Redis signal
HelixCD CD Agent (port 8889)
↓
Kubernetes (GKE/EKS)
↓
HelixCD Observability Agent (port 8890)
↓
HelixCD Chat Engine
↓
Developer (plain English)

## Component Flow

┌─────────────────────────────────────────┐
│            DOCKER COMPOSE               │
│                                         │
│  ┌──────────┐  ┌──────────┐            │
│  │ CI Agent │  │ CD Agent │            │
│  │  :8888   │  │  :8889   │            │
│  └────┬─────┘  └────┬─────┘            │
│       │              │                  │
│  ┌────▼──────────────▼────┐            │
│  │    Observability Agent  │            │
│  │         :8890           │            │
│  └────────────┬────────────┘            │
│               │                         │
│  ┌────────────▼────────────┐            │
│  │     Chat Engine         │            │
│  └────────────┬────────────┘            │
│               │                         │
│  ┌────────────▼────────────┐            │
│  │   Unified Dashboard     │            │
│  │        :9999            │            │
│  └─────────────────────────┘            │
│                                         │
│  SHARED SERVICES                        │
│  ┌────────┐ ┌──────────┐ ┌──────────┐  │
│  │ Ollama │ │ ChromaDB │ │  Redis   │  │
│  │ :11434 │ │  :8000   │ │  :6379   │  │
│  └────────┘ └──────────┘ └──────────┘  │
│  ┌────────────────────────────────────┐ │
│  │     PostgreSQL + pgvector :5432    │ │
│  └────────────────────────────────────┘ │
└─────────────────────────────────────────┘

## Build Order (strict — never change)
1. core/           → shared library first
2. ci/             → CI Agent second
3. cd/             → CD Agent third
4. observability/  → Obs Agent fourth
5. chat/           → Chat Engine fifth
6. dashboard/      → Dashboard last

Never build agents before core/
Never build dashboard before agents

═══════════════════════════════════════════════════
SECTION 4 — FOLDER STRUCTURE
═══════════════════════════════════════════════════

helixcd/ (YOU ARE HERE)
│
├── AGENT_CONTEXT_PUBLIC.md  ← this file
├── AI_RULES.md              ← read this too
├── .cursorrules             ← Cursor auto-loads
├── .github/
│   ├── AGENT_GUIDE.md       ← contributor guide
│   ├── CODEOWNERS           ← ShamshabadAnil owns all
│   ├── ISSUE_TEMPLATE/      ← issue templates
│   └── workflows/           ← GitHub Actions
│
├── core/                    ← SHARED LIBRARY
│   ├── llm/                 ← LLM clients
│   │   ├── ollama_client.py
│   │   ├── claude_client.py
│   │   └── llm_router.py
│   ├── memory/              ← ChromaDB + sessions
│   │   ├── chroma_manager.py
│   │   ├── session_context.py
│   │   └── log_store.py
│   ├── executor/            ← Shell execution
│   │   ├── shell_executor.py
│   │   ├── command_whitelist.py
│   │   └── output_parser.py
│   ├── state/               ← Redis manager
│   │   └── redis_manager.py
│   ├── db/                  ← PostgreSQL
│   │   ├── postgres_client.py
│   │   └── migrations/
│   ├── notifier/            ← Notifications
│   │   └── notify.py
│   └── logger/              ← Structured logging
│       └── logger.py
│
├── ci/                      ← CI AGENT
│   ├── agent.py             ← main CI agent
│   ├── stack_detector.py    ← auto-detect stack
│   ├── pipeline/            ← 8 CI stages
│   ├── trigger/             ← webhooks + watcher
│   ├── state/               ← pipeline state
│   └── prompts/             ← LLM system prompts
│
├── cd/                      ← CD AGENT
│   ├── agent.py             ← main CD agent
│   ├── deployment/          ← 7 CD stages
│   ├── cloud/               ← GCP/AWS/Azure
│   ├── state/               ← deployment state
│   └── prompts/             ← LLM system prompts
│
├── observability/           ← OBS AGENT
│   ├── agent.py             ← main obs agent
│   ├── collector/           ← log/metric collection
│   ├── analyzer/            ← AI analysis
│   ├── alerts/              ← alerting system
│   └── prompts/             ← LLM system prompts
│
├── chat/                    ← CHAT ENGINE
│   ├── chat_engine.py       ← core chat logic
│   ├── query_parser.py      ← parse questions
│   ├── log_search.py        ← semantic search
│   └── response_builder.py  ← AI responses
│
├── dashboard/               ← WEB UI
│   ├── server.py            ← FastAPI server
│   ├── websocket.py         ← real-time updates
│   └── static/              ← HTML/CSS/JS
│
├── k8s/                     ← K8S MANIFESTS
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   ├── configmap.yaml
│   ├── hpa.yaml
│   ├── namespace-prod.yaml
│   ├── namespace-staging.yaml
│   ├── jobs/
│   ├── canary/
│   └── blue-green/
│
├── examples/                ← STACK EXAMPLES
│   ├── nodejs/
│   ├── python/
│   ├── go/
│   ├── java/
│   └── flutter/
│
├── tests/                   ← TEST SUITE
│   ├── unit/
│   └── integration/
│
├── docker/                  ← DOCKERFILES
│   ├── agent/Dockerfile
│   ├── dashboard/Dockerfile
│   └── ollama/
│
├── scripts/                 ← SETUP SCRIPTS
│   ├── setup.sh
│   ├── setup-models.sh
│   └── migrate-db.sh
│
├── docker-compose.yml       ← all services
├── docker-compose.dev.yml   ← development
├── main.py                  ← entry point
├── config.py                ← configuration
├── requirements.txt         ← dependencies
├── .env.example             ← env template
├── helixcd.yml.example      ← user config
├── LICENSE                  ← MIT
├── README.md                ← public docs
├── CONTRIBUTING.md
├── CHANGELOG.md
├── SECURITY.md
└── CLA.md

═══════════════════════════════════════════════════
SECTION 5 — CODING STANDARDS SUMMARY
═══════════════════════════════════════════════════

## Quick Reference (full doc in helixcd-vision)

Style:
  Python 3.11+ only
  PEP8 strictly
  Max line length: 79 chars
  4 spaces indent always

Always required:
  Type hints on ALL functions
  Docstrings on ALL functions
  Tests for ALL new code (80%+ coverage)
  Error handling on ALL external calls

Never allowed:
  Hardcoded values (use .env)
  Secrets in code (use Secret Manager)
  localhost in Docker (use container names)
  Placeholders or TODOs in submissions
  Untested code in PRs

File naming:
  Python:  snake_case.py
  Config:  snake_case.yml
  Docs:    snake_case.md
  K8s:     kebab-case.yaml
  Scripts: kebab-case.sh

Naming conventions:
  Classes:   PascalCase
  Functions: snake_case
  Constants: UPPER_SNAKE_CASE
  Variables: snake_case
  Private:   _snake_case

Commit format:
  feat(module): description
  fix(module):  description
  test(module): description
  docs:         description
  chore:        description

Branch naming:
  feature/description
  fix/description
  docs/description

═══════════════════════════════════════════════════
SECTION 6 — CI AGENT DETAILS
═══════════════════════════════════════════════════

## What CI Agent Does
Replaces Jenkins/GitLab CI completely.
Runs locally on developer machine.
Uses Ollama as AI brain.

## 8 Pipeline Stages (in order)
1. CHECKOUT     git pull origin main
2. INSTALL      npm install / pip install
3. LINT         eslint / flake8 / auto-fix
4. TEST         jest / pytest (min 70% coverage)
5. SECURITY     semgrep + gitleaks + audit-ci
6. BUILD        docker build + trivy scan
7. PUSH         push to GCR (primary) ECR (fallback)
8. SIGNAL       Redis → frenzlo-ci:complete

## Auto-Fix Logic (per stage)
Attempt 1: Ollama llama3.1:8b
           context = error output only
Attempt 2: Ollama deepseek-coder:6.7b
           context = error + logs + code
Attempt 3: Claude API claude-sonnet-4-6
           context = full history + memory
Failed 3x: Stop + notify developer

## Supported Stacks (auto-detected)
Node.js, Python, Go, Java, Flutter, Ruby

## Trigger Methods
1. GitLab webhook (port 8888)
2. GitHub webhook (port 8888)
3. Git file watcher (30s polling)
4. Manual CLI (python main.py --trigger)
5. REST API (POST /trigger)
6. Dashboard button

## Key Files
ci/agent.py              → main loop
ci/stack_detector.py     → detect language
ci/pipeline/stages.py    → stage definitions
ci/pipeline/fix_engine.py → auto-fix logic
ci/trigger/              → all trigger types
ci/prompts/ci_system_prompt.txt → LLM prompt

═══════════════════════════════════════════════════
SECTION 7 — CD AGENT DETAILS
═══════════════════════════════════════════════════

## What CD Agent Does
Listens for CI success signal via Redis.
Deploys to Kubernetes autonomously.
Monitors health post-deploy.
Auto-rollbacks if health degrades.

## 7 Deployment Stages (in order)
1. VALIDATE     confirm image exists in registry
2. PREPARE      connect to correct K8s cluster
3. PRE-CHECKS   verify cluster ready
4. MIGRATE      run DB migrations safely
5. DEPLOY       rolling/canary/blue-green
6. MONITOR      10 minute health check loop
7. CLEANUP      annotations + old RS cleanup

## Deployment Strategies
Rolling:    default, zero downtime
Canary:     10% traffic first, auto-promote
Blue-Green: full parallel, instant switch

## Environment Strategy
develop branch → staging namespace
main branch    → production namespace
feature/*      → CI only, no deploy

## Rollback Triggers
Pod restarts > 3 in 10 minutes
Error rate in logs > 5%
Less than 50% pods ready
Service has no endpoints

## Key Files
cd/agent.py                      → main loop
cd/deployment/stages.py          → stage defs
cd/deployment/health_monitor.py  → health checks
cd/deployment/rollback_engine.py → auto rollback
cd/deployment/strategy.py        → deploy methods
cd/cloud/gcp_client.py           → GKE operations
cd/cloud/aws_client.py           → EKS operations

═══════════════════════════════════════════════════
SECTION 8 — OBSERVABILITY + CHAT DETAILS
═══════════════════════════════════════════════════

## What Observability Agent Does
Collects logs from all K8s pods.
Monitors metrics continuously.
AI analyzes logs for patterns.
Alerts on anomalies automatically.
Correlates deploys with issues.
Predicts problems before they occur.

## Log Sources
Kubernetes pods (all namespaces)
Docker containers
CI/CD pipeline runs
Application stdout/stderr
Nginx access logs
PostgreSQL slow queries
Redis logs
Kafka consumer logs

## What Chat Engine Does
Lets developer query logs in plain English.

Examples:
"Why did the app crash at 3pm?"
"Show me all auth errors today"
"How many users were affected?"
"What changed before the spike?"

## Chat Query Types
Natural language: "Show errors last hour"
Filter queries:   "logs service=auth level=error"
AI analysis:      "Summarize today's issues"
Actions:          "Fix the JWT error"

## Key Files
observability/agent.py                    → main
observability/collector/log_collector.py  → collect
observability/analyzer/log_analyzer.py   → AI analyze
observability/analyzer/root_cause.py     → root cause
observability/alerts/alert_manager.py    → alerts
chat/chat_engine.py                      → chat logic
chat/log_search.py                       → semantic search

═══════════════════════════════════════════════════
SECTION 9 — DASHBOARD DETAILS
═══════════════════════════════════════════════════

## What Dashboard Shows
Single unified UI at port 9999.
Shows all 3 pillars in one place.
Real-time updates via WebSocket.

## Dashboard Sections
Header:        current status + manual trigger
CI Panel:      stage progress + live logs
CD Panel:      deployment progress + pod status
Obs Panel:     health metrics + alerts
Chat Panel:    log query interface
History:       pipeline + deployment history

## Tech Stack
Backend:  FastAPI + WebSocket
Frontend: HTML5 + CSS3 + Vanilla JS
Charts:   Chart.js (CDN)
Theme:    Dark (developer friendly)
No framework: plain HTML/JS only

## Key Files
dashboard/server.py              → FastAPI
dashboard/websocket.py           → realtime
dashboard/static/index.html      → main UI
dashboard/static/js/dashboard.js → main logic
dashboard/static/js/chat.js      → chat UI
dashboard/static/js/logs.js      → log viewer
dashboard/static/js/metrics.js   → charts

═══════════════════════════════════════════════════
SECTION 10 — CURRENT STATUS
═══════════════════════════════════════════════════

Phase:          Documentation
Code:           NOT STARTED
Dashboard:      NOT STARTED

## What Is Done
✅ Repository structure
✅ All placeholder files
✅ .cursorrules
✅ Governance files (AI_RULES etc)
✅ GitHub branch protection
✅ CLA system
✅ License (MIT)
✅ README

## What Is Next
1. Write all 40 design documents
   (in helixcd-vision repo)
2. Build core/ library
3. Build CI agent
4. Build CD agent
5. Build observability
6. Build chat engine
7. Build dashboard

## Important Note
Do NOT start coding until
documents are written and approved.
Code must follow design docs exactly.
Design docs are in helixcd-vision repo.
Request access from ShamshabadAnil.

═══════════════════════════════════════════════════
SECTION 11 — NEVER DO THIS
═══════════════════════════════════════════════════

❌ Never change product name (HelixCD)
❌ Never change tech stack
❌ Never use localhost in Docker
❌ Never use frontend frameworks
❌ Never hardcode values or secrets
❌ Never skip tests
❌ Never write placeholders
❌ Never push to main directly
❌ Never merge own PRs
❌ Never put business info in this repo
❌ Never reference helixcd-vision URLs
❌ Never start coding before doc approved
❌ Never install Ollama on macOS directly
❌ Never run as root in Docker
❌ Never use PersistentClient for ChromaDB

═══════════════════════════════════════════════════
SECTION 12 — QUICK REFERENCE
═══════════════════════════════════════════════════

Owner:          ShamshabadAnil
Public repo:    github.com/ShamshabadAnil/helixcd
Private repo:   github.com/ShamshabadAnil/helixcd-vision
Language:       Python 3.11+
LLM primary:    Ollama llama3.1:8b
LLM fallback:   Claude claude-sonnet-4-6
Vector DB:      ChromaDB HTTP client
State:          Redis
Database:       PostgreSQL + pgvector
Containers:     Docker (all services)
K8s primary:    GCP GKE
K8s fallback:   AWS EKS
Dashboard:      Port 9999
CI webhook:     Port 8888
CD webhook:     Port 8889
Obs agent:      Port 8890
Network:        helixcd-network
Build order:    core → ci → cd → obs → chat → dashboard