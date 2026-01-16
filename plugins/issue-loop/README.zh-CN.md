[English](README.md) | 简体中文

# issue-loop

一个 Claude Code 插件，用于把一个 issue/任务以“循环迭代”的方式推进到可合并的 PR：

1. 实现最小修复
2. 提交 commit
3. 创建或更新 PR
4. 等待 AI/机器人 review 评论
5. 应用反馈
6. 重复直到可合并

## 安装

```bash
/plugin marketplace add lollipopkit/cc-plugins
/plugin install issue-loop@lk-ccp
```

## 组件

- Skill：`skills/issue-loop/SKILL.md`
- Agent：`agents/issue-loop-runner.md`
- Commands：
  - `/issue-loop`：启动或继续该工作流
  - `/issue-loop-enable`：创建/更新 `.claude/issue-loop.local.md`
- Hook：
  - `hooks/hooks.json`：Stop hook，可通过用户提供的命令模板发送 IM 通知

## 配置

在你的项目根目录创建 `.claude/issue-loop.local.md`。

最小模板：

```markdown
---
enabled: true
base_branch: "main"

# Review behavior
review_mode: "github"   # github|local-agent|custom
max_review_polls: 40
review_poll_seconds: 60

# External non-interactive LLM (optional)
llm_shell: "auto"       # auto|bash|fish
llm_command_template: "" # e.g. llm_script.sh "$ISSUE_LOOP_PROMPT"  OR  ccpxy "$ISSUE_LOOP_PROMPT"

# Notifications (optional)
notify_enabled: false
notify_shell: "auto"            # auto|bash|fish
notify_on_stop: true
notify_command_template: ""      # executed with selected shell; can reference env vars below
---

这里可以写给 issue-loop 的额外说明。
```

### 模板与环境变量

`llm_command_template`：

- 期望执行一个非交互式的 LLM 工具。
- runner 会在执行前导出 `ISSUE_LOOP_PROMPT`。
- 命令应输出一个 Markdown checklist，以便稳定解析。

期望输出格式：

```markdown
## Review Checklist
- [ ] path/to/file.ts:123 - 描述需要做的具体修改
- [ ] path/to/file.ts - 描述修改（行号可选）
- [ ] (general) 非文件级建议（尽量少用）
```

解析脚本：`python3 "$CLAUDE_PLUGIN_ROOT/scripts/parse-review-checklist.py"`（开发时也可用 `python3 issue-loop/scripts/parse-review-checklist.py`）。

示例：

- `llm_script.sh "$ISSUE_LOOP_PROMPT"`
- `ccpxy gpt -- -p "$ISSUE_LOOP_PROMPT"`（如果 `ccpxy` 只在 fish 下可用，设置 `llm_shell: "fish"`）

关于 `ccpxy`：在 fish 配置里，`ccpxy` 会把第一个非 option 参数当作 profile 名（例如 `gpt`/`g3p`/`g3f`/`gc`/`glm`/`c`）。不要把 `llm_command_template` 设成 `ccpxy "$ISSUE_LOOP_PROMPT"`，因为 prompt 会被当成 profile。

关于 `claude` CLI：非交互模式是 `-p/--print`，因此模板通常需要包含 `-p` 并把 prompt 放到最后。

`notify_command_template`：

- 由 Stop hook 脚本 `scripts/issue-loop-notify.sh` 执行。
- hook 会导出：
  - `ISSUE_LOOP_MESSAGE`（短消息）
  - `ISSUE_LOOP_PROJECT_DIR`
  - `ISSUE_LOOP_EVENT_NAME`
  - `ISSUE_LOOP_REASON`
  - `ISSUE_LOOP_TRANSCRIPT_PATH`
  - `ISSUE_LOOP_EVENT_JSON_B64`（base64 编码的 hook 输入 JSON）
