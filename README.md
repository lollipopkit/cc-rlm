English | [简体中文](README.zh-CN.md)

# Claude Code Plugins

## Plugins

- `recursive-reasoning`: Recursive Reasoning Engine - multi-pass reasoning with Self-Refine, Reflexion, Tree of Thoughts.
- `dev-loop`: Iterate on an issue until it is ready to merge: create branch, fix, commit, open PR, wait for AI review, apply feedback, repeat.

Plugin-specific docs live in each plugin folder.

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
