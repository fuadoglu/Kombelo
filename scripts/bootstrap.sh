#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
if ! command -v flutter >/dev/null 2>&1 || ! command -v dart >/dev/null 2>&1; then
  echo "Missing prerequisite: Flutter stable 3.50.0 with Dart 3.14.0. Install it from https://docs.flutter.dev/get-started/install" >&2
  exit 2
fi
flutter_version="$(flutter --version)"
dart_version="$(dart --version 2>&1)"
if ! grep -q 'Flutter 3.50.0' <<<"$flutter_version" || ! grep -q '3.14.0' <<<"$dart_version"; then
  echo "Unsupported SDK. Required: Flutter stable 3.50.0 and Dart 3.14.0." >&2
  exit 2
fi
cp contracts/game-v1.json apps/mobile/assets/game-v1.json
cp contracts/classic-lifecycle-v1.json apps/mobile/assets/classic-lifecycle-v1.json
flutter pub get
(cd apps/mobile && dart run sqflite_common_ffi_web:setup)
