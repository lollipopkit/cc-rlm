---
name: Context Firewall
description: This skill should be used when the user asks to "analyze a large log", "summarize a big file", "read the whole repository", "process long tool output", "avoid context window overflow", "use sub-agents for preprocessing", "add evidence with line numbers", "verify claims with locators", or mentions "TaskSpec", "SubResult", "Evidence Contract", "Context Firewall", "Map-Reduce", "FileWorker", "Aggregator", "Critic".
version: 0.1.0
---

Implement a **Context Firewall** workflow to prevent the master context from being flooded by large inputs.

## Purpose

Route large inputs (big files, logs, PDFs/images, long MCP/tool outputs) through sub-agents that produce **compressed, auditable results**. Only pass back:

- Structured claims
- Evidence locators (line/symbol/tool-call)
- Coverage statements

## When to use

Prefer this workflow when any of the following is true:

- The user wants the "full" content of a large file/log/document.
- Tool output is long/noisy (search results, crawls, API responses).
- The task needs multi-file scanning or cross-file synthesis.
- The output must be **verifiable** without re-reading everything.

## Core contract (Evidence Contract)

For every meaningful claim:

- Attach at least one `evidence` item.
- Use a locator that enables low-cost verification.

Locator preference order:

1) `line_range` (default)
2) `symbol_range` (functions/classes)
3) `tool_call` (tool-derived facts; include args hash and rerun hint when safe)
4) `byte_range/json_path/stack_signature` (define, but treat as harder to verify in v1)

Keep quotes short:

- Respect the `quote_max_chars` constraint.
- Never paste large raw blobs.

## Recommended workflow

### 1) Generate TaskSpec

Create a `TaskSpec.v1` that is explicit about:

- Objective
- Inputs (files/tool calls)
- Questions
- must_cover checklist
- Constraints (budget + evidence requirements)
- Risk level

Prefer using the command:

- `/cf-spec` to generate a schema-valid template.

### 2) Run Map-Reduce preprocessing

Use `/cf-run` to:

- Split inputs into shards
- Run `cf-fileworker` on each shard in parallel
- Merge with `cf-aggregator` into a final `SubResult.v1`

Hard requirements for sub-agents:

- Output **strict JSON only** (no markdown fences, no extra commentary).
- Ensure every claim includes evidence.

### 3) Verify cheaply

Use `/cf-verify` to sample-check claims:

- Choose sampling rate by `risk_level`.
- Re-read only the referenced snippets.
- Produce `VerifyReport.v1`.

If verification fails:

- Request stronger evidence (more/clearer locators).
- Narrow `must_cover`.
- Run a second-pass `cf-critic` to independently review.

## Coverage & anti-leak rules

Always include a `coverage` section that declares:

- Which inputs were scanned
- Which method was used (grep+window, full scan, time-window scan)
- Known gaps (missing archives, not provided inputs)

Never:

- Dump raw input into the master context.
- Hide uncertainty: mark gaps explicitly.

## Operational defaults

Default thresholds are configurable in:

- `.claude/context-firewall.local.md`

Defaults:

- `read_warn_bytes: 524288`
- `tool_output_warn_chars: 20000`
- `sample_rate: {low:0.05, medium:0.15, high:0.30}`

## Related resources

- Commands:
  - `plugins/context-firewall/commands/cf-spec.md`
  - `plugins/context-firewall/commands/cf-run.md`
  - `plugins/context-firewall/commands/cf-verify.md`
- Agents:
  - `plugins/context-firewall/agents/cf-fileworker.md`
  - `plugins/context-firewall/agents/cf-aggregator.md`
  - `plugins/context-firewall/agents/cf-critic.md`
- Schemas:
  - `plugins/context-firewall/schemas/task-spec.v1.schema.json`
  - `plugins/context-firewall/schemas/sub-result.v1.schema.json`
  - `plugins/context-firewall/schemas/verify-report.v1.schema.json`
  - `plugins/context-firewall/schemas/settings.v1.schema.json`
- Settings template:
  - `plugins/context-firewall/scripts/settings-frontmatter.md`
