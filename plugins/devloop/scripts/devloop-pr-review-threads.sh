#!/bin/bash
set -euo pipefail

# Fetch active (not outdated, not resolved) PR review thread comments via GitHub GraphQL.
#
# Outputs JSON Lines (one JSON object per line), suitable for piping.
#
# Usage:
#   bash "${CLAUDE_PLUGIN_ROOT}/scripts/devloop-pr-review-threads.sh" --repo owner/name --pr 123
#
# Notes:
# - Requires `gh` authenticated.
# - If --repo or --pr is omitted, will infer from current repo / current PR when possible.

usage() {
  cat <<'EOF'
Usage:
  devloop-pr-review-threads.sh [--repo owner/name] [--pr <number>] [--json] [--jq <filter>]

Options:
  --repo owner/name   GitHub repository (default: current repo)
  --pr <number>       Pull request number (default: current PR number)
  --json              Output JSONL (default)
  --jq <filter>       Apply jq filter to raw GraphQL response (advanced)

Examples:
  bash "${CLAUDE_PLUGIN_ROOT}/scripts/devloop-pr-review-threads.sh" --repo lollipopkit/cc-plugins --pr 33
EOF
}

REPO=""
PR=""
JQ_FILTER=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo)
      REPO="${2:-}"
      shift 2
      ;;
    --pr)
      PR="${2:-}"
      shift 2
      ;;
    --jq)
      JQ_FILTER="${2:-}"
      shift 2
      ;;
    --json)
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown arg: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ -z "$REPO" ]]; then
  REPO=$(gh repo view --json nameWithOwner --jq '.nameWithOwner')
fi

if [[ -z "$PR" ]]; then
  PR=$(gh pr view --json number --jq '.number')
fi

OWNER="${REPO%%/*}"
NAME="${REPO#*/}"

QUERY='query($name: String!, $owner: String!, $pr: Int!) {
  repository(owner: $owner, name: $name) {
    pullRequest(number: $pr) {
      reviewThreads(first: 100) {
        nodes {
          isOutdated
          isResolved
          comments(last: 20) {
            nodes {
              body
              path
              line
              author { login }
            }
          }
        }
      }
    }
  }
}'

if [[ -n "$JQ_FILTER" ]]; then
  gh api graphql -F owner="$OWNER" -F name="$NAME" -F pr="$PR" -f query="$QUERY" --jq "$JQ_FILTER"
  exit $?
fi

# Default: output JSONL of active comments (one JSON object per line).
gh api graphql -F owner="$OWNER" -F name="$NAME" -F pr="$PR" -f query="$QUERY" \
  --jq '.data.repository.pullRequest.reviewThreads.nodes[] | select(.isOutdated == false and .isResolved == false) | .comments.nodes[]'
