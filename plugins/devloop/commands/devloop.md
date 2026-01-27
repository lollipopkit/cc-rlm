---
name: devloop
description: 启动或恢复 devloop 工作流（创建分支 → 修复 → 提交 → PR → 等待 AI 审查 → 应用评论 → 重复）。
allowed-tools: ["Read", "Write", "Edit", "Grep", "Glob", "Bash", "AskUserQuestion", "TodoWrite", "Task", "Skill"]
argument-hint: "--issue <github-url|number|feishu/lark-url|text|file> [--base main]"
---

使用本插件中的插件组件运行 devloop 工作流。此命令通过重复循环，将任务推进到可以合并的 pull request。

## 强制工作流

1. **读取设置**：读取 `.claude/devloop.local.md` 以获取项目特定的配置（审查模式、分支等）。
2. **确定问题来源**：从 GitHub issue、URL、飞书项目、本地文件或文本描述中识别任务。
3. **调用循环代理**：启动 `devloop-runner` 以执行完整的 修复/审查 周期。

## 行为

- **初始设置**：如果在基准分支（默认 `main`）上，则创建一个新分支。
- **开发周期**：将实施任务委托给 `devloop-implementer`，将验证任务委托给 `devloop-validator`。
- **审查循环**：
  - **轮询审查**：等待 PR 状态更改和审查评论。
  - **审查策略**：遵循设置中的 `review_mode`。
    - `github`（默认）：使用 `scripts/devloop-pr-review-threads.sh` 轮询评论。
    - `custom`：在每个周期触发特定的技能（例如 `coderabbit:review`）或脚本。
  - **处理反馈**：自动针对新评论实施修复并重新验证。
- **完成**：当 PR 获得批准且 `mergeable` 状态为 `MERGEABLE` 时停止。

## 规则与安全

- **Git 协议**：严禁在共享/远程分支上使用 `git push --force` 或 `git commit --amend`。
- **无 AI 签名**：提交或 PR 中绝对不允许出现 "Co-authored-by: Claude" 或 "Generated with Claude"。
- **自主轮询**：使用 `sleep` 保持在轮询循环中，两轮之间无需请求用户交互。
- **通知**：如果启用，使用 `scripts/devloop-notify.sh` 通过 `hooks.json` 发送更新。
