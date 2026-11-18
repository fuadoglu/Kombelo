# Execution contract

Authority: game-v1.json and GAME_PROTOCOL govern the engine, OpenAPI and schema govern service interfaces, UI_SYSTEM governs visual implementation, and RELEASE governs launch evidence. PRODUCT explains intent. If a normative rule conflicts, write a focused decision and update affected contracts and fixtures in the same change. Use gates as ordered checkpoints across the full product.

| Slice | Implement | Demonstrate |
|---|---|---|
| A | Flutter/Dart pinned workspace, shared engine, local persistence, Canvas input | Play Classic in Chrome, intersecting clear, next drag during clear, kill/resume on Android |
| B | Original brand, all nine locales, accessible onboarding, bundled sound | First/returning launch, muted and reduced motion, Arabic, large text, Android audio focus |
| C | Account, anonymous-to-email linking, nickname, rank and friends | Invite and accept, late/duplicate submit, tied ranks, opt-out and account deletion |
| D | AdMob, Firebase adapters, push and legal site | Test inventory only, callback after dismissal, duplicate grant, no fill, consent revocation, expired deep link |
| E | Android release candidate | Signed internal build, rollback drill, usage disclosures, asset/font provenance, device evidence |
| F | iOS | Validate fresh signing, store privacy and audience rules, native SDK parity and device behavior |

## Progress checkpoint · first rules increment

Completed scope: the first roughly 10% increment establishes the pure Dart `packages/game_rules` boundary, implements the v1 xorshift generator and move scoring/line-clear rules, and checks them against the checked-in contract vectors. It does not claim that Slice A or the mobile game is complete. Flutter UI, SQLite persistence, Chrome pointer scenarios, and Android kill/resume remain open acceptance gates.

Evidence for this increment: `./scripts/bootstrap.sh` and `./scripts/verify.sh` pass with Flutter stable 3.50.0 / Dart 3.14.0. The rule package has no Flutter runtime dependency. Since this increment has no user-visible screen, the Chrome and native gates remain pending until the mobile slice is implemented.

At A, record supported SDKs and add one repo-level bootstrap and one verify command. Bootstrap must be repeatable from a clean clone, produce no credentials, and state exact missing prerequisites. Verify must run analyzer, engine vectors, UI tests and the documentation checker. Use Dart lockfiles and stable SDK versions. Keep the playbook short and update command names in README when implemented.

For every visible slice start Flutter in Chrome, then drive a real pointer flow. If Chrome cannot be opened by Flutter directly, launch the Flutter web-server target and open the resulting URL in Chrome. Provide a forwarded URL when available, otherwise attach screenshots. Native SDK integrations require separate verification on Android; mocks remain explicitly labeled. Use fixture parameters or a dev-only route with gameplay, combo intersection, result, offline restore, league, consent and settings. Release builds must exclude fixture routes and mock flags.

Evidence format: slice and commit, commands and exit status, Chrome viewport and observed scenario, URL or screenshot, native device/build and result, known gaps. Use one concise checkpoint and summarize logs unless a failure needs excerpts. Never fabricate runs or carry forward a green result after related changes.

For legal and store launch collect publisher identity, support and privacy contacts, domain, actual vendors, age policy, data retention, territories, approved copy, advertising inventory IDs and signing through owner-controlled channels. Keep production ads and engagement off until eligible users and provider behavior are verified. Do not substitute a fabricated publisher or deploy draft policies.
