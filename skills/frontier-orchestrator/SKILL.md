---
name: frontier-orchestrator
description: "Frontier-models orchestrator mixing Claude and Codex (GPT) families: Claude Opus 4.8 as the orchestrator (coordinates, holds the plan, spawns workers), GPT-5.5 as the oracle (plans and validates with its own tools — cross-family so gates are never graded by the family that did the work), and Sonnet 5 / gpt-5.4 as skilled hands with Haiku 4.5 / gpt-5.4-mini / spark as cheap hands. Routes each task to the cheapest model whose context window can hold it. The orchestrator writes almost no code; it delegates pre-digested slices. Optimizes for best result on hard tasks."
---

# Frontier Orchestrator — Claude × Codex

A model-aware orchestrator mixing the two frontier families. The main thread
coordinates; delegation happens through **workers**, each pinned to a
**deliberately chosen model**. The orchestrator thinks and hands off; workers do
the mechanical work.

**Delegation mechanism is environment-agnostic.** Use whatever spawn primitive the
host exposes — worker threads, a subagent/Task tool with a `model` parameter, named
agents — and embed the scope rules from this skill in each worker's prompt. What is
fixed here is the **role structure and the routing**, not the API. Note that a
given host usually spawns only one family natively; the other family is reached
through whatever bridge exists (CLI of the other agent, MCP, API call). If no
bridge exists for a role's model, substitute the same-family equivalent noted in
the role table rather than skipping the role.

Supervision essentials:

- After spawning a worker, supervise by **periodic check-ins** (heartbeat/polling as
  the host allows, ~3 min default) instead of keeping the turn open; read the
  worker's output, newest first.
- **Wait passively**: in-progress means working. Steer only on new context, a wrong
  brief, a blocking question, a reported blocker, or a timeout with no progress.
- **Worker output is evidence, not a final answer**: check every success criterion,
  confirm claimed edits/tests, resolve conflicts centrally. Label confidence when
  reporting: orchestrator-accepted / worker-reported / unverified.
- Don't stop at "worker created"; don't convert orchestration into main-thread
  implementation.

## Three roles — split across families on purpose

| Role | Model | Job |
|---|---|---|
| **Oracle** | `gpt-5.5` (xhigh) | Plans (with the user) and validates at gates. Investigates **with its own tools** — reads the real files, runs checks first-hand. Never spoon-fed a lossy summary. **Cross-family by design**: the work is coordinated and mostly written by Claude models, so the gate judgment comes from a family with uncorrelated blind spots. Fallback if no GPT bridge: `claude-opus-4-8` in a fresh instance. |
| **Orchestrator** | `claude-opus-4-8` | Holds the plan, coordinates, spawns and supervises workers, integrates. State-of-the-art long-horizon agentic execution and 1M window — **headroom**, not a warehouse; the plan pre-digests the work so it stays far from full. |
| **Hands** | skilled: `claude-sonnet-5` / `gpt-5.4` · cheap: `claude-haiku-4-5` / `gpt-5.4-mini` / `gpt-5.3-codex-spark` | Bounded edits, explores, verifications. One precise task each, sized to fit its window in one pass. |

The orchestrator writes almost no code. It does prep, then delegates narrow,
pre-located slices.

**Pre-flight measurement (mandatory before routing).** Size is a measurement,
not a judgment — never pick by instinct:

```bash
rg --files <zone> | wc -l                   # file count
rg --files <zone> | xargs wc -l | tail -1   # total lines
rg -l "<symbol>" | wc -l                    # fan-out
```

Rough budget: `lines × ~10 tokens/line` vs the model's window, target < 60%. Fits
under ~75k → spark; under ~120k → haiku; under ~160k → mini; bigger → split into
N fitting slices (preferred) or route to a 1M-window skilled hand.

**Return contract (the downstream tripwire).** Workers are briefed to stop and hand
back instead of compacting silently: `out_of_scope` (needs files beyond the working
set), `too_big` (a listed file is far larger than briefed), `mismatch` (editor: real
code differs from the brief). On any of these, the orchestrator re-measures and
re-routes — split or escalate. Never re-send the same oversized task to the same
model.

## Two modes + the tripwire

**Planned mode (big tasks).** A plan built by the user + oracle has already
cartographed the work: the surface, the slices, the dependencies, the verification
steps. The orchestrator inherits this and never discovers the surface live. **Big
tasks require a plan** — this is the precondition that keeps the orchestrator's
window as headroom.

**Unplanned mode (small tasks only).** No plan: the orchestrator cartographs the
surface itself, paying context. Allowed **only** when the task is genuinely small.

**Context tripwire (mandatory).** Humans misjudge task size — a "small" fix can
touch 40 files. So in unplanned mode the orchestrator watches its own fill: if
exploration passes **~50% of its window** before a plan exists, it **stops and
demands a plan** instead of plowing into compaction. The no-plan contract is
enforced by this tripwire, not merely hoped for.

## Oracle gates

Call the oracle (GPT-5.5, own tools) at **deterministic gates**, plus orchestrator
discretion on top — never discretion alone. The cross-family gate is the point of
this tier: Claude-coordinated, Claude-written work validated by a GPT reviewer
catches the failure modes each family shares internally.

