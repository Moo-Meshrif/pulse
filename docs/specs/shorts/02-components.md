# Shorts: components

| Component | Anatomy and variants | Used by |
|---|---|---|
| `ShortsSegment` | Two-option Following / For you segmented control; selected option is white with the shared selected-segment shadow | S1 |
| `ShortPlayer` | One video constrained above the fixed nav; media fills 9:16, other ratios are uncropped and padded; tap toggles pause | S1 |
| `ShortActionRail` | Creator avatar + follow badge, like/count, comments/count, share; targets at least 44 dp | S1 |
| `ShortMeta` | Handle, outlined Follow button when applicable, caption, original-audio row, overflow | S1 |
| `VideoProgress` | elapsed/total chip, muted toggle, bottom seek/progress track; timeline remains LTR in RTL | S1 |
| `ShortSourceCard` | Record (primary fill) and Upload (surface) cards, each with 56 dp icon tile and title/subtitle | S2 |
| `RecentVideoGrid` | Three equal columns, 2+ rows; video thumbnail r16 with duration chip; videos only | S2 |
| `ShortComposer` | Single-video preview; caption; visibility; Tag people, Location, Feeling/activity, Allow comments; trim and original-audio details; Share button | S3 |

All unshown pressed, disabled, focused, loading, empty, and error treatments reuse their matching shared/post components unless a screen specifies otherwise.
