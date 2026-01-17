---
description: Master orchestrator for iterative multi-pass reasoning using Sub-Agents
argument-hint: [problem or question]
allowed-tools: Read, Task, mcp__seq-think__sequentialthinking
---

# Recursive Command (Master)

Use the **recursive** skill to solve complex problems by orchestrating a team of specialized sub-agents. As the Master agent, you will plan the strategy, delegate tasks, and verify the results.

## Problem

$ARGUMENTS

## Master Orchestration Flow

1. **Decompose**: Break the problem into a sequential execution plan.
2. **Delegate**: Use the `Task` tool to launch `recursive-executor` sub-agents for each step.
3. **Verify**: Critique and verify the output of each sub-agent.
4. **Reflect**: Maintain a reflection memory buffer across delegations.
5. **Synthesize**: Integrate all sub-task results into a final, polished answer.
6. **Confidence**: Stop when confidence reaches 8/10 or diminishing returns occur.
