---
name: tdd
description: Implement a requested test-first workflow through observable behavior, one failing test and one working change at a time.
---

# Test-first development

Use the agreed behavior and public contract; infer routine details from the repository instead of requiring another approval of an already authorized task. Identify a test boundary that reaches the real behavior and reuse the existing runner.

1. Write one meaningful failing test and run it. Confirm the failure is the expected missing behavior, not broken setup.
2. Make the smallest implementation that passes it and run the test again.
3. Repeat for the next behavior; avoid writing an entire imagined test suite ahead of the implementation.
4. Refactor only where the working change reveals a concrete need, keeping the tests green.

Test outcomes through the real contract rather than internal method names or call counts. Mock external boundaries when isolation is needed; do not replace the behavior being tested. Run the relevant broader checks after integrating the change and report what actually ran.

References, when needed: [test examples](tests.md), [boundary mocking](mocking.md), [refactoring criteria](refactoring.md).
