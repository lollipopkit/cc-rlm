---
name: gws:prune
description: Prune metadata for workspaces that no longer exist on disk
allowed-tools: Bash, Read
---

Prune workspaces:

1. Run prune command:

   ```bash
   bash ${CLAUDE_PLUGIN_ROOT}/scripts/gws-wrapper.sh prune --json
   ```
