# Interface and asset specification

Design baseline at 360×800 and 430×932 logical pixels, portrait; fit the board horizontally with 16 px side gutters, centered, and scale to available vertical safe area. Use 8 equal cells with 2 px gaps at baseline and fit the entire board above the tray. Keep the tray above system gesture insets, three equal hit zones of at least 48×48 logical px, and reserved feedback height so large scores and translated labels never shift the board mid-drag. At large text, allow chrome to scroll/reflow independently, preserve board geometry during gestures and provide tap-placement. Root surfaces: #121634 canvas, #20264A board, #30365C cell, #F7F8FF text, #B8C0E3 secondary. Pieces: #2DE1D2 cyan, #FFE05A yellow, #FF69B5 magenta, #FF926B coral, #A68CFF violet. Verify contrast on actual gradient backgrounds. Radius 16 panels, 12 controls, 6 cells. Fonts: system fallback plus licensed Noto where coverage requires. Score numerals tabular.

| Route | Top | Main | Bottom |
|---|---|---|---|
| Classic | Score, best, pause | Board and one-shot teaching cue | Three fixed tray slots |
| Result | Result and real record flag | Score, best, optional eligible undo | Play again; league access |
| League | Daily date, attempts, close time | Friends / Country / World, nearby rank and empty state | Play daily; selected week view |
| Profile | Nickname, public code | Country, recovery, friends and reports | Privacy and account actions |
| Settings | Localized title | Language, motion, audio, haptics, push | Legal, support, notices |

Brand mark is the original ceramic diagonal tile symbol committed under docs/media. README uses the original documentation pictograms. Runtime controls use a pinned Lucide subset; interactive labels must remain understandable without icons. Do not reuse store/game competitor assets. Contract sprite export: launcher adaptive foreground and opaque background for Android, monochrome themed mark, iOS opaque store master, web and legal favicon. QA at icon sizes 24, 48, and 192 px.

Motion uses stable position and glow, no screen-wide flash. First reveal is a single brand fade and never gates input beyond startup. Audio events: landing, clear, combo steps 2–4, multi-clear, record, gentle invalid return. Select at most one dominant cue per move (record > multi > combo > clear > land). Avoid per-cell playback. For a licensed candidate pack, pin its source, preserve licenses, and independently check each file's release terms. For the original mnemonic use D5, F#5, A5 with soft attack/decay; cap loudness and confirm on speakers. Ship assets locally; record source checksum and final checksum. Separate sound, music and haptic controls, respect platform focus, and never play after backgrounding.

Manual locale > ordered device locale > unambiguous OS region fallback > English. Country suggestion comes from OS region and can be changed before it freezes for a league week. Device language changes re-resolve only in automatic mode. Confirm source-language readability, pt-BR and Arabic pluralization, RTL focus order, bidirectional nickname isolation, and accessible tap-placement before release.
