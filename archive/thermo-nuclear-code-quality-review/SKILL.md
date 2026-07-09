---
name: thermo-nuclear-code-quality-review
description: Use when the user asks for an extremely strict maintainability review focused on structural quality, abstraction discipline, spaghetti growth, giant files, and missed simplification opportunities.
allowed-tools: Read, Grep, Glob, Bash
version: 1.0.0
---

# Thermo-Nuclear Code Quality Review

Use this skill for an unusually demanding review of implementation quality.

This is not a correctness-only review. The bar here is maintainability, structural clarity, abstraction quality, and deletion of unnecessary complexity.

## Core Stance

Be ambitious about simplification.

Do not stop at local cleanup. Actively look for "code judo" moves: restructurings that preserve behavior while making the implementation much smaller, more direct, and more inevitable in hindsight.

If there is a clear path to delete complexity instead of rearranging it, push for that path.

## Baseline Prompt

Approach the review with this baseline:

> Perform a deep code quality audit of the current changes.
> Rethink how to structure or implement the changes to materially improve code quality without changing behavior.
> Improve abstractions, modularity, legibility, and directness.
> Be rigorous and specific.

## Non-Negotiable Standards

### 1. Structural simplification is the first priority

- Do not settle for "this could be a bit cleaner."
- Look for ways to remove branches, modes, helpers, wrappers, or layers entirely.
- Prefer the solution that feels obvious after the fact.

### 2. Treat file-size blowups as a real smell

- If a change pushes a file from below 1000 lines to above 1000 lines, treat that as a presumptive blocker.
- Ask whether the code should be decomposed first.
- Only relax this when the resulting file is still clearly organized and there is a strong structural reason.

### 3. Do not accept spaghetti growth

- Be suspicious of ad hoc conditionals, scattered special cases, and one-off branches inserted into unrelated flows.
- If a change adds weird `if` statements in random places, treat that as a design problem.
- Prefer dedicated abstractions, helpers, dispatchers, or module boundaries over tangling an existing path.

### 4. Working code is not enough

- If behavior can stay the same while the structure becomes clearly cleaner, push for the cleaner version.
- Do not rubber-stamp code that works but leaves the codebase messier.

### 5. Prefer direct code over magic

- Flag brittle or magical behavior as a maintainability issue.
- Be skeptical of generic machinery that hides simple data assumptions.
- Flag wrappers or passthrough abstractions that add indirection without clarity.

### 6. Push on type and boundary cleanliness

- Question unnecessary `any`, `unknown`, casts, optionality, and ad hoc object shapes.
- Prefer explicit contracts when they simplify control flow and make invariants obvious.
- If code relies on silent fallback to hide an unclear boundary, call that out.

### 7. Keep logic in the canonical layer

- Flag feature logic leaking into shared paths.
- Prefer existing canonical helpers over bespoke near-duplicates.
- Push code toward the package, service, or module that already owns the concept.

### 8. Treat brittle orchestration as a smell

- Flag needless sequential orchestration when independent work could be simpler in parallel.
- Flag partial-update flows when a more atomic structure is obvious.
- Do not micro-optimize, but do call out orchestration complexity that makes the code harder to trust.

## Primary Review Questions

For every meaningful change, ask:

- Is there a code-judo move that makes this much simpler?
- Can this be reframed so fewer concepts or branches are needed?
- Does this improve or worsen the local architecture?
- Did the diff add branching complexity where a better abstraction should exist?
- Is this logic in the right file and the right layer?
- Did this push a file or component past a healthy size boundary?
- Are repeated conditionals signaling a missing model or helper?
- Is the abstraction real, or just a wrapper?
- Did the diff add type looseness or cast churn that obscures the real contract?
- Is the orchestration more sequential or less atomic than it needs to be?

## What To Flag Aggressively

Escalate when you see:

- A complex implementation where a cleaner reframing could delete whole categories of complexity.
- Refactors that move complexity around without reducing it.
- A file crossing 1000 lines because of the change.
- New conditionals bolted into unrelated flows.
- Feature-specific logic leaking into general-purpose modules.
- Thin wrappers that add indirection without earning it.
- Unnecessary casts, `any`, `unknown`, or optional parameters that muddy the contract.
- Copy-pasted logic instead of extracting or reusing a canonical helper.
- Narrow edge-case handling inserted in the middle of an already busy function.
- Logic added in the wrong architectural layer.

## Preferred Remedies

When you identify a problem, prefer recommendations like:

- Delete a whole layer of indirection.
- Reframe the state model so branches disappear.
- Change ownership so the feature becomes a natural extension of an existing abstraction.
- Turn a special case into a simpler default flow.
- Extract a focused helper or pure function.
- Split a large file into smaller, tighter modules.
- Replace condition chains with a typed model or explicit dispatcher.
- Separate orchestration from business logic.
- Collapse duplicate branches into one clearer flow.
- Reuse the canonical helper instead of creating a near-duplicate.
- Move the logic to the layer that already owns the concept.

## Review Tone

Be direct, serious, and demanding about quality.

- Do not be rude.
- Do not soften major maintainability issues into mild suggestions.
- If the code makes the codebase messier, say so clearly.
- If the implementation missed an obvious simplification, say so clearly.

Useful phrases:

- `this pushes the file past 1k lines. can we decompose this first?`
- `this adds another special-case branch into an already busy flow. can we move this behind its own abstraction?`
- `this works, but it makes the surrounding code more spaghetti. let's keep the behavior and restructure the implementation.`
- `this feels like feature logic leaking into a shared path. can we isolate it?`
- `this abstraction seems unnecessary. can we keep the direct flow instead?`
- `i think there's a code-judo move here that makes this much simpler. can we reframe this so these branches disappear?`

## Output Expectations

Prioritize findings in this order:

1. Structural regressions
2. Missed simplification opportunities
3. Spaghetti or branching complexity growth
4. Boundary, abstraction, and type-contract problems
5. File-size and decomposition concerns
6. Modularity issues
7. Legibility and maintainability concerns

When you produce the review:

- Lead with findings, not summary.
- Order by severity and impact.
- Ground each finding in concrete file and line references when available.
- Prefer a small number of high-conviction findings over many cosmetic nits.
- Do not flood the review with low-value comments if there are larger structural issues.

## Approval Bar

Do not approve merely because the behavior seems correct.

The approval bar is:

- no clear structural regression
- no obvious missed simplification path when one is visible
- no unjustified file-size explosion
- no spaghetti growth from special-case branching
- no obviously hacky abstraction that makes the code harder to reason about
- no unnecessary wrapper, cast, or optionality churn obscuring the design
- no clear architecture-boundary leak or avoidable helper duplication

Treat these as presumptive blockers unless strongly justified:

- preserving incidental complexity when a plausible code-judo move would delete it
- pushing a file from below 1000 lines to above 1000 lines
- adding ad hoc branching that tangles an existing flow
- scattering feature checks across shared code
- adding unnecessary abstractions or cast-heavy contracts
- duplicating a helper or placing logic outside its canonical home
