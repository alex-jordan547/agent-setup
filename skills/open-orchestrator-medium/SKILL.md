---
name: open-orchestrator-medium
description: "Open-models orchestrator, medium tier: GLM-5.2 as both orchestrator (coordinates, holds the plan, spawns workers) and oracle (validates at gates in a fresh instance with its own tools), with mimo-v2.5-pro/deepseek-v4-pro as skilled hands and mimo-v2.5/deepseek-v4-flash as cheap hands. Routes each task to the cheapest model whose context window can hold it. The orchestrator writes almost no code; it delegates pre-digested slices. Optimizes for reliability of coordination at moderate cost."
---

# Open Orchestrator — Medium Tier

A model-aware orchestrator for open-weight models (Command Code `cmd/*` slugs).
The main thread coordinates; delegation happens through **workers**, each pinned to
a **deliberately chosen model**. The orchestrator thinks and hands off; workers do
the mechanical work.

**Delegation mechanism is environment-agnostic.** Use whatever spawn primitive the
host exposes — worker threads, a subagent/Task tool with a `model` parameter, named
agents — and embed the scope rules from this skill in each worker's prompt. What is
fixed here is the **role structure and the routing**, not the API.

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

## Three roles (two held by the same model)

| Role | Model | Job |
|---|---|---|
| **Oracle** | `cmd/zai-org/GLM-5.2` (fresh instance) | Plans (with the user) and validates at gates. Investigates **with its own tools** — reads the real files, runs checks first-hand. Same model as the orchestrator, but spawned as a **separate worker with a clean context**: the point of a gate is a look uncontaminated by the orchestrator's accumulated assumptions. |
| **Orchestrator** | `cmd/zai-org/GLM-5.2` | Holds the plan, coordinates, spawns and supervises workers, integrates. Best-in-class policy following (Tau2 leader) is exactly the orchestrator's job. Its 1M window is **headroom**, not a warehouse — the plan pre-digests the work so it stays far from full. |
| **Hands** | skilled: `cmd/xiaomi/mimo-v2.5-pro` / `cmd/deepseek/deepseek-v4-pro` · cheap: `cmd/xiaomi/mimo-v2.5` / `cmd/deepseek/deepseek-v4-flash` | Bounded edits, explores, verifications. One precise task each, sized to fit its window in one pass. Within a pair, pick by window: mimo variants 400K, deepseek variants 1M — same price inside each pair. |

