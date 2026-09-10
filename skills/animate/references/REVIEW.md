# Motion reviews and opportunities

Use for a diff review, an interface audit or a request for missing motion. For native work, apply the criteria to native gestures and runtimes rather than copying CSS advice.

## Scope and evidence

Identify the affected surfaces, stack, existing tokens and how often the interaction occurs. Read-only review and opportunity requests produce findings, not edits. An inspection of source code cannot establish frame rate, haptic timing or gesture feel.

## Evaluate

- Purpose: does motion explain feedback, location or state? Is decoration proportionate to the frequency and context?
- Responsiveness: does content remain accessible while movement plays? Are repeated actions or reversals delayed?
- Continuity: does a new gesture pick up from the visible position, carry velocity and cancel cleanly?
- Semantics: are trigger origin, entry/exit direction and navigation behavior coherent?
- Accessibility: is reduced motion respected, including an instant result where appropriate? Are keyboard access, focus, text scaling and non-gesture alternatives preserved?
- Cost: do traces or device observations support a performance claim? Check layout, paint, frame callbacks and unnecessary runtime crossings where relevant.

For opportunities, look for missing press feedback, abrupt state changes, loss of spatial context or a gesture that stops unnaturally. Reuse existing behavior when it already communicates the state; do not propose motion merely to fill a list.

## Report

For each useful finding, give the location, triggering interaction, observed or code-supported consequence, and proposed correction. Rank by user impact and distinguish verified defects from feel checks still needed.

If an implementation plan is requested, include the affected component, existing tokens to reuse, intended states and verification scenario. Include exact values only when they are established by the design or measurements; label proposed tuning values as such. A reviewer should be able to report no findings without inventing cosmetic work.
