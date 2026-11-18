# Delivery, release and operations

| Gate | Deliverable | Evidence |
|---|---|---|
| 1 | Board, scoring, persistence, input and animation | Chrome game and result walkthrough, deterministic pure Dart replay, Android drag and resume |
| 2 | Brand, intro, onboarding, audio, all locales and accessibility | Small/large Chrome viewports, Arabic RTL, large text, reduced motion, real Android audio and haptics |
| 3 | Identity, nickname, recovery, friends, leagues and scheduling | Chrome fixture plus Android API integration, duplicate/late results, tie rankings, account deletion and moderation |
| 4 | AdMob, consent, Firebase, notifications and legal | Chrome settings and flow demonstrations, native test inventory, consent matrix, earned reward callback tests, opt-in and deep links |
| 5 | Android release candidate | Signed build in controlled distribution, device matrix, verified store disclosures, policy and rights review, rollback rehearsal |
| 6 | iOS | Separate App Store review, SDK/consent assessment, native devices and platform distribution verification |

Run Chrome after each visible delivery slice and include evidence at every gate. Profile compact and tall phones, both hands, low-end Android, 60 and higher refresh rates where supported, interrupted audio, system gesture navigation, background/kill/resume, offline, slow API and fresh/returning users. Compare first-attempt placement, accidentally committed moves, drag-to-visible response, clear-to-next-pick and first-run teachability. Critical ship gates: zero known preview/commit mismatches or state-loss defects; release target p95 UI and raster frame times within each 60 Hz budget on reference device under busy gameplay, measure percent of missed frames and record device/model/build. No blocking crashes, money/consent bugs or unverifiable SDK states.

Keep at least 30 daily versioned boards. Validate solvability and score spread with deterministic solver and human fixtures. UTC open/close in API is authoritative even if jobs are down. Scheduled finalizer catches up, locks by event ID, snapshots rankings transactionally and is safe to rerun. Publish replacement before open only; after open void all scores for the faulty puzzle and recalculate the week. Audit operator, reason, timestamp and previous/new config. Restrict commands for ad kill switch, void/recalculate, nickname reset and notification stop. No admin UI.

Monitor crash-free sessions, frame timings, schedule backlog, score verification errors, reward failures, consent and notification delivery. Do not place private data in logs. Use staged rollout, immutable bundles and backward-compatible expand/contract migrations. Rehearse read-only league mode, server rollback and public notice; Classic stays playable. Keep separate development, staging and production projects. Pin supported native toolchains and check current target SDK, store forms and signing rules at each release.
