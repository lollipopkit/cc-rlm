#!/usr/bin/env python3
"""Parse external LLM Markdown checklist output into structured JSON.

Expected input format (recommended):

## Review Checklist
- [ ] path/to/file.ts:123 - Do X
- [ ] path/to/file.ts - Do Y
- [ ] (general) Do Z

Output: JSON array of items:
[{"checked": false, "file": "...", "line": 123, "message": "..."}, ...]
"""

from __future__ import annotations

import json
import re
import sys
from typing import Any, Dict, List


CHECK_ITEM_RE = re.compile(r"^\s*[-*]\s+\[(?P<mark>[ xX])\]\s+(?P<body>.+?)\s*$")

# Accept:
#   path/to/file:12:34 - message
#   path/to/file:12 - message
#   path/to/file - message
#   (general) message
FILE_LINE_RE = re.compile(
    r"^(?P<file>(?:[A-Za-z]:)?[^:\s][^:\n]*?)(?::(?P<line>\d+))?(?::(?P<col>\d+))?$"
)


def _split_target_and_message(body: str) -> Dict[str, str]:
    body = body.strip()

    # Prefer explicit separators with surrounding spaces.
    for sep in (" - ", " — "):
        if sep in body:
            left, right = body.split(sep, 1)
            return {"target": left.strip(), "message": right.strip()}

    # If the line begins with a scope marker like "(general) ...", treat it as non-file guidance.
    if body.startswith("(") and ")" in body:
        parts = body.split(")", 1)
        scope = (parts[0] + ")").strip()
        message = parts[1].strip()
        return {"target": scope, "message": message}

    # If no separator is present, treat the whole line as message.
    return {"target": "", "message": body}


def _parse_target(target: str) -> Dict[str, Any]:
    target = target.strip()
    if target.startswith("(") and target.endswith(")"):
        return {"scope": target[1:-1].strip()}

    m = FILE_LINE_RE.match(target)
    if not m:
        return {"raw_target": target}

    file_path = m.group("file")
    line = m.group("line")
    col = m.group("col")

    out: Dict[str, Any] = {"file": file_path}
    if line is not None:
        out["line"] = int(line)
    if col is not None:
        out["col"] = int(col)
    return out


def parse_markdown(md: str) -> List[Dict[str, Any]]:
    items: List[Dict[str, Any]] = []
    for line in md.splitlines():
        m = CHECK_ITEM_RE.match(line)
        if not m:
            continue

        checked = m.group("mark").strip().lower() == "x"
        body = m.group("body").strip()

        parts = _split_target_and_message(body)
        target = parts["target"]
        message = parts["message"]

        item: Dict[str, Any] = {"checked": checked, "message": message}
        if target:
            item.update(_parse_target(target))
        items.append(item)

    return items


def main() -> int:
    md = sys.stdin.read()
    items = parse_markdown(md)
    json.dump(items, sys.stdout, ensure_ascii=False, indent=2)
    sys.stdout.write("\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
