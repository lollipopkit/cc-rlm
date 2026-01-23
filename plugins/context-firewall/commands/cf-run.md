---
name: cf-run
description: Run the context-firewall workflow: split inputs, invoke FileWorkers, aggregate into SubResult.v1.
allowed-tools: ["Read", "Write", "Edit", "Bash", "Task", "AskUserQuestion"]
argument-hint: "--spec <file|json> [--out <path>]"
---

Run the context-firewall workflow.

## Arguments

$ARGUMENTS

Expected:

- `--spec <file|json>` (required)
- `--out <path>` (optional)

## Steps

### 1) Resolve project root

- Run `pwd` via Bash and treat it as the project root directory.

### 2) Load TaskSpec JSON (`--spec`)

- Extract the `--spec` value from `$ARGUMENTS`.
  - If parsing fails or `--spec` is missing, emit a schema-valid **SubResult.v1** with `status: "tool_error"` and a single `followups` array containing the required usage message (e.g., `--spec <file|json> [--out <path>]`).

- If the `--spec` value, after trimming leading whitespace, begins with `{`, treat it as inline JSON.
- Otherwise treat it as a file path (use the untrimmed value):
  - If it is not absolute, resolve to an absolute path by joining with the project root.
  - Read the file content via Read.

### 3) Parse and validate TaskSpec.v1

- Parse the spec content as JSON.
- Validate minimum fields:
  - `version == "TaskSpec.v1"`
  - `task_id` is non-empty
  - `output_schema == "SubResult.v1"`
  - `inputs` is a non-empty array
  - `questions` is a non-empty array

Error handling (MANDATORY, JSON-only):

- If JSON parsing/validation fails, output a schema-valid **SubResult.v1** JSON:
  - `version: "SubResult.v1"`
  - `task_id`: use `"unknown"` if missing
  - `status: "tool_error"`
  - `answers: []`
  - `coverage.inputs_scanned: []`
  - `followups`: describe the missing/invalid fields

### 4) Load settings (optional)

- If `<root>/.claude/context-firewall.local.md` exists, read it and parse YAML frontmatter.
- If frontmatter has `enabled: false`, output a schema-valid SubResult.v1 JSON with:
  - `status: "partial"`
  - `answers: []`
  - `coverage.inputs_scanned: []`
  - `followups: [{"need":"plugin disabled","suggested_next_task":"set enabled: true in .claude/context-firewall.local.md"}]`

### 5) Persist TaskSpec

- Determine persistence root:
  - Default: `<root>/.claude/context-firewall/`
  - If settings frontmatter has `persist.dir`, use that path (resolve relative to `<root>`).
  - If settings frontmatter has `persist.enabled: false`, skip all persistence steps.

- Ensure these directories exist (create via Bash if missing):
  - `<persist_root>/task-specs/`
  - `<persist_root>/results/`

- Write the TaskSpec JSON to:
  - `<persist_root>/task-specs/<task_id>.json`

### 6) Map phase: launch FileWorkers (parallel)

- For each element in `TaskSpec.inputs`, build a shard TaskSpec JSON:
  - Copy the original TaskSpec.
  - Replace `inputs` with a single-element array containing only that input.
  - Optionally append `" [shard i/N]"` to `objective`.

- Launch one Task sub-agent per shard using the Task tool.
  - `subagent_type`: `cf-fileworker`
  - Provide the shard TaskSpec JSON in the prompt.
  - Require strict JSON-only output.

Concurrency rule:

- When there are multiple inputs, start all FileWorker Task tool calls in a single assistant message (parallel tool use).

### 7) Reduce phase: aggregate

- Collect all FileWorker outputs as JSON objects.
- Launch a Task sub-agent using the Task tool:
  - `subagent_type`: `cf-aggregator`
  - Prompt must include:
    1) the original TaskSpec JSON
    2) a JSON array `fileworker_results` with all FileWorker outputs

### 8) Persist final SubResult

- If `persist.enabled` is not false, write final SubResult JSON to:
  - `<persist_root>/results/<task_id>.json`

- If `--out` is provided:
  - Resolve to absolute path (join with root if relative).
  - Write the same JSON to that path.

### 9) Final output

- Print the final SubResult JSON to stdout (assistant message) and nothing else.

## Output rules (MANDATORY)

- Output **strict JSON only**, conforming to `SubResult.v1`.
- Do not include markdown fences.
- Do not include narrative text before or after the JSON.
- Do not paste large raw inputs into the output.
- Ensure every claim has at least one evidence locator.
