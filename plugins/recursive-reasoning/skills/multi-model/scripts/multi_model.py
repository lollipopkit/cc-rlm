#!/usr/bin/env python3
"""Multi-model battle runner.

Reads configuration from a .env file (searching upward from CWD) and calls
OpenAI-compatible chat completions endpoints.

Security:
- Never prints API keys.
- Treats model identity as numeric IDs in all prompts.

Requires: Python 3.9+
"""

from __future__ import annotations

import argparse
import json
import os
import pathlib
import re
import sys
import time
import urllib.error
import urllib.request
from dataclasses import dataclass
from typing import Any, Dict, List, Optional, Tuple


_ENV_LINE_RE = re.compile(r"^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*)\s*$")


def _strip_quotes(value: str) -> str:
    if len(value) >= 2 and ((value[0] == value[-1]) and value[0] in ("\"", "'")):
        return value[1:-1]
    return value


def find_dotenv(start: pathlib.Path) -> Optional[pathlib.Path]:
    current = start.resolve()
    for parent in [current, *current.parents]:
        candidate = parent / ".env"
        if candidate.is_file():
            return candidate
    return None


def load_env_file(dotenv_path: pathlib.Path) -> Dict[str, str]:
    env: Dict[str, str] = {}
    for line in dotenv_path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        match = _ENV_LINE_RE.match(line)
        if not match:
            continue
        key, raw_value = match.group(1), match.group(2)
        value = _strip_quotes(raw_value.strip())
        env[key] = value
    return env


@dataclass(frozen=True)
class Provider:
    base_url: str
    api_key: str


@dataclass(frozen=True)
class ModelRef:
    provider: str
    model: str


def parse_models(models_raw: str) -> List[ModelRef]:
    models: List[ModelRef] = []
    for part in [p.strip() for p in models_raw.split(",") if p.strip()]:
        if ":" in part:
            provider, model = part.split(":", 1)
            models.append(ModelRef(provider=provider.strip().lower(), model=model.strip()))
        else:
            models.append(ModelRef(provider="default", model=part))
    return models


def build_providers(env: Dict[str, str]) -> Dict[str, Provider]:
    providers: Dict[str, Provider] = {}

    default_base = env.get("ARENA_OPENAI_BASE_URL", "").strip()
    default_key = env.get("ARENA_OPENAI_API_KEY", "").strip()
    if default_base:
        providers["default"] = Provider(base_url=default_base, api_key=default_key)

    prefix = "ARENA_PROVIDER_"
    for key, value in env.items():
        if not key.startswith(prefix) or not key.endswith("_BASE_URL"):
            continue
        provider_name = key[len(prefix) : -len("_BASE_URL")].lower()
        base_url = value.strip()
        api_key = env.get(f"{prefix}{provider_name.upper()}_API_KEY", "").strip()
        if base_url:
            providers[provider_name] = Provider(base_url=base_url, api_key=api_key)

    return providers


def _http_json(
    *,
    url: str,
    api_key: str,
    payload: Dict[str, Any],
    timeout_s: float,
) -> Dict[str, Any]:
    body = json.dumps(payload).encode("utf-8")
    headers = {
        "Content-Type": "application/json",
    }
    if api_key:
        headers["Authorization"] = f"Bearer {api_key}"

    req = urllib.request.Request(url=url, data=body, headers=headers, method="POST")
    try:
        with urllib.request.urlopen(req, timeout=timeout_s) as resp:
            data = resp.read().decode("utf-8")
            return json.loads(data)
    except urllib.error.HTTPError as e:
        data = e.read().decode("utf-8", errors="replace")
        raise RuntimeError(f"HTTP {e.code} from {url}: {data}") from e
    except urllib.error.URLError as e:
        raise RuntimeError(f"Network error calling {url}: {e}") from e


def openai_chat_completions(
    *,
    provider: Provider,
    model: str,
    messages: List[Dict[str, str]],
    temperature: float,
    max_tokens: int,
    timeout_s: float,
) -> str:
    base = provider.base_url.rstrip("/")
    url = f"{base}/chat/completions"
    payload: Dict[str, Any] = {
        "model": model,
        "messages": messages,
        "temperature": temperature,
        "max_tokens": max_tokens,
    }

    result = _http_json(url=url, api_key=provider.api_key, payload=payload, timeout_s=timeout_s)

    choices = result.get("choices")
    if not isinstance(choices, list) or not choices:
        raise RuntimeError("No choices in response")
    message = choices[0].get("message")
    if not isinstance(message, dict):
        raise RuntimeError("Invalid message in response")
    content = message.get("content")
    if not isinstance(content, str):
        raise RuntimeError("Invalid content in response")
    return content.strip()


