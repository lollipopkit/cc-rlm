---
name: Dev Loop
description: This skill should be used when the user asks to "run dev-loop", "fix this issue and open a PR", "auto commit and create a PR", "wait for AI code review and apply comments", or "iterate until merge-ready".
version: 1.0.3
---

Run an iterative workflow that takes an issue/task input and drives it to a merge-ready pull request through repeated branch creation → fix → commit → PR → review → apply feedback cycles.

## Mandatory Workflow

1. **Create Branch**:
   - If on the base branch (e.g. `main`): Create a new descriptive branch based on the issue/task content.
   - If NOT on the base branch:
     - Check if the current branch is already associated with a different PR number or issue identifier.
     - If a DIFFERENT association is detected: Prompt the user to either switch to the base branch or explicitly confirm reusing the current branch for the new task.
     - Otherwise: Continue on the current branch.
2. **Implement Fix**: Research and implement the smallest correct fix.
3. **Commit**: Create a clear commit message.
4. **Pull Request**: Open a PR for review.
5. **Wait for Review**: Poll for AI or human review comments.
6. **Address Feedback**: Apply changes based on review comments and commit/push again.
7. **Repeat**: Iterate through cycles of review and feedback until the PR is approved or merged.

## Inputs

Accept one of:

- A GitHub issue/PR URL or number (prefer `gh` to fetch title/body, labels, and existing PR linkage).
- A local file path containing the task description.
- A free-form text description.

If the user provides a free-form description or a local file but NO GitHub issue exists yet, and the goal is a GitHub-based workflow:

- Offer to create a GitHub issue first using `gh issue create --title "<title>" --body "<body>"`.
- Use the newly created issue number for the rest of the workflow.

## Settings and state

Read `.claude/dev-loop.local.md` from the project root when present.

- Parse YAML frontmatter to control behavior.
- Treat markdown body as additional instructions to append to the working prompt.

Recommended frontmatter fields:

- `enabled: true|false`
- `base_branch: "main"`

Review:

- `max_review_polls: 40`
- `review_poll_seconds: 60`
- `wait_behavior: "poll"|"ping_ai"`
- `ai_reviewer_id: "..."` (e.g., `coderabbitai`, required if `wait_behavior` is `ping_ai`)
- `ping_message_template: "..."` (default: `@{{ai_id}} This PR is awaiting review feedback. Could you provide an update?`)
- `ping_threshold: 3` (number of wait rounds before pinging, minimum 1. Placeholder `{{ai_id}}` will be replaced by `ai_reviewer_id`)

Notifications (optional):

- `notify_enabled: true|false`
- `notify_shell: "auto"|"bash"|"fish"`
- `notify_on_stop: true|false`
- `notify_command_template: "..."` (a user-provided command template)

## GitHub default workflow (gh)

1. Fetch/Create issue context
   - Use `gh issue view` or `gh pr view` to get title/body and current status.
   - If NO issue identifier is provided (only free-form text or a local file):
     - Prompt the user to confirm if they want to track this in a new GitHub issue.
     - When confirmed, use `gh issue create --title "<summary>" --body "<description>"` to create it.
   - For non-base branches without an issue, try to find an associated PR using `gh pr list --head $(git branch --show-current) --json number,url,title,body`.
2. Create branch
   - Check if the current branch is the base branch (e.g. `main`).
   - If NOT on the base branch, verify if the current branch is already associated with the target issue/PR.
   - If associated with a DIFFERENT issue/PR, prompt the user to either switch to the base branch or explicitly confirm reusing the current branch.
   - If creating a new branch, generate a descriptive branch name and check it out. Otherwise, use the chosen/confirmed existing branch.
3. Implement minimal fix
   - Read only necessary files.
   - Avoid refactors not required for the fix.
4. Validate
   - Run the smallest relevant test/build command.
5. Commit
   - Use a clear commit message derived from the issue title.
6. Open PR
   - Use `gh pr create` with a structured body: Summary + Test plan.
   - If the issue is from GitHub, include `Closes #<issue-number>` or the issue URL in the PR body to link them.
7. Wait for AI review
   - Poll `gh api graphql` for new comments and review state.
   - Use GraphQL to filter out outdated and resolved comments:

     ```bash
     gh api graphql -F owner='{owner}' -F name='{repo}' -F pr={number} -f query='
       query($name: String!, $owner: String!, $pr: Int!) {
         repository(owner: $owner, name: $name) {
           pullRequest(number: $pr) {
             reviewThreads(first: 100) {
               nodes {
                 isOutdated
                 isResolved
                 comments(last: 20) {
                   nodes {
                     body
                     path
                     line
                     author { login }
                   }
                 }
               }
             }
           }
         }
       }
     ' --jq '.data.repository.pullRequest.reviewThreads.nodes[] | select(.isOutdated == false and .isResolved == false) | .comments.nodes[]'
     ```

   - Polling Strategy (Autonomous):
     - DO NOT wait for user input between polls. Use the `Bash` tool with `sleep <seconds>` to wait autonomously.
     - Initial wait: 5 minutes (`sleep 300`).
     - Increase wait time by 1 minute each round if no new comments are found.
     - Keep track of `wait_rounds_without_response`.
     - If `wait_behavior` is `ping_ai` and `wait_rounds_without_response` reaches `ping_threshold`, post the configured ping message as a PR comment and reset `wait_rounds_without_response = 0` to avoid repeated pings.
     - Stop polling and ask the user for guidance ONLY if the cumulative wait exceeds 30 minutes.
     - If new comments are found, immediately proceed to "Apply feedback" and reset the polling cycle.
8. Apply feedback
   - Address comments in the smallest changeset.
   - If feedback looks wrong or out-of-scope, ask the user.
9. Repeat
   - Commit/push and wait for another review cycle until merge-ready.

## Safety and boundaries

- Avoid destructive operations.
- Avoid guessing URLs.
- Avoid committing secrets; do not commit `.env`, credentials, or tokens.

## Escalation prompts

Ask the user when:

- A review comment requests a change that seems incorrect.
- The change expands scope beyond the original issue.
- The workflow requires credentials or access that is unavailable.
