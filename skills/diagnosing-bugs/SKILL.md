---
name: diagnosing-bugs
description: Investigate a bug or performance regression using a reproducible symptom, testable hypotheses and checks matched to the fix.
---

# Diagnose a bug

Trace the reported symptom through the actual callers and available logs. Read the relevant domain contracts and recent changes. Build the smallest practical check that can detect this symptom: a test, request, CLI invocation, UI flow or replay.

- Make hypotheses falsifiable and test the cheapest discriminating observation first. Read-only investigation can continue while access or a full reproducer is missing; distinguish a suspected cause from a confirmed one.
- For intermittent failures, record the trigger and reproduction rate before and after. For performance, establish a baseline under comparable conditions before optimizing.
- Fix where affected callers share the cause. A regression check must exercise the reported behavior, not merely the new helper or the absence of an exception.
- Use targeted, identifiable instrumentation and remove it afterward. If reproduction requires manual interaction, adapt [the capture template](scripts/hitl-loop.template.sh); use a non-production environment unless separately authorized.
- Re-run the original scenario after the fix and the focused regression check. Report the confirmed cause, observed result and remaining validation limits. If no suitable check is possible, state that limitation instead of inventing proof.
