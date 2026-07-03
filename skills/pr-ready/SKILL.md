---
name: pr-ready
displayName: CEL PR Ready
description: Prepare and create a pull request — runs verification, checks branch state, summarizes changes, creates PR via gh CLI.
version: 1.0.0
author: CEL
tags: [cel, pr, github, verify, workflow]
disable-model-invocation: true
---

## Steps

1. **Verify** — Run `/verify` first. If any check fails, stop and report.

2. **Branch check:**
   - Ensure not on master/main: `git branch --show-current`
   - Check remote tracking: `git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null`
   - If no tracking, push: `git push -u origin HEAD`

3. **Analyze changes:**
   - Commits: `git log master..HEAD --oneline`
   - File stats: `git diff master...HEAD --stat`
   - Full diff for summary: `git diff master...HEAD`

4. **Create PR via gh CLI:**
   - Title: concise (< 70 chars), from commit history
   - Body format:
     ```
     ## Summary
     - bullet points summarizing changes

     ## Test plan
     - [ ] Verification checks passed
     - [ ] specific test items
     ```
   - Command: `gh pr create --title "..." --body "..."`

5. **Return the PR URL.**

$ARGUMENTS: optional target branch (default: master), --draft flag, or specific title.
