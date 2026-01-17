# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Plugin Management

- Add local repository as marketplace: `/plugin marketplace add .`
- Add remote repository as marketplace: `/plugin marketplace add lollipopkit/cc-plugins`
- Install a plugin: `/plugin install <plugin-name>@lk-ccp`
- List installed plugins: `/plugin list`

### Linting & Formatting

- Markdown linting: Ensure compliance with `.markdownlint.json` (disables MD013 and MD041).
- No standard build or test commands exist at the root; development is done by testing plugins live in Claude Code.

## Architecture & Code Structure

### Project Overview

This repository is a monorepo for Claude Code plugins. Each plugin extends Claude's capabilities with specialized agents, commands, hooks, and skills.

### Plugin Structure

All plugins follow a standard directory layout:

- `agents/`: AI agent definitions (Markdown files with YAML frontmatter).
- `commands/`: Slash commands available in the CLI.
- `hooks/`: Lifecycle hooks (e.g., `Stop` hook defined in `hooks.json`).
- `scripts/`: Helper scripts (Bash/Python) used by commands or agents.
- `skills/`: Complex multi-step capabilities defined in `SKILL.md`.

### Core Plugins

- `dev-loop`: Automates the software development lifecycle (branch -> fix -> commit -> PR -> review).
- `recursive-reasoning`: Implements advanced reasoning patterns (Master/Sub-Agent, Tree of Thoughts, Reflexion).

### Design Patterns

- **Master/Sub-Agent**: Used for complex orchestration. A "Master" agent plans and delegates to "Executor" sub-agents.
- **Local Settings**: Plugins often read per-project configuration from the target project's `.claude/<plugin-name>.local.md` file.
- **Markdown-Driven Logic**: Behavior is primarily defined via system prompts in Markdown files, using YAML frontmatter to specify tool permissions.

## Coding Conventions

- **GitHub CLI**: Prefer using `gh` for all GitHub-related operations (PRs, issues, comments).
- **Git Protocol**: Always create descriptive branches for new tasks.
- **Verification**: When implementing complex reasoning, always include a verification step to validate outputs.

## Additional

- DO NOT define `agents` in `plugin.json`. Agents are auto-discovered from the `agents/` directory.
