[English](README.md) | 简体中文

# dev-loop

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
/plugin install dev-loop@lk-ccp
```

## 组件

- Skill：`skills/dev-loop/SKILL.md`
- Agent：`agents/dev-loop-runner.md`
- Commands：
  - `/dev-loop`：启动或继续该工作流
  - `/dev-loop-enable`：创建/更新 `.claude/dev-loop.local.md`
- Hook：
  - `hooks/hooks.json`：Stop hook，可通过用户提供的命令模板发送 IM 通知

## 配置

在你的项目根目录创建 `.claude/dev-loop.local.md`。

最小模板：

```markdown
---
enabled: true
base_branch: "main"

# Review behavior
review_mode: "github"   # github|local-agent|custom
max_review_polls: 40
review_poll_seconds: 60

# Wait for review behavior
wait_behavior: "poll"   # poll|ping_ai
ai_reviewer_id: "coderabbitai"
ping_message_template: "@{{ai_id}} This PR is awaiting review feedback. Could you provide an update?"
ping_threshold: 3       # number of wait rounds before pinging (minimum 1)

# External non-interactive LLM (optional)
# This allows using a custom LLM script/command to generate fixes instead of using the agent's built-in reasoning.
# The template can reference $DEV_LOOP_PROMPT.
llm_shell: "auto"       # auto|bash|fish
llm_command_template: "" # e.g. llm_script.sh "$DEV_LOOP_PROMPT"  OR  ccpxy "$DEV_LOOP_PROMPT"

# Notifications (optional)
notify_enabled: false
notify_shell: "auto"            # auto|bash|fish
notify_on_stop: true
notify_command_template: ""      # executed with selected shell; can reference env vars below
---

这里可以写给 dev-loop 的额外说明。
```
