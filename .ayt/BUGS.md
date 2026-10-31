# Bugs
<!-- one `## BUG-<PREFIX>-<N>: <title>` section per bug. status: open|fixed|wontfix -->

## BUG-SHIP-1: ayt-pr / ayt-pr-review miss a subdir `.ayt/` when run from the git root
status: fixed
breaks: SHIP-2
severity: medium

Steps:
1. In a repo whose ayt docs are in a subdir (`<sub>/.ayt/`), `cd` to the git root and run `/ayt-pr` on a branch with a ticket ticked done
Expected: step 4 finds `<sub>/.ayt/` and the in-scope tickets, base-done filter and id-clash check run against it
Actual: `git diff`/`git grep` pathspecs `.ayt/requirements/`, `.ayt/REQUIREMENTS.md` are cwd-relative, match nothing, so no tickets are found
Reproduced: yes: `git grep -h -A1 '^## PLAN-1:' origin/main -- .ayt/REQUIREMENTS.md` is empty from the git root, matches from the subdir (found by /ayt-review 2026-10-29 on PLAN-5)
Suspect: skills/ayt-pr/SKILL.md:23-24, skills/ayt-pr-review/SKILL.md:25 (run from the located `.ayt/`'s parent dir, or prefix its path)
Cause: "Locate docs" can pick a `.ayt/` below cwd, but the git pathspecs after it (`.ayt/requirements/`, `.ayt/BUGS.md`, `.ayt/REQUIREMENTS.md`) assumed cwd was its parent dir; ayt-review had the same cause
Verification:
- tests: none (no runner); regression check from the git root of the playground monorepo (docs in `ayt/.ayt/`); `bash -n` + `shellcheck install.sh uninstall.sh` → clean
- fix → skills/ayt-pr step 4, ayt-review Locate docs, ayt-pr-review step 3: keep the `.ayt/`'s dir in a quoted `d` and run git as `git -C "$d" …`
- before → from root, `git diff "$B" -- .ayt/requirements/` → 0 `+- [x]` lines; `git grep '^- \[x\] \*\*PLAN-1\*\*' HEAD -- .ayt/requirements/` → 0 hits
- after → same rule with `git -C "$d"` (d=ayt) from root → INST-5, INST-6, INST-7 in scope; PLAN-1 grep → 1 hit
- SHIP-2 acceptance unchanged (dirty-tree first, cheap checks, slug, review gate, no tests)

## BUG-SHIP-2: ayt-pr-review misses earlier ayt reviews on busy PRs (no pagination)
status: open
breaks: SHIP-5
severity: medium

Steps:
1. Run `/ayt-pr-review` on a PR with more than 30 reviews or review comments, then run it again
Expected: every earlier ayt review and inline comment is found; ids continue after the highest used, nothing is re-posted
Actual: `gh api …/reviews` and `…/comments` return the first page (30) only, so older ayt findings can be missed: ids reused, findings re-posted
Reproduced: no: read the code path (REL-1 audit 2026-10-29); `gh api` paginates only with `--paginate`
Suspect: skills/ayt-pr-review/SKILL.md Gather 4 (add `--paginate`)

## BUG-SHIP-3: ayt-pr-review puts GitHub-fetched values inside GraphQL query strings
status: open
breaks: none
severity: medium

Steps:
1. `/ayt-pr-review` resolves an earlier thread, or reads review threads
Expected: per PROJECT.md Constraints, nothing fetched from GitHub is interpolated into a command; values go in as GraphQL variables (`-F threadId=@file` / `-f`)
Actual: the thread id (from GitHub) and owner/repo/number are pasted into the `-f query='…'` text
Reproduced: no: read the code path (REL-1 audit 2026-10-29); GitHub-issued node ids make exploitation unlikely, but it breaks the Constraint
Suspect: skills/ayt-pr-review/SKILL.md Gather 5 and Post (resolveReviewThread mutation)

## BUG-PLAN-1: skills disagree on finding `.ayt/` from a monorepo root
status: open
breaks: none
severity: low

Steps:
1. Monorepo with one project set up (`apps/web/.ayt/`); from the git root run `/ayt-implement`, `/ayt-review`, `/ayt-bug` or `/ayt-docs`
Expected: like `/ayt-new-idea`: one `*/.ayt/` below the root → use it; several → ask; none → suggest `/ayt-init`
Actual: they only walk up from cwd; "several below root, ask" says nothing about exactly one, and some never say what to do with none, so an agent may suggest `/ayt-init` at the root and create a second `.ayt/`
Reproduced: no: read the code path (REL-1 audit 2026-10-29); README says "nearest `.ayt/` above cwd"
Suspect: Locate docs in ayt-implement, ayt-review, ayt-bug, ayt-docs (ayt-new-idea has the full rule)

## BUG-SHIP-4: running ayt-review / ayt-implement on someone else's branch runs their PROJECT.md commands
status: open
breaks: none
severity: low

Steps:
1. Check out a contributor's branch that edits `.ayt/PROJECT.md` `test:` / `lint:`, then run `/ayt-review`
Expected: the user is warned before running test/lint commands that changed on the branch (or the README says so)
Actual: the commands run as written, like running the contributor's tests by hand; nothing points this out
Reproduced: no: read the code path (REL-1 audit 2026-10-29); `/ayt-pr-review` is safe (never checks out or runs PR code)
Suspect: skills/ayt-review/SKILL.md `## 1. Suite`, skills/ayt-implement/SKILL.md `## Before starting`; README
