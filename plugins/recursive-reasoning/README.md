English | [简体中文](README.zh-CN.md)

# Recursive Reasoning Engine Plugin

A Claude Code plugin that implements state-of-the-art recursive reasoning techniques for iterative solution refinement.

## Features

- **Master/Sub-Agent Architecture**: Formal hierarchy with a Master Planner/Orchestrator and specialized Sub-Agents for execution.
- **Self-Refine**: Generate → Critique → Refine loop orchestrated by the Master.
- **Reflexion**: Maintain memory buffer across delegations.
- **Tree of Thoughts**: Multi-branch exploration with backtracking.
- **Self-Consistency**: Sample diverse paths, select consensus.
- **Multi-Model Collaboration**: Judge/Critique across different LLMs.
- **Least-to-Most**: Problem decomposition into subproblems.

## Installation

```bash
/plugin marketplace add lollipopkit/cc-plugins
/plugin install recursive-reasoning@lk-ccp
```

## Usage

### Skills

This plugin provides multiple Skills:

- `recursive`: recursive reasoning workflow (prompt-driven)
- `multi-model`: multi-model battle runner via OpenAI-compatible endpoints (reads `.env`)
- `recursive-arena`: orchestrates recursive iterations using multi-model battle as the generator

### Trigger Phrases

The `recursive` Skill activates automatically when you use phrases like:

- "Use recursive reasoning to solve this"
- "Think recursively about..."
- "Refine this iteratively"
- "Deep think mode"
- "Multi-pass reasoning"
- "Self-refine this solution"

The `multi-model` / `recursive-arena` Skills activate when you ask for "multi-model battle", "battle models", "compare models", or "recursive arena".

### Slash Commands

For stable and explicit triggering, use the slash commands:

| Command | Description |
| ------- | ----------- |
| `/recursive-reasoning:recursive [problem]` | Invoke recursive reasoning for iterative multi-pass reasoning |
| `/recursive-reasoning:multi-model [task]` | Run multi-model battle |
| `/recursive-reasoning:recursive-arena [task]` | Combine recursive refinement with multi-model battles |

### Example

```text
User: Use recursive reasoning to design a rate limiter algorithm

Claude: [Applies Master/Sub-Agent workflow]
- Phase 1: Decompose problem into sub-tasks (Planning)
- Phase 2: Delegate Task 1 to recursive-executor (Execution)
- Phase 3: Verify sub-agent output (Verification)
- Phase 4: Delegate Task 2 with context...
- Phase 5: Final Synthesis and Verification
- Final: Polished answer with orchestration summary
```

## Mode Selection

| Problem Type | Mode | Iterations |
| -------------- | ------ | ------------ |
| Simple bug fix | Light Recursive | 2 |
| Algorithm design | Full Recursive | 3-4 |
| Architecture decision | Full Recursive + ToT | 4-5 |
| Creative/open-ended | Full Recursive + Branching | 5+ |
| Mission-critical code | Full Recursive + Consistency | 5+ |

## License

MIT
