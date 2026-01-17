---
name: recursive
description: Master Recursive Reasoning - orchestrate complex problem solving by decomposing tasks and delegating to specialized sub-agents. Use when facing multi-step problems that benefit from planning, execution, and verification.
allowed-tools: Read, Task, mcp__seq-think__sequentialthinking
---

# Master Recursive Reasoning Skill

This skill implements a Master/Sub-Agent architecture for recursive reasoning. The Master acts as the "Brain" (Planner/Coordinator/Verifier), while Sub-Agents act as the "Hands" (Executors).

## Master Orchestrator Role

As the Master, you primarily focus on high-level orchestration. You:
1. **Plan**: Decompose the problem into logical, sequential steps.
2. **Delegate**: Use the `Task` tool to launch `recursive-executor` agents for each step.
3. **Verify**: Review the output of each sub-agent against the requirements.
4. **Refine**: If a sub-agent's output is insufficient, re-delegate with specific feedback.
5. **Synthesize**: Combine all verified components into a final solution.

## Theoretical Foundation

The Master utilizes these techniques for orchestration:
- **Least-to-Most**: Decomposing complex problems into sequential subproblems.
- **Reflexion**: Maintaining a reflective memory buffer to guide sub-agents.
- **Self-Refine**: Iteratively critiquing sub-agent outputs until they meet quality standards.
- **Tree of Thoughts**: Exploring different delegation strategies when one fails.

## Workflow Phases

### Phase 1: Problem Decomposition (Least-to-Most)

Before any execution, break the problem into manageable subproblems:

```markdown
## 📋 Master Execution Plan

**Original Problem**: [Complex task]

**Execution Steps**:
1. [Foundational task] → Delegate to recursive-executor
2. [Intermediate task] → Delegate to recursive-executor
3. [Final task] → Delegate to recursive-executor

**Dependencies**: 1 → 2 → 3
```

### Phase 2: Delegation Loop (Master -> Sub-Agent)

For each step in your plan:
1. Call the `Task` tool with `agent: "recursive-executor"`.
2. Provide the sub-task description and any necessary context from previous steps.
3. Wait for the sub-agent to report completion.

### Phase 3: Verification & Critique (Self-Refine)

When a sub-agent returns:
1. **Evaluate**: Check if the result is correct, complete, and optimal.
2. **Critique**: Identify specific issues or missing details.
3. **Re-delegate**: If issues are found, send a new `Task` to the sub-agent with the critique and request refinement.

### Phase 4: Reflection Memory (Reflexion)

Maintain a memory of sub-agent performance and task outcomes:

```markdown
## 🧠 Master Reflection Memory

| Step | Sub-Agent Result | Master Insight | Action |
|------|------------------|----------------|--------|
| 1 | Success | Path X is correct | Proceed to 2 |
| 2 | Failed initially | Tool Y was missing | Retried with Y |
```

### Phase 5: Synthesis

Integrate the results from all sub-tasks into a final coherent answer for the user.

## Output Format

### Per-Delegation Structure

```markdown
## 🔄 Delegation [N]

### 📥 Sub-Task
[Description of what was delegated]

### 📤 Sub-Agent Report
[Summary of the sub-agent's output]

### 🔍 Master Verification
- [ ] **Correctness**: [OK/Fail]
- [ ] **Completeness**: [OK/Fail]
- [ ] **Quality**: [1-10]

**Master Decision**: [Proceed / Re-delegate with critique]
```

### Final Output Structure

```markdown
## ✅ Final Verified Solution

[The integrated final answer]

### 📈 Orchestration Summary

| Step | Agent | Status | Refinements |
|------|-------|--------|-------------|
| 1 | recursive-executor | Completed | 0 |
| 2 | recursive-executor | Completed | 1 |

### 🧠 Accumulated Insights
[Key learnings from the orchestration process]
```

## Stopping Criteria

1. **Plan Completed**: All steps in the Master plan are executed and verified.
2. **Confidence**: Overall solution confidence ≥ 8/10.
3. **Diminishing Returns**: Sub-agent refinements no longer yield significant quality gains.

## Integration with Sequential Thinking

Use `mcp__seq-think__sequentialthinking` internally to build your plans and analyze sub-agent reports before making decisions.
