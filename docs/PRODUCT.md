# Product and interaction specification

## Board and score

Use 8×8 portrait board coordinates, row and column 0–7, immutable shape masks with explicit orientation and three stable tray slots. No rotation gesture. Any unused slot may be played first. Validate bounds and overlap, apply occupied cells, detect all full rows and columns from one post-placement snapshot, and clear their union. Score the lines separately. Refill when all slots are used, then check remaining legal placements. Classic ends only when no remaining piece fits. Ranked also ends at its move cap. Colors are cosmetic.

Initial balance fixture: placed cells + 10 × cleared lines + 5 × n × (n−1) + 3 × min(9, chain−1) on a clearing move, with n the cleared-line count. A clear increments the consecutive-clear chain once; a non-clearing placement resets it. Render “3 combo” as chain length, never as a score multiplier. Validate with human sessions and seeded simulations before production; freeze the finalized integer formula per rules version. Classic uses fixed versioned shape weights and seeded randomness per round; reject pathological catalog weights in simulation. No ad-, locale-, spend- or score-dependent piece manipulation. Ranked uses a published-bundle digest and fixed sequence, including colors and orientations.

## Screens and onboarding

- Launch shows the OS splash only while startup requires it. In-app brand flash is a soft single non-flashing reveal with a 350 ms ceiling and no artificial wait. Reduced motion uses a static mark. Returning players enter the persisted route without replaying onboarding.
- First Classic opens a playable board with one setup cue and a dismissible instruction. Teach placement by doing, then reveal clear and combo meaning at the first occurrence. No forced account, ad or push request before play.
- Game shows score, best, board, three thumb-reachable tray slots and pause. Pause contains resume, restart confirmation and settings. Classic result prioritizes Play again. Ranked result shows pending/confirmed state plus friends, country and world tabs. Deep links resolve the relevant board or the closed result.
- Profile supports nickname, friend code, country and account recovery/deletion. Settings include locale, audio, haptics, motion, notification preferences, privacy options, licenses and legal links. Empty, offline, loading, expired and failure states have explicit copy and a recovery action.

## Input and presentation

One pointer owns the drag. Large non-overlapping tray hit areas respect safe areas and system gestures. Derive a thumb lift from layout, freeze it throughout the gesture, use small grid-edge hysteresis and show one authoritative valid preview. Commit only the displayed target if still valid and within release tolerance. Invalid or interrupted drags return without state changes. Second touches cannot steal ownership. Support accessible tap-select and tap-position with semantic feedback and keyboard support on the preview.

Use deep indigo board, glossy ceramic pieces in cyan, yellow, magenta, coral and violet, clear empty-cell edges and recognizable outlines. Create an original app icon showing a diagonal arrangement of three ceramic cells and one short line-clear trail. Keep the silhouette readable at launcher size. Use Lucide outline icons only for interface controls. Build dark board surfaces, legible text, visible focus and safe touch targets. Board geometry never mirrors in RTL.

Use 70–100 ms landing and 140–220 ms line wave as tuning defaults. Repaint effects independently. Logical clears are immediate and the next piece can be picked up while the effect finishes. Stale animation never covers the active preview. Never use full-screen strobing or repeated bursts. Prioritize record fanfare > multi-line clear > combo note > placement sound; collapse same-move cues and bound polyphony. Preload short locally bundled samples, preserve device silent/audio-focus behavior and offer independent SFX, music, haptics and reduced motion. Use an original three-note mnemonic for Kombelo, not a sample pack's recognizable melody.

## Locale and audience

Use first supported match from ordered OS language preferences, keeping explicit script/region when supported, then an OS/explicit region fallback when it maps unambiguously to a supported locale, then English. Manual preference wins and persists. Region suggestion is independently derived from OS region and confirmed by the player for rankings. No GPS or IP-based locale guessing. Test AZ, EN, TR, RU, ES, pt-BR, DE, FR, AR, mixed-script nickname text, larger text and missing translation fallback. Use a higher launch bar for forms, accessible contrast and Arabic layout; see release gates.
