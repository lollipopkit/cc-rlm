---
name: gws:list
description: List all workspaces managed by gws
allowed-tools: Bash, Read
---

List existing workspaces:
```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/gws-wrapper.sh ls --json
```

Display the list of workspaces, including their branch names, paths, and whether they have uncommitted changes (dirty).
