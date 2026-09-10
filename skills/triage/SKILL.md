---
name: triage
description: Assess issues or external pull requests, verify their claims and prepare an actionable next state or implementation brief.
disable-model-invocation: true
---

# Triage

Read the project's tracker conventions and existing labels. For an item, inspect its full request, replies and prior triage notes; for a PR, include the diff. Resolve whether a supplied identifier names an issue or PR before acting.

- Check whether the requested behavior already exists and whether a prior scope decision applies. Reproduce bug claims or inspect the relevant code before labeling them confirmed.
- Separate the category from the workflow state. Use existing equivalents of needs-triage, needs-info, ready-for-agent, ready-for-human or wontfix; these names are examples, not labels to create automatically.
- Carry forward resolved questions. Ask only for information that prevents a reliable next step. Use the existing grilling skill when a design interview is actually requested.
- An explicit state-change request authorizes that state change, not unrelated comments, closures or implementation. For read-only triage, report the recommended state and evidence. Apply authorized tracker changes and verify them without redundant confirmation.

For a ready item, use [AGENT-BRIEF.md](AGENT-BRIEF.md) to describe behavior, acceptance criteria and scope. If information is missing, state what is known and the specific question that blocks work.

If the project keeps a rejection knowledge base, use [OUT-OF-SCOPE.md](OUT-OF-SCOPE.md) when recording an authorized rejection. Already-implemented behavior is not a rejected feature. Preserve unrelated labels and do not create extra documentation machinery by default.
