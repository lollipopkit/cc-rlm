---
name: devloop
description: Start or resume the devloop workflow (create branch → fix → commit → PR → wait for AI review → apply comments → repeat).
allowed-tools: ["Read", "Write", "Edit", "Grep", "Glob", "Bash", "AskUserQuestion", "TodoWrite", "Task", "Skill"]
argument-hint: "--issue <github-url|number|feishu/lark-url|text|file> [--base main]"
---

Run the devloop workflow using the plugin components in this plugin. This command drives a task to a merge-ready pull request through repeated cycles.

## Mandatory Workflow

1. **Create Branch**:
   - If on the base branch (e.g. `main`): Create a new descriptive branch based on the issue/task content.
   - If NOT on the base branch: Check if the current branch is already associated with a different PR or issue. Prompt if a mismatch is detected.
2. **Implement Fix**: Research and implement the smallest correct fix.
3. **Validate**: Run the smallest relevant test/build command.
4. **Commit**: Create a clear commit message.
5. **Pull Request**: Open a PR for review.
6. **Wait for Review**: Poll for review comments and PR mergeability status (`MERGEABLE`, `UNKNOWN`, or `CONFLICTING`).
7. **Address Feedback**: Apply changes based on review comments and commit/push again.
8. **Repeat**: Iterate until the PR is approved and `mergeable` is `MERGEABLE`.

## Behavior

1. **Determine the issue source**:

   - If the argument looks like a GitHub URL or issue/PR number, use `gh` to fetch title/body, labels, repo, and existing PR linkage.
   - If the argument looks like a Feishu/Lark Project issue URL or identifier, fetch the issue title/body via Feishu Project OpenAPI (requires local credentials) and use that as the task description.
     - Typical issue URL pattern (seen in the wild): `https://project.feishu.cn/<project_key>/<work_item_type>/detail/<work_item_id>` (e.g. `.../story/detail/123`).
     - Auth (Project OpenAPI): send `X-PLUGIN-TOKEN` (and sometimes `X-USER-KEY`) headers.
       - Get a plugin token (example): `POST {base_url}/open_api/authen/plugin_token` with JSON `{ "plugin_id": "...", "plugin_secret": "..." }`, then use response `data.token` as `X-PLUGIN-TOKEN`.
     - Fetch work item details (example): `POST {base_url}/open_api/{project_key}/work_item/{work_item_type_key}/query` with JSON `{ "work_item_ids": [<work_item_id>] }`.
   - When NO argument is provided, or if starting on a non-base branch, use `gh pr list --head $(git branch --show-current) --json number,url,title,body` to check for an existing PR associated with the current branch.
   - Should NO argument be provided and NO existing PR is found, the agent will prompt for a task description or offer to create a new issue.
   - If the argument looks like a local file path, read it and treat it as the issue/task description.
   - Otherwise, treat it as a free-form text task.
   - For cases where a text task or local file is provided and no GitHub issue exists, the agent will offer to create one to track the work.

2. **Read settings** from `.claude/devloop.local.md` if present. Supported fields in YAML frontmatter:

   - `enabled: true|false`
   - `base_branch: "main"`
   - `review_mode: "github"|"coderabbit"|"local-agent"|"custom"`
   - `max_review_polls: 40`
   - `review_poll_seconds: 60`
   - `wait_behavior: "poll"|"ping_ai"`
   - `ai_reviewer_id: "..."` (e.g., `coderabbitai`)
   - `ping_message_template: "..."`
   - `ping_threshold: 3`
   - `notify_enabled: true|false`
   - `notify_shell: "auto"|"bash"|"fish"`
   - `notify_on_stop: true|false`
   - `notify_command_template: "..."`
   - `workspace_mode: "gws"|"local"` (set to `"gws"` for `git-ws` integration)

3. **Invoke the loop agent** `devloop-runner` to execute the full fix/review cycle.

## Rules & Safety

- **Branch Logic**: Create a new branch based on the issue content ONLY if the current branch is the base branch.
- **Git Protocol**: NEVER use `git push --force`, `git push -f`, or `git commit --amend` on branches that have already been pushed to the remote or have an open PR. Always create new commits and use standard `git push`.
- **Review Polling**: The agent will remain in an autonomous polling loop using `sleep` between polls.
  - GraphQL for filtering comments:

    ```bash
    gh api graphql -F owner='{owner}' -F name='{repo}' -F pr={number} -f query='
      query($name: String!, $owner: String!, $pr: Int!) {
        repository(owner: $owner, name: $name) {
          pullRequest(number: $pr) {
            reviewThreads(first: 100) {
              nodes { isOutdated isResolved comments(last: 20) { nodes { body path line author { login } } } }
            }
          }
        }
      }
    ' --jq '.data.repository.pullRequest.reviewThreads.nodes[] | select(.isOutdated == false and .isResolved == false) | .comments.nodes[]'
    ```

- **Presence & Communication (MANDATORY)**:
  - CRITICAL: DO NOT include "Co-authored-by: Claude" or any variation in commit messages.
  - CRITICAL: DO NOT include "Generated with Claude" or AI signatures in PR descriptions. Specifically, NEVER include "🤖 Generated with [Claude Code](https://claude.com/claude-code)".
  - Maintain a professional, human-like presence in all git and GitHub metadata.
  - If any sub-agent or tool includes these, you MUST remove them before completing the task.
- **Avoid destructive operations**.
- If review comments request changes that look incorrect or out-of-scope, ask the user before proceeding.
- Prefer using `gh` for GitHub workflows when available.
