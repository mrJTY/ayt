#!/usr/bin/env bash
# Symlink ayt skills into agent harnesses' skills dirs.
# Usage: ./install.sh [--project] [--uninstall] [target ... | all]  (default: claude); --help lists targets
# ./uninstall.sh is ./install.sh --uninstall.
set -euo pipefail

src="$(cd "$(dirname "$0")/skills" && pwd)"
targets=(claude codex agy cursor pi)

# Per harness: "<user dir, relative to $HOME> <project dir, relative to git root>".
# To add a harness: add a line here and its name to `targets`.
target_dirs() {
  case "$1" in
    claude) echo ".claude/skills .claude/skills" ;;
    agy) echo ".gemini/antigravity-cli/skills .agents/skills" ;;
    # codex, cursor and pi all read the shared Agent Skills dir
    codex | cursor | pi) echo ".agents/skills .agents/skills" ;;
    *) return 1 ;;
  esac
}

user_dir() {
  local user _
  read -r user _ <<<"$(target_dirs "$1")"
  if [[ "$1" == claude ]]; then
    echo "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills"
  else
    echo "$HOME/$user"
  fi
}

usage() {
  echo "Usage: ./install.sh [--project] [--uninstall] [target ... | all]  (default: claude)"
  echo "       ./uninstall.sh [--project] [target ... | all]  removes the links again"
  echo
  printf '  %-8s %-45s %s\n' target "user dir" "--project dir"
  for t in "${targets[@]}"; do
    read -r _ proj <<<"$(target_dirs "$t")"
    printf '  %-8s %-45s %s\n' "$t" "$(user_dir "$t")" "<git root>/$proj"
  done
}

banner() {
  cat <<'ART'
    _    __   __ _____
   / \   \ \ / /|_   _|
  / _ \   \ V /   | |
 / ___ \   | |    | |
/_/   \_\  |_|    |_|
    All Y'need is Text
ART
}

project=false
uninstall=false
names=()
for arg in "$@"; do
  case "$arg" in
    -h | --help | --list) usage; exit 0 ;;
    --project) project=true ;;
    --uninstall) uninstall=true ;;
    all) names+=("${targets[@]}") ;;
    *) names+=("$arg") ;;
  esac
done
[[ ${#names[@]} -eq 0 ]] && names=(claude)
$uninstall || banner

for name in "${names[@]}"; do
  if ! target_dirs "$name" >/dev/null; then
    { echo "unknown target: $name"; echo; usage; } >&2
    exit 1
  fi
done

if $project; then
  base="$(git rev-parse --show-toplevel)"
fi

status=0
linked=$'\n'
for name in "${names[@]}"; do
  if $project; then
    read -r _ proj <<<"$(target_dirs "$name")"
    dest="$base/$proj"
  else
    dest="$(user_dir "$name")"
  fi
  if [[ "$linked" == *$'\n'"$dest"$'\n'* ]]; then
    echo "$name: already done in $dest"
    continue
  fi
  linked+="$dest"$'\n'

  if $uninstall; then
    # Only links into our skills/; real files, dirs and other links stay.
    removed=0
    for link in "$dest"/ayt-*; do
      if [[ -L "$link" && "$(readlink "$link")" == "$src/"* ]]; then
        rm "$link"
        echo "$name: removed $link"
        removed=$((removed + 1))
      fi
    done
    [[ $removed -eq 0 ]] && echo "$name: nothing to remove in $dest"
    continue
  fi

  mkdir -p "$dest"
  # Drop links left behind by renamed or removed skills (only ones pointing into our skills/).
  for link in "$dest"/ayt-*; do
    if [[ -L "$link" && ! -e "$link" && "$(readlink "$link")" == "$src/"* ]]; then
      rm "$link"
      echo "$name: removed stale $(basename "$link")"
    fi
  done
  for skill in "$src"/*/; do
    skill_name="$(basename "$skill")"
    link="$dest/$skill_name"
    # Never touch a real file or dir; any ayt-* symlink is ours to replace.
    if [[ -e "$link" && ! -L "$link" ]]; then
      echo "$name: skipped $skill_name: $link exists and is not a symlink; move it away and re-run" >&2
      status=1
      continue
    fi
    old=""
    [[ -L "$link" ]] && old="$(readlink "$link")"
    ln -sfn "${skill%/}" "$link"
    if [[ -n "$old" && "$old" != "${skill%/}" ]]; then
      echo "$name: relinked $skill_name -> $link (was $old)"
    else
      echo "$name: linked $skill_name -> $link"
    fi
  done
done
exit "$status"
