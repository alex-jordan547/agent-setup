---
name: code-review
description: Review a branch, pull request or working changes against the requested behavior and repository conventions, with concrete evidence for defects.
---

# Code review

Pin the actual review scope before inspecting it. Use the supplied base; otherwise infer it from the PR or repository and state it. For committed work compare from the merge-base. For working changes include the relevant staged, unstaged and untracked files; an empty committed diff does not mean an empty working tree.

Read the originating request/spec when available and the repository's review instructions. A missing spec limits the conformance assessment but does not block reviewing observable defects. Use a repository graph if required, then confirm its leads in current callers and tests.

Review for:

- missing or incorrect requested behavior;
- regressions in callers, state transitions, error handling and data contracts;
- authorization, validation, privacy and data-loss risks at affected boundaries;
- tests that exercise the actual changed behavior, with gaps distinguished from confirmed bugs;
- documented conventions, without reporting formatting already enforced by tooling.

For each finding, identify the trigger, affected behavior, precise location and consequence. Verify it in the current code or with a focused check. Label uncertainty; omit speculative style complaints and unrelated refactors.

Rank findings by impact. Separate correctness defects from missing validation or conformance uncertainty. Report no findings when none are supported, together with the scope and checks performed. Review alone does not authorize edits or publication. Delegate only when authorized and genuinely useful for independent areas.
