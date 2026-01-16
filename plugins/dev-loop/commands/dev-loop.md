---
name: dev-loop
description: Start or resume the dev-loop workflow (create branch → fix → commit → PR → wait for AI review → apply comments → repeat).
allowed-tools: ["Read", "Write", "Edit", "Grep", "Glob", "Bash", "AskUserQuestion", "TodoWrite", "Task"]
argument-hint: "--issue <github-url|number|text|file> [--base main]"
---

Run the dev-loop workflow using the plugin components in this plugin.

Behavior:

1. Determine the issue source:
   - If the argument looks like a GitHub URL or issue/PR number, use `gh` to fetch title/body, labels, repo, and existing PR linkage.
   - If the argument looks like a local file path, read it and treat it as the issue/task description.
   - Otherwise, treat it as a free-form text task.
2. Read settings from `.claude/dev-loop.local.md` if present.
3. Invoke the loop agent `dev-loop-runner` to execute the full fix/review cycle.

Rules:

- Branch Logic:
    1. Check if the current branch is the base branch (e.g. `main`).
    2. If NOT the base branch, check if it's already associated with a different PR or issue.
    3. If associated with a DIFFERENT issue/PR, prompt the user to either switch to the base branch or explicitly confirm reusing the current branch.
    4. Create a new branch based on the issue content ONLY if the current branch is the base branch.
- Avoid destructive operations.
- If review comments request changes that look incorrect or out-of-scope, ask the user before proceeding.
- Prefer using `gh` for GitHub workflows when available.
