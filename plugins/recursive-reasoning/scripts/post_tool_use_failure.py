#!/usr/bin/env python3
from __future__ import annotations

import json
import os
import re
import sys
from typing import Any, Dict


def _load_input() -> Dict[str, Any]:
    try:
        return json.load(sys.stdin)
    except Exception:
        return {}


def _contains_secret_like_output(text: str) -> bool:
    # Very conservative checks: avoid printing anything that looks like an API key/token.
    patterns = [
        r"(?i)api[_-]?key\s*[:=]",
        r"(?i)bearer\s+[A-Za-z0-9_\-\.]+",
        r"(?i)token\s*[:=]",
        r"(?i)secret\s*[:=]",
    ]
    return any(re.search(p, text) for p in patterns)


def main() -> int:
    data = _load_input()

    if data.get("hook_event_name") != "PostToolUse" or data.get("tool_name") != "Bash":
        return 0

    tool_response = data.get("tool_response") or {}
    success = tool_response.get("success")

    # If the Bash tool failed, surface a short hint only for arena-related commands.
    if success is False:
        tool_input = data.get("tool_input") or {}
        cmd = tool_input.get("command")
        cmd_str = cmd if isinstance(cmd, str) else ""

        is_recursive = (
            "${CLAUDE_PLUGIN_ROOT}/skills/multi-model/scripts/multi_model.py" in cmd_str
            or "${CLAUDE_PLUGIN_ROOT}/skills/recursive-arena/scripts/recursive_arena.py" in cmd_str
            or "skills/multi-model/scripts/multi_model.py" in cmd_str
            or "skills/recursive-arena/scripts/recursive_arena.py" in cmd_str
            or re.search(r"\bmulti_model\.py\b", cmd_str) is not None
            or re.search(r"\brecursive_arena\.py\b", cmd_str) is not None
        )

        if not is_recursive:
            return 0

        hints: list[str] = []
        if re.search(r"\bpython\b", cmd_str) and not re.search(r"\bpython3\b", cmd_str):
            hints.append("Use `python3` (this environment may not have `python`).")

        hints.append(
            "Ensure `.env` exists (searched upward from CWD) and includes `ARENA_MODELS` and provider base URL vars."
        )

        msg = "Recursive-reasoning hook hint (multi-model/recursive-arena Bash failed): " + " ".join(hints)
        if not _contains_secret_like_output(msg):
            print(json.dumps({"decision": "block", "reason": msg}))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
