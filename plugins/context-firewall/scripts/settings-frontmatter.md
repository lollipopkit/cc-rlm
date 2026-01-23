---
enabled: true

# Advisory thresholds
read_warn_bytes: 524288
tool_output_warn_chars: 20000

# Sampling rates for /cf-verify
sample_rate:
  low: 0.05
  medium: 0.15
  high: 0.30

# Default constraints applied when TaskSpec omits them
constraints:
  max_output_tokens: 1200
  max_claims: 25
  evidence_per_claim_min: 1
  quote_max_chars: 240

# Persistence
persist:
  enabled: true
  dir: .claude/context-firewall
---

# context-firewall local settings

This file is read by context-firewall commands/hooks.
Only YAML frontmatter is parsed in v1.
