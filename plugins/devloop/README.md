[English](README.md) | [简体中文](README.zh-CN.md)

# devloop

一个 Claude Code 插件，通过迭代循环将任务/issue 推进到可合并的 PR：

1. **创建分支**：始终根据 issue/任务内容创建一个新的描述性分支。
2. **实施修复**：研究并实施正确的修复或实现。
3. **提交**：创建一个清晰的提交消息。
4. **Pull Request**：打开一个 PR 以供审查。
5. **等待审查**：轮询审查评论。
6. **处理反馈**：根据审查评论应用更改并再次提交/推送。
7. **重复**：迭代执行审查和反馈循环，直到 PR 获批或合并。

## 安装

```bash
/plugin marketplace add lollipopkit/cc-plugins
/plugin install devloop@lk-ccp
```

## 组件

- Command: `commands/devloop.md` (工作流定义)
- Agent: `agents/devloop-runner.md`
- Commands:
  - `/devloop` – 启动或恢复该工作流
  - `/devloop-enable` – 创建/更新 `.claude/devloop.local.md`
- Hook:
  - `hooks/hooks.json` – Stop 钩子，可使用用户提供的命令模板发送 IM 通知

## 配置

在你的项目根目录创建 `.claude/devloop.local.md`。

最小模板：

```markdown
---
enabled: true
base_branch: "main"

# 审查行为
review_mode: "github"   # github|custom
custom_review_skill: ""  # 可选；例如 "coderabbit:review"
max_review_polls: 40
review_poll_seconds: 60

# 等待审查行为
wait_behavior: "poll"   # poll|ping_ai
ai_reviewer_id: ""
ping_message_template: "@{{ai_id}} 此 PR 正在等待审查反馈。您可以提供更新吗？"
ping_threshold: 3       # 提醒前的等待轮数 (最小为 1)

# 通知 (可选)
notify_enabled: false
notify_shell: "auto"            # auto|bash|fish
notify_on_stop: true
notify_command_template: ""      # 在选定的 shell 中执行；可以引用下方的环境变量
---

由 <https://github.com/lollipopkit/cc-plugins> 生成
```
