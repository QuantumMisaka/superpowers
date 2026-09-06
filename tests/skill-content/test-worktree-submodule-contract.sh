#!/usr/bin/env bash
# Structural lint only; setup/failure decisions need scenario evaluation.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
python3 - "$SCRIPT_DIR/../.." <<'CHECK'
from pathlib import Path
import re
import sys
root = Path(sys.argv[1]).resolve()
skill = root / 'skills/using-git-worktrees/SKILL.md'
text = skill.read_text()
assert text.startswith('---\n')
assert re.search(r'^name: using-git-worktrees$', text, re.M)
assert re.search(r'^description: .+', text, re.M)
assert (root / 'tests/skill-content/workflow-consistency-scenarios.md').is_file()
print('PASS: worktree skill entry and scenario resource exist')
print('NOT VERIFIED: isolation, submodule selection, setup or failure decisions; use scenarios')
CHECK
