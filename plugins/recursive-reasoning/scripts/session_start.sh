#!/bin/sh
set -eu

# SessionStart hook: add lightweight context and ensure python3 is available.
# Note: stdout is injected into context for SessionStart.

if command -v python3 >/dev/null 2>&1; then
  PYTHON3_BIN="$(command -v python3)"
  echo "Recursive-reasoning plugin: python3 detected at ${PYTHON3_BIN}."
else
  echo "Recursive-reasoning plugin: python3 not found in PATH; multi-model/recursive-arena commands that run python scripts may fail." >&2
fi

# Also persist a couple of env vars for subsequent Bash hooks.
# CLAUDE_ENV_FILE is only available in SessionStart.
if [ -n "${CLAUDE_ENV_FILE:-}" ]; then
  {
    echo 'export RECURSIVE_REASONING_PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT}"'
    echo 'export RECURSIVE_REASONING_PROJECT_ROOT="${CLAUDE_PROJECT_DIR}"'
  } >> "$CLAUDE_ENV_FILE"
fi

exit 0
