---
name: multi-model
description: Multi-model battle for iterative (recursive) refinement. Rotates models every iteration and has other models judge/critique. Use when user asks to "battle models", "compare models", "multi-LLM", or wants iterative refinement across multiple OpenAI-compatible / Ollama models.
allowed-tools: Read, Bash(python:*)
---

# Multi-Model Skill

Run a multi-model “battle” loop where:

- Each iteration uses a different model (rotating by index).
- The active model produces a candidate answer.
- Other models judge and critique it.
- The process keeps the best-scoring answer as the current best.

## Configuration (.env)

This skill reads `.env` (searching upward from the current working directory) to find multi-model config.

### Single-endpoint setup (OpenAI-compatible)

- `ARENA_OPENAI_BASE_URL` (e.g. `http://localhost:11434/v1` for Ollama, or `https://api.openai.com/v1`)
- `ARENA_OPENAI_API_KEY` (optional for Ollama)
- `ARENA_MODELS` (comma-separated model names)

Example:

```env
ARENA_OPENAI_BASE_URL=http://localhost:11434/v1
ARENA_OPENAI_API_KEY=
ARENA_MODELS=qwen3:8b,deepseek-r1:14b
```

### Multi-provider setup (optional)

- `ARENA_MODELS=provider:model,provider:model2,...`
- `ARENA_PROVIDER_<PROVIDER>_BASE_URL=...`
- `ARENA_PROVIDER_<PROVIDER>_API_KEY=...`

Example:

```env
ARENA_MODELS=ollama:qwen3:8b,openai:gpt-4o-mini
ARENA_PROVIDER_OLLAMA_BASE_URL=http://localhost:11434/v1
ARENA_PROVIDER_OLLAMA_API_KEY=
ARENA_PROVIDER_OPENAI_BASE_URL=https://api.openai.com/v1
ARENA_PROVIDER_OPENAI_API_KEY=YOUR_KEY
```

## How to run

1. Ensure `.env` exists and contains the variables above.
2. Run the multi-model script.

```bash
python3 "${CLAUDE_PLUGIN_ROOT}/skills/multi-model/scripts/multi_model.py" --prompt "<your task>" --iters 5
```

Options you can use:

- `--iters N`: number of iterations (each iteration rotates the writer model)
- `--max-judges N`: cap number of judge models per round
- `--json`: output machine-readable JSON
- `--out path.json`: save JSON transcript

## Output expectations

- Treat model identity as an internal numeric ID (`Model 0`, `Model 1`, ...).
- In any prompts to models, do not disclose provider/model names; only IDs.
- Never print secrets from `.env` (API keys).
