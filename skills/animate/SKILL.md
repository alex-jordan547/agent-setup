---
name: animate
description: Build, review, or audit web animations and suggest useful motion. Use animate-expo for React Native and Expo.
---

# Web animation

Match the request: implement when asked to build, report findings when asked to review, and suggest opportunities without editing when asked for ideas.

- Start with the interaction's purpose, frequency and existing motion tokens. Frequent actions should stay responsive; decorative motion should not delay access to content.
- Reuse the project's components and animation tools. CSS transitions usually cover state changes; use the installed motion library or platform APIs when gestures, exits or layout need them.
- Prefer transform and opacity when they fit the visual result. Measure layout/paint-heavy effects instead of assuming a property or library guarantees acceleration.
- Preserve the current position and velocity when an interaction is interrupted. Anchor a popover to its trigger; keep navigation and dismissal direction coherent.
- Treat durations, easing and spring settings as tunable starting points. Use the project's tokens before introducing new values.
- Include reduced-motion behavior, keyboard access, focus handling and hover gating. An instant state change is a valid reduced-motion treatment; decorative copies must not duplicate accessible controls.

## References

Load only what the task needs:

- [RECIPES.md](RECIPES.md): examples for a specific component, including optional easing values.
- [Gesture details](references/INTERACTION.md): velocity handoff, boundaries and interruption.
- [Review and opportunities](references/REVIEW.md): focused diff reviews, whole-interface audits or missing feedback.
- [Vocabulary](references/VOCABULARY.md): names for effects described informally.

Check repeated activation, mid-flight reversal and reduced motion in the real browser. Distinguish code review from observed runtime behavior; name anything not exercised. For audit-only work, report the relevant location, user impact and proposed fix rather than implementing it.
