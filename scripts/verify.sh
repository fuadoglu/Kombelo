#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
if ! command -v dart >/dev/null 2>&1; then
  echo "Missing prerequisite: Dart SDK 3.14.0 (included in Flutter stable 3.50.0)." >&2
  exit 2
fi
(cd packages/game_rules && dart analyze && dart test)
python3 scripts/check_contracts.py
python3 scripts/check_lifecycle.py
