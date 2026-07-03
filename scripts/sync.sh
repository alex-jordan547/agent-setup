#!/usr/bin/env bash
# Sync this repo's skills to every agent skill location on this machine.
#
# Destinations:
#   - <home>/.agents/skills          : all skills (cross-tool standard dir)
#   - <home>/.codex/skills           : only $CODEX_SKILLS from config.env
#   - under WSL, the same two dirs on the Windows side (/mnt/c/Users/$WINDOWS_USER)
#
# A manifest file (.agent-setup-managed) is written per destination. Only
# entries listed there are ever pruned, so skills installed by other tools
# (gstack, npx skills, ...) are never touched.
#
# Usage: sync.sh [--dry-run] [--no-prune]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILLS_DIR="$REPO_ROOT/skills"
MANIFEST_NAME=".agent-setup-managed"

# shellcheck disable=SC1091
source "$REPO_ROOT/config.env"

DRY_RUN=0
PRUNE=1
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    --no-prune) PRUNE=0 ;;
    *) echo "Unknown flag: $arg" >&2; exit 1 ;;
  esac
done

run() {
  if [ "$DRY_RUN" = 1 ]; then
    echo "  [dry-run] $*"
  else
    "$@"
  fi
}

is_wsl() {
  [ "$(uname -s)" = "Linux" ] && grep -qi microsoft /proc/version 2>/dev/null
}

# sync_skills <dest_dir> <skill...>
sync_skills() {
  local dest="$1"; shift
  local names=("$@")
  echo "-> $dest"
  run mkdir -p "$dest"

  for name in "${names[@]}"; do
    [ -d "$SKILLS_DIR/$name" ] || { echo "  !! missing in repo: $name" >&2; continue; }
    run rsync -a --delete --copy-links --exclude .DS_Store \
      "$SKILLS_DIR/$name/" "$dest/$name/"
  done

  # Prune: remove previously-managed skills no longer in the sync set.
  local manifest="$dest/$MANIFEST_NAME"
  if [ "$PRUNE" = 1 ] && [ -f "$manifest" ]; then
    while IFS= read -r old; do
      [ -n "$old" ] || continue
      local still=0
      for name in "${names[@]}"; do [ "$name" = "$old" ] && still=1 && break; done
      if [ "$still" = 0 ] && [ -d "$dest/$old" ]; then
        echo "  prune: $old"
        run rm -rf "${dest:?}/$old"
      fi
    done < "$manifest"
  fi

  if [ "$DRY_RUN" = 1 ]; then
    echo "  [dry-run] write manifest $manifest"
  else
    printf '%s\n' "${names[@]}" > "$manifest"
  fi
}

# bash 3.2 compatible (macOS default shell has no mapfile; BSD find has no -printf)
ALL_SKILLS=()
while IFS= read -r d; do
  ALL_SKILLS+=("$(basename "$d")")
done < <(find "$SKILLS_DIR" -mindepth 1 -maxdepth 1 -type d | sort)
read -r -a CODEX_SET <<< "$CODEX_SKILLS"

echo "agent-setup sync ($([ "$DRY_RUN" = 1 ] && echo dry-run || echo live), ${#ALL_SKILLS[@]} skills)"

sync_skills "$HOME/.agents/skills" "${ALL_SKILLS[@]}"
sync_skills "$HOME/.codex/skills" "${CODEX_SET[@]}"

if is_wsl; then
  WIN_HOME="/mnt/c/Users/$WINDOWS_USER"
  if [ -d "$WIN_HOME" ]; then
    sync_skills "$WIN_HOME/.agents/skills" "${ALL_SKILLS[@]}"
    sync_skills "$WIN_HOME/.codex/skills" "${CODEX_SET[@]}"
  else
    echo "!! WSL detected but $WIN_HOME not found — check WINDOWS_USER in config.env" >&2
  fi
fi

echo "Done."
