English | [简体中文](README.zh-CN.md)

# devloop

A Claude Code plugin that drives a task/issue to a merge-ready PR through an iterative loop:

1. **Create Branch**: Always start by creating a new descriptive branch based on the issue/task content.
2. **Implement Fix**: Research and implement the smallest correct fix.
3. **Commit**: Create a clear commit message.
4. **Pull Request**: Open a PR for review.
5. **Wait for Review**: Poll for review comments.
6. **Address Feedback**: Apply changes based on review comments and commit/push again.
7. **Repeat**: Iterate through cycles of review and feedback until the PR is approved or merged.

## Installation

```bash
/plugin marketplace add lollipopkit/cc-plugins
/plugin install devloop@lk-ccp
```

## Components

- Command: `commands/devloop.md` (Workflow definition)
- Agent: `agents/devloop-runner.md`
- Commands:
  - `/devloop` – start or resume the workflow
  - `/devloop-enable` – create/update `.claude/devloop.local.md`
- Hook:
  - `hooks/hooks.json` – Stop hook that can send IM notifications using a user-provided command template

## Configuration

Create `.claude/devloop.local.md` in your project root.

Minimal template:

```markdown
---
enabled: true
base_branch: "main"

# Review behavior
review_mode: "github"   # github|coderabbit|local-agent|custom
max_review_polls: 40
review_poll_seconds: 60

# Wait for review behavior
wait_behavior: "poll"   # poll|ping_ai
ai_reviewer_id: "coderabbitai"
ping_message_template: "@{{ai_id}} This PR is awaiting review feedback. Could you provide an update?"
ping_threshold: 3       # number of wait rounds before pinging (minimum 1)

# Notifications (optional)
notify_enabled: false
notify_shell: "auto"            # auto|bash|fish
notify_on_stop: true
notify_command_template: ""      # executed with selected shell; can reference env vars below
---

Additional instructions for devloop can go here.
```
