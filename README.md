English | [简体中文](README.zh-CN.md)

# Claude Code Plugins

GPT 5.2 / Claude 4.5 Opus is recommended for the best experience.

## Plugins

- `recursive-reasoning`: Recursive Reasoning Engine - multi-pass reasoning with Self-Refine, Reflexion, Tree of Thoughts.
- `devloop`: Iterate on an issue until it is ready to merge: create branch, fix, commit, open PR, wait for AI review, apply feedback, repeat.
- `gws-manager`: Manage parallel development workspaces and advisory locks using the gws CLI tool.
- `context-firewall`: Use sub-agents to preprocess large inputs into auditable, compressed results with evidence locators (Map-Reduce + verification).

## Usage

### Remote Marketplace

In Claude Code:

```bash
# Add this repo as a marketplace
/plugin marketplace add lollipopkit/cc-plugins
# Install plugins from this marketplace
/plugin install <plugin-name>@lk-ccp # replace <plugin-name> with the specific plugin name
```

### Local Development

If you want to use the local version of this repo:

```bash
# Add local folder as a marketplace
/plugin marketplace add .
# Install plugins from the local marketplace
/plugin install <plugin-name>@lk-ccp
```

## License

MIT
