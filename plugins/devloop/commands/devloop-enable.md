---
name: devloop-enable
description: Quickly enable devloop for this repo by creating or updating `.claude/devloop.local.md`.
allowed-tools: ["Read", "Write", "Edit", "AskUserQuestion"]
---

Enable devloop for the current project.

Steps:

1. Ensure a `.claude/` directory exists in the project root.
2. If `.claude/devloop.local.md` exists, update frontmatter keys:
   - `enabled: true`
3. If it does not exist, create it with a minimal template and safe defaults.
4. Ask user for:
   - `review_mode` (github|custom, default: `github`)
     - If `review_mode` is `custom`:
       - `custom_review_skill` (optional; e.g., `coderabbit:review` if you have the CodeRabbit plugin installed)
   - `wait_behavior` (poll|ping_ai, default: `poll`)
   - If `wait_behavior` is `ping_ai`:
     - `ai_reviewer_id` (e.g., a bot account/login to ping)
     - `ping_message_template` (default: `@{{ai_id}} This PR is awaiting review feedback. Could you provide an update?`)
     - `ping_threshold` (number of wait rounds with no response before pinging, default: 3)
   - `notify_enabled` (true/false)
   - If `notify_enabled` is true, ask for the notification method/template:
     - Provide common examples like `ntfy` (e.g., `curl -d "$DEVLOOP_MESSAGE" ntfy.sh/topic`), `Bark`, or custom scripts.
   - `notify_command_template` (optional)
   - `notify_shell` (auto|bash|fish)
5. Remind that hook config is loaded at session start; restart Claude Code for hook changes to take effect.

Notes:

- `notify_command_template` may reference `$DEVLOOP_MESSAGE` and `$DEVLOOP_EVENT_JSON_B64`.
