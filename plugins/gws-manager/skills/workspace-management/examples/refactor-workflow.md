# Refactoring Workflow Example

This example demonstrates how to use `gws` and the `gws-manager` plugin for a complex multi-file refactoring task.

## Scenario

The user wants to refactor the database layer to use a new connection pool. This involves changes across multiple files in `internal/db/` and updating usages in `cmd/server/`.

## Step 1: Initialize Workspace

Start by creating a dedicated environment for the refactor.

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/gws-wrapper.sh new refactor-db-pool \
  --agent "claude-refactor-1" \
  --task "Refactor DB connection pool to use pgxpool" \
  --json
```

**Note**: Save the `path` returned in the JSON response. All subsequent operations should happen within that directory.

## Step 2: Secure Advisory Locks

Before making changes, lock the directories you intend to modify to signal your intent to other agents.

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/gws-wrapper.sh lock "internal/db/**" \
  --owner "claude-refactor-1" \
  --ws "refactor-db-pool" \
  --json
```

## Step 3: Implementation

Switch to the workspace directory and perform the refactoring.

1. Read files in `internal/db/`.
2. Implement the new connection pool logic.
3. Update callers in `cmd/server/`.
4. Run local tests within the workspace.
5. Release the advisory lock before integration.

   ```bash
   bash ${CLAUDE_PLUGIN_ROOT}/scripts/gws-wrapper.sh unlock "internal/db/**" \
     --owner "claude-refactor-1" \
     --json
   ```

## Step 4: Verification

Verify that the changes are correct and don't break existing functionality.

```bash
go test ./internal/db/...
go build ./cmd/server/
```

## Step 5: Integration

Merge the changes back to the main branch via the integration workspace.

```bash
# Prepare integration workspace
bash ${CLAUDE_PLUGIN_ROOT}/scripts/gws-wrapper.sh ensure-integration --json

# Perform integration with tests
bash ${CLAUDE_PLUGIN_ROOT}/scripts/gws-wrapper.sh integrate refactor-db-pool \
  --mode merge \
  --no-ff \
  --run "go test ./..." \
  --json
```

## Step 6: Cleanup

Remove the workspace once integrated.

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/gws-wrapper.sh rm refactor-db-pool --json
```