def redact_env(env: Dict[str, str]) -> Dict[str, str]:
    redacted: Dict[str, str] = {}
    for k, v in env.items():
        if "KEY" in k or "TOKEN" in k or "SECRET" in k:
            redacted[k] = "***"
        else:
            redacted[k] = v
    return redacted


def _model_id_label(model_index: int) -> str:
    return f"Model {model_index}"


def build_writer_prompt(
    *,
    user_prompt: str,
    model_index: int,
    iteration: int,
    current_best: Optional[str],
    prior_round_summary: Optional[str],
) -> List[Dict[str, str]]:
    system = (
        "You are participating in a multi-model arena. "
        "Your identity is an internal numeric ID only. "
        "Do not mention any provider or model names. "
        "Write a high-quality answer.")

    context_parts = [
        f"Iteration: {iteration}",
        f"Your ID: {_model_id_label(model_index)}",
        "You may see a current best answer from prior rounds.",
    ]
    if current_best:
        context_parts.append("Current best answer:\n" + current_best)
    if prior_round_summary:
        context_parts.append("Prior judges summary:\n" + prior_round_summary)

    user = "\n\n".join(context_parts) + "\n\nTask:\n" + user_prompt
    return [
        {"role": "system", "content": system},
        {"role": "user", "content": user},
    ]


def build_judge_prompt(
    *,
    user_prompt: str,
    judge_index: int,
    writer_index: int,
    iteration: int,
    candidate: str,
) -> List[Dict[str, str]]:
    system = (
        "You are a judge in a multi-model arena. "
        "You do not know real model identities; you only see numeric IDs. "
        "Do not guess identities."
    )

    rubric = (
        "Score the candidate from 1-10 across these dimensions: correctness, completeness, clarity, "
        "efficiency, safety. Provide:\n"
        "- Overall score (integer 1-10)\n"
        "- 3-8 bullet critiques\n"
        "- 1-3 concrete improvement actions\n"
        "- A one-paragraph summary.\n"
        "Output as JSON with keys: score, critiques, actions, summary."
    )

    user = (
        f"Iteration: {iteration}\n"
        f"You are: {_model_id_label(judge_index)}\n"
        f"Candidate author: {_model_id_label(writer_index)}\n\n"
        f"Task:\n{user_prompt}\n\n"
        f"Candidate:\n{candidate}\n\n"
        f"Rubric:\n{rubric}"
    )

    return [
        {"role": "system", "content": system},
        {"role": "user", "content": user},
    ]


def try_parse_json(text: str) -> Optional[Dict[str, Any]]:
    try:
        value = json.loads(text)
    except json.JSONDecodeError:
        return None
    if isinstance(value, dict):
        return value
    return None


def clamp_int(value: Any, lo: int, hi: int) -> Optional[int]:
    if isinstance(value, bool):
        return None
    if isinstance(value, int):
        return max(lo, min(hi, value))
    if isinstance(value, float) and value.is_integer():
        return max(lo, min(hi, int(value)))
    if isinstance(value, str) and value.strip().isdigit():
        return max(lo, min(hi, int(value.strip())))
    return None


def aggregate_judgements(judgements: List[Dict[str, Any]]) -> Tuple[float, str]:
    scores: List[int] = []
    summaries: List[str] = []
    for j in judgements:
        score = clamp_int(j.get("score"), 1, 10)
        if score is not None:
            scores.append(score)
        summary = j.get("summary")
        if isinstance(summary, str) and summary.strip():
            summaries.append(summary.strip())
    avg = sum(scores) / len(scores) if scores else 0.0
    summary = "\n".join(f"- {s}" for s in summaries)
    return avg, summary


def select_judges(model_count: int, writer_index: int, max_judges: int) -> List[int]:
    judges = [i for i in range(model_count) if i != writer_index]
    return judges[: max(0, min(len(judges), max_judges))]


