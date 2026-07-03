---
name: format-and-commit
description: Format code (Prettier + ESLint), run tests, and create a semantic git commit
disable-model-invocation: true
---

# format-and-commit

Format code and create a git commit with staged changes.

## What This Skill Does

When you invoke `/format-and-commit`, Claude will:

1. **Format code** - Run `npm run format:lint` on both frontend and backend
2. **Verify tests pass** - Run `npm test -- --run` to ensure no regressions
3. **Stage changes** - Add modified files with `git add`
4. **Create commit** - Generate a semantic commit message and commit changes

## How to Use

Simply invoke:
```
/format-and-commit
```

Then follow the prompts. Claude will:
- Show you the files being committed
- Propose a semantic commit message based on changes
- Ask for confirmation before committing

## Example

```bash
User: /format-and-commit

Claude:
✓ Formatting code...
✓ Running tests...
✓ Files changed:
  - api/src/matches/services/matches.service.ts
  - web/src/components/MatchTable.tsx

Proposed commit message:
"feat(matches): add team performance calculation in service

This adds a new `calculateTeamPerformance` method to compute team stats
based on recent match results, improving the match simulation accuracy."

Ready to commit? [y/n]
```

## Benefits

- Ensures code quality before committing
- Consistent commit messages following semantic versioning
- No need to manually run format/lint/test steps
- Integrates with husky pre-commit hooks
