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
assert len(text.splitlines()) <= 60, "always-loaded router exceeds 60 lines"
assert len(text.encode("utf-8")) <= 6144, "always-loaded router exceeds 6144 bytes"
assert text.startswith('---\n'), router
assert re.search(r'^name: using-superpowers$', text, re.M)
assert re.search(r'^description: .+', text, re.M)
routes = set(re.findall(r'\bL[123]\b', text))
assert routes == {'L1', 'L2', 'L3'}, routes
for name in ('brainstorming', 'writing-plans'):
    path = root / 'skills' / name / 'SKILL.md'
    assert path.is_file(), path
    assert re.search(r'^name: ' + name + '$', path.read_text(), re.M), path
for path in (root / 'skills/using-superpowers/references').glob('*-tools.md'):
    assert path.stat().st_size > 0, path
print('PASS: route identifiers, skill entry metadata, and reference files')
print('NOT VERIFIED: authorization transitions or execution decisions; use the scenario evaluation')
PY
