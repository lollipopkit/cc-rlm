#!/usr/bin/env python3
"""Recursive-Arena orchestrator.

Runs an outer iterative loop (recursive-style) where each round calls the multi-model runner
to generate a best candidate via multiple models.

This script is designed to be run by Claude Code via Bash(python:*).

Security:
- Never prints API keys.
- Never reveals provider/model names; only numeric IDs already produced by arena.
"""

from __future__ import annotations

import argparse
import json
import os
import pathlib
import subprocess
import sys
from typing import Any, Dict, Optional, Tuple


def _plugin_root() -> pathlib.Path:
    root = os.environ.get("CLAUDE_PLUGIN_ROOT", "").strip()
    if root:
        return pathlib.Path(root)

    # Fallback: locate by relative path from this file.
    return pathlib.Path(__file__).resolve().parents[3]


def _run_multi_model(
    *,
    prompt: str,
    arena_iters: int,
    max_judges: int,
    temperature: float,
    max_tokens: int,
    timeout_s: float,
) -> Dict[str, Any]:
    plugin_root = _plugin_root()
    multi_model_py = plugin_root / "skills" / "multi-model" / "scripts" / "multi_model.py"

    cmd = [
        sys.executable,
        str(multi_model_py),
        "--prompt",
        prompt,
        "--iters",
        str(arena_iters),
        "--max-judges",
        str(max_judges),
        "--temperature",
        str(temperature),
        "--max-tokens",
        str(max_tokens),
        "--timeout",
        str(timeout_s),
        "--json",
    ]

    try:
        completed = subprocess.run(
            cmd,
            check=False,
            capture_output=True,
            text=True,
            timeout=timeout_s,
        )
    except subprocess.TimeoutExpired as e:
        raise RuntimeError(f"multi-model timed out after {timeout_s:.0f}s") from e

    if completed.returncode != 0:
        stderr = completed.stderr.strip()
        stdout = completed.stdout.strip()
        detail = stderr or stdout or f"multi-model exited with {completed.returncode}"
        raise RuntimeError(detail)

    try:
        return json.loads(completed.stdout)
    except json.JSONDecodeError as e:
        raise RuntimeError("multi-model did not return valid JSON") from e


def _summarize_round(arena_json: Dict[str, Any]) -> Tuple[float, str, str]:
    best = arena_json.get("best") or {}
    best_score = best.get("avg_score")
    best_answer = best.get("answer")

    if not isinstance(best_score, (int, float)):
        best_score = 0.0
    if not isinstance(best_answer, str):
        best_answer = ""

    rounds = arena_json.get("rounds")
    writer = ""
    if isinstance(rounds, list) and rounds:
        # The last round that set the best is not tracked explicitly.
        # Use the final round's writer as a reasonable label without extra coupling.
        last = rounds[-1]
        if isinstance(last, dict):
            w = last.get("writer")
            if isinstance(w, str):
                writer = w

    return float(best_score), writer, best_answer


def main() -> int:
    parser = argparse.ArgumentParser(description="Recursive-Arena orchestrator")
    parser.add_argument("--prompt", required=True)
    parser.add_argument("--iters", type=int, default=4, help="Outer iterations")
    parser.add_argument("--arena-iters", type=int, default=int(os.environ.get("RLM_ARENA_ARENA_ITERS", "3")))
    parser.add_argument("--max-judges", type=int, default=int(os.environ.get("RLM_ARENA_MAX_JUDGES", "3")))
    parser.add_argument("--temperature", type=float, default=0.4)
    parser.add_argument("--max-tokens", type=int, default=1200)
    parser.add_argument("--timeout", type=float, default=120.0)
    parser.add_argument("--json", action="store_true")
    args = parser.parse_args()

    outer_prompt = args.prompt

    transcript: Dict[str, Any] = {
        "outer_iters": args.iters,
        "multi_model_iters": args.arena_iters,
        "rounds": [],
        "final": None,
    }

    best_answer: Optional[str] = None
    best_score: float = -1.0

    for i in range(1, max(1, args.iters) + 1):
        multi_model_json = _run_multi_model(
            prompt=outer_prompt,
            arena_iters=args.arena_iters,
            max_judges=args.max_judges,
            temperature=args.temperature,
            max_tokens=args.max_tokens,
            timeout_s=args.timeout,
        )

        score, writer, answer = _summarize_round(multi_model_json)

        transcript["rounds"].append(
            {
                "iteration": i,
                "prompt": outer_prompt,
                "arena": {
                    "best_score": round(score, 3),
                    "best_writer": writer,
                },
                "answer": answer,
            }
        )

        if score >= best_score:
            best_score = score
            best_answer = answer

        # Minimal refinement: feed back the current best answer and ask for improvements.
        # Keep it deterministic and avoid leaking provider/model names.
        outer_prompt = (
            args.prompt
            + "\n\nCurrent best answer (from prior rounds):\n"
            + (best_answer or "")
            + "\n\nImprove the answer: fix any correctness gaps, add missing requirements, and tighten clarity."
        )

    transcript["final"] = {
        "best_score": round(best_score, 3),
        "answer": best_answer or "",
    }

    if args.json:
        sys.stdout.write(json.dumps(transcript, indent=2, ensure_ascii=False) + "\n")
    else:
        sys.stdout.write((best_answer or "") + "\n")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