def main() -> int:
    parser = argparse.ArgumentParser(description="Multi-model arena battle runner")
    parser.add_argument("--prompt", required=True, help="User task prompt")
    parser.add_argument("--iters", type=int, default=5, help="Number of iterations")
    parser.add_argument("--max-judges", type=int, default=3, help="Max judge models per iteration")
    parser.add_argument("--temperature", type=float, default=0.4)
    parser.add_argument("--max-tokens", type=int, default=1200)
    parser.add_argument("--timeout", type=float, default=120.0)
    parser.add_argument("--json", action="store_true", help="Print JSON transcript")
    parser.add_argument("--out", help="Write JSON transcript to path")
    args = parser.parse_args()

    dotenv = find_dotenv(pathlib.Path.cwd())
    if not dotenv:
        raise SystemExit(".env not found (searching upward from current directory)")

    env = load_env_file(dotenv)

    models_raw = env.get("ARENA_MODELS", "").strip()
    if not models_raw:
        raise SystemExit("ARENA_MODELS missing in .env")

    models = parse_models(models_raw)
    providers = build_providers(env)
    if not providers:
        raise SystemExit("No providers configured. Set ARENA_OPENAI_BASE_URL or ARENA_PROVIDER_<X>_BASE_URL")

    missing_providers = sorted({m.provider for m in models if m.provider not in providers})
    if missing_providers:
        raise SystemExit(f"Missing provider config for: {', '.join(missing_providers)}")

    transcript: Dict[str, Any] = {
        "dotenv": str(dotenv),
        "config": {
            "env": redact_env({k: env[k] for k in sorted(env.keys()) if k.startswith("ARENA_")}),
            "iters": args.iters,
            "max_judges": args.max_judges,
            "temperature": args.temperature,
            "max_tokens": args.max_tokens,
        },
        "models": [{"id": _model_id_label(i)} for i in range(len(models))],
        "rounds": [],
        "best": None,
    }

    current_best: Optional[str] = None
    current_best_score: float = -1.0
    prior_judges_summary: Optional[str] = None

    for iteration in range(1, max(1, args.iters) + 1):
        writer_index = (iteration - 1) % len(models)
        writer_ref = models[writer_index]
        writer_provider = providers[writer_ref.provider]

        writer_messages = build_writer_prompt(
            user_prompt=args.prompt,
            model_index=writer_index,
            iteration=iteration,
            current_best=current_best,
            prior_round_summary=prior_judges_summary,
        )

        started = time.time()
        candidate = openai_chat_completions(
            provider=writer_provider,
            model=writer_ref.model,
            messages=writer_messages,
            temperature=args.temperature,
            max_tokens=args.max_tokens,
            timeout_s=args.timeout,
        )
        writer_elapsed = time.time() - started

        judges = select_judges(len(models), writer_index, args.max_judges)
        judgements: List[Dict[str, Any]] = []
        for judge_index in judges:
            judge_ref = models[judge_index]
            judge_provider = providers[judge_ref.provider]

            judge_messages = build_judge_prompt(
                user_prompt=args.prompt,
                judge_index=judge_index,
                writer_index=writer_index,
                iteration=iteration,
                candidate=candidate,
            )

            j_started = time.time()
            judge_text = openai_chat_completions(
                provider=judge_provider,
                model=judge_ref.model,
                messages=judge_messages,
                temperature=0.0,
                max_tokens=800,
                timeout_s=args.timeout,
            )
            j_elapsed = time.time() - j_started

            judge_json = try_parse_json(judge_text) or {
                "score": None,
                "critiques": ["Judge did not return valid JSON"],
                "actions": [],
                "summary": judge_text[:8000],
            }
            judge_json["judge"] = _model_id_label(judge_index)
            judge_json["elapsed_s"] = round(j_elapsed, 3)
            judgements.append(judge_json)

        avg_score, prior_judges_summary = aggregate_judgements(judgements)

        round_entry = {
            "iteration": iteration,
            "writer": _model_id_label(writer_index),
            "writer_elapsed_s": round(writer_elapsed, 3),
            "candidate": candidate,
            "judgements": judgements,
            "avg_score": round(avg_score, 3),
        }
        transcript["rounds"].append(round_entry)

        if avg_score >= current_best_score:
            current_best_score = avg_score
            current_best = candidate

    transcript["best"] = {
        "avg_score": round(current_best_score, 3),
        "answer": current_best,
    }

    if args.out:
        out_path = pathlib.Path(args.out)
        out_path.write_text(json.dumps(transcript, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")

    if args.json:
        sys.stdout.write(json.dumps(transcript, indent=2, ensure_ascii=False) + "\n")
    else:
        sys.stdout.write(current_best or "")
        sys.stdout.write("\n")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
