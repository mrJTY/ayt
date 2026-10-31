#!/usr/bin/env bash
# Pre-commit / pre-release checks: secrets, personal paths, stray files, shell and skill sanity.
# Usage: bin/check.sh [--staged]   (default: every tracked file under ayt/)
# --staged checks what is about to be committed (index contents), used by .githooks/pre-commit.
set -uo pipefail

cd "$(dirname "$0")/.." || exit 1
staged=false
[[ "${1:-}" == --staged ]] && staged=true

fail=0
problem() { echo "  ✗ $*" >&2; fail=1; }
warn() { echo "  ! $*" >&2; }

# Files to check (relative to this dir), NUL-separated so odd names are safe.
files=()
if $staged; then
  while IFS= read -r -d '' f; do files+=("$f"); done < <(git diff --cached --name-only --diff-filter=ACMR -z --relative -- .)
else
  while IFS= read -r -d '' f; do files+=("$f"); done < <(git ls-files -z -- .)
fi
[[ ${#files[@]} -eq 0 ]] && exit 0

# Content of a file as it will be committed (index) or as tracked (HEAD/worktree).
content() { if $staged; then git show ":./$1" 2>/dev/null; else cat -- "$1"; fi; }

echo "ayt checks (${#files[@]} files, $($staged && echo staged || echo tracked))"

# 1. Files that should never be committed.
for f in "${files[@]}"; do
  case "$(basename "$f")" in
    .env | .env.* | *.pem | *.key | *.p12 | *.pfx | id_rsa* | id_ed25519* | *.keystore | .netrc | .npmrc | credentials*.json | .DS_Store | *.swp | *.log)
      problem "$f: file type that should not be committed" ;;
  esac
  if [[ -f "$f" ]] && (($(wc -c <"$f") > 1048576)); then
    problem "$f: larger than 1 MB"
  fi
done

# 2. Secrets. gitleaks when installed, built-in patterns always.
if command -v gitleaks >/dev/null; then
  if $staged; then
    gitleaks protect --staged --redact --no-banner -v >&2 || problem "gitleaks found secrets in staged changes"
  else
    gitleaks detect --no-git --source . --redact --no-banner >&2 || problem "gitleaks found secrets"
  fi
else
  warn "gitleaks not installed (brew install gitleaks); using built-in patterns only"
fi

secret_re='(AKIA|ASIA)[0-9A-Z]{16}|-----BEGIN [A-Z ]*PRIVATE KEY-----|gh[pousr]_[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{30,}|xox[abprs]-[A-Za-z0-9-]{10,}|sk-[A-Za-z0-9_-]{20,}|AIza[0-9A-Za-z_-]{35}|(api[_-]?key|secret|token|passw(or)?d)[A-Za-z0-9_]*["'"'"']?[[:space:]]*[:=][[:space:]]*["'"'"'][^"'"'"' ]{12,}["'"'"']'
# Personal info: home directories and email addresses other than the project's public ones.
personal_re='/Users/[A-Za-z0-9._-]+/|/home/[A-Za-z0-9._-]+/|C:[\\]Users[\\]'

for f in "${files[@]}"; do
  [[ -f "$f" ]] || $staged || continue
  # Skip binaries.
  content "$f" | grep -qI . || continue
  if hits=$(content "$f" | grep -nEi -- "$secret_re"); then
    while IFS= read -r line; do problem "$f:${line%%:*}: looks like a secret"; done <<<"$hits"
  fi
  if hits=$(content "$f" | grep -nE -- "$personal_re" | grep -v 'ayt-allow-path'); then
    while IFS= read -r line; do problem "$f:${line%%:*}: personal path (use ~ or <path>; add 'ayt-allow-path' on the line to allow)"; done <<<"$hits"
  fi
done

# 3. Whitespace errors and leftover conflict markers.
if $staged; then
  git diff --cached --check -- . >&2 || problem "whitespace errors or conflict markers (above)"
else
  for f in "${files[@]}"; do
    content "$f" | grep -qE '^(<<<<<<<|>>>>>>>) ' && problem "$f: conflict marker"
  done
fi

# 4. Shell scripts parse and pass shellcheck.
for f in "${files[@]}"; do
  case "$f" in
    *.sh | .githooks/*)
      bash -n "$f" 2>&1 | sed 's/^/    /' >&2
      [[ ${PIPESTATUS[0]} -eq 0 ]] || problem "$f: bash syntax error"
      if command -v shellcheck >/dev/null; then
        shellcheck "$f" >&2 || problem "$f: shellcheck findings"
      fi ;;
  esac
done

# 5. Each skill has frontmatter whose name matches its directory.
for f in "${files[@]}"; do
  [[ "$f" == skills/*/SKILL.md ]] || continue
  dir="$(basename "$(dirname "$f")")"
  head="$(content "$f" | awk 'NR==1{next} /^---$/{exit} {print}')"
  [[ "$(content "$f" | head -1)" == --- ]] || { problem "$f: missing frontmatter"; continue; }
  grep -qx "name: $dir" <<<"$head" || problem "$f: frontmatter name must be '$dir'"
  grep -q '^description: ' <<<"$head" || problem "$f: missing description"
done

if ((fail)); then
  echo "checks failed" >&2
  exit 1
fi
echo "checks passed"
