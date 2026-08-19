<!-- Managed by agent-setup (scripts/sync.sh). Source of truth: repo root CURSOR.md.
     Do not edit the synced copy (~/.cursor/CURSOR.md) — the next sync overwrites it
     after backing up the old file to <path>.bak-<timestamp>. -->

# Agent Guidelines

Behavioral guidelines to reduce common LLM coding mistakes, derived from [Andrej Karpathy's observations](https://x.com/karpathy/status/2015883857489522876) on LLM coding pitfalls.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

## Operating Principles

- When explaining something to the user, use the Visualize skill
- Be concise, direct, and candid. Challenge weak assumptions and distinguish verified facts from uncertainty
- Ground research in authoritative, current sources and link important evidence
- Preserve the original goal and constraints; finish authorized work end to end and verify the actual result before claiming completion
- Ask questions only when a decision is materially ambiguous, risky, or requires approval
- Use relevant skills; spawn subagents only for genuinely independent work and synthesize their findings
- Keep changes focused and simple. Avoid unrelated edits, unnecessary abstractions, and low-signal tests
- Test observable behavior, review substantial changes, and validate user-facing work in the real interface when applicable
- Preserve unrelated work and never take destructive, production, or external actions beyond what the user authorized
- Report meaningful blockers, outcomes, and evidence without noisy progress
