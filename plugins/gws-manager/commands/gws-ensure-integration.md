---
name: gws:ensure-integration
description: Ensure the integration workspace is ready and up to date
argument-hint: [--from base-branch]
allowed-tools: Bash, Read
---

Prepare integration workspace:
1. Run ensure-integration command:
   ```bash
   bash ${CLAUDE_PLUGIN_ROOT}/scripts/gws-wrapper.sh ensure-integration $ARGUMENTS --json
   ```
