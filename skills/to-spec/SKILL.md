---
name: to-spec
description: Turn the agreed conversation into a concise specification with observable acceptance criteria and explicit scope.
disable-model-invocation: true
---

# Conversation to specification

Synthesize what is already decided. Check the relevant code and existing domain terms; ask only about a gap that would materially change the result. Distinguish agreed decisions, reasonable assumptions and unresolved choices.

Use the project's spec format when present. Otherwise cover:

- the user's problem and desired behavior;
- contracts or decisions needed to implement it;
- acceptance criteria and how to verify them;
- scope exclusions and unresolved decisions.

Scale detail to the work. Use examples or a prototype's small decision-bearing snippet when they clarify a contract; avoid exhaustive user stories and speculative implementation plans.

Use the requested destination and existing tracker conventions. If publication is authorized, publish without another routine confirmation and verify the returned item. Otherwise provide the spec or save it in the project's established documentation location. Do not invent labels or require a separate setup skill.
