---
name: to-tickets
description: Split a plan or specification into independently verifiable tickets with explicit blocking dependencies.
disable-model-invocation: true
---

# Specification to tickets

Read the source plan and relevant code. Check for existing tickets before creating duplicates. Preserve agreed decisions and use the project's domain vocabulary.

Each ticket should deliver a bounded behavior with observable acceptance criteria and only the dependencies that truly block it. Prefer a complete path across the necessary layers, not separate schema/API/UI tickets that cannot be verified alone.

For a broad contract migration that cannot land in independent slices, use expand, migrate callers, then contract. Identify shared integration branches or coordinated deployment requirements explicitly instead of promising that incompatible intermediate states work alone.

Use the project's ticket template, or include:

- title and source spec;
- behavior delivered and scope limits;
- acceptance criteria and verification;
- blocking tickets, or none.

Use the requested tracker or local document. When publication is authorized, create blockers first, use their returned identifiers for native dependency links where supported, and verify the resulting items and links. Otherwise provide the proposed tickets locally. Do not close or modify a parent issue unless requested. Ask only about unresolved scope or dependencies, not for another approval of a settled breakdown.
