#!/usr/bin/env python3
"""HelixCD Custom Standards Checker.

Checks things standard tools miss.
Run: python3 scripts/check_standards.py
"""
import sys
from pathlib import Path
from typing import List, Tuple


def check_no_frontend_framework(
    files: List[Path]
) -> List[str]:
    """Check no JS framework in HTML files.

    Args:
        files: List of HTML files to check.

    Returns:
        List of violations found.
    """
    violations = []
    forbidden = [
        "react", "vue", "angular",
        "svelte", "ember", "backbone",
        "jquery"
    ]
    for file in files:
        try:
            content = file.read_text().lower()
            for framework in forbidden:
                if f"cdn.{framework}" in content or \
                   f"/{framework}@" in content or \
                   f"from '{framework}'" in content:
                    violations.append(
                        f"❌ {file}: Found '{framework}'"
                        f" — use plain HTML/JS only"
                    )
        except Exception:
            pass
    return violations


def check_chromadb_client(
    files: List[Path]
) -> List[str]:
    """Check ChromaDB uses HttpClient not PersistentClient.

    Args:
        files: List of Python files.

    Returns:
        List of violations found.
    """
    violations = []
    for file in files:
        try:
            content = file.read_text()
            if "chromadb" in content:
                if "PersistentClient" in content:
                    violations.append(
                        f"❌ {file}: Uses PersistentClient"
                        f" — use HttpClient only:\n"
                        f"   client = chromadb.HttpClient("
                        f"host='chromadb', port=8000)"
                    )
        except Exception:
            pass
    return violations


def check_no_localhost(
    files: List[Path]
) -> List[str]:
    """Check no localhost in Docker-related Python code.

    Args:
        files: List of Python files.

    Returns:
        List of violations found.
    """
    violations = []
    forbidden = [
        "localhost:11434",
        "localhost:8000",
        "localhost:6379",
        "localhost:5432",
        "127.0.0.1",
    ]
    skip_dirs = ["tests", "examples", "scripts"]

    for file in files:
        if any(d in str(file) for d in skip_dirs):
            continue
        try:
            content = file.read_text()
            for pattern in forbidden:
                if pattern in content:
                    violations.append(
                        f"❌ {file}: Found '{pattern}'\n"
                        f"   Use container names:\n"
                        f"   ollama:11434\n"
                        f"   chromadb:8000\n"
                        f"   redis:6379\n"
                        f"   postgres:5432"
                    )
        except Exception:
            pass
    return violations


def check_helixcd_naming(
    files: List[Path]
) -> List[str]:
    """Check product name is always HelixCD.

    Args:
        files: List of markdown files.

    Returns:
        List of violations found.
    """
    violations = []
    wrong_names = [
        "helix-cd",
        "helix_cd",
        " helixcd",
        "HELIXCD",
        "Helix CD",
        "helix cd",
    ]
    doc_files = [
        f for f in files
        if f.suffix in [".md", ".txt", ".rst"]
        and ".git" not in str(f)
    ]
    for file in doc_files:
        try:
            content = file.read_text()
            for wrong in wrong_names:
                if wrong in content:
                    violations.append(
                        f"❌ {file}: Found '{wrong}'"
                        f" — always use 'HelixCD'"
                    )
        except Exception:
            pass
    return violations


def check_no_secrets_pattern(
    files: List[Path]
) -> List[str]:
    """Check for common secret patterns.

    Args:
        files: List of Python files.

    Returns:
        List of violations found.
    """
    violations = []
    secret_patterns = [
        "password=",
        "api_key=",
        "secret=",
        "token=",
        "AWS_SECRET",
        "PRIVATE_KEY",
    ]
    skip = [".env.example", "test_"]

    for file in files:
        if any(s in str(file) for s in skip):
            continue
        try:
            content = file.read_text().lower()
            for pattern in secret_patterns:
                if f'{pattern}"' in content or \
                   f"{pattern}'" in content:
                    if "os.getenv" not in content and \
                       "environ" not in content:
                        violations.append(
                            f"❌ {file}: Possible hardcoded"
                            f" secret: '{pattern}'\n"
                            f"   Use: os.getenv('{pattern.upper()}')"
                        )
        except Exception:
            pass
    return violations


def check_python_version_syntax(
    files: List[Path]
) -> List[str]:
    """Check no old Python string formatting.

    Args:
        files: List of Python files.

    Returns:
        List of violations found.
    """
    violations = []
    for file in files:
        try:
            content = file.read_text()
            if '%" %' in content or \
               "% (" in content:
                violations.append(
                    f"❌ {file}: Old % string format"
                    f" — use f-strings instead"
                )
        except Exception:
            pass
    return violations


def main() -> int:
    """Run all HelixCD custom standards checks.

    Returns:
        Exit code 0 for pass, 1 for fail.
    """
    root = Path(".")

    py_files = [
        f for f in root.rglob("*.py")
        if ".venv" not in str(f)
        and "venv" not in str(f)
        and "__pycache__" not in str(f)
        and ".git" not in str(f)
    ]

    html_files = [
        f for f in root.rglob("*.html")
        if ".git" not in str(f)
    ]

    all_files = list(root.rglob("*"))

    print("")
    print("🔍 HelixCD Custom Standards Checker")
    print("════════════════════════════════════")
    print("")

    checks: List[Tuple[str, List[str]]] = [
        (
            "No JS framework (plain HTML/JS only)",
            check_no_frontend_framework(html_files)
        ),
        (
            "ChromaDB HttpClient (not PersistentClient)",
            check_chromadb_client(py_files)
        ),
        (
            "No localhost (use container names)",
            check_no_localhost(py_files)
        ),
        (
            "HelixCD naming (exact case)",
            check_helixcd_naming(all_files)
        ),
        (
            "No hardcoded secrets",
            check_no_secrets_pattern(py_files)
        ),
        (
            "Python 3.11+ syntax (f-strings)",
            check_python_version_syntax(py_files)
        ),
    ]

    all_violations: List[str] = []

    for check_name, violations in checks:
        if violations:
            print(f"❌ FAILED: {check_name}")
            for v in violations:
                print(f"   {v}")
            print("")
            all_violations.extend(violations)
        else:
            print(f"✅ PASSED: {check_name}")

    print("")
    print("════════════════════════════════════")

    if all_violations:
        print(f"❌ {len(all_violations)} violation(s) found")
        print("   Fix all before committing")
        print("════════════════════════════════════")
        return 1

    print("✅ All custom standards passed!")
    print("════════════════════════════════════")
    return 0


if __name__ == "__main__":
    sys.exit(main())
