#!/usr/bin/env bash
# Structural lint only. Behavioral evaluation lives in workflow-consistency-scenarios.md.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
python3 - "$SCRIPT_DIR/../.." <<'PY'
import re
import sys
from pathlib import Path

root = Path(sys.argv[1]).resolve()
role_guide = root / 'skills/using-superpowers/references/role-selection.md'
def local_links(path):
    return {(path.parent / target).resolve()
            for target in re.findall(r'\]\(([^)]+\.md)\)', path.read_text())
            if not re.match(r'\w+://', target) and '<' not in target}

role_links = local_links(role_guide)
for adapter in ('codex', 'opencode', 'dsh', 'kimi-code'):
    target = role_guide.with_name(f'{adapter}-tools.md')
    assert target in role_links and target.is_file(), target
skills = ('subagent-driven-development', 'dispatching-parallel-agents', 'requesting-code-review')
for name in skills:
    path = root / 'skills' / name / 'SKILL.md'
    content = path.read_text()
    assert content.startswith('---\n'), path
    assert re.search(r'^name: ' + re.escape(name) + r'$', content, re.M), path
    links = local_links(path)
    assert role_guide in links, path
    for target in links:
        assert target.is_file(), (path, target)
for name in ('implementer-prompt.md', 'task-reviewer-prompt.md', 're-review-prompt.md'):
    path = root / 'skills/subagent-driven-development' / name
    assert not re.search(r'\[MODEL|^\s*model:', path.read_text(), re.M), path
print('PASS: routing structure, local reference targets, and config-owned model boundaries')
print('NOT VERIFIED: dispatch behavior, role precedence, authorization, or completion decisions')
PY
