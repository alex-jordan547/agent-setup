#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  contribution_preflight.sh start
  contribution_preflight.sh draft
  contribution_preflight.sh ready <PR-number> <base-branch>

Run from an OmniRoute git worktree. The script never changes tracked files.
EOF
}

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

pass() {
  printf 'OK: %s\n' "$1"
}

require_file() {
  [ -f "$1" ] || fail "required repository guidance missing: $1"
}

mode="${1:-}"
case "$mode" in
  start|draft) ;;
  ready)
    [ "$#" -eq 3 ] || { usage >&2; exit 2; }
    ;;
  *)
    usage >&2
    exit 2
    ;;
esac

root="$(git rev-parse --show-toplevel 2>/dev/null)" || fail "not inside a git worktree"
cd "$root"

repo_name="$(basename "$root")"
[ "$repo_name" = "OmniRoute" ] || fail "expected OmniRoute worktree, found: $root"

for file in \
  AGENTS.md \
  CONTRIBUTING.md \
  docs/dev/CONTRIBUTION_GOLDEN_PATH.md \
  docs/ops/BRANCHING_MODEL.md \
  changelog.d/README.md \
  .github/pull_request_template.md; do
  require_file "$file"
done
pass "all mandatory contribution guidance files exist"

upstream_url="$(git remote get-url upstream 2>/dev/null)" || fail "missing upstream remote"
git remote get-url origin >/dev/null 2>&1 || fail "missing origin remote"
case "$upstream_url" in
  *diegosouzapw/OmniRoute*) ;;
  *) fail "upstream does not point to diegosouzapw/OmniRoute: $upstream_url" ;;
esac
pass "upstream and origin remotes are configured"

git fetch upstream --prune
pass "upstream refs refreshed"

release_refs="$(git for-each-ref --format='%(refname:short)' 'refs/remotes/upstream/release/v*')"
[ -n "$release_refs" ] || fail "no upstream release/v* branch found"

active_version="$(
  printf '%s\n' "$release_refs" \
    | sed 's#^upstream/release/v##' \
    | awk -F. 'NF >= 3 && $1 ~ /^[0-9]+$/ && $2 ~ /^[0-9]+$/ && $3 ~ /^[0-9]+$/ { print }' \
    | sort -t. -k1,1n -k2,2n -k3,3n \
    | tail -n 1
)"
[ -n "$active_version" ] || fail "could not derive the highest numeric release branch"
active_base="release/v${active_version}"
printf 'INFO: highest fetched release branch: %s\n' "$active_base"
printf 'REQUIRED: verify live GitHub release-freeze state before choosing or confirming the base\n'

branch="$(git symbolic-ref --quiet --short HEAD 2>/dev/null)" || fail "detached HEAD"
head_sha="$(git rev-parse HEAD)"
printf 'INFO: branch=%s head=%s\n' "$branch" "$head_sha"

if [ "$mode" = "start" ]; then
  printf 'REQUIRED: read all mandatory guidance files and applicable subdirectory AGENTS.md files now\n'
  printf 'REQUIRED: classify the change and record its Golden Path checks in the task plan\n'
  if [ -n "$(git status --short)" ]; then
    printf 'WARN: worktree is dirty; preserve and classify every existing change before editing\n'
  else
    pass "worktree is clean"
  fi
  exit 0
fi

case "$branch" in
  main|release/*) fail "publication branch must not be main or release/*: $branch" ;;
esac

[ -z "$(git status --short)" ] || fail "worktree must be clean before draft or Ready transition"
pass "publication branch and worktree state are valid"

if [ "$mode" = "draft" ]; then
  git rev-parse --verify HEAD >/dev/null
  pass "implementation is committed"
  printf 'REQUIRED: push this exact SHA, create the PR as draft, then read back number/base/head/draft/SHA\n'
  exit 0
fi

pr_number="$2"
base_branch="$3"
case "$pr_number" in
  ''|*[!0-9]*) fail "PR number must be numeric: $pr_number" ;;
esac
case "$base_branch" in
  release/v*) ;;
  *) fail "base branch must be release/v*: $base_branch" ;;
esac

git show-ref --verify --quiet "refs/remotes/upstream/$base_branch" \
  || fail "base branch is not present in refreshed upstream refs: $base_branch"
git merge-base --is-ancestor "upstream/$base_branch" HEAD \
  || fail "branch is not reconciled with current upstream/$base_branch"
pass "base branch is an ancestor of HEAD"

fragment_count=0
fragment_path=""
for section in features fixes maintenance; do
  for candidate in "changelog.d/$section/${pr_number}-"*.md; do
    [ -e "$candidate" ] || continue
    fragment_count=$((fragment_count + 1))
    fragment_path="$candidate"
  done
done
[ "$fragment_count" -eq 1 ] \
  || fail "expected exactly one changelog fragment prefixed ${pr_number}-, found $fragment_count"
grep -Eq '^- ' "$fragment_path" || fail "fragment must contain a bullet starting with - "
grep -Eq "(pull/${pr_number}|#${pr_number})" "$fragment_path" \
  || fail "fragment does not reference PR #${pr_number}"
pass "PR-numbered changelog fragment is present and references the PR"

remote_sha="$(git ls-remote origin "refs/heads/$branch" | awk 'NR == 1 { print $1 }')"
[ -n "$remote_sha" ] || fail "origin branch not found: $branch"
[ "$remote_sha" = "$head_sha" ] \
  || fail "origin SHA mismatch: local=$head_sha remote=$remote_sha"
pass "origin branch matches local HEAD"

git diff --check
pass "git diff --check"

npm run check:changelog-integrity
pass "changelog integrity gate"

printf 'REQUIRED: read back PR #%s and verify draft=true, base=%s, head=%s, SHA=%s\n' \
  "$pr_number" "$base_branch" "$branch" "$head_sha"
printf 'REQUIRED: verify recorded focused gates and obtain action-time user confirmation before Ready\n'
