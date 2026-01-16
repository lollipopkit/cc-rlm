English | [简体中文](README.zh-CN.md)

# RLM - Recursive Language Model Plugin

A Claude Code plugin that implements state-of-the-art recursive reasoning techniques for iterative solution refinement.

## Features

- **Self-Refine**: Generate → Critique → Refine loop (~20% improvement)
- **Reflexion**: Maintain memory buffer across iterations
- **Tree of Thoughts**: Multi-branch exploration with backtracking
- **Self-Consistency**: Sample diverse paths, select consensus
- **Constitutional AI**: Principle-guided self-critique
- **Least-to-Most**: Problem decomposition into subproblems

## Installation

```bash
/plugin marketplace add lollipopkit/cc-plugins
/plugin install rlm@lk-ccp
```

## Usage

### Skills

This plugin provides multiple Skills:

- `rlm`: recursive reasoning workflow (prompt-driven)
- `arena`: multi-model battle runner via OpenAI-compatible endpoints (reads `.env`)
- `rlm-arena`: orchestrates RLM iterations using arena as the generator

### Trigger Phrases

The `rlm` Skill activates automatically when you use phrases like:

- "Use RLM to solve this"
- "Think recursively about..."
- "Refine this iteratively"
- "Deep think mode"
- "Multi-pass reasoning"
- "Self-refine this solution"

The `arena` / `rlm-arena` Skills activate when you ask for "arena", "battle models", "compare models", or "rlm arena".

### Slash Commands

For stable and explicit triggering, use the slash commands:

| Command | Description |
| ------- | ----------- |
| `/rlm:rlm [problem]` | Invoke RLM for iterative multi-pass reasoning |
| `/rlm:arena [task]` | Run multi-model arena battle |
| `/rlm:rlm-arena [task]` | Combine RLM with arena multi-model battles |

### Example

```text
User: Use RLM to design a rate limiter algorithm

Claude: [Applies RLM workflow]
- Phase 1: Decompose problem
- Phase 2: Generate initial solution
- Phase 3: Self-critique against principles
- Phase 4: Explore alternative branches
- Phase 5: Refine and iterate
- Phase 6: Verify consistency
- Final: Synthesized answer with evolution summary
```

## Mode Selection

| Problem Type | Mode | Iterations |
| -------------- | ------ | ------------ |
| Simple bug fix | Light RLM | 2 |
| Algorithm design | Full RLM | 3-4 |
| Architecture decision | Full RLM + ToT | 4-5 |
| Creative/open-ended | Full RLM + Branching | 5+ |
| Mission-critical code | Full RLM + Consistency | 5+ |

## License

MIT
