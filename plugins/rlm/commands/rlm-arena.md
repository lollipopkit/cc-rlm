---
description: Combine RLM recursive refinement with arena multi-model battles
argument-hint: [complex task]
allowed-tools: Read, Bash(python:*)
---

# RLM-Arena Command

Use the **rlm-arena** skill to orchestrate RLM iterations where each iteration uses the arena multi-model battle as the generator.

## Task

$ARGUMENTS

## Instructions

Run the rlm-arena orchestrator:

```bash
python "${CLAUDE_PLUGIN_ROOT}/skills/rlm-arena/scripts/rlm_arena.py" --prompt "$ARGUMENTS" --iters 4 --arena-iters 3
```

Present the results with:

1. Final best answer
2. Evolution summary table (iteration, writer model ID, avg judge score, key refinement)
3. Accumulated insights from the RLM reflection memory

Never disclose provider/model names; only use numeric IDs.
