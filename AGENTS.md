# Kombelo agent contract

## Required workflow

- Read this file, README and only the sections relevant to the current slice. Use rg, scoped diffs and targeted tests. Batch independent reads. Keep status to evidence, decisions and blockers. Read full logs only on failure.
- Inspect git status and preserve user changes. Change only files needed for the assigned slice. Do not add an SDK, service, schema, permission, dependency or abstraction without a concrete requirement and documented tradeoff. Pin dependency changes and commit lockfiles.
- Implement through normal entry points. Run format, analysis and affected tests. Keep deterministic fixtures, migration coverage and evidence for every changed invariant. Never mark a skipped, mocked or unavailable test as passed.
- Every visible implementation slice must run locally in Chrome. Use the preview entry point and mobile viewports at 360×800 and 430×932, plus RTL and reduced motion when relevant. Exercise the actual changed flow and share a live preview link or screenshots and observed behavior. Record command, viewport, scenario and result in the PR. If the browser is unavailable, report the exact blocker and leave the visual gate pending.
- Every native integration also needs Android verification. Chrome fixtures are deterministic and explicitly labeled. Browser success never certifies ads, OS gestures, audio latency, notifications, consent dialogs or platform lifecycle.
- Keep commands and handoff short. Provide changed behavior, direct evidence, remaining gates and any decision made. Stop after the requested slice is complete. Do not silently redefine rules.
- Never commit keys, signing materials, service-account credentials, raw player data or production ad IDs in test paths. Use test inventory only. Never provision, publish, merge or change production configuration without explicit authorization.
- Do not introduce admin UI, purchases, paid rank advantages, copied game assets, ad-triggered difficulty, fake achievements, runtime locale guessing from IP or device fingerprinting.
- Before release, satisfy docs/RELEASE.md. Document real blockers rather than weakening gates.

## Normative specifications

- Follow [execution slices](docs/EXECUTION.md). Use the game JSON and vectors, [game protocol](docs/GAME_PROTOCOL.md), [OpenAPI](contracts/openapi.json), [SQL schema](contracts/schema.sql) and the relevant UI/integration contracts before changing behavior.
- Run `python3 scripts/check_contracts.py` for contract edits. Do not stop after creating scaffolding. Finish the active slice through its normal entry point, exercise failure paths and demonstrate the user-visible result.
- Use the browser and native evidence format in EXECUTION. If a genuine platform prerequisite is absent, complete independent checks and identify precisely which verification remains.
