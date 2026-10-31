#!/usr/bin/env bash
# Remove the ayt skill links install.sh created. Same arguments as install.sh.
# Usage: ./uninstall.sh [--project] [target ... | all]  (default: claude)
set -euo pipefail
exec "$(dirname "$0")/install.sh" --uninstall "$@"
