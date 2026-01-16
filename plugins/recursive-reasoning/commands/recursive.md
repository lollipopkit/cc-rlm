---
description: Invoke recursive-reasoning for iterative multi-pass reasoning
argument-hint: [problem or question]
allowed-tools: Read, Write, Edit, Bash, Grep, Glob, mcp__seq-think__sequentialthinking
---

# Recursive Command

Use the **recursive** skill to solve this problem through iterative refinement using Self-Refine, Reflexion, and Tree of Thoughts techniques.

## Problem

$ARGUMENTS

## Instructions

1. Follow the Recursive execution flow: Decompose → Generate → Critique → Reflect → Refine → Synthesize
2. Maintain a reflection memory buffer across iterations
3. Use the per-iteration output format with confidence metrics
4. Stop when confidence reaches 8/10 or diminishing returns occur
5. Provide the final answer with evolution summary
