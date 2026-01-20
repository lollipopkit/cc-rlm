---
name: gws:new
description: Create a new parallel development workspace (worktree)
argument-hint: [name] [--agent agent-id] [--task task-desc] [--from branch]
allowed-tools: Bash, Read
---

Create a new workspace using the gws tool.

1. If [name] is not provided, generate a descriptive name based on the current task (e.g., `feat-auth`, `refactor-db`).
2. Run the command:
   ```bash
   bash ${CLAUDE_PLUGIN_ROOT}/scripts/gws-wrapper.sh new $ARGUMENTS --json
   ```
3. Report the workspace name, path, and branch to the user.
4. Suggest using the `workspace-agent` or switching to the new path to continue work.
