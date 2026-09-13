#!/usr/bin/env bash
# Tests for the SDD workspace: scripts/sdd-workspace resolves a self-ignoring,
# PER-PLAN working-tree directory for SDD artifacts, and the SDD scripts write
# into their plan's directory.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SDD_SCRIPTS="$REPO_ROOT/skills/subagent-driven-development/scripts"

FAILURES=0
TEST_ROOT=""
TEST_SCRATCH_DIR="${HOME:?HOME must be set}/scratch"

pass() { echo "  [PASS] $1"; }
fail() {
    echo "  [FAIL] $1"
    FAILURES=$((FAILURES + 1))
}

main() {
    echo "=== Test: sdd-workspace ==="

    mkdir -p "$TEST_SCRATCH_DIR"
    TEST_ROOT="$(mktemp -d "$TEST_SCRATCH_DIR/sdd-workspace-test.XXXXXX")"
    echo "  fixture retained at: $TEST_ROOT"

    # Resolve repo to its physical path so string comparisons match the
    # helper's output (git rev-parse --show-toplevel resolves symlinks; on
    # macOS mktemp lives under /var -> /private/var).
    git init -q -b main "$TEST_ROOT/repo"
    local repo
    repo="$(cd "$TEST_ROOT/repo" && git rev-parse --show-toplevel)"

    cat > "$repo/plan-a.md" <<'PLAN'
# Plan A

## Task 1: First thing

Do the first thing.
PLAN
    cat > "$repo/plan-b.md" <<'PLAN'
# Plan B

## Task 1: Other thing

Do the other thing.
PLAN

    # --- argument validation ---
    local rc=0
    (cd "$repo" && "$SDD_SCRIPTS/sdd-workspace" >/dev/null 2>&1) || rc=$?
    if [[ "$rc" -eq 2 ]]; then
        pass "sdd-workspace without a plan errors with exit 2"
    else
        fail "sdd-workspace without a plan errors with exit 2"
        echo "    exit: $rc"
    fi

    rc=0
    (cd "$repo" && "$SDD_SCRIPTS/sdd-workspace" no-such-plan.md >/dev/null 2>&1) || rc=$?
    if [[ "$rc" -eq 2 ]]; then
        pass "sdd-workspace with a missing plan file errors with exit 2"
    else
        fail "sdd-workspace with a missing plan file errors with exit 2"
        echo "    exit: $rc"
    fi

    # --- per-plan resolution ---
    local dir_a dir_b
    dir_a="$(cd "$repo" && "$SDD_SCRIPTS/sdd-workspace" plan-a.md)"
    dir_b="$(cd "$repo" && "$SDD_SCRIPTS/sdd-workspace" plan-b.md)"

    if [[ "$dir_a" == "$repo/.superpowers/sdd/plan-a" ]]; then
        pass "prints <repo-root>/.superpowers/sdd/<plan-basename>"
    else
        fail "prints <repo-root>/.superpowers/sdd/<plan-basename>"
        echo "    got: $dir_a"
    fi

    if [[ "$dir_a" != "$dir_b" && -d "$dir_a" && -d "$dir_b" ]]; then
        pass "two plans resolve to two distinct directories"
    else
        fail "two plans resolve to two distinct directories"
        echo "    a: $dir_a"
        echo "    b: $dir_b"
    fi

    if [[ -f "$repo/.superpowers/sdd/.gitignore" && "$(cat "$repo/.superpowers/sdd/.gitignore")" == "*" ]]; then
        pass "self-ignoring .gitignore created at .superpowers/sdd/ with '*'"
    else
        fail "self-ignoring .gitignore created at .superpowers/sdd/ with '*'"
    fi

    printf 'x\n' > "$dir_a/artifact.md"
    local status
    status="$(cd "$repo" && git status --porcelain)"
    # plan-a.md/plan-b.md are intentionally untracked fixture files; only the
    # workspace must be invisible.
    if [[ "$status" != *".superpowers"* ]]; then
        pass "workspace invisible to git status"
    else
        fail "workspace invisible to git status"
        echo "    status: $status"
    fi

    ( cd "$repo" && git add -A )
    local staged
    staged="$(cd "$repo" && git diff --cached --name-only)"
    if [[ "$staged" != *".superpowers"* ]]; then
        pass "git add -A does not stage the workspace"
    else
        fail "git add -A does not stage the workspace"
        echo "    staged: $staged"
    fi

    # --- task-brief lands in its plan's directory ---
    local brief_out brief_path
    brief_out="$(cd "$repo" && "$SDD_SCRIPTS/task-brief" plan-a.md 1)"
    brief_path="$(printf '%s\n' "$brief_out" | sed -n 's/^wrote \(.*\): [0-9][0-9]* lines$/\1/p')"
    if [[ "$brief_path" == "$repo/.superpowers/sdd/plan-a/task-1-brief.md" ]]; then
        pass "task-brief writes its brief under the plan's workspace"
    else
        fail "task-brief writes its brief under the plan's workspace"
        echo "    got: $brief_path"
    fi

    # --- review-package takes the plan first and lands in its directory ---
    local git_id=(-c user.email=t@example.com -c user.name=t -c commit.gpgsign=false)
    ( cd "$repo" \
        && git "${git_id[@]}" commit -qm c1 \
        && printf 'y\n' > f && git add f \
        && git "${git_id[@]}" commit -qm c2 )
    local rp_out rp_path
    rp_out="$(cd "$repo" && "$SDD_SCRIPTS/review-package" plan-a.md HEAD~1 HEAD)"
    rp_path="$(printf '%s\n' "$rp_out" | sed -n 's/^wrote \(.*\): [0-9].*$/\1/p')"
    case "$rp_path" in
        "$repo/.superpowers/sdd/plan-a/review-"*.diff)
            pass "review-package writes its diff under the plan's workspace" ;;
        *)
            fail "review-package writes its diff under the plan's workspace"
            echo "    got: $rp_path"
            ;;
    esac

    rc=0
    (cd "$repo" && "$SDD_SCRIPTS/review-package" HEAD~1 HEAD >/dev/null 2>&1) || rc=$?
    if [[ "$rc" -eq 2 ]]; then
        pass "review-package without a plan errors with exit 2"
    else
        fail "review-package without a plan errors with exit 2"
        echo "    exit: $rc"
    fi

    local rp_explicit
    rp_explicit="$(cd "$repo" && "$SDD_SCRIPTS/review-package" plan-a.md HEAD~1 HEAD "$TEST_ROOT/explicit.diff")"
    if [[ -s "$TEST_ROOT/explicit.diff" && "$rp_explicit" == *"$TEST_ROOT/explicit.diff"* ]]; then
        pass "review-package honors an explicit OUTFILE"
    else
        fail "review-package honors an explicit OUTFILE"
        echo "    got: $rp_explicit"
    fi

    # --- dirty, path-scoped review package ---
    local staged_owned="staged-owned.txt"
    local unstaged_owned="f"
    local untracked_owned="untracked-owned.txt"
    local untracked_binary="untracked-owned.bin"
    local literal_owned="literal*.txt"
    local unrelated="unrelated.txt"
    printf 'staged content\n' > "$repo/$staged_owned"
    ( cd "$repo" && git add -- "$staged_owned" )
    printf 'worktree change\n' >> "$repo/$unstaged_owned"
    printf 'untracked content\n' > "$repo/$untracked_owned"
    printf '\000\377\001binary\n' > "$repo/$untracked_binary"
    printf 'literal path content\n' > "$repo/$literal_owned"
    printf 'unrelated content\n' > "$repo/$unrelated"

    local staged_index_before
    staged_index_before="$(cd "$repo" && git ls-files --stage)"
    local dirty_out dirty_path dirty_rc=0
    dirty_out="$(cd "$repo" && "$SDD_SCRIPTS/review-package" plan-a.md --dirty -- \
        "$staged_owned" "$unstaged_owned" "$untracked_owned" "$untracked_binary" "$literal_owned")" || dirty_rc=$?
    dirty_path="$(printf '%s\n' "$dirty_out" | sed -n 's/^wrote \(.*\): dirty snapshot.*$/\1/p')"

    if [[ "$dirty_rc" -eq 0 && -s "$dirty_path" && "$dirty_out" == *"$dirty_path"* ]]; then
        pass "dirty review-package writes a non-empty default workspace file"
    else
        fail "dirty review-package writes a non-empty default workspace file"
        echo "    exit: $dirty_rc"
        echo "    output: $dirty_out"
        echo "    path: $dirty_path"
    fi

    if [[ -n "$dirty_path" ]] && grep -a -q '^## HEAD$' "$dirty_path" && grep -a -q '^## Owned paths' "$dirty_path" && \
        grep -a -q '^## Scoped status' "$dirty_path"; then
        pass "dirty package records HEAD, owned paths, and scoped status"
    else
        fail "dirty package records HEAD, owned paths, and scoped status"
    fi

    if [[ -n "$dirty_path" ]] && grep -a -q 'staged content' "$dirty_path" && grep -a -q 'worktree change' "$dirty_path" && \
        grep -a -q 'untracked content' "$dirty_path" && grep -a -q 'GIT binary patch' "$dirty_path" && \
        grep -a -q 'literal path content' "$dirty_path"; then
        pass "dirty package captures staged, unstaged, text-untracked, binary-untracked, and literal paths"
    else
        fail "dirty package captures staged, unstaged, text-untracked, binary-untracked, and literal paths"
    fi

    if [[ -n "$dirty_path" && -s "$dirty_path" ]] && { ! grep -a -q "$unrelated" "$dirty_path" && ! grep -a -q 'unrelated content' "$dirty_path"; }; then
        pass "dirty package excludes unrelated working-tree files"
    else
        fail "dirty package excludes unrelated working-tree files"
    fi

    if [[ -n "$dirty_path" ]] && grep -a -q 'not attributable.*pre-dispatch baseline' "$dirty_path"; then
        pass "dirty package warns that attribution requires a pre-dispatch baseline"
    else
        fail "dirty package warns that attribution requires a pre-dispatch baseline"
    fi

    local staged_index_after
    staged_index_after="$(cd "$repo" && git ls-files --stage)"
    if [[ "$staged_index_before" == "$staged_index_after" ]]; then
        pass "dirty package leaves the git index unchanged"
    else
        fail "dirty package leaves the git index unchanged"
    fi

    local dirty_out_2 dirty_path_2 dirty_rc_2=0
    dirty_out_2="$(cd "$repo" && "$SDD_SCRIPTS/review-package" plan-a.md --dirty -- "$untracked_owned")" || dirty_rc_2=$?
    dirty_path_2="$(printf '%s\n' "$dirty_out_2" | sed -n 's/^wrote \(.*\): dirty snapshot.*$/\1/p')"
    if [[ "$dirty_rc_2" -eq 0 && -s "$dirty_path_2" && "$dirty_path" != "$dirty_path_2" ]]; then
        pass "dirty default output is unique across snapshots"
    else
        fail "dirty default output is unique across snapshots"
        echo "    exit: $dirty_rc_2"
        echo "    first:  $dirty_path"
        echo "    second: $dirty_path_2"
    fi

    local rc=0
    (cd "$repo" && "$SDD_SCRIPTS/review-package" plan-a.md --dirty -- >/dev/null 2>&1) || rc=$?
    if [[ "$rc" -eq 2 ]]; then
        pass "dirty review-package rejects an empty owned path list"
    else
        fail "dirty review-package rejects an empty owned path list"
        echo "    exit: $rc"
    fi

    rc=0
    (cd "$repo" && "$SDD_SCRIPTS/review-package" plan-a.md --dirty -- ../outside.txt >/dev/null 2>&1) || rc=$?
    if [[ "$rc" -eq 2 ]]; then
        pass "dirty review-package rejects an out-of-repository path"
    else
        fail "dirty review-package rejects an out-of-repository path"
        echo "    exit: $rc"
    fi

    # --- Worktree isolation: a linked worktree resolves its own workspace ---
    local wt="$TEST_ROOT/wt"
    ( cd "$repo" && git worktree add -q "$wt" -b wt-feature )
    local wt_root wt_dir
    wt_root="$(cd "$wt" && git rev-parse --show-toplevel)"
    wt_dir="$(cd "$wt" && "$SDD_SCRIPTS/sdd-workspace" plan-a.md)"
    if [[ "$wt_dir" == "$wt_root/.superpowers/sdd/plan-a" && "$wt_dir" != "$dir_a" ]]; then
        pass "linked worktree resolves its own distinct workspace"
    else
        fail "linked worktree resolves its own distinct workspace"
        echo "    main: $dir_a"
        echo "    wt:   $wt_dir"
    fi

    printf 'y\n' > "$wt_dir/artifact.md"
    local wt_status
    wt_status="$(cd "$wt" && git status --porcelain)"
    if [[ "$wt_status" != *".superpowers"* ]]; then
        pass "worktree workspace invisible to git status"
    else
        fail "worktree workspace invisible to git status"
        echo "    status: $wt_status"
    fi

    echo ""
    if [[ "$FAILURES" -ne 0 ]]; then
        echo "FAILED: $FAILURES assertion(s)."
        exit 1
    fi
    echo "PASS"
}

main "$@"
