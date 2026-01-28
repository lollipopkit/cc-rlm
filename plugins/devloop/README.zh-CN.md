[English](README.md) | 简体中文

# devloop

一个 Claude Code 插件，用于把一个 issue/任务以“循环迭代”的方式推进到可合并的 PR：

1. **创建分支**：始终根据 issue/任务内容创建一个新的描述性分支。
2. **实现修复**：研究并实现最小正确修复。
3. **提交 commit**：创建清晰的提交消息。
4. **Pull Request**：打开 PR 进行审查。
5. **等待审查**：轮询 review 评论。
6. **应用反馈**：根据 review 评论应用更改，并再次提交/推送。
7. **重复**：迭代执行 review 和反馈循环，直到 PR 被批准或合并。

## 安装

```bash
/plugin marketplace add lollipopkit/cc-plugins
/plugin install devloop@lk-ccp
```

## 组件

- Command：`commands/devloop.md` (工作流定义)
- Agent：`agents/devloop-runner.md`
- Commands：
  - `/devloop`：启动或继续该工作流
  - `/devloop-enable`：创建/更新 `.claude/devloop.local.md`
- Hook：
  - `hooks/hooks.json`：Stop hook，可通过用户提供的命令模板发送 IM 通知

## 配置

在你的项目根目录创建 `.claude/devloop.local.md`。

最小模板：

```markdown
---
enabled: true
base_branch: "main"

# 审查行为
max_review_polls: 40
review_poll_seconds: 60

# 等待审查行为
wait_behavior: "poll"   # poll|ping_ai
ping_message_template: "@{{ai_id}} This PR is awaiting review feedback. Could you provide an update?"
ping_threshold: 3       # ping 前的等待轮数（最少 1）

# 通知 (可选)
notify_enabled: false
notify_shell: "auto"            # auto|bash|fish
notify_on_stop: true
notify_command_template: ""      # 使用所选 shell 执行
---

由 <https://github.com/lollipopkit/cc-plugins> 生成
```
