#!/bin/bash

# Find gws binary: 1. project root, 2. primary worktree root, 3. system PATH
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
PRIMARY_ROOT="$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null | xargs dirname 2>/dev/null || echo "$ROOT")"
LOCAL_GWS="$ROOT/gws"
PRIMARY_GWS="$PRIMARY_ROOT/gws"

# Determine module path for build hint
MODULE_PATH="."
if [[ -f "$ROOT/go.mod" ]]; then
  MODULE_PATH=$(grep "^module " "$ROOT/go.mod" | awk '{print $2}')
  MODULE_PATH="${MODULE_PATH:-.}"
fi

if [[ -x "$LOCAL_GWS" ]]; then
  exec "$LOCAL_GWS" "$@"
elif [[ -x "$PRIMARY_GWS" ]]; then
  exec "$PRIMARY_GWS" "$@"
elif command -v gws >/dev/null 2>&1; then
  exec gws "$@"
else
  echo "Error: 'gws' binary not found in project root or PATH."
  echo "Please go install github.com/lollipopkit/gws/cmd/gws@latest"
  exit 6
fi