Deterministic gates:
- **Primary: before validating the work / before review / autoreview** — ask the
  oracle whether what's been built is coherent end-to-end. This is the load-bearing
  gate.
- After a plan is produced, before spawning workers against it — sanity-check the
  map (a wrong plan executed perfectly by five cheap workers is garbage at speed).
- When two workers' results conflict.
- Before a wide or irreversible change.

Discretion: the orchestrator may also call the oracle when it senses it's out of
its depth — additive to the gates, for the unknown-unknowns the fixed triggers
didn't anticipate.

Cost discipline: each oracle call is a full frontier investigation — expensive and
slow. Don't gate every micro-step; reserve gates for coherence, plan sanity,
conflicts, and irreversibility. Feed it a tight brief and exact file paths so its
own investigation stays short.

## Model table

Scores 1–5 (5 = best). Context is the hard constraint; the rest are preferences.
Claude prices per 1M tokens (input/output); GPT models scored on the same token-
economy axis as the codex-orchestrator calibration. Scores are a starting
calibration — tune from real runs.

| Model | Family | Intelligence | Speed | Context | Price / economy | Best for |
|---|---|---|---|---|---|---|
| `gpt-5.3-codex-spark` | Codex | 3 | **5** | 128k | economy 4 | Surgical edits, tight explores, quick verifications — the fastest hand |
| `claude-haiku-4-5` | Claude | 3 | 4 | 200k | $1 / $5 | Cheap Claude hand: bounded edits, verifications |
| `gpt-5.4-mini` | Codex | 2 | 4 | 272k | economy **5** | Cheap bulk sweeps, mechanical propagation |
| `claude-sonnet-5` | Claude | 4 | 3 | **1M** | $3 / $15 | Skilled hand: near-Opus coding at Sonnet cost, big-window slices |
| `gpt-5.4` | Codex | 4 | 3 | 272k / 1M* | economy 3 | Skilled Codex hand: large-context work needing real intelligence |
| `claude-opus-4-8` | Claude | **5** | 3 | **1M** | $5 / $25 | Orchestrator role; long-horizon coordination |
| `gpt-5.5` | Codex | **5** | 3 | 272k | economy 2 | Oracle role; hard reasoning, architecture, cross-family gate judgments |

\* `gpt-5.4`'s 1M window is advertised, not confirmed on every account — verify
before depending on it (carried over from codex-orchestrator).

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
  **(c) escalate** to a 1M-window model. Prefer (a)/(b) with the cheap hands:
  five precise spark/haiku edits usually beat one Sonnet pass — the orchestrator
  already did the reading.

## Routing decision

1. **Needs real reasoning** (design, ambiguous tradeoff, subtle root-cause)? → the
   oracle, or keep it on the orchestrator. Never send genuine reasoning to `mini`.
2. **Precise, well-specified edit or narrow check**, working set **< ~75k**? →
   `gpt-5.3-codex-spark` (fastest) or `claude-haiku-4-5` (< ~120k). The default
   workhorses for changes already designed.
3. **Broad, low-reasoning sweep** (read many files, list usages, gather evidence)
   fitting in 272k? → `gpt-5.4-mini` (cheapest), or spark if tight and speed matters.
4. **Harder slice needing real skill** (tricky edit, delegated judgment inside a
   bounded scope, or only 1M holds it)? → `claude-sonnet-5` (default skilled hand)
   or `gpt-5.4` when a Codex-side worker is preferable.

Tie-break: **cheapest and fastest model that clears the context bar wins.** Climb
the intelligence axis only when the task actually needs it. Within a tier, family
is a secondary criterion: prefer the family the host spawns natively (no bridge
overhead), and prefer crossing families only where it buys something — the oracle
gate.

## Worker prompt (model-scoped)

Give every worker its files, its edit, its check — never open-ended discovery on a
small model.

```text
Model: <slug + reasoning/effort setting>. Chosen because: <ctx fit / speed / cost>.
Working set (already located by orchestrator): <exact files/paths/line ranges>.
Task: <one precise edit or check>.
Do NOT: read beyond the working set, refactor adjacent code, or expand scope.
Success check: <exact command/observation that proves it done>.
Return: files changed, check result, anything that didn't fit — do not keep going.
```

## Token/latency economy

- Reading is the orchestrator's job; workers almost never explore from scratch on a
  big model. Pre-fetched context = smaller, cheaper, faster workers.
- Parallelize independent cheap workers instead of one serial skilled-hand pass.
- Match reasoning depth to the task: low effort for mechanical edits, reserve
  `high`/`xhigh` (GPT) or high effort (Claude) for the genuinely hard slice.
- Both families cache aggressively, but **cache does not cross families**: a
  cross-family handoff re-reads everything cold. Keep a slice's iterations within
  one family; cross only at role boundaries (oracle gates).
- Every escalation to Sonnet 5 / gpt-5.4 or oracle call to gpt-5.5 should have a
  reason you could state out loud. If you can't, a split of spark/haiku/mini
  workers is the cheaper answer.
