---
name: dev-loop
description: Start or resume the dev-loop workflow (create branch → fix → commit → PR → wait for AI review → apply comments → repeat).
allowed-tools: ["Read", "Write", "Edit", "Grep", "Glob", "Bash", "AskUserQuestion", "TodoWrite", "Task"]
argument-hint: "--issue <github-url|number|text|file> [--base main]"
---

Run the dev-loop workflow using the plugin components in this plugin. This command drives a task to a merge-ready pull request through repeated cycles.

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
   - If NO argument is provided, or if starting on a non-base branch, use `gh pr list --head $(git branch --show-current) --json number,url,title,body` to check for an existing PR associated with the current branch.
   - If NO argument is provided and NO existing PR is found, the agent will prompt for a task description or offer to create a new issue.
2. **Read settings** from `.claude/dev-loop.local.md` if present. Supported fields in YAML frontmatter:
   - `enabled: true|false`
   - `base_branch: "main"`
   - `wait_behavior: "poll"|"ping_ai"`
   - `ai_reviewer_id: "..."` (e.g., `coderabbitai`)
   - `ping_threshold: 3`
   - `notify_enabled: true|false`
3. **Invoke the loop agent** `dev-loop-runner` to execute the full fix/review cycle.

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

- **Avoid destructive operations**.
- If review comments request changes that look incorrect or out-of-scope, ask the user before proceeding.
- Prefer using `gh` for GitHub workflows when available.
