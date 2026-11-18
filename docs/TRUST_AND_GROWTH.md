# Monetization, engagement, legal and licensed assets

## AdMob and audience

AdMob is the only revenue source. Classic has optional rewarded undo and sparse full-screen ads between rounds; no banner, app-open or ranked ads. Use google_mobile_ads, UMP consent/privacy options as applicable and test IDs in non-production. Start full-screen cap after first session with at least 3 completed Classic rounds and 5 minutes since the last impression, applied only when ad is ready, not after the same round's rewarded ad. Earn reward only on SDK earned callback; handle load failure, dismissal, retry, backgrounding and duplicate callbacks. Never gate starting a round on SDK initialization or a network call. Offer no targeted ads where consent or age rules prohibit them.

The product explicitly includes children. Before production SDK activation, verify actual target-audience declarations, approved SDK versions, eligibility and age/consent behavior for each store and rollout region. Unknown age uses the restrictive path: no ads, marketing analytics or engagement pushes until a policy-approved audience flow permits them. Keep age handling neutral and minimize stored data. For child sessions keep Classic available; disable public nickname, friend discovery, behavioral notifications and ad features by default. Reassess iOS audience/category and third-party SDK eligibility separately. Production flags stay off until this gate passes. Monetization forecasts must account for ineligible users and regions.

## Firebase and notifications

Use Firebase Analytics (GA4; consent-gated where applicable), Crashlytics (scrub payloads and gate collection as applicable), FCM (opt-in preferences plus platform permission), and use AdMob native callbacks for permitted impression-level reporting. Integration failure cannot block Classic. Use minimal typed events: onboarding_complete, round_start, round_end, combo_milestone, record_break, ranked_submit, ad_offer, ad_earned, notification_open. Prefer aggregate parameters (mode, tier, duration bucket, rule version). No nickname, email, friend code, raw move history or precise location in analytics. Maintain an event and retention inventory. Monitor first-round completion, replay, D1/D7, rewarded undo continuation, ad abandonment and push opt-outs. Preserve a holdout for cadence changes.

Ask after first meaningful league use. Default one promotional notification per local day and quiet hours 21:00–09:00, using eligible local time zone. Real friend invite or score overtake and unplayed daily board only; handle expiry, duplicates, revocation, invalid token and app deep link. Never put private nickname or score on lock screen by default. Adult/eligible users can opt out per type at any time.

## Legal delivery

Ship responsive branded HTTPS pages for Privacy, Terms, Account and Data Deletion, Support, Community Rules and Third-Party Notices. Link from settings and store listings where applicable, with locale fallback, revision date and a public contact point. Privacy must match actual data, purposes, vendors, age handling, retention and user controls. Account deletion requires authenticated request, revokes access, removes or anonymizes personal and leaderboard data per approved policy, and documents backups and exceptions. Configure public app-ads.txt through the verified developer site when applicable. Store Data safety and App Privacy disclosures must match production SDK behavior. Never invent owner identity, contact, jurisdiction or legal approval. These are launch inputs and require owner and appropriate legal review.

## Art and sound

- Lucide for functional icons, pin upstream revision, vendor selected SVGs and retain actual ISC and applicable Feather/MIT notices. Suggested set: gamepad-2, trophy, users, globe, flag, bell, pause, play, volume-2, volume-x, music-2, settings, undo-2, share-2, shield, circle-help, chevron-left. No remote asset fetch during play.
- Original Kombelo app icon, wordmark, ceramic blocks and three-note motif. Provide launcher/adaptive/themed and iOS variants and documentation of authored components. Use Noto script coverage under OFL as needed and preserve actual license notices.
- Open sound-library candidates: Kenney Interface Sounds and verified asset-specific Freesound CC0 files. Confirm each upstream file and redistribution/derivative terms before vendoring. Normalize and trim audio, test on device speakers, preserve attribution where required and keep source files separate from optimized runtime assets.
- Maintain a manifest with path, upstream URL, author, pinned revision, license, alterations and SHA-256. Missing or incompatible provenance fails release. Provide in-app notices. Prefer CC0/OFL/ISC/MIT for the respective asset roles. A dependency license never grants rights to unrelated art or sounds.

## Primary references

- [Google Play target audience](https://support.google.com/googleplay/android-developer/answer/9867159)
- [Google Play Families policies](https://support.google.com/googleplay/android-developer/answer/9893335)
- [AdMob Flutter targeting](https://developers.google.com/admob/flutter/targeting)
- [Flutter rewarded ads](https://developers.google.com/admob/flutter/rewarded)
- [Firebase Analytics events](https://firebase.google.com/docs/analytics/flutter/events)
- [Apple App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Lucide license](https://lucide.dev/license)