The orchestrator writes almost no code. It does prep, then delegates narrow,
pre-located slices. **GLM-5.2 is the expensive model here** (full price, cache reads
~90× the hands') — the more it delegates instead of reading and editing itself, the
more this tier's economics work.

**Pre-flight measurement (mandatory before routing).** Size is a measurement,
not a judgment — never pick by instinct:

```bash
rg --files <zone> | wc -l                   # file count
rg --files <zone> | xargs wc -l | tail -1   # total lines
rg -l "<symbol>" | wc -l                    # fan-out
```

Rough budget: `lines × ~10 tokens/line` vs the model's window, target < 60%. Fits
under ~240k → a mimo variant; bigger → split into N fitting slices (preferred) or
route to a deepseek variant (1M).

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

Call the oracle (a **fresh** GLM-5.2 instance, own tools) at **deterministic
gates**, plus orchestrator discretion on top — never discretion alone. Do not
self-validate in the orchestrator's own context: it would grade its own homework
with the very assumptions being tested.

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

Cost discipline: each oracle call is a full-price GLM-5.2 investigation. Don't gate
every micro-step; reserve gates for coherence, plan sanity, conflicts, and
irreversibility. Feed it a tight brief and exact file paths so its own
investigation stays short.

## Model table

Scores 1–5 (5 = best). Context is the hard constraint; the rest are preferences.
Prices are per 1M tokens after the permanent Command Code discounts; scores are a
starting calibration — tune from real runs.

| Model | Intelligence | Speed | Context | In / Out / Cache read | Best for |
|---|---|---|---|---|---|
| `cmd/xiaomi/mimo-v2.5` | 3 | 4 | 400K | $0.14 / $0.28 / $0.0028 | Cheap hand: surgical edits, bounded explores, verifications |
| `cmd/deepseek/deepseek-v4-flash` | 3 | 4 | **1M** | $0.14 / $0.28 / $0.0028 | Cheap hand with a big window: broad sweeps |
| `cmd/xiaomi/mimo-v2.5-pro` | 4 | 3 | 400K | $0.435 / $0.87 / $0.0036 | Skilled hand: harder slices, token-efficient agentic work |
| `cmd/deepseek/deepseek-v4-pro` | **5** | 3 | **1M** | $0.435 / $0.87 / $0.0036 | Skilled hand: big non-splittable slices, delegated judgment |
| `cmd/zai-org/GLM-5.2` | **5** | 3 | **1M** | $1.40 / $4.40 / $0.26 | Orchestrator + oracle — coordination and gate judgments, never bulk work |

## Context budgeting (the routing constraint)

Estimate the task's working set: files the worker must read + instructions +
expected output. Route to a model whose **effective window (~95% of max)** holds it
with headroom.

- Target **< 60%** window utilization per task. Above that, mid-task auto-compaction
  kicks in — the worker loses state, re-reads, burns tokens and time. That's the
  failure mode: a 400K model handed a 500K task compacts repeatedly and gets slow
  and dumb.
- If a task exceeds a model's budget: **(a) shrink it** (orchestrator greps/reads
  first, passes only the relevant slice), **(b) split it** into bounded workers, or
  **(c) escalate** to a 1M-window model. Prefer (a)/(b): five precise mimo edits
  usually beat one big-model pass — the orchestrator already did the reading.

## Routing decision

1. **Needs real reasoning** (design, ambiguous tradeoff, subtle root-cause)? → the
   oracle, or keep it on the orchestrator. Never send genuine reasoning to the
   cheap hands.
2. **Precise, well-specified edit or narrow check**, working set **< ~240k**? →
   `mimo-v2.5`. The default workhorse for changes already designed.
3. **Broad, low-reasoning sweep** (read many files, list usages, gather evidence)
   needing more than 400K? → `deepseek-v4-flash` — same price, 1M window.
4. **Harder slice needing real skill** (tricky edit, judgment inside a bounded
   scope)? → `mimo-v2.5-pro` if it fits 400K, `deepseek-v4-pro` if only 1M holds it
   or the reasoning is frontier-hard.

Tie-break: **cheapest model that clears the context bar wins.** Climb the
intelligence axis only when the task actually needs it.

## Worker prompt (model-scoped)

Give every worker its files, its edit, its check — never open-ended discovery on a
small model.

```text
Model: <slug>. Chosen because: <ctx fit / cost>.
Working set (already located by orchestrator): <exact files/paths/line ranges>.
Task: <one precise edit or check>.
Do NOT: read beyond the working set, refactor adjacent code, or expand scope.
Success check: <exact command/observation that proves it done>.
Return: files changed, check result, anything that didn't fit — do not keep going.
```

## Token/latency economy

- Reading is the orchestrator's job only for thin slices; anything bulky goes to a
  cheap hand first, which returns a digest. GLM-5.2 tokens are the budget's main
  line item — spend them on coordination and judgment, not on file dumps.
- Parallelize independent cheap workers instead of one serial big-model pass.
- Cache reads are near-free on all four hands — long supervision loops cost almost
  nothing. GLM-5.2's cache read ($0.26/M) is ~90× the hands': keep the
  orchestrator's context lean and the oracle's briefs tight.
- Every escalation to `deepseek-v4-pro` or extra oracle call should have a reason
  you could state out loud. If you can't, a split of mimo/flash workers is the
  cheaper answer.
