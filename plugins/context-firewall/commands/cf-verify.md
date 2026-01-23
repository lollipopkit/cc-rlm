---
name: cf-verify
description: Verify SubResult.v1 by sampling evidence locators and re-reading only referenced snippets.
allowed-tools: ["Read", "Write", "Edit", "Bash", "Grep", "WebFetch", "WebSearch", "AskUserQuestion"]
argument-hint: "--result <file|json> [--risk low|medium|high] [--out <path>]"
---

Verify a context-firewall SubResult.v1.

## Arguments

$ARGUMENTS

Expected:

- `--result <file|json>` (required)
- `--risk low|medium|high` (optional, default: medium)
- `--out <path>` (optional)

## Steps

### 1) Resolve project root

- Run `pwd` via Bash and treat it as the project root directory.

### 2) Load SubResult JSON (`--result`)

- Extract the `--result` value from `$ARGUMENTS`.
- If the `--result` value begins with `{`, treat it as inline JSON.
- Otherwise treat it as a file path:
  - If it is not absolute, resolve to an absolute path by joining with the project root.
  - Read the file content via Read.

### 3) Parse SubResult.v1 JSON

- Parse the content as JSON.
- If invalid JSON or missing required fields, output a **VerifyReport.v1** with:
  - `task_id: "unknown"`
  - `status: "failed"`
  - `checked/passed/failed` consistent with 0 checks
  - `recommendation` telling the user to provide a valid SubResult.v1

### 4) Determine sampling rate

- Use `--risk` if provided; otherwise default to `medium`.
- Sampling rates:
  - high: 0.30
  - medium: 0.15
  - low: 0.05

### 5) Select claims to verify (deterministic)

- Flatten claims into a list in stable order:
  - Iterate answers in order.
  - Iterate claims in order.
- For each claim, derive a stable `claim_id`:
  - If `claim.claim_id` exists and is non-empty, use it.
  - Else use `answers[<answer_index>].claims[<claim_index>]`.

- Determine N = ceil(total_claims * sample_rate).
  - If `total_claims > 0`, ensure `N >= 1`.
  - If `total_claims == 0`, set `N = 0`.

- Select the first N claims from the flattened list.

### 6) Verify each sampled claim

For each selected claim, attempt to verify **at least one** evidence item.

General rules:

- Prefer verifying the first evidence item with a `line_range` locator.
- Treat a claim as **passed** if any evidence item can be verified and is consistent.
- Treat a claim as **failed** if:
  - a verifiable locator is provided but the snippet contradicts the claim, or
  - a quoted substring is provided but is not found in the referenced snippet.
- Treat a claim as **partial (unverifiable)** if all evidence locators are of types not supported in v1 verification.

#### Locator handling

A) `line_range`

- Resolve locator `path`:
  - If absolute, use it.
  - If relative, join with project root.
- Read exactly the referenced lines:
  - Use Read with `offset = start` and `limit = end-start+1`.
- If `evidence.quote` is present:
  - Confirm the quote text appears within the read snippet.
- Decide pass/fail:
  - Pass if the snippet is consistent with the claim (and quote matches when provided).
  - Fail if quote is missing from snippet or snippet clearly contradicts.

B) `symbol_range`

- Resolve locator `path` as above.
- Use Grep to search the `symbol` within the file.
  - If multiple matches, use the first match.
- Read a small window around the best match:
  - Example: 60 lines starting at (match_line - 10), clamped to >= 1.
- Pass/fail based on whether the snippet supports the claim.

C) `tool_call`

`rerun_hint` contract (recommended):

- Use a typed object (see `schemas/sub-result.v1.schema.json`):
  - `{ "type": "web_fetch", "url": "...", "prompt": "..." }`
  - `{ "type": "web_search", "query": "...", "allowed_domains": [...], "blocked_domains": [...] }`
  - `{ "type": "unknown", "note": "..." }`

Verification rules:

- If `rerun_hint` is present and schema-shaped:
  - `rerun_hint.type == "web_fetch"`:
    - Run WebFetch with:
      - `url: rerun_hint.url`
      - `prompt: rerun_hint.prompt`
    - Confirm the rerun result is broadly consistent with the claim.

  - `rerun_hint.type == "web_search"`:
    - Run WebSearch with:
      - `query: rerun_hint.query`
      - `allowed_domains: rerun_hint.allowed_domains` (if present)
      - `blocked_domains: rerun_hint.blocked_domains` (if present)
    - Confirm the rerun result is broadly consistent with the claim.

  - `rerun_hint.type == "unknown"`:
    - Do not rerun.
    - Mark as partial verification for that evidence.

- If `rerun_hint` is absent or not schema-shaped:
  - Mark claim as partial verification for that evidence.

D) `byte_range` / `json_path` / `stack_signature`

- Not verifiable in v1.
- Mark as partial verification and recommend using `line_range` or `symbol_range` evidence.

### 7) Produce VerifyReport.v1

- `checked`: number of sampled claims (N)
- `passed`: number of sampled claims that passed
- `failed`: number of sampled claims that failed

Status rules:

- `ok` if `failed == 0` and `checked > 0` and all checked claims passed.
- `failed` if `failed > 0`.
- `partial` otherwise (e.g., no claims, or unverifiable locators only). This includes cases where `checked > 0` but `passed == 0` and `failed == 0` because all sampled claims were unverifiable.

Include `failures[]` items for each failed claim:

- `claim_id`
- `reason`
- `evidence` (include the locator that was checked)

Set `recommendation`:

- For failed: suggest rerun `/cf-run` with stronger evidence requirements or run `cf-critic`.
- For partial: suggest using more `line_range`/`symbol_range` locators.

### 8) Persist report

- Determine persistence root:
  - Default: `<root>/.claude/context-firewall/`
  - If `<root>/.claude/context-firewall.local.md` exists and has `persist.dir`, use that path (resolve relative to `<root>`).
  - If settings has `persist.enabled: false`, skip persistence.

- If persistence is enabled:
  - Ensure directory exists: `<persist_root>/verify/` (create via Bash if missing).
  - Write VerifyReport JSON to `<persist_root>/verify/<task_id>.json`.

- If `--out` is provided, resolve to absolute (join with root if relative) and write there too.

## Output rules (MANDATORY)

- Output **strict JSON only**, conforming to `VerifyReport.v1`.
- Do not include markdown fences.
- Do not include narrative text before or after the JSON.
