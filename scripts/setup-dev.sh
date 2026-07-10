#!/bin/bash
# HelixCD Developer Setup
# Run once after cloning repo
# Sets up all enforcement locally

set -e

echo ""
echo "══════════════════════════════════════"
echo "  HelixCD Developer Setup"
echo "══════════════════════════════════════"
echo ""

# Check Python version
echo "Checking Python version..."
PYTHON_VERSION=$(python3 --version 2>&1 | \
  grep -oE "[0-9]+\.[0-9]+")
MAJOR=$(echo $PYTHON_VERSION | cut -d. -f1)
MINOR=$(echo $PYTHON_VERSION | cut -d. -f2)

if [ "$MAJOR" -lt 3 ] || \
   ([ "$MAJOR" -eq 3 ] && [ "$MINOR" -lt 11 ]); then
  echo "❌ Python 3.11+ required"
  echo "   Found: Python $PYTHON_VERSION"
  echo ""
  echo "Install on macOS:"
  echo "  brew install python@3.11"
  exit 1
fi
echo "  ✅ Python $PYTHON_VERSION found"

# Check pip
echo "Checking pip..."
pip3 --version > /dev/null 2>&1 || \
  (echo "❌ pip not found" && exit 1)
echo "  ✅ pip found"

# Install project dependencies
echo ""
echo "Installing project dependencies..."
pip3 install -r requirements.txt
echo "  ✅ requirements.txt installed"

# Install dev tools
echo ""
echo "Installing dev enforcement tools..."
pip3 install \
  pre-commit \
  flake8 \
  flake8-docstrings \
  flake8-annotations \
  flake8-bugbear \
  mypy \
  bandit \
  pydocstyle \
  pip-audit \
  pytest \
  pytest-cov \
  pytest-asyncio \
  commitizen

echo "  ✅ Dev tools installed"

# Install pre-commit hooks
echo ""
echo "Installing pre-commit hooks..."
pre-commit install
pre-commit install --hook-type commit-msg
echo "  ✅ Pre-commit hooks installed"

# Run initial standards check
echo ""
echo "Running initial standards check..."
python3 scripts/check_standards.py

# Run pre-commit on all files
echo ""
echo "Running pre-commit on all files..."
pre-commit run --all-files || true

echo ""
echo "══════════════════════════════════════"
echo "  ✅ Developer setup complete!"
echo "══════════════════════════════════════"
echo ""
echo "Enforcement active on your machine:"
echo "  ├── Pre-commit hooks (before commit)"
echo "  ├── flake8 (PEP8 style)"
echo "  ├── mypy (type hints)"
echo "  ├── bandit (security)"
echo "  ├── gitleaks (secrets)"
echo "  └── commitizen (commit format)"
echo ""
echo "Also enforced on GitHub:"
echo "  ├── All above + more"
echo "  ├── Test coverage 80%+"
echo "  ├── Docstring check"
echo "  ├── Dependency audit"
echo "  └── Custom HelixCD checks"
echo ""
echo "No prompt injection can bypass these."
echo "Code passes or fails. Period."
echo "══════════════════════════════════════"
