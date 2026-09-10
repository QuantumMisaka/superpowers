#!/usr/bin/env bash
# Compatibility entry point.  The old version matched long prose fragments;
# this check protects the load-bearing shape of the skill contracts instead.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

python3 - "$REPO_ROOT" <<'PY'
from pathlib import Path
import re
import sys

root = Path(sys.argv[1]).resolve()

def frontmatter(path: Path):
    text = path.read_text()
    assert text.startswith("---\n"), path
    end = text.find("\n---\n", 4)
    assert end > 0, path
    header = text[4:end].splitlines()
    fields = {}
    for line in header:
        if ":" in line:
            key, value = line.split(":", 1)
            fields[key.strip()] = value.strip()
    assert fields.get("name"), path
    description = fields.get("description", "")
    assert description, path
    assert len(description) <= 1024, path
    assert text[end + 5 :].strip(), path
    return text, fields

skills = {
    "using-superpowers",
    "brainstorming",
    "writing-plans",
    "receiving-code-review",
    "requesting-code-review",
    "writing-skills",
}

for name in skills:
    path = root / "skills" / name / "SKILL.md"
    text, fields = frontmatter(path)
    assert fields["name"] == name, path
    print(f"PASS: {name} metadata")

for source in (
    root / "skills/writing-skills/SKILL.md",
    root / "skills/writing-skills/testing-skills-with-subagents.md",
):
    text = source.read_text()
    for target in re.findall(r"\]\(([^)]+\.md)\)", text):
        if not re.match(r"\w+://", target):
            assert (source.parent / target).is_file(), (source, target)
print("PASS: writing-skill local references resolve")

for path in (
    root / "skills/test-driven-development/SKILL.md",
    root / "skills/verification-before-completion/SKILL.md",
):
    frontmatter(path)
print("PASS: behavior and evidence skills contain nonempty bodies")
PY

printf 'Skill structure checks passed\n'
