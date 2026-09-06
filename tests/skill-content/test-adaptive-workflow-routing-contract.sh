#!/usr/bin/env bash
# Structural lint, not an evaluation of agent routing decisions.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
python3 - "$SCRIPT_DIR/../.." <<'PY'
import re
import sys
from pathlib import Path
root = Path(sys.argv[1]).resolve()
router = root / 'skills/using-superpowers/SKILL.md'
text = router.read_text()
assert text.startswith('---\n'), router
assert re.search(r'^name: using-superpowers$', text, re.M)
assert re.search(r'^description: .+', text, re.M)
routes = re.findall(r'^- (L[123])\s', text, re.M)
assert routes == ['L1', 'L2', 'L3'], routes
assert len(text.splitlines()) <= 60 and len(text.encode()) <= 6144, 'entry budget exceeded'
for name in ('brainstorming', 'writing-plans'):
    path = root / 'skills' / name / 'SKILL.md'
    assert path.is_file(), path
    assert re.search(r'^name: ' + name + '$', path.read_text(), re.M), path
for path in (root / 'skills/using-superpowers/references').glob('*-tools.md'):
    assert path.stat().st_size > 0, path
print('PASS: route inventory, skill entry structure, reference files, 60-line/6KB router budget')
print('NOT VERIFIED: authorization transitions or execution decisions; use the scenario evaluation')
PY
