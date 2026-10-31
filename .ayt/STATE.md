# State
updated: 2026-10-29
focus: INST-5, INST-6, INST-7, BUG-SHIP-1, REL-1
next: /ayt-review, then commit, then /ayt-pr
notes:
- Open source: this folder is ready to copy to its own public repo (github.com/mrJTY/ayt, MIT, © mrJTY); REL-1 gate met (no high bugs, BUG-SHIP-1 fixed)
- open: BUG-SHIP-2 ayt-pr-review misses earlier ayt reviews on busy PRs (no pagination)
- open: BUG-SHIP-3 ayt-pr-review puts GitHub-fetched values inside GraphQL query strings
- open: BUG-PLAN-1 skills disagree on finding `.ayt/` from a monorepo root
- open: BUG-SHIP-4 running ayt-review / ayt-implement on someone else's branch runs their PROJECT.md commands
- SHIP-7 still ready: reword the rename Constraint in PROJECT.md (circular with /ayt-pr)
- INST-8 (draft): harness quirks (Codex implicit invocation, Cursor duplicates, Antigravity IDE dir)
- Possible /ayt-new-idea: /ayt-review and /ayt-pr-review write the BUGS.md entry themselves when a finding is marked "bug"
