---
name: cf-spec
description: Generate a TaskSpec.v1 JSON template for the context-firewall workflow.
allowed-tools: ["Read", "Write", "Edit", "Bash", "AskUserQuestion"]
argument-hint: "[--id <task_id>] [--risk low|medium|high] [--objective <text>]"
---

Generate a **TaskSpec.v1** JSON template for the user to edit.

## Arguments

$ARGUMENTS

## Steps

1) Parse arguments:

- `--id <task_id>` (optional)
- `--risk low|medium|high` (optional, default: medium)
- `--objective <text>` (optional)

1) Determine `task_id`:

- If `--id` is provided, use it.
- Otherwise generate one using Bash:
  - `date +%Y%m%d` for the date
  - `uuidgen | tr -d '-' | cut -c1-6` for a short suffix
  - Format: `cf-<YYYYMMDD>-<suffix>`

1) Determine `risk_level`:

- Use `--risk` if provided, else `"medium"`.

1) Determine `objective`:

- If `--objective` is provided, use it.
- Otherwise set a generic placeholder string that the user should replace.

1) Output TaskSpec JSON with:

- `version: "TaskSpec.v1"`
- `output_schema: "SubResult.v1"`
- `map_reduce.enabled: true`
- `critic.enabled: true`
- `constraints` filled with defaults
- Include minimal **schema-valid** placeholders:
  - `inputs`: include a single placeholder input (e.g. `{ "type": "file", "path": "<PATH>" }`).
  - `questions`: include a single placeholder question (e.g. `"<QUESTION>"`).

## Output rules (MANDATORY)

- Output **strict JSON only**.
- Do not use markdown fences.
- Do not include any explanation text before or after the JSON.
