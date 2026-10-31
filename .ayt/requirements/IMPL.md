# Implement
ayt-implement: tickets and bug fixes, STATE.md progress and resume.
<!-- tickets: `- [ ] **<ID>**: <title>`; [x] done, [ ] ready, `(draft)` after the id = draft. Detail in indented bullets. -->

- [x] **IMPL-1**: Implement tickets and fix bugs
  - [x] No args: resumes STATE.md focus, else all `ready` tickets + `open` bugs (bugs first)
  - [x] Sequential, test-first; ticks STATE.md progress per step so a new session resumes
  - [x] Records `tests:` / `verified:` evidence and ticks the ticket done (`[x]`); a bug gets `Verification:` and `status: fixed` (needs regression test + `Cause:`)
  - [x] Never commits, pushes or stashes
