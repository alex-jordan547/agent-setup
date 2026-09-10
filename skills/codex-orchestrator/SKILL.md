---
name: codex-orchestrator
description: Coordinate explicitly requested Codex subagents with bounded ownership, compact briefs and verified integration.
---

# Codex orchestration

Delegate when the user requests it or the active instructions authorize it. Split independent work; keep dependent steps sequential.

Use roles actually exposed by the current runtime. Read-only exploration, implementation and verification need different permissions, not separate model catalogs. Select named agents and models from the current configuration or available tool schema rather than a remembered matrix.

Give each agent one objective, relevant source pointers, explicit file/responsibility ownership, success checks and a stop condition. Editing agents must preserve other contributors' work. Use isolated worktrees when concurrent edits overlap; do not fork full history solely to change a model.

The primary agent owns integration and any authorized branch/commit/PR lifecycle unless explicitly delegated. Subtasks do not inherit permission to publish. Pass enough context to reproduce the task without copying unrelated conversation history.

Wait on returned agent identifiers, reuse agents for related follow-up and steer on new evidence or blockers. Reconcile changes, inspect the combined diff and run checks against the integrated result. An agent's completion message is evidence to inspect, not proof that the combined work passes.
