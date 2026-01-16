---
description: Run multi-model battle for iterative refinement across LLMs
argument-hint: [task or problem]
allowed-tools: Read, Bash(python:*)
---

# Multi-Model Command

Use the **multi-model** skill to run a multi-model battle where different LLMs compete and judge each other's answers.

## Task

$ARGUMENTS

## Instructions

Run the multi-model script with the given task:

```bash
python3 "${CLAUDE_PLUGIN_ROOT}/skills/multi-model/scripts/multi_model.py" --prompt "$ARGUMENTS" --iters 5
```

Parse the output and present:

1. The winning answer
2. Judge scores summary
3. Model rotation insights (using numeric IDs only, never disclose model names)
