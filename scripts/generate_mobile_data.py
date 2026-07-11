#!/usr/bin/env python3
"""
HelixCD Mobile Data Generator.

Generates data.json for the mobile
prompt page. Run by GitHub Actions
after every helix done commit.

Output: docs/data.json
"""
import json
import os
import re
import sys
from datetime import datetime
from pathlib import Path


# ── PATHS ──────────────────────────────────────
WORKSPACE = Path(
    os.environ.get(
        "GITHUB_WORKSPACE",
        str(Path.home() / "helixcd-workspace")
    )
)

REPO = WORKSPACE / "helixcd"
VISION = WORKSPACE / "helixcd-vision"
OUTPUT = REPO / "docs" / "data.json"


def get_next_task(
    registry: Path
) -> dict:
    """Get next task from work registry.

    Args:
        registry: Path to WORK_REGISTRY.md.

    Returns:
        Task dictionary.
    """
    if not registry.exists():
        return {
            "id": "01",
            "name": "Product Vision",
            "status": "not_started"
        }

    with open(registry, encoding="utf-8") as f:
        content = f.read()

    # In progress first
    patterns = [
        (r'\|\s*(\S+)\s*\|([^|]+)\|[^|]*'
         r'In Progress[^|]*\|', "in_progress"),
        (r'\|\s*(\S+)\s*\|([^|]+)\|[^|]*'
         r'Not Started[^|]*\|', "not_started"),
        (r'\|\s*(\S+)\s*\|([^|]+)\|[^|]*'
         r'[Ww][Ii][Pp][^|]*\|', "in_progress"),
        (r'\|\s*(\S+)\s*\|([^|]+)\|[^|]*'
         r'\[TODO\][^|]*\|', "not_started"),
    ]

    for pattern, status in patterns:
        matches = re.findall(pattern, content)
        if matches:
            return {
                "id": matches[0][0].strip(),
                "name": matches[0][1].strip(),
                "status": status
            }

    return {
        "id": "done",
        "name": "All tasks complete!",
        "status": "complete"
    }


def get_progress(
    registry: Path
) -> dict:
    """Get project progress statistics.

    Args:
        registry: Path to WORK_REGISTRY.md.

    Returns:
        Progress statistics dictionary.
    """
    if not registry.exists():
        return {
            "done": 0,
            "total": 181,
            "percent": 0
        }

    with open(registry, encoding="utf-8") as f:
        content = f.read()

    done = (
        content.count("[APPROVED]") +
        content.count("[DONE]") +
        content.count("Completed") +
        len(re.findall(r'🔵|🟢', content))
    )
    total_markers = (
        content.count("[TODO]") +
        content.count("[WIP]") +
        content.count("Not Started") +
        content.count("In Progress") +
        len(re.findall(r'🔴|🟡', content))
    )
    total = max(done + total_markers, 181)
    pct = int(done * 100 / total) if total else 0

    return {
        "done": done,
        "total": total,
        "percent": pct
    }


def get_memory(vision: Path) -> list:
    """Get last 3 session summaries.

    Args:
        vision: Path to helixcd-vision.

    Returns:
        List of memory summary strings.
    """
    memory_file = vision / "MEMORY_LOG.md"

    if not memory_file.exists():
        return ["No previous sessions"]

    with open(
        memory_file, encoding="utf-8"
    ) as f:
        content = f.read()

    sessions = re.findall(
        r'## SESSION_\d+.*?(?=## SESSION_|\Z)',
        content,
        re.DOTALL
    )

    summaries = []
    for s in sessions[-3:]:
        agent_m = re.search(
            r'agent:\s*(.+)', s
        )
        done_m = re.search(
            r'### completed\n(.+?)(?=###|\Z)',
            s, re.DOTALL
        )
        date_m = re.search(
            r'date:\s*(.+)', s
        )

        parts = []
        if date_m:
            parts.append(
                date_m.group(1).strip()[:10]
            )
        if agent_m:
            parts.append(
                agent_m.group(1).strip()
            )
        if done_m:
            first = done_m.group(1)\
                .strip().split('\n')[0]
            parts.append(first[:60])

        if parts:
            summaries.append(
                " | ".join(parts)
            )

    return summaries or ["No sessions yet"]


def build_prompt(
    task: dict,
    progress: dict,
    memory: list
) -> str:
    """Build minimal agent prompt.

    Target: under 700 tokens.

    Args:
        task: Current task dictionary.
        progress: Progress statistics.
        memory: Memory summary list.

    Returns:
        Minimal prompt string.
    """
    memory_str = "\n".join(
        f"- {m}" for m in memory[-2:]
    )

    return f"""# HelixCD Agent Context
Owner: ShamshabadAnil
Progress: {progress['done']}/{progress['total']} ({progress['percent']}%)

TASK: {task['id']} - {task['name']}

STACK(LOCKED):
Python3.11 | Ollama+ChromaDB+Redis+PostgreSQL
FastAPI | HTML+CSS+VanillaJS | Docker | GKE+GCR

CONNECTIONS(DOCKER - NEVER localhost):
ollama:11434 | chromadb:8000
redis:6379 | postgres:5432

RULES(NEVER BREAK):
- Type hints + docstrings on ALL functions
- Tests required (80%+ coverage)
- No secrets in code
- No React/Vue/Angular
- No placeholders or TODOs
- No localhost in Docker code

LAST SESSIONS:
{memory_str}

REPOS:
github.com/ShamshabadAnil/helixcd
github.com/ShamshabadAnil/helixcd-vision

Confirm task. Begin immediately.
End with: Run helix done"""


def generate() -> None:
    """Generate mobile data JSON file.

    Returns:
        None
    """
    print("Generating mobile data...")

    registry = VISION / "WORK_REGISTRY.md"
    task = get_next_task(registry)
    progress = get_progress(registry)
    memory = get_memory(VISION)
    prompt = build_prompt(
        task, progress, memory
    )

    data = {
        "task_id": task["id"],
        "task_name": task["name"],
        "task_status": task["status"],
        "progress_done": progress["done"],
        "progress_total": progress["total"],
        "progress_percent": progress["percent"],
        "phase": "documentation",
        "prompt": prompt,
        "memory": memory,
        "token_estimate": len(prompt) // 4,
        "updated": datetime.now().isoformat(),
        "owner": "ShamshabadAnil"
    }

    OUTPUT.parent.mkdir(
        parents=True, exist_ok=True
    )

    with open(OUTPUT, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2)

    print(f"[OK] data.json generated")
    print(f"     Task: {task['id']} - {task['name']}")
    print(f"     Progress: {progress['done']}/{progress['total']}")
    print(f"     Tokens: ~{len(prompt)//4}")
    print(f"     Output: {OUTPUT}")


if __name__ == "__main__":
    generate()
