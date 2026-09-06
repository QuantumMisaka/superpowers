#!/usr/bin/env bash
# Structural lint only. Behavioral evaluation lives in workflow-consistency-scenarios.md.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
python3 - "$SCRIPT_DIR/../.." <<'PY'
import re
import sys
from pathlib import Path

root = Path(sys.argv[1]).resolve()
reference = root / 'skills/using-superpowers/references/codex-tools.md'
assert reference.is_file(), reference
skills = ('subagent-driven-development', 'dispatching-parallel-agents', 'requesting-code-review')
for name in skills:
    path = root / 'skills' / name / 'SKILL.md'
    content = path.read_text()
    assert content.startswith('---\n'), path
    assert re.search(r'^name: ' + re.escape(name) + r'$', content, re.M), path
    # A real reference pointer, without forcing harness-specific prose on leaf skills.
    assert 'references/*-tools.md' in content, path
    assert 'codex-tools.md' not in content, path
    for target in re.findall(r'\]\(([^)]+\.md)\)', content):
        if not re.match(r'\w+://', target) and '<' not in target:
            assert (path.parent / target).is_file(), (path, target)
for path in (root / 'skills').rglob('*.md'):
    assert not re.search(r'codex-routing-kit|gpt-5\.6|\b(luna|terra|sol)\b', path.read_text(), re.I), path
for name in ('implementer-prompt.md', 'task-reviewer-prompt.md', 're-review-prompt.md'):
    path = root / 'skills/subagent-driven-development' / name
    assert not re.search(r'\[MODEL|^\s*model:', path.read_text(), re.M), path
print('PASS: routing structure, local reference targets, and config-owned model boundaries')
print('NOT VERIFIED: dispatch behavior, role precedence, authorization, or completion decisions')
PY
