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
# - Implements cursor-based pagination for both reviewThreads and thread comments.

usage() {
  cat <<'EOF'
Usage:
  devloop-pr-review-threads.sh [--repo owner/name] [--pr <number>] [--json] [--jq <filter>]

Options:
  --repo owner/name   GitHub repository (default: current repo)
  --pr <number>       Pull request number (default: current PR number)
  --json              Output JSONL (default)
  --jq <filter>       Apply jq filter to a single raw GraphQL response (advanced; no pagination)

Examples:
  bash "${CLAUDE_PLUGIN_ROOT}/scripts/devloop-pr-review-threads.sh" --repo lollipopkit/cc-plugins --pr 33
EOF
}

REPO=""
PR=""
JQ_FILTER=""

need_value() {
  local flag="$1"
  local value="${2:-}"

  if [[ -z "$value" || "$value" == -* ]]; then
    echo "Missing value for $flag" >&2
    usage >&2
    exit 2
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo)
      need_value "--repo" "${2:-}"
      REPO="$2"
      shift 2
      ;;
    --pr)
      need_value "--pr" "${2:-}"
      PR="$2"
      shift 2
      ;;
    --jq)
      need_value "--jq" "${2:-}"
      JQ_FILTER="$2"
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

if ! command -v gh >/dev/null 2>&1; then
  echo "gh is required" >&2
  exit 127
fi

if [[ -z "$REPO" ]]; then
  REPO=$(gh repo view --json nameWithOwner --jq '.nameWithOwner')
fi

if [[ -z "$PR" ]]; then
  PR=$(gh pr view --json number --jq '.number')
fi

if [[ "$REPO" != */* || "${REPO#*/}" == *"/"* ]]; then
  echo "Invalid --repo format: expected owner/name" >&2
  exit 2
fi

OWNER="${REPO%%/*}"
NAME="${REPO#*/}"

# Advanced: allow a user-provided --jq against a single response (no pagination).
if [[ -n "$JQ_FILTER" ]]; then
  QUERY_SINGLE='query($name: String!, $owner: String!, $pr: Int!) {
  repository(owner: $owner, name: $name) {
    pullRequest(number: $pr) {
      reviewThreads(first: 100) {
        nodes {
          isOutdated
          isResolved
          comments(first: 100) {
            nodes { body path line author { login } }
          }
        }
      }
    }
  }
}'

  gh api graphql -F owner="$OWNER" -F name="$NAME" -F pr="$PR" -f query="$QUERY_SINGLE" --jq "$JQ_FILTER"
  exit $?
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 is required for pagination/JSONL output" >&2
  exit 127
fi

OWNER="$OWNER" NAME="$NAME" PR="$PR" python3 - <<'PY'
import json
import os
import subprocess
import sys
from typing import Any, Dict, Optional

OWNER = os.environ["OWNER"]
NAME = os.environ["NAME"]
PR = os.environ["PR"]

QUERY_THREADS = r"""
query($name: String!, $owner: String!, $pr: Int!, $threadsAfter: String) {
  repository(owner: $owner, name: $name) {
    pullRequest(number: $pr) {
      reviewThreads(first: 100, after: $threadsAfter) {
        pageInfo { hasNextPage endCursor }
        nodes {
          id
          isOutdated
          isResolved
          comments(first: 100) {
            pageInfo { hasNextPage endCursor }
            nodes { body path line author { login } }
          }
        }
      }
    }
  }
}
"""

QUERY_THREAD_COMMENTS = r"""
query($id: ID!, $commentsAfter: String) {
  node(id: $id) {
    ... on PullRequestReviewThread {
      id
      isOutdated
      isResolved
      comments(first: 100, after: $commentsAfter) {
        pageInfo { hasNextPage endCursor }
        nodes { body path line author { login } }
      }
    }
  }
}
"""


def gh_graphql(query: str, variables: Dict[str, Any]) -> Dict[str, Any]:
    cmd = ["gh", "api", "graphql"]
    for k, v in variables.items():
        if v is None:
            continue
        cmd += ["-F", f"{k}={v}"]
    cmd += ["-f", f"query={query}"]

    res = subprocess.run(cmd, capture_output=True, text=True)
    if res.returncode != 0:
        sys.stderr.write(res.stderr)
        raise SystemExit(res.returncode)

    try:
        data = json.loads(res.stdout)
    except json.JSONDecodeError as e:
        sys.stderr.write(res.stdout)
        sys.stderr.write(str(e) + "\n")
        raise SystemExit(1)

    errors = data.get("errors")
    if errors:
        sys.stderr.write(json.dumps(errors, ensure_ascii=False, indent=2))
        sys.stderr.write("\n")
        raise SystemExit(1)

    return data


def emit_jsonl(obj: Any) -> None:
    sys.stdout.write(json.dumps(obj, ensure_ascii=False))
    sys.stdout.write("\n")
    sys.stdout.flush()


def main() -> int:
    threads_after: Optional[str] = None

    while True:
        resp = gh_graphql(
            QUERY_THREADS,
            {
                "owner": OWNER,
                "name": NAME,
                "pr": PR,
                "threadsAfter": threads_after,
            },
        )

        threads = (
            resp.get("data", {})
            .get("repository", {})
            .get("pullRequest", {})
            .get("reviewThreads", {})
        )

        for thread in threads.get("nodes", []) or []:
            if thread.get("isOutdated") or thread.get("isResolved"):
                continue

            thread_id = thread.get("id")
            comments_conn = thread.get("comments") or {}
            for c in comments_conn.get("nodes", []) or []:
                emit_jsonl(c)

            page = comments_conn.get("pageInfo") or {}
            comments_after = page.get("endCursor") if page.get("hasNextPage") else None

            while comments_after and thread_id:
                resp2 = gh_graphql(
                    QUERY_THREAD_COMMENTS,
                    {
                        "id": thread_id,
                        "commentsAfter": comments_after,
                    },
                )

                node = (resp2.get("data", {}) or {}).get("node")
                if not node:
                    break
                if node.get("isOutdated") or node.get("isResolved"):
                    break

                comments_conn2 = node.get("comments") or {}
                for c in comments_conn2.get("nodes", []) or []:
                    emit_jsonl(c)

                page2 = comments_conn2.get("pageInfo") or {}
                comments_after = page2.get("endCursor") if page2.get("hasNextPage") else None

        threads_page = threads.get("pageInfo") or {}
        if threads_page.get("hasNextPage"):
            threads_after = threads_page.get("endCursor")
            continue

        break

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
PY
