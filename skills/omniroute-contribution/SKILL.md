---
name: omniroute-contribution
description: Safely plan, implement, validate, and publish contributions to diegosouzapw/OmniRoute. Use for every OmniRoute contribution task that may inspect or change code, create or update a branch, commit, push, add a changelog fragment, open or update a pull request, or mark a PR ready for review. Trigger again at the start of each new PR or independently publishable task, even within the same conversation.
---

# OmniRoute Contribution

Treat the current repository as the source of truth. Never reuse a remembered contribution workflow
without refreshing it for the current PR.

## Start every contribution task

1. Run `scripts/contribution_preflight.sh start` from the OmniRoute worktree.
2. Read these files completely from the current active release context before planning or editing:
   - root `AGENTS.md` and every `AGENTS.md` governing directories in scope;
   - `CONTRIBUTING.md`;
   - `docs/dev/CONTRIBUTION_GOLDEN_PATH.md`;
   - `docs/ops/BRANCHING_MODEL.md`;
   - `changelog.d/README.md`;
   - `.github/pull_request_template.md`.
3. Read the area-specific architecture, security, or contributor documents linked by those files.
4. Verify the highest active `release/v*` branch and check for an open `release-freeze` marker using
   live GitHub state. Do not infer either from package versions or memory.
5. Classify the change by Golden Path category and copy its contracts, focused tests, and gates into
   the working plan.

If the repository guidance changed, replace the workflow below with the new repository guidance and
explain the change to the user.

## Keep contribution lifecycle ownership at the root

The primary agent owns the base branch, commits, changelog fragment, PR state, remote verification,
and CI follow-up. Delegated agents may inspect or edit an explicitly bounded working set, but must not
create branches, commits, pushes, changelog fragments, or PR state transitions unless explicitly
assigned that lifecycle responsibility.

Monitor every delegated task until completion and integrate its evidence before publishing.

## Implement and validate

1. Branch from the verified active release tip using the repository's naming conventions.
2. Name every affected contract before editing.
3. Keep the diff scoped and preserve unrelated user changes.
4. Add or update focused automated tests for production-code changes.
5. Run the category-specific Golden Path loop during implementation.
6. Before review, fetch the active base again, inspect incoming commits, reconcile the branch, inspect
   `git diff <active-base>...HEAD`, and rerun every focused check recorded in the PR description.

Do not claim the full test matrix passed when it was left to CI. Record CI-only validation explicitly.

## Publish with the mandatory draft sequence

For a user-facing change requiring a changelog fragment, use this state machine exactly:

1. Commit the implementation and focused tests.
2. Run `scripts/contribution_preflight.sh draft`.
3. Push the branch and verify the exact remote SHA.
4. Create the PR as **draft** against the verified active release branch using the repository template.
5. Read back the PR and record its actual number, base, head, draft state, and head SHA.
6. Add exactly one appropriate `changelog.d/{features|fixes|maintenance}/<PR>-<slug>.md` fragment
   containing the PR link and repository credit format. Never guess or reserve a PR number.
7. Run formatting, `npm run check:changelog-integrity`, the recorded focused loop, and
   `git diff --check` on the final tree.
8. Commit and push the fragment, then verify the remote SHA again.
9. Run `scripts/contribution_preflight.sh ready <PR-number> <base-branch>`.
10. Read back the remote PR again. Confirm that it is still draft, its base/head and remote SHA match,
    its description records the real evidence, and required checks are not known failing.
11. Obtain action-time user confirmation before marking the PR Ready for review.
12. Mark it Ready, verify `draft=false`, then monitor the CI jobs triggered by the transition.

For a change that genuinely needs no fragment, write the reason in the PR description and still use
the draft sequence. Never silently omit the fragment for user-facing behavior.

## Fail closed

Stop before publication or Ready transition when any of these is unresolved:

- active release or freeze status;
- applicable repository instructions;
- dirty or unintended diff;
- missing focused test for production code;
- missing or mismatched PR-numbered fragment;
- local/remote SHA mismatch;
- PR base/head/draft mismatch;
- required local gate failure;
- missing user confirmation for the Ready transition.

Do not downgrade a failure to a warning merely to finish the workflow.

## Helper script

Resolve `scripts/contribution_preflight.sh` relative to this skill directory, but execute it with the
OmniRoute repository as the working directory. A standard shared installation can run:

```bash
"$HOME/.agents/skills/omniroute-contribution/scripts/contribution_preflight.sh" start
"$HOME/.agents/skills/omniroute-contribution/scripts/contribution_preflight.sh" draft
"$HOME/.agents/skills/omniroute-contribution/scripts/contribution_preflight.sh" ready 9245 release/v3.8.50
```

The script validates local and remote invariants. It does not replace live GitHub verification of
release freezes, PR state, CI, or user confirmation.
