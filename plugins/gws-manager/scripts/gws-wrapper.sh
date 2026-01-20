#!/bin/bash

# Find gws binary: 1. project root, 2. system PATH
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
LOCAL_GWS="$ROOT/gws"

# Determine module path for build hint
MODULE_PATH="."
if [[ -f "$ROOT/go.mod" ]]; then
  MODULE_PATH=$(grep "^module " "$ROOT/go.mod" | awk '{print $2}')
  MODULE_PATH="${MODULE_PATH:-.}"
fi

if [[ -x "$LOCAL_GWS" ]]; then
  exec "$LOCAL_GWS" "$@"
elif command -v gws >/dev/null 2>&1; then
  exec gws "$@"
else
  echo "Error: 'gws' binary not found in project root or PATH."
  echo "Please build it using: go build -o gws ${MODULE_PATH}/cmd/gws"
  exit 6
fi
