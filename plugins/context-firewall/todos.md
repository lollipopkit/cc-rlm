# context-firewall 后续待办（Todos）

> 说明：以下为 context-firewall 插件的可选增强/后续工作项。

- [ ] （可选）补充 Skill：`plugins/context-firewall/skills/context-firewall/SKILL.md`（触发语句 + 最佳实践 + 常见失败模式）
- [ ] （可选）补充最小 README/使用说明（安装/命令用法/settings 模板/测试清单）
- [ ] （可选）增强端到端用例：更接近真实场景的日志分析/代码库问答 TaskSpec 样例（含 must_cover 与证据抽样策略）
- [ ] （可选）在 Claude Code 里手动验证 hooks：重启 session 后验证 PreToolUse/PostToolUse/UserPromptSubmit 提醒触发
- [ ] （可选）完善 Verifier：对 `tool_call` 的 `rerun_hint` 增强（WebFetch/WebSearch 参数结构约定）
- [ ] （可选）完善 Aggregator：冲突检测/聚类规则更明确（同 claim 去重键、证据签名）
- [ ] （可选）清理/固化 demo 工件策略：是否保留 demo-task.json 与产物示例（避免污染仓库）
- [ ] （可选）提交 Git commit（如需要再做）
