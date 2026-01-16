---
name: recursive-arena
description: Orchestrates recursive iterations using the multi-model battle as the generator each round. Use when user wants recursive refinement plus model battles, multi-LLM consensus, or says "recursive arena".
allowed-tools: Read, Bash(python:*)
---

# Recursive-Arena Orchestrator

This skill composes two skills:

- `multi-model`: generates candidate answers by rotating models and collecting judge feedback.
- `recursive`: provides the macro-loop structure (decompose → critique → reflect → refine → converge).

## Core behavior

For each recursive iteration:

1. Call the multi-model script to produce the best candidate for the current prompt.
2. Treat the multi-model best answer as the iteration’s `Current Solution`.
3. Use multi-model judge summaries as the primary input to `Self-Critique` and to update `Reflection Memory`.
4. If not converged, refine the prompt (or add constraints) and run the next iteration.

## How to run

This orchestrator uses the multi-model runner bundled in this plugin:

```bash
python3 "${CLAUDE_PLUGIN_ROOT}/skills/recursive-arena/scripts/recursive_arena.py" --prompt "<your task>" --iters 4 --arena-iters 3
```

## Configuration

Multi-model configuration is read from `.env` (same rules as the `multi-model` skill):

- `ARENA_MODELS`, `ARENA_OPENAI_BASE_URL` / provider variants.

Optional orchestration env:

- `RLM_ARENA_ARENA_ITERS` default for multi-model per outer iteration
- `RLM_ARENA_MAX_JUDGES` default judge cap

## Output

- The final answer is the best outer-iteration result.
- Show an evolution summary table with:
  - Iteration number
  - Writer model ID used by arena winner (numeric ID only)
  - Average judge score
  - Key refinement applied

Never disclose provider/model names; only numeric IDs.
Never print secrets from `.env`.
