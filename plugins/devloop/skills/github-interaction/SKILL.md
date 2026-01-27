---
name: github-interaction
description: 关于如何使用 GitHub CLI (gh) 和 GraphQL 交互处理 issue、pull request 和审查评论的指南。
---

# GitHub 交互技能 (Skill)

此技能提供了关于使用 `gh` CLI 和 GitHub 的 GraphQL API 来管理 `devloop` 工作流中的开发生命周期的指南。

## 核心操作

### 1. Issue 与 PR 管理

- **获取 Issue 详情**：`gh issue view <id> --json title,body,labels`
- **获取 PR 状态**：`gh pr view --json number,state,mergeable,reviewDecision,isDraft`
- **列出分支对应的 PR**：`gh pr list --head <branch-name> --json number,url,title,body`
- **创建 PR**：`gh pr create --title "<title>" --body "<body>" --base <base-branch>`

### 2. 获取审查评论 (GraphQL)

标准的 `gh pr view --json reviews` 通常会返回截断或过时的评论。对于 `devloop`，我们使用专门的 GraphQL 查询来获取**活跃（未过时且未解决）**的审查线程。

#### 使用辅助脚本

`devloop` 插件提供了一个脚本来处理分页和过滤：

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/devloop-pr-review-threads.sh" --repo "owner/repo" --pr <number>
```

该脚本输出 JSON Lines (JSONL)，可以逐行解析。

#### 原始 GraphQL 查询模式

如果你需要手动查询，请使用 `gh api graphql` 并配合支持分页的模式：

```graphql
query($name: String!, $owner: String!, $pr: Int!, $cursor: String) {
  repository(owner: $owner, name: $name) {
    pullRequest(number: $pr) {
      reviewThreads(first: 50, after: $cursor) {
        pageInfo {
          hasNextPage
          endCursor
        }
        nodes {
          isOutdated
          isResolved
          comments(last: 1) {
            nodes { body path line author { login } }
          }
        }
      }
    }
  }
}
```

**处理分页**：

- **初始请求**：将 `$cursor` 设置为 `null`。
- **后续请求**：如果 `pageInfo.hasNextPage` 为 `true`，获取 `pageInfo.endCursor` 并将其作为下一次请求中的 `$cursor` 变量传入。
- **批次大小**：建议使用 `first: 50` 以平衡负载大小和请求次数。

## 状态定义

- **可合并性 (Mergeable)**：
  - `MERGEABLE`：准备好合并。
  - `CONFLICTING`：存在合并冲突（需要手动干预）。
  - `UNKNOWN`：GitHub 仍在计算中（再次轮询）。
- **审查决定 (Review Decision)**：
  - `APPROVED`：PR 已获批准。
  - `CHANGES_REQUESTED`：需要修复。
  - `REVIEW_REQUIRED`：仍在等待审查。

## 最佳实践

- **分页**：对于大型 PR，始终处理 `reviewThreads` 和 `comments` 的分页。
- **过滤**：仅处理 `isResolved: false` 且 `isOutdated: false` 的线程，以避免重复工作。
- **草案 (Drafts)**：如果 `isDraft: true`，应继续轮询，但可以抑制提醒/通知。
