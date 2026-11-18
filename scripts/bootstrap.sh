#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
if ! command -v dart >/dev/null 2>&1; then
  echo "Missing prerequisite: Dart SDK 3.14.0. Install Flutter stable 3.50.0 from https://docs.flutter.dev/get-started/install" >&2
  exit 2
fi
if ! dart --version 2>&1 | grep -q '3.14.0'; then
  echo "Unsupported Dart SDK. Required: Dart 3.14.0 (Flutter stable 3.50.0 bundle)." >&2
  exit 2
fi
(cd packages/game_rules && dart pub get)
