#!/bin/bash
# HelixCD Branch Protection Setup
# Owner: ShamshabadAnil only
# Usage: ./setup-branch-protection.sh YOUR_GITHUB_TOKEN

set -e

if [ -z "$1" ]; then
  echo "Usage: ./setup-branch-protection.sh YOUR_TOKEN"
  echo ""
  echo "Get token at:"
  echo "github.com → Settings → Developer Settings"
  echo "→ Personal Access Tokens → Tokens (classic)"
  echo "→ Generate with 'repo' scope"
  exit 1
fi

TOKEN=$1
REPO="ShamshabadAnil/helixcd"
API="https://api.github.com/repos/$REPO"

echo "🔒 Setting up branch protection for HelixCD..."
echo ""

# Protect main branch
echo "Protecting main branch..."
curl -s -X PUT \
  -H "Authorization: token $TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  "$API/branches/main/protection" \
  -d '{
    "required_status_checks": {
      "strict": true,
      "contexts": [
        "Code Style (PEP8)",
        "Type Hints (mypy)",
        "Tests (min 80% coverage)",
        "Security Scan (bandit)",
        "Secret Detection (gitleaks)",
        "Docstring Check",
        "Dependency Audit",
        "Commit Format Check",
        "No Localhost In Code",
        "No Hardcoded Values",
        "HelixCD Custom Standards",
        "All Standards Passed"
      ]
    },
    "enforce_admins": false,
    "required_pull_request_reviews": {
      "required_approving_review_count": 1,
      "dismiss_stale_reviews": true,
      "require_code_owner_reviews": true
    },
    "restrictions": {
      "users": ["ShamshabadAnil"],
      "teams": []
    },
    "allow_force_pushes": false,
    "allow_deletions": false,
    "required_linear_history": true
  }' > /dev/null

echo "  ✅ main branch protected"

# Protect develop branch
echo "Protecting develop branch..."
curl -s -X PUT \
  -H "Authorization: token $TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  "$API/branches/develop/protection" \
  -d '{
    "required_status_checks": {
      "strict": true,
      "contexts": [
        "Code Style (PEP8)",
        "Type Hints (mypy)",
        "Tests (min 80% coverage)",
        "Security Scan (bandit)",
        "Secret Detection (gitleaks)"
      ]
    },
    "enforce_admins": false,
    "required_pull_request_reviews": {
      "required_approving_review_count": 1,
      "dismiss_stale_reviews": true
    },
    "restrictions": null,
    "allow_force_pushes": false,
    "allow_deletions": false
  }' > /dev/null

echo "  ✅ develop branch protected"
echo ""
echo "══════════════════════════════════════"
echo "  ✅ Branch protection complete!"
echo "══════════════════════════════════════"
echo ""
echo "main requires:"
echo "  ├── All 12 checks passing"
echo "  ├── Owner approval (ShamshabadAnil)"
echo "  ├── No force pushes ever"
echo "  └── Linear history only"
echo ""
echo "develop requires:"
echo "  ├── 5 core checks passing"
echo "  └── 1 reviewer approval"
echo "══════════════════════════════════════"
