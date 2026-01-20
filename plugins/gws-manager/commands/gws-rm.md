---
name: gws:rm
description: Remove a workspace and its associated worktree
argument-hint: <name>
allowed-tools: Bash, Read
---

Remove workspace:
1. Run rm command:
   ```bash
   bash ${CLAUDE_PLUGIN_ROOT}/scripts/gws-wrapper.sh rm $ARGUMENTS --json
   ```
