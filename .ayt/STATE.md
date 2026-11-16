# State
updated: 2026-11-03
focus: SHIP-8, SHIP-9
next: /ayt-pr-review
notes:
- /ayt-dyb first real run (2026-11-03) on PR #96: fresh-context subagent review worked, sibling skills followed by reading their SKILL.md; 0 critical, 5 minors fixed once and not re-reviewed
- Open source: this folder is ready to copy to its own public repo (github.com/mrJTY/ayt, MIT, © mrJTY); REL-1 gate met (no high bugs, BUG-SHIP-1 fixed)
- open: BUG-SHIP-2 ayt-pr-review misses earlier ayt reviews on busy PRs (no pagination)
- open: BUG-SHIP-3 ayt-pr-review puts GitHub-fetched values inside GraphQL query strings
- open: BUG-PLAN-1 skills disagree on finding `.ayt/` from a monorepo root
- open: BUG-SHIP-4 running ayt-review / ayt-implement on someone else's branch runs their PROJECT.md commands
- SHIP-7 still ready: reword the rename Constraint in PROJECT.md (circular with /ayt-pr)
- INST-8 (draft): harness quirks (Codex implicit invocation, Cursor duplicates, Antigravity IDE dir)
- Possible /ayt-new-idea: /ayt-review and /ayt-pr-review write the BUGS.md entry themselves when a finding is marked "bug"
- PLAN-6 dogfood (pending, the user's call; this /ayt-new-idea session for SHIP-8/9 was a grill-style run: record whether it surfaced anything the old flow would miss): run the amended /ayt-new-idea on a real idea and record in `verified:` whether grilling surfaced a decision the old flow would likely have missed
