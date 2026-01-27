---
name: feishu-lark-interaction
description: 关于如何使用飞书项目 (Feishu Project) OpenAPI 获取并管理 issue 详情的指南。
---

# 飞书/Lark 交互技能 (Skill)

此技能提供了关于通过 OpenAPI 与飞书项目 (Feishu/Lark Project) 管理工具进行交互的指南。

## 身份验证

飞书项目 OpenAPI 的大多数请求需要两个自定义请求头：

- `X-PLUGIN-TOKEN`：通过插件身份验证流程获取。
- `X-USER-KEY`：（可选）用于受权限限制操作的用户特定密钥。

### 获取插件令牌 (Plugin Token)

```http
POST {base_url}/open_api/authen/plugin_token
Content-Type: application/json

{
  "plugin_id": "YOUR_PLUGIN_ID",
  "plugin_secret": "YOUR_PLUGIN_SECRET"
}
```

响应中的 `data.token` 应作为 `X-PLUGIN-TOKEN` 请求头使用。

## 错误处理

### 1. 常见状态码

- **401 Unauthorized**：`X-PLUGIN-TOKEN` 失效或过期。
  - **处理策略**：自动重新执行 [获取插件令牌](#获取插件令牌-plugin-token) 流程，更新 `X-PLUGIN-TOKEN` 后重试请求。
- **429 Too Many Requests**：触发频率限制。
  - **处理策略**：遵循 `Retry-After` 响应头建议的时间。若无，则采用指数退避（Exponential Backoff）配合随机抖动（Jitter）进行重试。
- **5xx Server Error**：服务端异常。
  - **处理策略**：自动重试并配合退避机制，若多次失败（如超过 3 次）则记录错误并切换至故障恢复模式。

### 2. 令牌管理与刷新

`data.token` 应被视为短期令牌。实现时应遵循：

- **按需获取**：在发起请求前或收到 401 响应时，自动调用 `POST /open_api/authen/plugin_token` 进行续期。
- **持久化**：令牌应在单次任务生命周期内缓存，避免频繁调用认证接口。

### 3. 网络故障处理

对于暂时性的网络波动：

- **退避机制**：实施指数退避算法（如 1s, 2s, 4s...），增加随机抖动以防止请求洪峰。
- **最大重试**：建议最大重试次数为 3-5 次，超过后应通过日志记录并中止当前操作，避免资源浪费。

## 核心操作

### 1. 获取 Issue 详情

要获取工作项（故事、缺陷、任务）的标题和描述：

```http
POST {base_url}/open_api/{project_key}/work_item/{work_item_type_key}/query
X-PLUGIN-TOKEN: p-xxxxxx
Content-Type: application/json

{
  "work_item_ids": [123456]
}
```

- **project_key**：在项目 URL 中可以找到（例如 `https://project.feishu.cn/<project_key>/...`）。
- **work_item_type_key**：项目类型（例如 `story`、`bug`、`task`）。
- **work_item_id**：URL 中的数字 ID。

### 2. URL 解析

典型的 issue URL 模式：
`https://project.feishu.cn/<project_key>/<work_item_type>/detail/<work_item_id>`

`devloop` 代理应自动从提供的 URL 中提取这些组件。

## 配置要求

要使用此集成，用户必须提供凭据（通常通过环境变量或安全的本地文件）：

- `FEISHU_PROJECT_BASE_URL`
- `FEISHU_PROJECT_PLUGIN_ID`
- `FEISHU_PROJECT_PLUGIN_SECRET`

## 映射到 Devloop

- **标题 (Title)**：映射到 devloop 任务标题。
- **描述 (Description)**：映射到 devloop 实施需求。
- **状态映射**：飞书项目的状态（如“进行中”、“已修复”）可用于将 devloop 生命周期同步回项目看板（如果需要）。
