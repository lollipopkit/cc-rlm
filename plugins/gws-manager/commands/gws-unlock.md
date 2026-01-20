---
name: gws:unlock
description: Release an advisory lock for a path pattern
argument-hint: <pattern> --owner <agent-id>
allowed-tools: Bash, Read
---

Release an advisory lock:
1. Run unlock command:
   ```bash
   bash ${CLAUDE_PLUGIN_ROOT}/scripts/gws-wrapper.sh unlock $ARGUMENTS --json
   ```
