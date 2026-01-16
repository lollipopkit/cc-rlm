---
name: Issue Loop
description: This skill should be used when the user asks to "run issue-loop", "fix this issue and open a PR", "auto commit and create a PR", "wait for AI code review and apply comments", or "iterate until merge-ready".
version: 0.1.0
---

Run an iterative workflow that takes an issue/task input and drives it to a merge-ready pull request through repeated fix → commit → PR → review → apply feedback cycles.

## Inputs

Accept one of:

- A GitHub issue/PR URL or number (prefer `gh` to fetch title/body, labels, and existing PR linkage).
- A local file path containing the task description.
- A free-form text description.

## Settings and state

Read `.claude/issue-loop.local.md` from the project root when present.

- Parse YAML frontmatter to control behavior.
- Treat markdown body as additional instructions to append to the working prompt.

Recommended frontmatter fields:

- `enabled: true|false`
- `base_branch: "main"`

Review:

- `review_mode: "github"|"local-agent"|"custom"`
- `max_review_polls: 40`
- `review_poll_seconds: 60`

External non-interactive LLM (optional):

- `llm_shell: "auto"|"bash"|"fish"`
- `llm_command_template: "..."` (a user-provided command template)

Notifications (optional):

- `notify_enabled: true|false`
- `notify_shell: "auto"|"bash"|"fish"`
- `notify_on_stop: true|false`
- `notify_command_template: "..."` (a user-provided command template)

## GitHub default workflow (gh)

1. Fetch issue context
   - Use `gh issue view` or `gh pr view` to get title/body and current status.
2. Create branch
   - Create a descriptive branch name.
3. Implement minimal fix
   - Read only necessary files.
   - Avoid refactors not required for the fix.
4. Validate
   - Run the smallest relevant test/build command.
5. Commit
   - Use a clear commit message derived from the issue title.
6. Open PR
   - Use `gh pr create` with a structured body: Summary + Test plan.
7. Wait for AI review
   - Poll `gh pr view` / `gh api` for new comments, review state, and check runs.
8. Apply feedback
   - Address comments in the smallest changeset.
   - If feedback looks wrong or out-of-scope, ask the user.
9. Repeat
   - Commit/push and wait for another review cycle until merge-ready.

## External LLM review (non-interactive)

When `review_mode` is not `github` and `llm_command_template` is configured:

- Build a review prompt and export it as `ISSUE_LOOP_PROMPT`.
- Require the external tool to output a Markdown checklist (see format below).
- Execute `llm_command_template` using `llm_shell`.
  - For `claude` CLI, use `-p/--print` and pass the prompt as the final argument.
  - For `ccpxy`, pass a profile first (e.g. `gpt`), then use `--` to forward `claude` args.
- Parse stdout into actionable items.

Required output format (Markdown checklist):

```markdown
## Review Checklist
- [ ] path/to/file.ts:123 - Describe the exact change to make
- [ ] path/to/file.ts - Describe the change (line optional)
- [ ] (general) Non-file guidance (use sparingly)
```

Parse this format with `scripts/parse-review-checklist.py` (call via `python3 "$CLAUDE_PLUGIN_ROOT/scripts/parse-review-checklist.py"`).

Do not invent command names. Use only commands provided by the user in settings or prompts.

## Custom command integration

When the user provides a custom command such as `xxxcli "do xxx"`, follow the instruction to use that CLI for:

- fetching issue context (Jira/other)
- posting status updates
- sending notifications

Do not invent command names. Use only commands provided by the user in settings or prompts.

## Safety and boundaries

- Avoid destructive operations.
- Avoid guessing URLs.
- Avoid committing secrets; do not commit `.env`, credentials, or tokens.

## Escalation prompts

Ask the user when:

- A review comment requests a change that seems incorrect.
- The change expands scope beyond the original issue.
- The workflow requires credentials or access that is unavailable.
