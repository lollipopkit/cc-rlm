---
name: devloop-enable
description: 通过创建或更新 `.claude/devloop.local.md` 快速为该仓库启用 devloop。
allowed-tools: ["Read", "Write", "Edit", "AskUserQuestion"]
---

为当前项目启用 devloop。

步骤：

1. 确保项目根目录存在 `.claude/` 目录。
2. 如果 `.claude/devloop.local.md` 已存在，更新前置内容 (frontmatter) 中的键。
3. 如果不存在，使用综合模板创建它。

## 推荐模板结构

在创建或更新 `.claude/devloop.local.md` 时，推荐使用以下结构：

```markdown
---
enabled: true
base_branch: "main"

# 审查策略
# "github": 使用 scripts/devloop-pr-review-threads.sh 轮询 GitHub 审查评论
# "custom": 在每个周期触发特定的技能（例如 coderabbit:review）
review_mode: "github"
custom_review_skill: "" # 仅在 review_mode 为 "custom" 时使用

# 轮询与等待行为
max_review_polls: 40
review_poll_seconds: 60
wait_behavior: "poll" # "poll" 或 "ping_ai"
ai_reviewer_id: "" # 例如 "coderabbitai[bot]"
ping_threshold: 3 # 提醒前的等待轮数
ping_message_template: "@{{ai_id}} 此 PR 正在等待审查反馈。您可以提供更新吗？"

# 通知
notify_enabled: false
notify_shell: "auto" # "auto"、"bash" 或 "fish"
notify_on_stop: true
notify_command_template: "curl -d \"$DEVLOOP_MESSAGE\" ntfy.sh/your-topic" # ntfy 模板示例

# 环境
workspace_mode: "local" # "local" 或 "gws" (用于 git-ws 隔离工作区)
---

# Devloop 项目指南

- 在此处添加项目特定的开发规则。
- 定义首选的测试命令（例如 "更改后运行 `npm test`"）。
- 指定代码风格或架构限制。
```

1. 询问用户关键字段的值（`review_mode`、`wait_behavior`、`notify_enabled` 等）以自定义模板。
2. 提醒钩子 (hook) 配置在会话开始时加载；需要重启 Claude Code 才能使钩子更改生效。
