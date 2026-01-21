# JSON Output Schemas

The `gws` tool provides `--json` output for all commands to facilitate integration with Claude Code and other agents.

## Common Fields

Every JSON response includes these fields:

```json
{
  "status": "success | error",
  "message": "Human readable message",
  "code": 0
}
```

## Command Specific Outputs

### `gws new`

```json
{
  "status": "success",
  "message": "Workspace created",
  "data": {
    "name": "feat-auth",
    "path": "/absolute/path/to/worktree",
    "branch": "feat-auth"
  }
}
```

### `gws ls`

```json
{
  "status": "success",
  "data": [
    {
      "name": "feat-auth",
      "path": "/path/to/feat-auth",
      "branch": "feat-auth",
      "agent": "agent-123",
      "task": "Implement auth"
    }
  ]
}
```

### `gws locks`

```json
{
  "status": "success",
  "data": [
    {
      "pattern": "pkg/auth/**",
      "owner": "agent-123",
      "workspace": "feat-auth",
      "expires": "2024-03-20T15:00:00Z"
    }
  ]
}
```

### `gws integrate`

```json
{
  "status": "success",
  "message": "Integration successful",
  "data": {
    "conflicts": [],
    "test_output": "PASS",
    "integrated_commit": "abc1234"
  }
}
```
