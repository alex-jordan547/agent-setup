---
name: codex-orchestrator
description: "Route explicitly requested Codex subagent or parallel-agent work across native roles and a small named-agent roster. Use when the user asks to delegate, spawn subagents, parallelize independent work, choose a subagent model, or explicitly invokes this skill. Do not trigger merely because delegation might be useful."
---

# Codex Orchestrator

Coordinate delegated work without turning the agent catalog into a model matrix.
Delegate only when the user explicitly requests subagents or another active instruction
requires them.

## Choose a role

Prefer native roles for ordinary work:

| Role | Use |
|---|---|
| `explorer` | Focused read-only codebase questions |
| `worker` | General implementation with explicit file ownership |
| `default` | Work that does not fit a narrower role |

Use named agents only for specialized behavior:

| Agent | Model | Use |
|---|---|---|
| `scout` | `gpt-5.6-luna` medium | Broad, cost-efficient evidence gathering |
| `editor_fast` | `gpt-5.3-codex-spark` medium | One small, pre-designed edit |
| `reviewer` | `gpt-5.6-sol` high | Final diff and end-to-end review |
| `verifier` | `gpt-5.3-codex-spark` low | Exact independent checks |

For exceptional architecture or conflict judgment, use `default` with
`gpt-5.6-sol` and `xhigh` reasoning. Pass a compact brief and source pointers instead
of copying a lossy conclusion.

## Route by task shape

- Use Luna for broad, low-risk evidence collection where efficiency matters.
- Use Spark for bounded edits and exact checks where speed matters.
- Use Terra through a native role for normal implementation and exploration.
- Use Sol for ambiguous reasoning, high-impact review, or cross-cutting coherence.
- Split only when workstreams are genuinely independent. Keep dependent work sequential.

Do not create model-specific role variants. Update the model behind a stable role when
the preferred model changes.

## Brief each agent

Give every agent:

- one concrete objective;
- explicit file or responsibility ownership;
- relevant source pointers and constraints;
- the exact success check or expected evidence;
- a clear stop condition for missing scope or mismatched assumptions.

Tell editing agents that they are not alone in the workspace, must preserve unrelated
changes, and must not revert other agents' work.

When selecting a different model or reasoning effort, do not use a full-history fork;
pass only the minimum recent turns or no conversation history plus a self-contained brief.

## Supervise and integrate

- Wait on the returned agent identifier and reuse the same agent for related follow-up.
- Steer only for new context, a wrong brief, a blocker, or a reported mismatch.
- Treat agent output as evidence, not proof of completion.
- Re-read changed files and run claim-matched verification before reporting success.
- Aggregate results centrally and surface conflicts instead of letting agents resolve them silently.
