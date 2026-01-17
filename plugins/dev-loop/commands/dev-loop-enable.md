---
name: dev-loop-enable
description: Quickly enable dev-loop for this repo by creating or updating `.claude/dev-loop.local.md`.
allowed-tools: ["Read", "Write", "Edit", "AskUserQuestion"]
---

Enable dev-loop for the current project.

Steps:

1. Ensure a `.claude/` directory exists in the project root.
2. If `.claude/dev-loop.local.md` exists, update frontmatter keys:
   - `enabled: true`
3. If it does not exist, create it with a minimal template and safe defaults.
4. Ask user for:
   - `review_mode` (default: `github`)
   - `wait_behavior` (poll|ping_ai, default: `poll`)
   - If `wait_behavior` is `ping_ai`:
     - `ai_reviewer_id` (e.g., `coderabbitai`)
     - `ping_message_template` (default: `@{{ai_id}} This PR is awaiting review feedback. Could you provide an update?`)
     - `ping_threshold` (number of wait rounds with no response before pinging, default: 3)
   - `llm_command_template` (optional)
   - `llm_shell` (auto|bash|fish)
   - `notify_enabled` (true/false)
   - If `notify_enabled` is true, ask for the notification method/template:
     - Provide common examples like `ntfy` (e.g., `curl -d "$DEV_LOOP_MESSAGE" ntfy.sh/topic`), `Bark`, or custom scripts.
   - `notify_command_template` (optional)
   - `notify_shell` (auto|bash|fish)
5. Remind that hook config is loaded at session start; restart Claude Code for hook changes to take effect.

Notes:

- `llm_command_template` may reference `$DEV_LOOP_PROMPT`.
- `notify_command_template` may reference `$DEV_LOOP_MESSAGE` and `$DEV_LOOP_EVENT_JSON_B64`.
