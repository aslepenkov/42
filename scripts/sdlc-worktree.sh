#!/usr/bin/env bash
# Deterministic git plumbing for the 42sdlc flow (see docs/forge.md).
#   feature <name>            switch the main checkout to sdlc/<name>, creating it from HEAD if needed
#   start   <ticket>          create .worktrees/<ID> on ticket/<ID>-<slug> from sdlc/<feature>; prints path
#   commit  <ticket> <msg>    stage everything in the ticket worktree and commit
#   merge   <ticket>          merge the ticket branch into sdlc/<feature>, then remove worktree and branch
#   path    <ticket>          print the ticket worktree path
# <ticket> is a ticket ID (T-001, B-002) or a path to its markdown file.
set -euo pipefail

MAIN="$(dirname "$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --path-format=absolute --git-common-dir)")"
WT_DIR="$MAIN/.worktrees"

die() { printf '%s\n' "$*" >&2; exit 1; }

field() { # frontmatter value: field <file> <key>
  awk -v k="$2" 'NR==1 && $0!="---" {exit} NR>1 && $0=="---" {exit}
    NR>1 && index($0, k": ")==1 {print substr($0, length(k)+3); exit}' "$1"
}

ticket_file() {
  if [[ -f "$1" ]]; then printf '%s\n' "$1"; return; fi
  local found
  found=$(find "$MAIN/docs/features" "$MAIN/docs/bugs" -name "$1-*.md" -print -quit 2>/dev/null || true)
  [[ -n "$found" ]] || die "Ticket not found: $1"
  printf '%s\n' "$found"
}

load_ticket() {
  FILE=$(ticket_file "$1")
  ID=$(field "$FILE" id)
  FEATURE=$(field "$FILE" feature)
  [[ "$ID" =~ ^[A-Z]+-[0-9]+$ ]] || die "Missing or invalid 'id' in $FILE"
  [[ "$FEATURE" =~ ^[a-z0-9][a-z0-9-]*$ ]] || die "Missing or invalid 'feature' in $FILE"
  local name; name=$(basename "$FILE" .md)
  BRANCH="ticket/$ID-${name#"$ID"-}"
  FEATURE_BRANCH="sdlc/$FEATURE"
  WT="$WT_DIR/$ID"
}

require_feature_checkout() {
  [[ "$(git -C "$MAIN" branch --show-current)" == "$FEATURE_BRANCH" ]] ||
    die "Main checkout must be on $FEATURE_BRANCH; run: bash scripts/sdlc-worktree.sh feature $FEATURE"
}

cmd="${1:-}"; shift || true
case "$cmd" in
  feature)
    [[ "${1:-}" =~ ^[a-z0-9][a-z0-9-]*$ ]] || die "Usage: feature <kebab-case-name>"
    if git -C "$MAIN" show-ref --verify --quiet "refs/heads/sdlc/$1"; then
      git -C "$MAIN" switch "sdlc/$1"
    else
      git -C "$MAIN" switch -c "sdlc/$1"
    fi
    ;;
  start)
    load_ticket "${1:?Usage: start <ticket>}"
    git -C "$MAIN" show-ref --verify --quiet "refs/heads/$FEATURE_BRANCH" || die "Missing $FEATURE_BRANCH; run feature $FEATURE first."
    if [[ ! -d "$WT" ]]; then
      if git -C "$MAIN" show-ref --verify --quiet "refs/heads/$BRANCH"; then
        git -C "$MAIN" worktree add --quiet "$WT" "$BRANCH"
      else
        git -C "$MAIN" worktree add --quiet -b "$BRANCH" "$WT" "$FEATURE_BRANCH"
      fi
    fi
    printf '%s\n' "$WT"
    ;;
  commit)
    load_ticket "${1:?Usage: commit <ticket> <message>}"
    [[ -n "${2:-}" ]] || die "Usage: commit <ticket> <message>"
    [[ -d "$WT" ]] || die "No worktree for $ID"
    git -C "$WT" add -A
    git -C "$WT" diff --cached --quiet && die "Nothing to commit in $WT"
    git -C "$WT" commit --quiet -m "$2" -m "Ticket: $ID"
    git -C "$WT" log -1 --oneline
    ;;
  merge)
    load_ticket "${1:?Usage: merge <ticket>}"
    require_feature_checkout
    [[ -z "$(git -C "$WT" status --porcelain 2>/dev/null)" ]] || die "Uncommitted changes in $WT"
    if ! git -C "$MAIN" merge --no-ff --quiet "$BRANCH" -m "chore(sdlc): merge $ID into $FEATURE_BRANCH"; then
      git -C "$MAIN" merge --abort
      printf 'Merge conflict: merge %s into %s inside %s, resolve, re-check, commit, then retry.\n' \
        "$FEATURE_BRANCH" "$BRANCH" "$WT" >&2
      exit 2
    fi
    git -C "$MAIN" worktree remove "$WT"
    git -C "$MAIN" branch -d --quiet "$BRANCH"
    git -C "$MAIN" log -1 --oneline
    ;;
  path)
    load_ticket "${1:?Usage: path <ticket>}"
    printf '%s\n' "$WT"
    ;;
  *)
    sed -n '2,8p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
    exit 1
    ;;
esac
