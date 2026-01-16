[English](README.md) | 简体中文

# RLM - Recursive Language Model 插件

一个 Claude Code 插件，用于实现前沿的递归推理/多轮自我改进工作流，帮助对解答进行迭代式精炼。

## 特性

- **Self-Refine**：生成 → 批判 → 改进 的循环（~20% 提升）
- **Reflexion**：在多轮迭代中维护反思记忆
- **Tree of Thoughts**：多分支探索与回溯
- **Self-Consistency**：采样多条推理路径并选择一致结论
- **Constitutional AI**：基于原则的自我审查与修订
- **Least-to-Most**：将复杂问题分解为子问题逐步求解

## 安装

```bash
/plugin marketplace add lollipopkit/cc-plugins
/plugin install rlm@lk-ccp
```

## 使用

### Skills

本插件包含多个 Skill：

- `rlm`：递归推理/多轮精炼工作流（prompt 驱动）
- `arena`：多模型对战（通过 OpenAI-compatible endpoint，读取 `.env`）
- `rlm-arena`：用 arena 作为每轮生成器的 RLM 编排器

### 触发短语

当你使用类似短语时会自动触发 `rlm` Skill：

- "Use RLM to solve this"
- "Think recursively about..."
- "Refine this iteratively"
- "Deep think mode"
- "Multi-pass reasoning"
- "Self-refine this solution"

当你请求 "arena" / "battle models" / "compare models" / "rlm arena" 时，会触发 `arena` / `rlm-arena`。

### Slash Commands

更稳定、显式的触发方式是使用 slash commands：

| 命令 | 说明 |
| ------- | ----------- |
| `/rlm:rlm [problem]` | 调用 RLM 执行多轮递归推理与精炼 |
| `/rlm:arena [task]` | 运行多模型 arena battle |
| `/rlm:rlm-arena [task]` | 结合 RLM 与 arena 多模型对战 |

### 示例

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

## 模式选择

| 问题类型 | 模式 | 迭代次数 |
| -------------- | ------ | ------------ |
| 简单 bug 修复 | Light RLM | 2 |
| 算法设计 | Full RLM | 3-4 |
| 架构决策 | Full RLM + ToT | 4-5 |
| 创意/开放式 | Full RLM + Branching | 5+ |
| 关键任务代码 | Full RLM + Consistency | 5+ |

## License

MIT
