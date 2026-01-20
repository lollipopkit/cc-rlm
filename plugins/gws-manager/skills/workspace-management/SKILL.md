---
name: Workspace Management
description: This skill should be used when the user asks to "create a workspace", "manage parallel development", "lock files", "isolate changes", "start a big feature", or "refactor the project". It provides guidance for using the gws CLI tool to manage git worktrees and advisory locks.
version: 0.1.0
---

## Overview

The `gws` CLI tool provides isolated development environments using `git worktrees`. This allows multiple agents or tasks to run in parallel without interfering with each other's changes. It also provides an advisory locking mechanism to prevent multiple agents from modifying the same files or directories simultaneously.

## Core Workflows

### 1. Starting a New Task

When starting a complex task (e.g., a large refactor or a new feature), create a dedicated workspace to isolate changes:

1. Generate a workspace name if not provided (e.g., `feat-auth` or `refactor-db`).
2. Run `bash ${CLAUDE_PLUGIN_ROOT}/scripts/gws-wrapper.sh new <name> --agent <agent-id> --task <task-description> --json`.
3. Note the returned path for the workspace.

### 2. Managing Advisory Locks

Prevent conflicts by locking the paths being modified:

- Before modifying files, check existing locks: `bash ${CLAUDE_PLUGIN_ROOT}/scripts/gws-wrapper.sh locks --json`.
- Lock the target directory or files: `bash ${CLAUDE_PLUGIN_ROOT}/scripts/gws-wrapper.sh lock "<pattern>" --owner <agent-id> --ws <workspace-name> --json`.
- Unlock after completion: `bash ${CLAUDE_PLUGIN_ROOT}/scripts/gws-wrapper.sh unlock "<pattern>" --owner <agent-id> --json`.

Patterns can be specific files (`src/main.go`) or directory globs (`src/**`).

### 3. Integrating Changes

Once the task is complete within the workspace:

1. Ensure the integration workspace is ready: `bash ${CLAUDE_PLUGIN_ROOT}/scripts/gws-wrapper.sh ensure-integration --json`.
2. Integrate the workspace changes: `bash ${CLAUDE_PLUGIN_ROOT}/scripts/gws-wrapper.sh integrate <name> --mode merge --run "go test ./..." --json`.
3. Resolve any conflicts in the `integration` workspace directory.

## Best Practices

- **Path Isolation**: Always work within the workspace path returned by `bash ${CLAUDE_PLUGIN_ROOT}/scripts/gws-wrapper.sh new`.
- **Locking**: Prefer locking broad patterns (e.g., `pkg/auth/**`) early in the task.
- **Clean up**: Use `bash ${CLAUDE_PLUGIN_ROOT}/scripts/gws-wrapper.sh rm <name>` or `bash ${CLAUDE_PLUGIN_ROOT}/scripts/gws-wrapper.sh prune` to remove completed workspaces.

## Configuration

The plugin supports per-project configuration via `.claude/gws-manager.local.md` in the repository root. This can be used to override default behaviors, specify integration branches, or define project-specific hooks.

## Additional Resources

### Reference Files

For detailed CLI usage and schemas, consult:
- **`references/cli-usage.md`** - Detailed command descriptions and flags.
- **`references/json-schema.md`** - JSON output structure for machine parsing.

### Example Files

Working examples in `examples/`:
- **`refactor-workflow.md`** - Step-by-step refactoring workflow using `gws`.
