---
description: Combine recursive refinement with multi-model battles
argument-hint: [complex task]
allowed-tools: Read, Bash(python:*)
---

# Recursive-Arena Command

Use the **recursive-arena** skill to orchestrate recursive iterations where each iteration uses the multi-model battle as the generator.

## Task

$ARGUMENTS

## Instructions

Run the recursive-arena orchestrator:

```bash
python3 "${CLAUDE_PLUGIN_ROOT}/skills/recursive-arena/scripts/recursive_arena.py" --prompt "$ARGUMENTS" --iters 4 --arena-iters 3
```

Present the results with:

1. Final best answer
2. Evolution summary table (iteration, writer model ID, avg judge score, key refinement)
3. Accumulated insights from the reflection memory

Never disclose provider/model names; only use numeric IDs.
