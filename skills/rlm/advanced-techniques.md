# RLM Advanced Techniques

This document provides detailed methodology for each technique integrated into the RLM skill.

## 1. Self-Refine (Madaan et al., 2023)

**Paper**: [Self-Refine: Iterative Refinement with Self-Feedback](https://arxiv.org/abs/2303.17651)

**Core Insight**: A single LLM can improve its outputs by ~20% through iterative self-feedback without any additional training.

### Three-Role Framework

```text
┌──────────────────────────────────────────────────┐
│                   SELF-REFINE                    │
├──────────────────────────────────────────────────┤
│                                                  │
│   ┌──────────┐    ┌──────────┐    ┌──────────┐  │
│   │GENERATOR │───▶│  CRITIC  │───▶│ REFINER  │  │
│   └──────────┘    └──────────┘    └──────────┘  │
│        │                               │        │
│        │                               │        │
│        └───────────◀───────────────────┘        │
│                  (iterate)                       │
│                                                  │
└──────────────────────────────────────────────────┘
```

### Implementation

**Step 1 - Generate**: Produce initial output
```
Given [task], here is my solution: [output_0]
```

**Step 2 - Critique**: Evaluate the output
```
Reviewing my solution for [task]:
- Strength: [what works]
- Weakness: [specific flaw]
- Missing: [gap in solution]
- Suggestion: [concrete improvement]
```

**Step 3 - Refine**: Apply critique
```
Based on the feedback, here is my improved solution: [output_1]
Changes made:
- [Change 1] addresses [weakness]
- [Change 2] adds [missing element]
```

---

## 2. Reflexion (Shinn et al., 2023)

**Paper**: [Reflexion: Language Agents with Verbal Reinforcement Learning](https://arxiv.org/abs/2303.11366)

**Core Insight**: Agents can learn from linguistic feedback stored in an episodic memory buffer, inducing better decisions in subsequent trials.

### Memory Buffer Architecture

```text
┌─────────────────────────────────────────────────────┐
│               REFLEXION MEMORY BUFFER               │
├─────────────────────────────────────────────────────┤
│                                                     │
│  Trial 1: "Failed because I assumed X. Next time   │
│            verify X before proceeding."            │
│                                                     │
│  Trial 2: "Succeeded but inefficient. The key      │
│            insight was to use approach Y."         │
│                                                     │
│  Trial 3: "Edge case Z caused failure. Add         │
│            explicit handling for Z."               │
│                                                     │
└─────────────────────────────────────────────────────┘
              │
              ▼
    ┌─────────────────┐
    │  NEXT ATTEMPT   │ ← Informed by accumulated memory
    └─────────────────┘
```

### Reflection Format

After each iteration, generate a reflection:

```markdown
### Reflection Entry [N]

**Outcome**: [Success/Partial/Failure]

**What happened**: [Factual description]

**Why it happened**: [Root cause analysis]

**Lesson learned**: [Actionable insight for future]

**Memory update**: [Concise rule to remember]
```

---

## 3. Tree of Thoughts (Yao et al., 2023)

**Paper**: [Tree of Thoughts: Deliberate Problem Solving with Large Language Models](https://arxiv.org/abs/2305.10601)

**Core Insight**: Organize intermediate reasoning steps as a tree, enabling exploration, self-evaluation, and backtracking.

### Tree Search Strategies

**BFS (Breadth-First)**: Explore all branches at current depth before going deeper
- Use when: Multiple promising paths, need comprehensive exploration

**DFS (Depth-First)**: Follow one path deeply, backtrack on failure
- Use when: Clear heuristics exist, deeper reasoning needed

### Implementation Pattern

```markdown
## 🌳 Tree of Thoughts Exploration

### Root: [Problem Statement]

### Level 1 Branches:
┌─ Branch A: [Approach 1]
│  └─ Evaluation: [Score/10], [Rationale]
├─ Branch B: [Approach 2]
│  └─ Evaluation: [Score/10], [Rationale]
└─ Branch C: [Approach 3]
   └─ Evaluation: [Score/10], [Rationale]

### Selected: Branch [X] (highest score)

### Level 2 (expanding Branch X):
┌─ Branch X.1: [Sub-approach 1]
│  └─ Evaluation: [Score/10]
└─ Branch X.2: [Sub-approach 2]
   └─ Evaluation: [Score/10]

### Backtrack Trigger:
If score < 5/10 at any level, backtrack to parent and try sibling.
```

---

## 4. Self-Consistency (Wang et al., 2023)

**Paper**: [Self-Consistency Improves Chain of Thought Reasoning](https://arxiv.org/abs/2203.11171)

**Core Insight**: Sample multiple diverse reasoning paths and select the most consistent answer by marginalization.

### Implementation

```markdown
## ✓ Self-Consistency Check

### Reasoning Path 1 (via [method A]):
[Step-by-step reasoning]
→ Answer: X

### Reasoning Path 2 (via [method B]):
[Step-by-step reasoning]
→ Answer: X

### Reasoning Path 3 (via [method C]):
[Step-by-step reasoning]
→ Answer: Y

### Aggregation:
| Answer | Count | Paths |
|--------|-------|-------|
| X | 2 | A, B |
| Y | 1 | C |

### Final Answer: X (67% consensus)

### Outlier Analysis:
Path C diverged because [specific reason]. This [does/does not] affect confidence.
```

---

## 5. Constitutional AI Principles (Anthropic, 2022)

**Paper**: [Constitutional AI: Harmlessness from AI Feedback](https://arxiv.org/abs/2212.08073)

**Core Insight**: Use explicit principles to guide self-critique and revision.

### Critique Checklist

```markdown
## Constitutional Critique

### Principle Compliance Check:

| Principle | Status | Issue | Severity |
|-----------|--------|-------|----------|
| Correctness | ✓/✗ | [if ✗] | H/M/L |
| Completeness | ✓/✗ | [if ✗] | H/M/L |
| Clarity | ✓/✗ | [if ✗] | H/M/L |
| Efficiency | ✓/✗ | [if ✗] | H/M/L |
| Maintainability | ✓/✗ | [if ✗] | H/M/L |
| Security | ✓/✗ | [if ✗] | H/M/L |
| Edge Cases | ✓/✗ | [if ✗] | H/M/L |

### Required Revisions:
1. [High severity issues first]
2. [Medium severity]
3. [Low severity if time permits]
```

---

## 6. Least-to-Most Prompting (Zhou et al., 2022)

**Paper**: [Least-to-Most Prompting Enables Complex Reasoning](https://arxiv.org/abs/2205.10625)

**Core Insight**: Decompose complex problems into a series of simpler subproblems, solving each in sequence where answers to earlier subproblems facilitate later ones.

### Decomposition Pattern

```markdown
## 📋 Least-to-Most Decomposition

### Original Problem:
[Complex task requiring multiple capabilities]

### Subproblem Chain:

**SP1**: [Simplest foundational subproblem]
- Required for: SP2, SP3
- Solution: [...]

**SP2**: [Intermediate subproblem]
- Requires: SP1
- Required for: SP3
- Solution: [..., using SP1's result]

**SP3**: [Final subproblem = original problem]
- Requires: SP1, SP2
- Solution: [..., synthesizing previous answers]

### Dependency Graph:
SP1 → SP2 → SP3
         ↘ SP3
```

---

## Combining Techniques

### Full RLM Pipeline

```text
┌─────────────────────────────────────────────────────────────┐
│                    FULL RLM PIPELINE                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. DECOMPOSE (Least-to-Most)                              │
│     └─ Break problem into subproblems                       │
│                                                             │
│  2. For each subproblem:                                    │
│     ┌─────────────────────────────────────────────────────┐ │
│     │ a. GENERATE initial solution                        │ │
│     │                                                     │ │
│     │ b. CRITIQUE (Constitutional AI)                     │ │
│     │    └─ Check against principles                      │ │
│     │                                                     │ │
│     │ c. BRANCH if uncertain (Tree of Thoughts)           │ │
│     │    └─ Explore alternatives, select best             │ │
│     │                                                     │ │
│     │ d. REFINE (Self-Refine)                             │ │
│     │    └─ Apply improvements                            │ │
│     │                                                     │ │
│     │ e. REFLECT (Reflexion)                              │ │
│     │    └─ Update memory buffer                          │ │
│     │                                                     │ │
│     │ f. VERIFY (Self-Consistency)                        │ │
│     │    └─ Check multiple paths agree                    │ │
│     │                                                     │ │
│     │ g. Repeat b-f until converged                       │ │
│     └─────────────────────────────────────────────────────┘ │
│                                                             │
│  3. SYNTHESIZE final answer from all subproblems            │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### When to Use Each Technique

| Situation | Primary Technique | Supporting Techniques |
|-----------|-------------------|----------------------|
| Complex multi-step task | Least-to-Most | Self-Refine |
| Uncertain which approach | Tree of Thoughts | Self-Consistency |
| Repeated similar failures | Reflexion | Constitutional AI |
| Need quality assurance | Constitutional AI | Self-Consistency |
| Improving existing solution | Self-Refine | Reflexion |
| High-stakes decision | All techniques | — |
