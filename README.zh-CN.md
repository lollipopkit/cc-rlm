[English](README.md) | 简体中文

# Claude Code 插件

## 插件列表

- `recursive-reasoning`: 递归推理引擎 - 通过 Self-Refine、Reflexion、Tree of Thoughts 实现多轮推理。
- `dev-loop`: 对一个 issue 进行迭代，直到准备好合并：创建分支、修复、提交、打开 PR、等待 AI 审查、应用反馈、重复。

各插件的具体文档位于各自的插件文件夹中。

## 使用方法

### 远程 Marketplace

在 Claude Code 中：

```bash
# 将此仓库添加为 marketplace
/plugin marketplace add lollipopkit/cc-plugins
# 从此 marketplace 安装插件
/plugin install <plugin-name>@lk-ccp # 替换 <plugin-name> 为具体插件名
```

### 本地开发

如果你想使用此仓库的本地版本：

```bash
# 将本地文件夹添加为 marketplace
/plugin marketplace add .
# 从本地 marketplace 安装插件
/plugin install <plugin-name>@lk-ccp
```

## 许可证

MIT
