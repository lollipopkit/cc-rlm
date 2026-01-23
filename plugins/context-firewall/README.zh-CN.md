# context-firewall

面向 Claude Code 的 Context Firewall 插件：把“大输入读取/筛选/归纳”交给子代理完成，只把**结构化压缩结论 + 可审计证据 locator + 覆盖声明**带回 Master，并提供低成本抽样复核。

## 组件

### Commands

- `/cf-spec`：生成 schema-valid 的 `TaskSpec.v1` 模板（严格 JSON only）。
- `/cf-run`：运行 Map-Reduce 预处理（FileWorker → Aggregator），输出 `SubResult.v1`（严格 JSON only）。
- `/cf-verify`：对 `SubResult.v1` 的 evidence 做抽样复核，输出 `VerifyReport.v1`（严格 JSON only）。

### Agents

- `cf-fileworker`：扫描单个 shard 输入，产出带证据的 claims（严格 JSON only）。
- `cf-aggregator`：合并多个 FileWorker 输出为单个 `SubResult.v1`（严格 JSON only）。
- `cf-critic`：用于高风险/冲突场景的独立复读与对比（严格 JSON only）。

### Hooks（仅提醒，不强拦截）

配置文件：`hooks/hooks.json`

- `PreToolUse`：在可能产生大规模上下文输入前提醒（Read / WebFetch / WebSearch / MCP 等）。
- `PostToolUse`：在 WebFetch/WebSearch 结果很长时提醒改走 context-firewall 流程。
- `UserPromptSubmit`：当用户粘贴大段 blob（日志/长 JSON/长文档）时提醒“先落盘再 /cf-run”。

## 设置（Settings）

创建项目级本地配置：

- `<project>/.claude/context-firewall.local.md`

模板见：

- `plugins/context-firewall/scripts/settings-frontmatter.md`

常用字段：

- `enabled`：开关
- `read_warn_bytes`：Read 大输入提醒阈值
- `tool_output_warn_chars`：工具输出过长提醒阈值
- `sample_rate`：/cf-verify 按 risk_level 的抽样比例
- `persist.dir`：落盘目录（默认 `.claude/context-firewall`）

## Schemas

- `schemas/task-spec.v1.schema.json`
- `schemas/sub-result.v1.schema.json`
- `schemas/verify-report.v1.schema.json`
- `schemas/settings.v1.schema.json`

## 示例（Examples）

- `examples/logs-timeout-task.json`：多日志分析（时间窗 + 关键词 must_cover）
- `examples/repo-entrypoints-task.json`：入口/调用链定位（含 git diff 上下文）

## 快速测试

见：`scripts/test-plan.md`
