---
name: gws:doctor
description: Perform health checks on the environment and gws configuration
allowed-tools: Bash, Read
---

Run diagnostic checks:

1. Run doctor command:

   ```bash
   bash ${CLAUDE_PLUGIN_ROOT}/scripts/gws-wrapper.sh doctor --json
   ```

2. Report any environment issues found (e.g., missing git worktree support, binary not found).
