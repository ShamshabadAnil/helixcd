#!/bin/bash
# Enable GitHub Pages for helixcd
# Run once with your GitHub token
# Usage: bash enable-github-pages.sh TOKEN

TOKEN=$1
REPO="ShamshabadAnil/helixcd"

if [ -z "$TOKEN" ]; then
  echo ""
  echo "Usage: bash enable-github-pages.sh TOKEN"
  echo ""
  echo "Get token at:"
  echo "github.com -> Settings"
  echo "-> Developer Settings"
  echo "-> Personal Access Tokens"
  echo "-> Generate with 'repo' scope"
  echo ""
  exit 1
fi

echo "Enabling GitHub Pages..."

curl -s -X POST \
  -H "Authorization: token $TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/$REPO/pages" \
  -d '{
    "source": {
      "branch": "main",
      "path": "/docs"
    }
  }' | python -c "
import json,sys
d=json.load(sys.stdin)
if 'html_url' in d:
  print(f'[OK] Pages enabled!')
  print(f'URL: {d[\"html_url\"]}')
else:
  print(f'Response: {json.dumps(d,indent=2)}')
" 2>/dev/null || echo "Check GitHub UI"

echo ""
echo "Also add VISION_PAT secret:"
echo "github.com/ShamshabadAnil/helixcd"
echo "-> Settings -> Secrets -> Actions"
echo "-> New secret: VISION_PAT"
echo "-> Value: your GitHub token"
echo ""
