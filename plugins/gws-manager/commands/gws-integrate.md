---
name: gws:integrate
description: Integrate changes from a workspace into the integration branch
argument-hint: [name] [--mode merge|rebase] [--no-ff] [--run test-cmd]
allowed-tools: Bash, Read
---

Integrate workspace changes:

1. If [name] is missing, attempt to determine the current workspace name from the working directory.
2. Run integration:

   ```bash
   bash ${CLAUDE_PLUGIN_ROOT}/scripts/gws-wrapper.sh integrate $ARGUMENTS --json
   ```

3. If there are conflicts, report the list of conflicting files and instruct the user to resolve them in the `integration` workspace.
4. Report test results if `--run` was used.
