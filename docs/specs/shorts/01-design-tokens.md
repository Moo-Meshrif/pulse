# Shorts: design tokens

Reuse all shared tokens in `../_theme/` and the documented app theme. No new global token set is needed.

| Token | Value | Use | Source |
|---|---|---|---|
| `videoChip` | shared `#161A19 @ 45%` | elapsed-time and duration chips over media | [seen] |
| `textOnPrimary` | shared white | media controls, action counts, captions | [seen] |
| `like` | shared `#E0323C` | follow badge and liked state | [seen] |
| `primary` | shared `#2E6B63` | Record card and selected actions | [user] |
| `primarySoft` | shared `#E2EEEB` | Upload icon tile | [seen] |
| `segmentTrack` | shared `#E3E7E5` | Following/For you segmented control | [seen] |

S1 applies top and bottom dark gradients over media only as needed for readable controls [estimated]. S2 uses the shared background/surface/card/radius tokens. The Short editor follows the New Post component language with a single-video preview [user].
