---
name: recursive
description: Recursive Reasoning - iteratively refine answers through multiple reasoning passes using Self-Refine, Reflexion, and Tree of Thoughts techniques. Use when asked to "think deeply", "refine iteratively", "use recursive reasoning", or when facing complex problems that benefit from multi-pass reasoning.
allowed-tools: Read, Write, Edit, Bash, Grep, Glob, mcp__seq-think__sequentialthinking
---

# Recursive Reasoning Skill

This skill implements state-of-the-art recursive reasoning techniques from research, including **Self-Refine**, **Reflexion**, and **Tree of Thoughts** principles.

## Theoretical Foundation

Recursive reasoning synthesizes multiple research paradigms:

| Technique | Core Idea | Source |
| ----------- | ----------- | -------- |
| **Self-Refine** | Single LLM acts as generator, critic, and refiner iteratively | Madaan et al. 2023 |
| **Reflexion** | Maintain reflective memory buffer across iterations | Shinn et al. 2023 |
| **Tree of Thoughts** | Explore multiple reasoning branches with backtracking | Yao et al. 2023 |
| **Self-Consistency** | Sample diverse paths, select most consistent answer | Wang et al. 2023 |
| **Constitutional AI** | Principle-guided self-critique and revision | Anthropic 2022 |
| **Least-to-Most** | Decompose complex problems into sequential subproblems | Zhou et al. 2022 |

## Workflow Phases

### Phase 1: Problem Decomposition (Least-to-Most)

Before solving, break complex problems into manageable subproblems:

```markdown
## 📋 Problem Decomposition

**Original Problem**: [Complex task]

**Subproblems** (solve in order):
1. [Foundational subproblem] → enables 2, 3
2. [Intermediate subproblem] → enables 3
3. [Final subproblem] → produces solution

**Dependencies**: 1 → 2 → 3
```

### Phase 2: Iterative Refinement Loop (Self-Refine)

For each iteration, act as three roles:

1. **Generator**: Produce current best solution
2. **Critic**: Evaluate against success criteria
3. **Refiner**: Apply targeted improvements

### Phase 3: Reflection Memory (Reflexion)

Maintain a **memory buffer** of insights across iterations:

```markdown
## 🧠 Reflection Memory

| Iteration | Key Insight | Action Taken |
|-----------|-------------|--------------|
| 1 | Missed edge case X | Added validation |
| 2 | Algorithm inefficient | Switched to O(n) |
| 3 | API misused | Checked documentation |
```

This memory prevents repeating mistakes and compounds learning.

### Phase 4: Branching Exploration (Tree of Thoughts)

When facing uncertainty, explore multiple paths:

```markdown
## 🌳 Reasoning Branches

**Decision Point**: [What approach to take?]

### Branch A: [Approach 1]
- Pros: ...
- Cons: ...
- Confidence: X/10

### Branch B: [Approach 2]
- Pros: ...
- Cons: ...
- Confidence: X/10

**Selected**: Branch [A/B] because [reasoning]
**Backtrack if**: [conditions that would trigger reconsideration]
```

### Phase 5: Self-Consistency Check

Before finalizing, verify consistency across reasoning paths:

```markdown
## ✓ Consistency Verification

**Multiple Reasoning Paths**:
1. Path via [method A] → Result: X
2. Path via [method B] → Result: X
3. Path via [method C] → Result: Y (outlier)

**Consensus**: X (2/3 paths agree)
**Outlier Analysis**: Path C failed because [reason]
```

## Output Format

### Per-Iteration Structure

```markdown
## 🔄 Iteration [N]

### 💡 Current Solution
[Your current best answer]

### 🔍 Self-Critique (Constitutional Principles)
- [ ] **Correctness**: Is it factually accurate?
- [ ] **Completeness**: Are all requirements addressed?
- [ ] **Clarity**: Is it easy to understand?
- [ ] **Efficiency**: Is it optimal?
- [ ] **Safety**: Are there security/edge case issues?

**Identified Issues**:
1. [Issue 1]: [Severity: High/Medium/Low]
2. [Issue 2]: [Severity: High/Medium/Low]

### 📝 Reflection (→ Memory Buffer)
> [Key insight from this iteration to remember]

### 🔧 Refinement Plan
| Priority | Improvement | Expected Impact |
|----------|-------------|-----------------|
| 1 | [Change 1] | [Impact] |
| 2 | [Change 2] | [Impact] |

### 📊 Metrics
- **Confidence**: [1-10]
- **Completeness**: [%]
- **Quality Delta**: [+X% from previous]

---
```

### Final Output Structure

```markdown
## ✅ Final Answer

[Refined solution]

### 📈 Evolution Summary

| Iter | Technique Used | Key Change | Confidence |
|------|----------------|------------|------------|
| 1 | Generate | Initial attempt | 4/10 |
| 2 | Self-Refine | Fixed [issue] | 6/10 |
| 3 | ToT Branch | Explored alt. | 7/10 |
| 4 | Consistency | Verified paths | 9/10 |

### 🧠 Accumulated Insights
[Key learnings from reflection memory]

### ⚠️ Remaining Considerations
[Any caveats, edge cases, or future improvements]
```

## Stopping Criteria

Stop iterating when ANY of these are met:

1. **Confidence threshold**: ≥ 8/10
2. **Diminishing returns**: Quality delta < 5% for 2 consecutive iterations
3. **Consistency achieved**: Multiple reasoning paths converge
4. **Max iterations**: Reached limit (default: 5)
5. **Perfect score**: All constitutional principles satisfied

## Mode Selection Guide

| Problem Type | Recommended Mode | Iterations |
| -------------- | ------------------ | ------------ |
| Simple bug fix | Light Recursive | 2 |
| Algorithm design | Full Recursive | 3-4 |
| Architecture decision | Full Recursive + ToT | 4-5 |
| Creative/open-ended | Full Recursive + Branching | 5+ |
| Mission-critical code | Full Recursive + Consistency | 5+ |

## Trigger Phrases

- "Use recursive reasoning to solve this"
- "Think recursively about..."
- "Refine this iteratively"
- "Deep think mode"
- "Multi-pass reasoning"
- "Self-refine this solution"
- "Explore multiple approaches"

## Integration with Sequential Thinking

For maximum depth, combine Recursive Reasoning with `mcp__seq-think__sequentialthinking`:

- **Sequential Thinking**: Micro-level step-by-step reasoning within each phase
- **Recursive Reasoning**: Macro-level iterative refinement across phases

```text
Recursive Iteration 1
  └── Sequential Thinking (steps 1-5)
Recursive Iteration 2
  └── Sequential Thinking (steps 1-7)
...
```
