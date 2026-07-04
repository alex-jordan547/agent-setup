---
name: codex-orchestrator
description: "Codex-only orchestrator with three roles: 5.5 as oracle (plans and validates with its own tools), 5.4 as the orchestrator (coordinates, holds the plan, spawns workers), and spark/mini as the hands (bounded edits, explores, verifications). Routes each task to the cheapest/fastest model whose context window can hold it. The orchestrator writes almost no code; it delegates pre-digested slices. Optimizes for best result, lowest latency, fewest tokens."
---

# Codex Orchestrator

A model-aware orchestrator for the Codex App. The main thread coordinates;
delegation happens through **worker threads** (`create_thread`), each pinned to a
**deliberately chosen model**. The orchestrator thinks and hands off; workers do
the mechanical work.

Full supervision protocol (heartbeats, waiting policy, review, confidence labels):
`~/.agents/skills/thread-orchestrator/SKILL.md`. This skill adds **model routing by
context window** and a **three-role structure** on top.

Delegation mechanism, in preference order:
1. **Named agents** (`~/.codex/agents/*.toml` or project `.codex/agents/`) — spawn by
   name; each is pinned to the right model with scope rules and stop conditions baked
   into its `developer_instructions`.
2. **Fallback** when the named agents aren't defined in the environment: worker threads
   via `create_thread` with `model` + `thinking` overrides, embedding the same scope
   rules in the worker prompt.

Native in-turn `multi_agent_v2` is disabled here (HTTP 400, openai/codex#26753) — do
not rely on it.

## Three roles

| Role | Model | Job |
|---|---|---|
| **Oracle** | `gpt-5.5` | Plans (with the user) and validates at gates. Investigates **with its own tools** — reads the real files, runs checks first-hand. Never spoon-fed a lossy summary. |
| **Orchestrator** | `gpt-5.4` | Holds the plan, coordinates, spawns and supervises workers, integrates. Its 1M window is **headroom**, not a warehouse — the plan pre-digests the work so it stays far from full. |
| **Hands** | `gpt-5.3-codex-spark` / `gpt-5.4-mini` | Bounded edits, tight explores, verifications. One precise task each, sized to fit their window in one pass. |

The orchestrator writes almost no code. It does prep, then delegates narrow,
pre-located slices.

## Named agent roster

Defined in `agents/*.toml` (synced to `~/.codex/agents/`). Sized variants exist because
an agent's model is fixed but task size varies — the orchestrator picks the variant.

| Agent | Model | Sandbox | Use |
|---|---|---|---|
| `explorer_spark` | spark | read-only | Tight bounded explores (working set ≪ 128k) |
| `explorer_mini` | 5.4-mini | read-only | Medium cheap sweeps (≪ 272k) |
| `explorer_max` | 5.4 | read-only | Huge one-pass sweeps needing synthesis |
| `editor_spark` | spark | workspace-write | The only writing hands: one surgical, pre-designed edit |
| `verifier_spark` | spark | workspace-write | Runs the exact given checks; never fixes |
| `reviewer` | 5.4 high | read-only | Correctness/security/regression review of a diff |
| `oracle` | 5.5 xhigh | read-only | Gate judgments (see Oracle gates) |

**Pre-flight measurement (mandatory before picking a variant).** Size is a measurement,
not a judgment — never pick by instinct:

```bash
rg --files <zone> | wc -l                   # file count
rg --files <zone> | xargs wc -l | tail -1   # total lines
rg -l "<symbol>" | wc -l                    # fan-out
```

Rough budget: `lines × ~10 tokens/line` vs the variant's window, target < 60%. Fits
under ~90k → spark variant; under ~160k → mini; bigger → split into N fitting slices
(preferred) or escalate to `explorer_max`.

**Return contract (the downstream tripwire).** Small-model agents are briefed to stop
and hand back instead of compacting silently: `out_of_scope` (needs files beyond the
working set), `too_big` (a listed file is far larger than briefed), `mismatch`
(editor: real code differs from the brief). On any of these, the orchestrator
re-measures and re-routes — split or escalate. Never re-send the same oversized task
to the same variant.

> Reality check: `gpt-5.4`'s 1M window is advertised in the model cache, not yet
> confirmed on this account. If real runs cap at 272k, the orchestrator loses its
> window edge over 5.5 — verify before depending on it.

## Two modes + the tripwire

**Planned mode (big tasks).** A plan built by the user + oracle (`gpt-5.5`) has
already cartographed the work: the surface, the slices, the dependencies, the
verification steps. The orchestrator inherits this and never discovers the surface
live. **Big tasks require a plan** — this is the precondition that keeps the
orchestrator's window as headroom.

**Unplanned mode (small tasks only).** No plan: the orchestrator cartographs the
surface itself, paying context. Allowed **only** when the task is genuinely small.

**Context tripwire (mandatory).** Humans misjudge task size — a "small" fix can
touch 40 files. So in unplanned mode the orchestrator watches its own fill: if
exploration passes **~50% of its window** before a plan exists, it **stops and
demands a plan** instead of plowing into compaction. The no-plan contract is
enforced by this tripwire, not merely hoped for.

## Oracle gates

Call the oracle (`gpt-5.5`, own tools) at **deterministic gates**, plus orchestrator
discretion on top — never discretion alone.

Deterministic gates:
- **Primary: before validating the work / before review / autoreview** — ask the
  oracle whether what's been built is coherent end-to-end. This is the load-bearing
  gate.
- After a plan is produced, before spawning workers against it — sanity-check the
  map (a wrong plan executed perfectly by five sparks is garbage at speed).
- When two workers' results conflict.
- Before a wide or irreversible change.

Discretion: the orchestrator (intel 4/5) may also call the oracle when it senses
it's out of its depth — additive to the gates, for the unknown-unknowns the fixed
triggers didn't anticipate.

Cost discipline: each oracle call is a full 5.5 investigation — expensive and slow.
Don't gate every micro-step; reserve gates for coherence, plan sanity, conflicts,
and irreversibility.

## Model table

Scores 1–5 (5 = best). Context is the hard constraint; the rest are preferences.
Numbers grounded in the Codex model list; scores are a starting calibration — tune
from real runs.

| Model | Intelligence | Speed | Context (ctx / max) | Token economy | Best for |
|---|---|---|---|---|---|
| `gpt-5.3-codex-spark` | 3 | **5** | 128k / 128k | 4 | Surgical edits, tight bounded explores, quick verifications |
| `gpt-5.4-mini` | 2 | 4 | 272k / 272k | **5** | Cheap bulk work, medium explorations, simple mechanical tasks |
| `gpt-5.4` | 4 | 3 | 272k / **1M** | 3 | Orchestrator role; large-context work needing real intelligence |
| `gpt-5.5` | **5** | 3 | 272k / 272k | 2 | Oracle role; hard reasoning, architecture, tricky diagnosis |

`codex-auto-review` is a review-only model — not a delegation target.

## Context budgeting (the routing constraint)

Estimate the task's working set: files the worker must read + instructions +
expected output. Route to a model whose **effective window (~95% of max)** holds it
with headroom.

- Target **< 60%** window utilization per task. Above that, mid-task auto-compaction
  kicks in — the worker loses state, re-reads, burns tokens and time. That's the
  spark failure mode: a 128k model handed a 150k task compacts repeatedly and gets
  slow and dumb.
- If a task exceeds a model's budget: **(a) shrink it** (orchestrator greps/reads
  first, passes only the relevant slice), **(b) split it** into bounded workers, or
  **(c) escalate** to a bigger-context model. Prefer (a)/(b) with spark/mini over
  (c): five precise spark edits usually beat one 5.4 pass — the orchestrator already
  did the reading.

