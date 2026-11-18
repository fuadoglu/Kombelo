# game_rules

Pure Dart, deterministic rules for Kombelo's versioned 8×8 block puzzle. This package contains no Flutter, storage, or network code.

## Current scope

- Immutable board, piece, tray, and game snapshot models.
- Versioned xorshift32 RNG and weighted piece/rotation/color generation.
- Placement validation, line-intersection clearing, combo chain, score, and move cap.
- JSON snapshot encoding for the local persistence adapter.

The canonical v1 rules and vectors live in `../../contracts/game-v1.json` and `../../contracts/game-v1-vectors.json`. Runtime catalog asset parity is checked by `scripts/check_contracts.py`.

Run `dart analyze` and `dart test` from this package directory. See `docs/GAME_PROTOCOL.md` for the normative rules and migration policy.
