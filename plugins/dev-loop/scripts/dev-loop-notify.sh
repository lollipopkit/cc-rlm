#!/bin/bash
set -euo pipefail

# Stop hook notification runner.
#
# Executes a user-provided notification command template from
# `.claude/dev-loop.local.md` when `notify_enabled: true`.
#
# This script intentionally allows arbitrary user-configured commands.
# Keep it gated behind explicit opt-in flags in the settings file.

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
SETTINGS_FILE="$PROJECT_DIR/.claude/dev-loop.local.md"

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

export("DEV_LOOP_EVENT_NAME", data.get("hook_event_name", ""))
export("DEV_LOOP_REASON", data.get("reason", ""))
export("DEV_LOOP_TRANSCRIPT_PATH", data.get("transcript_path", ""))

raw = json.dumps(data, ensure_ascii=False)
export("DEV_LOOP_EVENT_JSON_B64", base64.b64encode(raw.encode("utf-8")).decode("ascii"))
PY
  )
  # shellcheck disable=SC1090
  eval "$EXPORTS"
else
  export DEV_LOOP_EVENT_NAME=""
  export DEV_LOOP_REASON=""
  export DEV_LOOP_TRANSCRIPT_PATH="${CLAUDE_TRANSCRIPT_PATH:-}"
  export DEV_LOOP_EVENT_JSON_B64=""
fi

export DEV_LOOP_PROJECT_DIR="$PROJECT_DIR"

# Extract YAML frontmatter between the FIRST pair of --- markers.
#
# NOTE: This is intentionally a lightweight, line-based extractor and is NOT a full YAML parser.
# It only supports simple single-line `key: value` pairs.
#
# Backward-compat: `notify_command` (old) is treated as `notify_command_template` (new).
FRONTMATTER=""
if head -n 1 "$SETTINGS_FILE" | grep -q "^---$"; then
  FRONTMATTER=$(sed -n '2,/^---$/ { /^---$/q; p; }' "$SETTINGS_FILE" || true)
fi

enabled=$(echo "$FRONTMATTER" | awk -F': *' '$1=="enabled"{print $2}' | tr -d '"'\'' ' | head -n 1)
notify_enabled=$(echo "$FRONTMATTER" | awk -F': *' '$1=="notify_enabled"{print $2}' | tr -d '"'\'' ' | head -n 1)
notify_on_stop=$(echo "$FRONTMATTER" | awk -F': *' '$1=="notify_on_stop"{print $2}' | tr -d '"'\'' ' | head -n 1)
notify_shell=$(echo "$FRONTMATTER" | awk -F': *' '$1=="notify_shell"{print $2}' | tr -d '"'\'' ' | head -n 1)

# Backward-compat: notify_command (old) vs notify_command_template (new).
notify_command_template=$(echo "$FRONTMATTER" | awk -F': *' '$1=="notify_command_template"{sub($1 FS, ""); sub(/^[ \t]+/, ""); print}' | head -n 1)
notify_command=$(echo "$FRONTMATTER" | awk -F': *' '$1=="notify_command"{sub($1 FS, ""); sub(/^[ \t]+/, ""); print}' | head -n 1)
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
# Use a separate variable for the unquoted message and one for the shell-quoted version.
message="dev-loop stop event: ${DEV_LOOP_EVENT_NAME:-Stop} | project: $PROJECT_DIR"
if [[ -n "${DEV_LOOP_REASON:-}" ]]; then
  message="$message | reason: ${DEV_LOOP_REASON}"
fi
if [[ -n "${DEV_LOOP_TRANSCRIPT_PATH:-}" ]]; then
  message="$message | transcript: ${DEV_LOOP_TRANSCRIPT_PATH}"
fi
export DEV_LOOP_MESSAGE="$message"
# Provide a pre-quoted version for safer use in templates.
# Declare and assign separately to avoid masking exit status (SC2155).
DEV_LOOP_MESSAGE_QUOTED="'$(echo "$message" | sed "s/'/'\\\\''/g")'"
export DEV_LOOP_MESSAGE_QUOTED

run_with_shell() {
  local shell_name="$1"
  local cmd="$2"

  if [[ "$shell_name" == "fish" ]]; then
    if command -v fish >/dev/null 2>&1; then
      # Execute the command string directly in fish.
      fish -c "$cmd"
      return $?
    fi
    return 127
  fi

  bash -c "$cmd"
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
      echo "dev-loop-notify: unsupported notify_shell='${notify_shell}'; falling back to auto (bash then fish)" >&2
    fi

    if command -v bash >/dev/null 2>&1; then
      run_with_shell bash "$notify_command_template"
      exit $?
    fi

    run_with_shell fish "$notify_command_template"
    ;;
esac
