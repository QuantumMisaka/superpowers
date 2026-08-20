#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

bash "$SCRIPT_DIR/test-design-artifact-contract.sh"
bash "$SCRIPT_DIR/test-codex-subagent-routing-contract.sh"
bash "$SCRIPT_DIR/test-adaptive-workflow-routing-contract.sh"
bash "$SCRIPT_DIR/test-positive-evidence-language.sh"
bash "$SCRIPT_DIR/test-worktree-submodule-contract.sh"
