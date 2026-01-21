# CLI Usage Reference

For plugin-driven workflows, it is recommended to use the provided wrapper script to ensure consistent binary discovery:
`bash ${CLAUDE_PLUGIN_ROOT}/scripts/gws-wrapper.sh <command> [args]`

When running manually from the project root, you can use `./gws <command> [args]` if the binary is present.

## Commands

### `gws new <name>`

Creates a new worktree and branch.

- `--agent`: ID of the agent creating the workspace.
- `--task`: Short description of the task.
- `--from`: Base branch/commit (default: `origin/HEAD`).
- `--json`: Output result as JSON.

### `gws ls`

Lists all workspaces.

- `--json`: Output full details as JSON.

### `gws rm <name>`

Removes a workspace and its associated worktree.

- `--json`: Output result as JSON.

### `gws prune`

Prunes metadata for workspaces that no longer exist on disk.

- `--json`: Output result as JSON.

### `gws lock <pattern>`

Locks a path pattern.

- `--owner`: ID of the lock owner.
- `--ws`: Name of the workspace.
- `--ttl`: Expiration time (e.g., `1h`, `30m`).
- `--json`: Output result as JSON.

### `gws unlock <pattern>`

Unlocks a path pattern.

- `--owner`: ID of the lock owner.
- `--json`: Output result as JSON.

### `gws locks`

Lists all active locks.

- `--json`: Output result as JSON.

### `gws ensure-integration`

Ensures that the `integration` workspace is initialized and up to date with the base branch.

- `--from`: Base branch/commit to track (default: `origin/HEAD`).
- `--json`: Output result as JSON.

### `gws integrate <name>`

Integrates workspace branch into the `integration` branch.

- `--mode`: `merge` or `rebase`.
- `--run`: Optional command to run after integration (e.g., tests).
- `--no-ff`: Use non-fast-forward merge (only for `merge` mode).
- `--json`: Output result as JSON.

### `gws status`

Shows the status of the current workspace and active locks.

- `--json`: Output result as JSON.

### `gws doctor`

Performs health checks on the environment and `gws` configuration.

- `--json`: Output result as JSON.
