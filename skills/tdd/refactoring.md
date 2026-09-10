# Refactor after the behavior works

Use the passing test to protect a concrete simplification revealed by the change: repeated logic with the same contract, unnecessary indirection, or an interface that makes the tested behavior difficult to express.

Choose the smallest change that addresses that friction, then rerun the tests. A long function, primitive type or unfamiliar pattern alone is not a reason to add abstractions. Preserve unrelated code and do not expand the task into an architecture audit.
