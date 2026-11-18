#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
if ! command -v flutter >/dev/null 2>&1 || ! command -v dart >/dev/null 2>&1; then
  echo "Missing prerequisite: Flutter stable 3.50.0 with Dart 3.14.0." >&2
  exit 2
fi
flutter analyze apps/mobile packages/game_rules
(cd packages/game_rules && dart test)
(cd apps/mobile && flutter test test)
python3 scripts/check_contracts.py
python3 scripts/check_lifecycle.py