## Routing decision

1. **Needs real reasoning** (design, ambiguous tradeoff, subtle root-cause)? → the
   oracle, or keep it on the orchestrator. Never send genuine reasoning to `mini`.
2. **Precise, well-specified edit or narrow check**, working set **< ~90k**? →
   `gpt-5.3-codex-spark`. The default workhorse for changes already designed.
3. **Broad, low-reasoning sweep** (read many files, list usages, gather evidence)
   fitting in 272k? → `gpt-5.4-mini` (cheapest), or `spark` if tight and speed matters.
4. **Genuinely needs a huge window** (working set only 1M holds) **and** intelligence?
   → `gpt-5.4`. The escalation, not the default.

Tie-break: **cheapest and fastest model that clears the context bar wins.** Climb
the intelligence axis only when the task actually needs it.

## Worker prompt (model-scoped)

Give every worker its files, its edit, its check — never open-ended discovery on a
small model.

```text
Model: <slug + reasoning>. Chosen because: <ctx fit / speed / cost>.
Working set (already located by orchestrator): <exact files/paths/line ranges>.
Task: <one precise edit or check>.
Do NOT: read beyond the working set, refactor adjacent code, or expand scope.
Success check: <exact command/observation that proves it done>.
Return: files changed, check result, anything that didn't fit — do not keep going.
```

## Token/latency economy

- Reading is the orchestrator's job; workers almost never explore from scratch on a
  big model. Pre-fetched context = smaller, cheaper, faster workers.
- Parallelize independent spark workers instead of one serial big-model pass.
- Match reasoning effort to the task: `low`/`medium` for mechanical edits, reserve
  `high`/`xhigh` for the genuinely hard slice.
- Every escalation to `gpt-5.4`/`gpt-5.5` should have a reason you could state out
  loud. If you can't, a split of spark/mini workers is the cheaper answer.
