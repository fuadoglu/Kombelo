<img src="docs/media/brand.svg" alt="Kombelo mark" width="84" height="84">

# Kombelo

**Place blocks. Chain combos. Beat your best.**

An Android-first, one-thumb puzzle with an 8×8 board, three pieces, line clears and escalating combo feedback. iOS follows after Android release validation.

| | What players get |
|---|---|
| <img src="docs/media/game.svg" width="20" alt=""> | **Classic** · Offline endless play, personal best and resume after every move |
| <img src="docs/media/trophy.svg" width="20" alt=""> | **Leagues** · One daily board, two attempts, Friends / Country / World rankings |
| <img src="docs/media/world.svg" width="20" alt=""> | **Nine locales** · AZ, EN, TR, RU, ES, pt-BR, DE, FR, AR with device detection and manual override |
| <img src="docs/media/sound.svg" width="20" alt=""> | **Feedback** · Ceramic blocks, immediate drag, clear waves, combo sound and reduced motion |
| <img src="docs/media/bell.svg" width="20" alt=""> | **Return** · Opt-in daily boards and real friend activity |
| <img src="docs/media/shield.svg" width="20" alt=""> | **Profile and revenue** · Automatic ID, editable nickname, AdMob in eligible Classic sessions |

## Build map

| Guide | Contract |
|---|---|
| <img src="docs/media/code.svg" width="20" alt=""> [AGENTS.md](AGENTS.md) | Codex rules and [execution slices](docs/EXECUTION.md) |
| <img src="docs/media/game.svg" width="20" alt=""> [Product](docs/PRODUCT.md) | [Game protocol](docs/GAME_PROTOCOL.md), [catalog](contracts/game-v1.json), [vectors](contracts/game-v1-vectors.json) |
| <img src="docs/media/sound.svg" width="20" alt=""> [UI system](docs/UI_SYSTEM.md) | Layout, palette, original mark, motion, accessibility and [asset register](docs/ASSET_MANIFEST.md) |
| <img src="docs/media/code.svg" width="20" alt=""> [Engineering](docs/ENGINEERING.md) | [OpenAPI](contracts/openapi.json), [SQL](contracts/schema.sql), [service behavior](docs/SERVICE_BEHAVIOR.md) |
| <img src="docs/media/shield.svg" width="20" alt=""> [Trust and growth](docs/TRUST_AND_GROWTH.md) | [Integration matrix](docs/INTEGRATION_MATRIX.md), [legal drafts](docs/LEGAL_DRAFTS.md) |
| <img src="docs/media/docs.svg" width="20" alt=""> [Release](docs/RELEASE.md) | Android evidence, operations, rollout and iOS readiness |

## Run and verify

**Current status: implementation specification.** The documentation checker runs now with `python3 scripts/check_contracts.py`. The first implementation slice creates and pins the Flutter workspace and bootstrap command.

After bootstrap, from `apps/mobile`:

```sh
flutter run -d chrome --web-hostname=127.0.0.1 --web-port=8080
```

Open the local or forwarded URL in Chrome. Show the implemented flow at 360×800 and 430×932, and verify native integration separately on Android. Preview adapters are labeled; they never stand in for native ads, consent, push, audio focus or lifecycle evidence.

## Operations

Flutter and a shared Dart rule engine, SQLite local state, Dart API and PostgreSQL. AdMob is the only revenue source. Firebase supplies gated product telemetry, crashes and push. Versioned configuration, scheduled ranking and audit commands support operations without an admin panel.
