---
name: verify
displayName: CEL Verify
description: Run full verification (lint, typecheck, test, build) adapted to changed files. Use after code changes to ensure nothing is broken.
version: 1.0.0
author: CEL
tags: [cel, verify, testing, lint, build]
---

## Steps

1. **Detect changes:**
   ```bash
   git diff --name-only HEAD
   git diff --name-only --cached
   ```
   Categorize: web/ changes, convex/ changes, or both.

2. **If web/ changes:**
   Run sequentially, stop on first failure:
   ```bash
   cd web && npm run format:check
   cd web && npm run lint
   cd web && npx tsc --noEmit
   cd web && npm test -- --run --bail=1
   cd web && npm run build
   ```

3. **If convex/ changes:**
   ```bash
   npx eslint "convex/**/*.ts" --ignore-pattern "convex/_generated/**"
   npm run test:convex -- --bail=1
   ```

4. **Report:** List each check with pass/fail status. On failure, show the error output clearly.

IMPORTANT: Run all checks sequentially. Stop on first failure and report the issue.
