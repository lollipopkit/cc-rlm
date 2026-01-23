# context-firewall

Context Firewall plugin for Claude Code: preprocess large inputs using sub-agents, return compressed and auditable results with evidence locators, and verify claims at low cost.

## Components

### Commands

- `/cf-spec`: Generate a schema-valid `TaskSpec.v1` template (strict JSON only).
- `/cf-run`: Run Map-Reduce preprocessing (FileWorker → Aggregator) and output `SubResult.v1` (strict JSON only).
- `/cf-verify`: Sample-verify `SubResult.v1` evidence and output `VerifyReport.v1` (strict JSON only).

### Agents

- `cf-fileworker`: Scan a single shard input and produce evidence-backed claims (strict JSON only).
- `cf-aggregator`: Merge multiple FileWorker outputs into a single `SubResult.v1` (strict JSON only).
- `cf-critic`: Independent re-run for high-risk or conflict checking (strict JSON only).

### Hooks (advisory only)

Configured in `hooks/hooks.json`:

- `PreToolUse`: advise before potentially large reads / large tool outputs
- `PostToolUse`: advise after long WebFetch/WebSearch results
- `UserPromptSubmit`: advise when user pastes a large blob into the prompt

## Settings

Create a local config file:

- `<project>/.claude/context-firewall.local.md`

Use the template:

- `plugins/context-firewall/scripts/settings-frontmatter.md`

Common knobs:

- `enabled`: enable/disable workflow
- `read_warn_bytes`: advisory threshold for large reads
- `tool_output_warn_chars`: advisory threshold for tool output size
- `sample_rate`: verification sampling rate by risk level
- `persist.dir`: persistence directory (default `.claude/context-firewall`)

## Schemas

- `schemas/task-spec.v1.schema.json`
- `schemas/sub-result.v1.schema.json`
- `schemas/verify-report.v1.schema.json`
- `schemas/settings.v1.schema.json`

## Examples

- `examples/logs-timeout-task.json` - multi-log analysis with time window + keyword must_cover
- `examples/repo-entrypoints-task.json` - repo entrypoint/call-chain discovery + git diff context

## Quick test

See `scripts/test-plan.md`.
