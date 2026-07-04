---
name: codex-orchestrator
description: "Codex-only orchestrator that routes each delegated task to the cheapest/fastest model whose context window can hold it. The main thread does the research and prep, then spawns worker threads (create_thread with a per-worker model override) for bounded edits, explores, and verifications — writing almost no code itself. Optimizes for best result, lowest latency, fewest tokens."
---

# Codex Orchestrator

A model-aware orchestrator for the Codex App. Same main thread as coordinator;
delegation happens through **worker threads** (`create_thread`) each pinned to a
**deliberately chosen model**. The orchestrator does the thinking and hand-off
prep; workers do the mechanical work.

For the full supervision protocol (heartbeats, waiting policy, review, confidence
labels) see `~/.agents/skills/thread-orchestrator/SKILL.md`. This skill adds one
thing on top: **which model to send, sized to its context window.**

## Core rule

The orchestrator writes almost no code. For anything non-trivial it does the
research, reads the code, decides the exact change, then spawns workers to apply
narrow, pre-digested slices. A worker should receive a task it can finish inside
its context window in one pass — never a vague "figure this out and fix it".

Delegation mechanism: `create_thread` with `model` + `thinking` overrides. The
native in-turn subagents (`multi_agent_v2`) are disabled here (HTTP 400,
openai/codex#26753) — do not rely on them; use worker threads.

## Model table

Scores 1–5 (5 = best on that axis). Context is the hard constraint; the rest are
preferences. Numbers are grounded in the Codex model list; scores are a starting
calibration — tune from real runs.

| Model | Intelligence | Speed | Context (ctx / max) | Token economy | Best for |
|---|---|---|---|---|---|
| `gpt-5.3-codex-spark` | 3 | **5** | 128k / 128k | 4 | Surgical edits, tight bounded explores, quick verifications |
| `gpt-5.4-mini` | 2 | 4 | 272k / 272k | **5** | Cheap bulk work, medium explorations, simple mechanical tasks |
| `gpt-5.4` | 4 | 3 | 272k / **1M** | 3 | Large-context work needing real intelligence (huge explore + synthesis, big refactor read) |
| `gpt-5.5` | **5** | 3 | 272k / 272k | 2 | Hard reasoning, architecture, tricky diagnosis, ambiguous synthesis (or keep on the orchestrator itself) |

`codex-auto-review` is a review-only model — not a delegation target.

## Context budgeting (the routing constraint)

Estimate the task's working set: files the worker must read + instructions +
expected output. Route to a model whose **effective window (~95% of max)** holds
that with headroom.

- Target **< 60%** window utilization for the whole task. Above that, mid-task
  auto-compaction kicks in — the worker loses state, re-reads, and burns tokens
  and time. This is exactly the spark failure mode: a 128k model handed a task
  that needs 150k of reads compacts repeatedly and gets slow and dumb.
- If a task exceeds a model's budget, do one of: **(a) shrink it** (the
  orchestrator reads/greps first and passes only the relevant slice), **(b) split
  it** into several bounded workers, or **(c) escalate** to a bigger-context model.
- Prefer (a)/(b) with `spark`/`mini` over (c). Splitting a big job into five
  precise spark edits is usually faster and cheaper than one `gpt-5.4` pass — and
  the orchestrator already did the reading.

## Routing decision

1. **Does it need real reasoning** (design, ambiguous tradeoff, root-causing a
   subtle bug)? → do it on the orchestrator, or delegate to `gpt-5.5`. Never send
   genuine reasoning to `mini`.
2. **Is it a precise, well-specified edit or a narrow check**, and does its
   working set fit **< ~90k**? → `gpt-5.3-codex-spark`. This is the default
   workhorse for applying changes the orchestrator already designed.
3. **Is it a broad, low-reasoning sweep** (read many files, list usages, gather
   evidence) that fits in 272k? → `gpt-5.4-mini` (cheapest) — or `spark` if it's
   tight and speed matters.
4. **Does it genuinely need a huge context window** (a working set only 1M can
   hold) **and** some intelligence? → `gpt-5.4`. Use sparingly; it's the
   escalation, not the default.

Tie-break order: **cheapest and fastest model that clears the context bar wins.**
Only climb the intelligence axis when the task actually needs it.

## Complex-task pattern

When the task is hard, the orchestrator front-loads the work so workers stay cheap:

1. Do all the research itself: read the code, grep the surface, reproduce the bug,
   decide the exact diffs and the verification steps.
2. Split the change into narrow, independent slices.
3. Spawn several `spark` workers in parallel — one per slice — each with the exact
   files, the exact edit, and a concrete success check. Small enough to never
   compact.
4. Optionally spawn a `mini`/`spark` worker to verify (run tests, re-read, confirm)
   rather than trusting worker self-reports.
5. Integrate, judge, iterate. Escalate a slice to `gpt-5.5`/`gpt-5.4` only if a
   worker stalls or the slice turns out to need reasoning.

## Worker prompt (model-scoped)

Give every worker its files, its edit, its check — never open-ended discovery on a
small model.

```text
Model: <chosen slug + reasoning>. Chosen because: <ctx fit / speed / cost>.
Working set (already located by orchestrator): <exact files/paths/line ranges>.
Task: <one precise edit or check>.
Do NOT: read beyond the working set, refactor adjacent code, or expand scope.
Success check: <exact command/observation that proves it done>.
Return: files changed, check result, anything that didn't fit — do not keep going.
```

## Token/latency economy

- Reading is the orchestrator's job; workers should almost never explore from
  scratch on a big model. Pre-fetched context = smaller, cheaper, faster workers.
- Parallelize independent spark workers instead of one serial big-model pass.
- Match reasoning effort to the task: `low`/`medium` for mechanical edits, reserve
  `high`/`xhigh` for the genuinely hard slice.
- Every escalation to `gpt-5.4`/`gpt-5.5` should have a reason you could state out
  loud. If you can't, a split of `spark`/`mini` workers is the cheaper answer.
