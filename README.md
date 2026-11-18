# 🟪 Kombelo

**Place blocks. Chain combos. Beat your best.**

Kombelo is a portrait-first, one-thumb block puzzle for Android, followed by iOS. Place three pieces on an 8×8 board in any order, clear rows and columns, chain combos and chase a personal best. Glossy ceramic blocks, a precise drop preview and a rising three-note sound motif make every clear readable and gratifying.

| | Product |
|---|---|
| 🎮 | **Classic** · Offline endless play, local records and resume after every committed move |
| 🏆 | **Leagues** · One daily board, two ranked attempts, friends / country / world rankings and weekly standings |
| 👤 | **Profile** · Automatic immutable ID, editable nickname, public friend code and optional account recovery |
| 🌍 | **Languages** · AZ, EN, TR, RU, ES, pt-BR, DE, FR and AR with automatic locale resolution and manual override |
| 🔊 | **Feedback** · Line waves, combo notes, record fanfare and independent sound, music, haptics and reduced motion |
| 🔔 | **Notifications** · Opt-in daily boards and genuine friend activity, with local quiet hours |
| 🎬 | **Revenue** · AdMob only, through Classic round transitions and an optional earned undo |
| ⚙️ | **Operations** · Automatic schedule and ranking, versioned configuration, audited CLI, no admin panel |

## 🧭 Repository map

| | Document | Purpose |
|---|---|---|
| 🤖 | [AGENTS.md](AGENTS.md) | Mandatory Codex execution and review contract |
| 🎨 | [Product and UX](docs/PRODUCT.md) | Game rules, screen flows, design, motion and audio |
| 🏗️ | [Engineering](docs/ENGINEERING.md) | Monorepo, engines, API, data, Android and browser verification |
| 🚀 | [Release and operations](docs/RELEASE.md) | Milestones, QA, configuration, incident recovery and store gates |
| 🛡️ | [Trust and growth](docs/TRUST_AND_GROWTH.md) | AdMob, Firebase, notifications, legal pages and asset licensing |

## 💻 Development workflow

This repository starts with specifications. Implement the commands and project directories in the engineering plan before treating the following as runnable.

1. Pin the Flutter SDK and bootstrap dependencies.
2. Run the shared Dart tests and the Flutter preview tests.
3. Run `flutter run -d chrome --web-hostname=127.0.0.1 --web-port=8080` from `apps/mobile`. Open the served URL in Chrome and verify the milestone using a mobile viewport.
4. Run the corresponding flow on an Android emulator and physical phone before claiming native readiness. Chrome uses local integration adapters. Android validates ads, notifications, haptics and lifecycle behavior against native SDKs.

## 📍 Delivery status

Documentation baseline. Android ships first. The shared game rules, UI contracts and localization are designed for the subsequent iOS release. See the [release gates](docs/RELEASE.md) for evidence required at each stage.
