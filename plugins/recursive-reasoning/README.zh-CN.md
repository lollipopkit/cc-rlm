[English](README.md) | 简体中文

# Recursive Reasoning Engine 递归推理引擎插件

一个 Claude Code 插件，用于实现前沿的递归推理/多轮自我改进工作流，帮助对解答进行迭代式精炼。

## 特性

- **Master/Sub-Agent Architecture**：正式的 主/从 代理架构。主代理（Master）负责规划、协调与验证，从代理（Sub-Agent）负责具体任务执行。
- **Self-Refine**：生成 → 批判 → 改进 的循环（由 Master 编排）
- **Reflexion**：在任务委派中维护反思记忆
- **Tree of Thoughts**：多分支探索与回溯
- **Self-Consistency**：采样多条推理路径并选择一致结论
- **Multi-Model Collaboration**：多模型协同评审与批判
- **Least-to-Most**：将复杂问题分解为子问题逐步求解

## 安装

```bash
/plugin marketplace add lollipopkit/cc-plugins
/plugin install recursive-reasoning@lk-ccp
```

## 使用

### Skills

本插件包含多个 Skill：

- `recursive`：递归推理/多轮精炼工作流（prompt 驱动）
- `multi-model`：多模型对战（通过 OpenAI-compatible endpoint，读取 `.env`）
- `recursive-arena`：用 multi-model 作为每轮生成器的递归推理编排器

### 触发短语

当你使用类似短语时会自动触发 `recursive` Skill：

- "Use recursive reasoning to solve this"
- "Think recursively about..."
- "Refine this iteratively"
- "Deep think mode"
- "Multi-pass reasoning"
- "Self-refine this solution"

当你请求 "multi-model battle" / "battle models" / "compare models" / "recursive arena" 时，会触发 `multi-model` / `recursive-arena`。

### Slash Commands

更稳定、显式的触发方式是使用 slash commands：

| 命令 | 说明 |
| ------- | ----------- |
| `/recursive-reasoning:recursive [problem]` | 调用 recursive 执行多轮递归推理与精炼 |
| `/recursive-reasoning:multi-model [task]` | 运行多模型 battle |
| `/recursive-reasoning:recursive-arena [task]` | 结合递归精炼与多模型对战 |

### 示例

```text
User: Use recursive reasoning to design a rate limiter algorithm

Claude: [采用 Master/Sub-Agent 工作流]
- Phase 1: 分解问题为子任务 (规划)
- Phase 2: 委派任务 1 给 recursive-executor (执行)
- Phase 3: 验证从代理输出 (验证)
- Phase 4: 携带上下文委派任务 2...
- Phase 5: 最终综合与验证
- Final: 经过验证的最终答案及编排摘要
```

## 模式选择

| 问题类型 | 模式 | 迭代次数 |
| -------------- | ------ | ------------ |
| 简单 bug 修复 | Light Recursive | 2 |
| 算法设计 | Full Recursive | 3-4 |
| 架构决策 | Full Recursive + ToT | 4-5 |
| 创意/开放式 | Full Recursive + Branching | 5+ |
| 关键任务代码 | Full Recursive + Consistency | 5+ |

## License

MIT
