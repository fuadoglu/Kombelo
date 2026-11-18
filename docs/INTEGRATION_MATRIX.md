# Ads, telemetry and notification contracts

| Audience/state | Classic | Public features | Ads | Product analytics and engagement push |
|---|---|---|---|---|
| Unknown age | Available | Disabled pending eligibility | Off | Off |
| Child or restricted account | Available | Disabled | Off | Off |
| Eligible, consent unavailable or pending | Available | Subject to account eligibility | Off until permitted | Off for consent-gated collection; push separately opt-in |
| Eligible, choices resolved | Available | Enabled with abuse controls | Only permitted requests and formats | Use relevant collection consent and explicit push preferences |
| Revoked or configuration stale beyond TTL | Available | Governed by server eligibility | Stop new requests and discard queued inventory as required | Stop affected collection and suppress future deliveries |

Verify Google Play audience, regional consent, Safe SDK inventory, Google UMP privacy-options UI and Apple release requirements before live startup. SDK defaults must enforce zero advertising and marketing collection before eligibility. Developer fixtures and signed test builds use test inventory. No production SDK grants from preview. Maintain store declarations and privacy notice against actual network capture.

| Event | Once per | Allowed params |
|---|---|---|
| onboarding_complete | first success | version, locale |
| round_start / round_end | run start / terminal outcome | mode, rules_version, duration_bucket on end, score_bucket on end |
| combo_milestone | threshold per run | mode, threshold (2, 3, 5, 8) |
| record_break | finalized record | mode, score_bucket |
| ranked_submit | terminal submit outcome | outcome, rules_version |
| ad_offer / ad_earned | eligible offer / consumed entitlement | placement, format |
| notification_open | validated open | kind, target_status |

Use enumerated values, no input coordinates, nickname, email, public code or raw push tokens. Keep debug analytics separate and handle failures outside gameplay. Separate consent, SDK availability and remote kill switches. Use SDK impression callbacks for revenue reporting where allowed, with no duplicate custom reporting. Monitor D1/D7 and ad exit with a predefined analysis cohort and distinguish missing consent from zero activity.

Deduplicate daily push by player and local date, and friend activity by verified relationship and event ID; both share a one-per-local-day engagement cap. Recheck opt-in, quiet hours, block list, audience and target freshness at dispatch. Outbox retries keep the same ID. Choose a single active installation per player for the daily campaign. Handle spring/fall DST using IANA zones; if no eligible delivery window remains, expire without catch-up.
