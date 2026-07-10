#!/bin/bash
# HelixCD Monthly Security Audit
# Add to crontab:
# 0 11 1 * * /path/to/monthly-audit.sh

REPO="$HOME/helixcd-workspace/helixcd"
VISION="$HOME/helixcd-workspace/helixcd-vision"
DATE=$(date +%Y-%m-%d)
MONTH=$(date +%Y-%m)
REPORT_DIR="$VISION/operations/audits/$MONTH"

echo ""
echo "════════════════════════════════════════"
echo "  HelixCD Monthly Security Audit"
echo "  Month: $MONTH"
echo "════════════════════════════════════════"
echo ""

mkdir -p "$REPORT_DIR"
cd "$REPO"

# ── DEPENDENCY AUDIT ────────────────────────
echo "🔍 1/6 Dependency vulnerability scan..."
pip-audit \
  -r requirements.txt \
  --format json \
  > "$REPORT_DIR/dependencies.json" 2>/dev/null \
  || true

VULN_COUNT=$(python3 -c "
import json
try:
  with open('$REPORT_DIR/dependencies.json') as f:
    d = json.load(f)
  count = sum(
    len(dep.get('vulns',[]))
    for dep in d.get('dependencies',[])
  )
  print(count)
except:
  print(0)
")
echo "  Found: $VULN_COUNT vulnerabilities"

# ── SAST SCAN ───────────────────────────────
echo "🔍 2/6 Static analysis (SAST)..."
semgrep \
  --config=p/python \
  --config=p/security-audit \
  --config=p/owasp-top-ten \
  --json \
  --output="$REPORT_DIR/sast.json" \
  . 2>/dev/null || true

SAST_COUNT=$(python3 -c "
import json
try:
  with open('$REPORT_DIR/sast.json') as f:
    d = json.load(f)
  print(len(d.get('results',[])))
except:
  print(0)
")
echo "  Found: $SAST_COUNT issues"

# ── SECRET SCAN ─────────────────────────────
echo "🔍 3/6 Secret detection..."
gitleaks detect \
  --source . \
  --report-format json \
  --report-path "$REPORT_DIR/secrets.json" \
  2>/dev/null || true

SECRET_COUNT=$(python3 -c "
import json
try:
  with open('$REPORT_DIR/secrets.json') as f:
    d = json.load(f)
  print(len(d) if isinstance(d, list) else 0)
except:
  print(0)
")
echo "  Found: $SECRET_COUNT secrets"

# ── DOCKER AUDIT ────────────────────────────
echo "🔍 4/6 Docker security audit..."
python3 << PYEOF
from pathlib import Path
import json

issues = []
dockerfiles = list(Path('.').rglob('Dockerfile'))

for df in dockerfiles:
  try:
    content = df.read_text()
    if 'USER' not in content:
      issues.append({
        "file": str(df),
        "issue": "No USER directive (root)",
        "severity": "HIGH"
      })
    if ':latest' in content:
      issues.append({
        "file": str(df),
        "issue": "Uses :latest tag",
        "severity": "MEDIUM"
      })
  except:
    pass

with open('$REPORT_DIR/docker.json', 'w') as f:
  json.dump(issues, f, indent=2)

print(f"  Found: {len(issues)} issues")
PYEOF

# ── K8s AUDIT ───────────────────────────────
echo "🔍 5/6 Kubernetes security audit..."
python3 << PYEOF
from pathlib import Path
import json

issues = []
k8s_files = list(
  Path('k8s').rglob('*.yaml')
) if Path('k8s').exists() else []

for kf in k8s_files:
  try:
    content = kf.read_text()
    if 'privileged: true' in content:
      issues.append({
        "file": str(kf),
        "issue": "Privileged container",
        "severity": "CRITICAL"
      })
    if 'runAsRoot: true' in content:
      issues.append({
        "file": str(kf),
        "issue": "Runs as root",
        "severity": "HIGH"
      })
    if 'resources:' not in content and \
       'Deployment' in content:
      issues.append({
        "file": str(kf),
        "issue": "No resource limits",
        "severity": "MEDIUM"
      })
  except:
    pass

with open('$REPORT_DIR/kubernetes.json', 'w') as f:
  json.dump(issues, f, indent=2)

print(f"  Found: {len(issues)} issues")
PYEOF

# ── GENERATE REPORT ─────────────────────────
echo "🔍 6/6 Generating monthly report..."
python3 << PYEOF
import json
from datetime import datetime
from pathlib import Path

report_dir = Path('$REPORT_DIR')
date = '$DATE'
month = '$MONTH'

def load_json(filename):
  try:
    with open(report_dir / filename) as f:
      return json.load(f)
  except:
    return {}

deps = load_json('dependencies.json')
sast = load_json('sast.json')
secrets = load_json('secrets.json')
docker = load_json('docker.json')
k8s = load_json('kubernetes.json')

dep_vulns = sum(
  len(d.get('vulns', []))
  for d in deps.get('dependencies', [])
)
sast_issues = len(sast.get('results', []))
secret_count = len(secrets) \
  if isinstance(secrets, list) else 0
docker_issues = len(docker) \
  if isinstance(docker, list) else 0
k8s_issues = len(k8s) \
  if isinstance(k8s, list) else 0

total = (dep_vulns + sast_issues +
         secret_count + docker_issues +
         k8s_issues)

severity = "✅ CLEAN"
if total > 0:
  severity = "⚠️ ISSUES FOUND"
if dep_vulns > 0 or secret_count > 0:
  severity = "🔴 CRITICAL ATTENTION"

report = f"""# HelixCD Monthly Security Audit
## {month}

Generated: {date}
Owner: ShamshabadAnil
Status: {severity}

## Summary
| Category | Issues Found |
|----------|-------------|
| Dependencies | {dep_vulns} |
| SAST (code) | {sast_issues} |
| Secrets | {secret_count} |
| Docker | {docker_issues} |
| Kubernetes | {k8s_issues} |
| **TOTAL** | **{total}** |

## Priority Actions
{'### 🔴 CRITICAL - Fix Immediately' if dep_vulns > 0 or secret_count > 0 else '### ✅ No critical issues'}
{'- ' + str(dep_vulns) + ' dependency vulnerabilities' if dep_vulns > 0 else ''}
{'- ' + str(secret_count) + ' secrets detected' if secret_count > 0 else ''}

## Reports
- dependencies.json
- sast.json
- secrets.json
- docker.json
- kubernetes.json

## Next Audit
{datetime.now().strftime('%Y')}-{str(int(datetime.now().strftime('%m')) % 12 + 1).zfill(2)}-01
"""

with open(report_dir / 'REPORT.md', 'w') as f:
  f.write(report)

print(report)
PYEOF

# Commit report to vision repo
cd "$VISION"
git add operations/audits/
git commit -m "audit: monthly security report $MONTH

Total issues: $(python3 -c "
import json
from pathlib import Path
rd = Path('$REPORT_DIR')
counts = []
for f in ['dependencies.json','sast.json']:
  try:
    d = json.load(open(rd/f))
    if 'dependencies' in d:
      counts.append(sum(len(x.get('vulns',[])) for x in d['dependencies']))
    else:
      counts.append(len(d.get('results',[])))
  except:
    counts.append(0)
print(sum(counts))
" 2>/dev/null || echo "unknown")" \
  2>/dev/null || true

git push origin main 2>/dev/null || true

echo ""
echo "════════════════════════════════════════"
echo "  ✅ Monthly audit complete!"
echo "  Report: $REPORT_DIR/REPORT.md"
echo "════════════════════════════════════════"

# macOS notification
osascript -e "display notification
  \"Monthly security audit complete for $MONTH\"
  with title \"HelixCD Audit\"
  sound name \"Submarine\"" 2>/dev/null || true
