---
name: health
description: Code quality dashboard. Detects the project's own tools (type checker, linter, test runner, dead code, shellcheck), runs them all, computes a weighted 0-10 composite score, and tracks the trend across runs. Report-only — never fixes anything. Use when the user asks for a health check, a quality score, "how healthy is the codebase", or wants all checks run at once.
---

# /health — Code Quality Dashboard

You are a staff engineer who owns the quality dashboard. Run every available
check, score the results, present a clear dashboard, and show the trend.

**HARD GATE: do NOT fix any issues.** Dashboard and recommendations only.
The user decides what to act on.

## Step 1 — Detect the health stack

If AGENTS.md (or CLAUDE.md) has a `## Health Stack` section, use those tools
and skip auto-detection.

Otherwise auto-detect, in this order of evidence:

| Category  | Detect | Command |
|---|---|---|
| typecheck | `tsconfig.json` | `npx tsc --noEmit` (or the repo's own script) |
| lint | `biome.json[c]` / eslint config / ruff in `pyproject.toml` | `npx biome check .` / `npx eslint .` / `ruff check .` |
| test | `"test"` script in package.json / pytest / `Cargo.toml` / `go.mod` | the repo's test command |
| deadcode | knip installed or in devDependencies | `npx knip` |
| shell | shellcheck on PATH and `*.sh` files exist | `shellcheck <files>` |

Prefer the repo's own package.json scripts over raw binaries when both exist.
Show the detected list to the user and offer to persist it as a
`## Health Stack` section in AGENTS.md (do not persist without asking once).

## Step 2 — Run the tools

Run each tool sequentially. For each one capture: exit code, duration, and the
last 50 lines of output. npm-ecosystem tools that are not installed locally are
run via `npx -y <tool>` — never skip them for being absent. Only report
`SKIPPED (reason)` for tools outside the npm ecosystem (e.g. shellcheck,
ruff) when they are genuinely unavailable, never as a failure.

## Step 3 — Score

Score each category 0-10, then combine with these weights (renormalize weights
over the categories that actually ran):

| Category | Weight | 10 | 7 | 4 | 0 |
|---|---|---|---|---|---|
| test | 32% | all pass | >95% pass | >80% pass | ≤80% pass |
| typecheck | 26% | clean | <10 errors | <50 errors | ≥50 errors |
| lint | 21% | clean | <5 warnings | <20 warnings | ≥20 warnings |
| deadcode | 14% | clean | <5 unused | <20 unused | ≥20 unused |
| shell | 7% | clean | <5 findings | ≥5 findings | — |

Parsing hints: count `error TS` lines for tsc; use the summary line for
biome/eslint/ruff; parse pass/fail counts from the test runner (exit-code-only
runners: 0 → 10, non-zero → 4); count unused exports/files/deps for knip.

## Step 4 — Trend

Append one line to `~/.cache/agent-health/<repo-basename>.jsonl`
(create the directory if needed):

```json
{"ts":"<ISO date>","branch":"<git branch>","score":7.8,"categories":{"test":9,"typecheck":8,"lint":6,"deadcode":7}}
```

If previous entries exist, compare against the last run and show the delta
per category (▲ ▼ =).

## Step 5 — Dashboard

Report in this shape:

```
Code Health: 7.8/10  (▲ +0.4 vs last run, 2026-06-28)

  test       9/10  ████████▉   412 pass / 3 skip        12.4s
  typecheck  8/10  ████████    4 errors                  6.1s
  lint       6/10  ██████      11 warnings               2.3s
  deadcode   7/10  ███████     3 unused exports          4.0s
  shell      SKIPPED (shellcheck not installed)

Top issues to fix first:
1. <most impactful finding, with file:line>
2. …
3. …
```

Close with the 3 highest-impact recommendations (ranked by score impact per
effort), each pointing at concrete files. Then stop — no fixes.
