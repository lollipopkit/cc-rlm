# context-firewall

## Quick test checklist

- [ ] Restart Claude Code session (hooks load at startup).
- [ ] Run `/cf-spec --id demo --risk low --objective "..."` and confirm it prints strict JSON.
- [ ] Create a TaskSpec file and run `/cf-run --spec <file>`.
- [ ] Confirm persistence:
  - `.claude/context-firewall/task-specs/<task_id>.json`
  - `.claude/context-firewall/results/<task_id>.json`
- [ ] Run `/cf-verify --result .claude/context-firewall/results/<task_id>.json --risk low`.
- [ ] Confirm persistence:
  - `.claude/context-firewall/verify/<task_id>.json`

## Settings

Create `.claude/context-firewall.local.md` using template in:

- `plugins/context-firewall/scripts/settings-frontmatter.md`
