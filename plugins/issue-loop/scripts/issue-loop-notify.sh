#!/bin/bash
set -euo pipefail

# Stop hook notification runner.
#
# Executes a user-provided notification command template from
# `.claude/issue-loop.local.md` when `notify_enabled: true`.
#
# This script intentionally allows arbitrary user-configured commands.
# Keep it gated behind explicit opt-in flags in the settings file.

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
SETTINGS_FILE="$PROJECT_DIR/.claude/issue-loop.local.md"

if [[ ! -f "$SETTINGS_FILE" ]]; then
  exit 0
fi

# Read hook input JSON (Stop hook sends JSON on stdin).
HOOK_INPUT=""
if ! HOOK_INPUT=$(cat 2>/dev/null); then
  HOOK_INPUT=""
fi

# Export rich context for notify templates.
# Use base64 to avoid quoting/encoding issues in env vars.
if [[ -n "$HOOK_INPUT" ]] && command -v python3 >/dev/null 2>&1; then
  EXPORTS=$(HOOK_INPUT="$HOOK_INPUT" python3 - <<'PY'
import base64
import json
import os
import shlex

hook_input = os.environ.get("HOOK_INPUT", "").strip()
try:
    data = json.loads(hook_input) if hook_input else {}
except Exception:
    data = {}

def s(v):
    return "" if v is None else str(v)

def export(name, value):
    print(f"export {name}={shlex.quote(s(value))}")

export("ISSUE_LOOP_EVENT_NAME", data.get("hook_event_name", ""))
export("ISSUE_LOOP_REASON", data.get("reason", ""))
export("ISSUE_LOOP_TRANSCRIPT_PATH", data.get("transcript_path", ""))

raw = json.dumps(data, ensure_ascii=False)
export("ISSUE_LOOP_EVENT_JSON_B64", base64.b64encode(raw.encode("utf-8")).decode("ascii"))
PY
  )
  # shellcheck disable=SC1090
  eval "$EXPORTS"
else
  export ISSUE_LOOP_EVENT_NAME=""
  export ISSUE_LOOP_REASON=""
  export ISSUE_LOOP_TRANSCRIPT_PATH="${CLAUDE_TRANSCRIPT_PATH:-}"
  export ISSUE_LOOP_EVENT_JSON_B64=""
fi

export ISSUE_LOOP_PROJECT_DIR="$PROJECT_DIR"

# Extract YAML frontmatter between --- markers.
#
# NOTE: This is intentionally a lightweight, line-based extractor and is NOT a full YAML parser.
# It only supports simple single-line `key: value` pairs (no multiline values, no nested
# structures, and avoid special characters/colons in values). If you need richer config,
# switch to a proper YAML parser.
#
# Backward-compat: `notify_command` (old) is treated as `notify_command_template` (new).
FRONTMATTER=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' "$SETTINGS_FILE" || true)

enabled=$(echo "$FRONTMATTER" | awk -F': *' '$1=="enabled"{print $2}' | tr -d '"' | head -n 1)
notify_enabled=$(echo "$FRONTMATTER" | awk -F': *' '$1=="notify_enabled"{print $2}' | tr -d '"' | head -n 1)
notify_on_stop=$(echo "$FRONTMATTER" | awk -F': *' '$1=="notify_on_stop"{print $2}' | tr -d '"' | head -n 1)
notify_shell=$(echo "$FRONTMATTER" | awk -F': *' '$1=="notify_shell"{print $2}' | tr -d '"' | head -n 1)

# Backward-compat: notify_command (old) vs notify_command_template (new).
notify_command_template=$(echo "$FRONTMATTER" | awk -F': *' '$1=="notify_command_template"{sub($1 FS, ""); print}' | head -n 1)
notify_command=$(echo "$FRONTMATTER" | awk -F': *' '$1=="notify_command"{sub($1 FS, ""); print}' | head -n 1)
if [[ -z "${notify_command_template:-}" ]]; then
  notify_command_template="$notify_command"
fi

if [[ "${enabled:-true}" != "true" ]]; then
  exit 0
fi

if [[ "${notify_enabled:-false}" != "true" ]]; then
  exit 0
fi

if [[ "${notify_on_stop:-true}" != "true" ]]; then
  exit 0
fi

if [[ -z "${notify_command_template:-}" ]]; then
  exit 0
fi

# A short default message; templates should prefer structured env vars.
message="issue-loop stop event: ${ISSUE_LOOP_EVENT_NAME:-Stop} | project: $PROJECT_DIR"
if [[ -n "${ISSUE_LOOP_REASON:-}" ]]; then
  message="$message | reason: ${ISSUE_LOOP_REASON}"
fi
if [[ -n "${ISSUE_LOOP_TRANSCRIPT_PATH:-}" ]]; then
  message="$message | transcript: ${ISSUE_LOOP_TRANSCRIPT_PATH}"
fi
export ISSUE_LOOP_MESSAGE="$message"

run_with_shell() {
  local shell_name="$1"
  local cmd="$2"

  if [[ "$shell_name" == "fish" ]]; then
    if command -v fish >/dev/null 2>&1; then
      fish -lc "$cmd"
      return $?
    fi
    return 127
  fi

  bash -lc "$cmd"
}

case "${notify_shell:-auto}" in
  bash)
    run_with_shell bash "$notify_command_template"
    ;;
  fish)
    run_with_shell fish "$notify_command_template"
    ;;
  auto|*)
    if [[ -n "${notify_shell:-}" && "${notify_shell}" != "auto" && "${notify_shell}" != "bash" && "${notify_shell}" != "fish" ]]; then
      echo "issue-loop-notify: unsupported notify_shell='${notify_shell}'; falling back to auto (bash then fish)" >&2
    fi

    if command -v bash >/dev/null 2>&1; then
      run_with_shell bash "$notify_command_template"
      exit $?
    fi

    run_with_shell fish "$notify_command_template"
    ;;
esac
