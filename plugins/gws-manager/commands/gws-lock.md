---
name: gws:lock
description: Lock a path pattern to prevent concurrent modifications
argument-hint: <pattern> --owner <agent-id> --ws <workspace-name> [--ttl duration]
allowed-tools: Bash, Read
---

Secure an advisory lock:
1. Run lock command:
   ```bash
   bash ${CLAUDE_PLUGIN_ROOT}/scripts/gws-wrapper.sh lock $ARGUMENTS --json
   ```
2. If the lock is held by another owner, report the conflict and the current owner.
