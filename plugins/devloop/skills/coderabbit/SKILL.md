# coderabbit:review

This is an **external** skill provided by the **CodeRabbit Claude Code plugin** (which wraps the CodeRabbit CLI). The devloop plugin can invoke this skill when `review_mode: "coderabbit"` is selected.

Devloop does **not** implement CodeRabbit review itself.

## When devloop uses this skill

- During the **Wait for review** phase, if `review_mode` is set to `"coderabbit"`.
- Devloop triggers CodeRabbit once at the start of each polling cycle and then:
  - If findings are returned, treats them as review feedback and proceeds to **Apply feedback**.
  - If the skill is unavailable or fails (not installed, not authenticated, errors), devloop falls back to standard GitHub polling.

## Prerequisites

- Install and authenticate CodeRabbit CLI as required by the CodeRabbit plugin.
- Install the CodeRabbit Claude Code plugin so that the `coderabbit:review` skill is available.

## Invocation

In Claude Code, this skill is invoked via the `Skill` tool:

- `coderabbit:review`

## Expected output

The skill returns a structured review summary and findings (severity grouped, suggestions, etc.). Devloop uses the returned findings as actionable feedback.

## Failure modes

- CodeRabbit plugin not installed → `coderabbit:review` not available.
- CodeRabbit CLI not installed/authenticated → review invocation fails.

In these cases, devloop should continue with GitHub polling instead of stopping.
