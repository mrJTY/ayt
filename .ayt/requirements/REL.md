# Release
Release readiness: audits and publishing.
<!-- tickets: `- [ ] **<ID>**: <title>`; [x] done, [ ] ready, `(draft)` after the id = draft. Detail in indented bullets. -->

- [x] **REL-1**: Pre-release audit
  - problem: before going public we don't know which bugs, usability foot guns or security issues strangers would hit
  - outcome: every skill and install.sh audited, every finding filed, nothing high-severity open when the folder is copied
  - [x] Each skill and install.sh is checked for security (untrusted text, shell injection, destructive commands), PROJECT.md Constraints and first-run usability (no `.ayt/`, no gh auth, monorepo subdir, non-Claude harness); one `verified:` line per file
  - [x] Every finding is filed in BUGS.md as `BUG-<PREFIX>-<N>` (or as a ticket if it's a change), never left as a review id
  - [x] A dry run on a fresh scratch repo (init → new-idea → implement → review on a trivial ticket) completes without manual fixes
  - [x] At release: no open `high` bug and BUG-SHIP-1 fixed; open medium/low bugs are listed under Known issues in `docs/status.md`
  - decision: ready gate = no high bugs + BUG-SHIP-1 fixed (medium/low may ship open)
  - decision: runs after INST-5, INST-6 and BUG-SHIP-1 so it audits the final state; resets STATE.md just before the copy
  - out of scope: fixing medium/low findings
  - tests: none (no runner); `bash -n` + `shellcheck install.sh uninstall.sh` → clean
  - verified: ayt-init → refuses to overwrite, writes only `.ayt/`, asks ≤4 questions; no shell built from user text; first run in a monorepo subdir works (dry run)
  - verified: ayt-new-idea → writes nothing until Approve; id grep works on an empty epic (dry run: CLI-1); full locate rule (none / one / several)
  - verified: ayt-bug → no fix, no commit; locate rule partial → BUG-PLAN-1
  - verified: ayt-implement → never commits/pushes/stashes; runs PROJECT.md commands → BUG-SHIP-4; locate rule partial → BUG-PLAN-1
  - verified: ayt-review → writes only `.ayt/`; ids regex-filtered before git grep; `git -C "$d"` (BUG-SHIP-1); runs PROJECT.md commands → BUG-SHIP-4
  - verified: ayt-pr → clean-tree first, slugged branch names, title/body via files, `git -C "$d"`; dry run from monorepo root: scope CLI-1, no clash
  - verified: ayt-pr-review → PR text as data, bodies via files, never checks out PR code; no `--paginate` → BUG-SHIP-2; GraphQL values in query text → BUG-SHIP-3
  - verified: ayt-docs → never overwrites unmarked files, date-based refresh; locate rule partial → BUG-PLAN-1
  - verified: install.sh → no network, sudo or recursive delete; removes only links into its own skills/; quoted paths; real files skipped (INST-6)
  - verified: uninstall.sh → `exec install.sh --uninstall`; removes only links into this clone (INST-7)
  - verified: filed → BUGS.md BUG-SHIP-2 (medium), BUG-SHIP-3 (medium), BUG-PLAN-1 (low), BUG-SHIP-4 (low); harness quirks as draft INST-8
  - verified: dry run → scratch monorepo `tools/greet`: init → new-idea (CLI-1) → implement (tests + lint pass) → review/pr scope from the git root, by the skills' own commands; no manual fixes
  - verified: gate → `grep -c 'severity: high' .ayt/BUGS.md` → 0; BUG-SHIP-1 fixed; docs/status.md Known issues lists the 4 open bugs + INST-8
  - nfr: clean
