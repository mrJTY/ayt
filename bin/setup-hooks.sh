#!/usr/bin/env bash
# Point this clone's git hooks at .githooks/ (pre-commit runs bin/check.sh --staged).
set -euo pipefail
cd "$(dirname "$0")/.." || exit 1
git config core.hooksPath "$(git rev-parse --show-prefix).githooks"
echo "hooks enabled: core.hooksPath = $(git config core.hooksPath)"
