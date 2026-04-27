#!/usr/bin/env bash
set -euo pipefail

SCOPE_PATH="superpowers/5.0.7"

usage() {
  cat <<'EOF'
Usage:
  scripts/sp-checkpoint.sh -m "<topic message>" [--tag <tag-name>]

Examples:
  scripts/sp-checkpoint.sh -m "update feedback evolution contract"
  scripts/sp-checkpoint.sh -m "docs sync for hooks" --tag sp-v5.0.7-xia-2026-04-23-01

Behavior:
  1) Shows current git status
  2) Adds only superpowers/5.0.7 changes
  3) Commits using message format: superpowers: <message>
  4) Pushes current branch to origin
  5) Optionally creates and pushes one tag
EOF
}

require_git_repo() {
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Error: current directory is not a git repository." >&2
    exit 1
  fi
}

normalize_commit_message() {
  local raw="$1"
  if [[ "$raw" == superpowers:* ]]; then
    printf '%s' "$raw"
  else
    printf 'superpowers: %s' "$raw"
  fi
}

message=""
tag_name=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -m|--message)
      if [[ $# -lt 2 ]]; then
        echo "Error: missing value for $1" >&2
        usage
        exit 1
      fi
      message="$2"
      shift 2
      ;;
    --tag)
      if [[ $# -lt 2 ]]; then
        echo "Error: missing value for --tag" >&2
        usage
        exit 1
      fi
      tag_name="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Error: unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ -z "$message" ]]; then
  echo "Error: commit message is required." >&2
  usage
  exit 1
fi

require_git_repo

echo "==> Checking status"
git status -sb

echo "==> Staging scoped path: $SCOPE_PATH"
git add "$SCOPE_PATH"

if git diff --cached --quiet; then
  echo "No staged changes under $SCOPE_PATH. Nothing to commit."
  exit 0
fi

branch="$(git branch --show-current)"
if [[ -z "$branch" ]]; then
  echo "Error: could not detect current branch." >&2
  exit 1
fi

commit_message="$(normalize_commit_message "$message")"
echo "==> Committing: $commit_message"
git commit -m "$commit_message"

echo "==> Pushing branch: $branch"
git push origin "$branch"

if [[ -n "$tag_name" ]]; then
  if git rev-parse -q --verify "refs/tags/$tag_name" >/dev/null 2>&1; then
    echo "Error: tag already exists: $tag_name" >&2
    exit 1
  fi

  echo "==> Creating tag: $tag_name"
  git tag "$tag_name"
  echo "==> Pushing tag: $tag_name"
  git push origin "$tag_name"
fi

echo "Done."
