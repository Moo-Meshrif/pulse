# Shorts feature: overview

Platform: Flutter phone, 390 × 844 design frame, light mode, LTR + RTL, EN + AR [user]. Sources: `screenshots/s1-shorts-feed.png` and `screenshots/s2-new-short.png` (both 720 × 1559 px), with no Figma [user]. Reuse `../_theme/`, `lib/core/theme/`, and `../_theme/rtl.md`.

Shorts are a vertical, one-video-at-a-time feed. A Short is one video, maximum 60 seconds [user]. The existing shared media policy currently permits 90 seconds, so implementation must change that limit to 60 seconds [user]. Use `ContentKind.short`, shared content publishing, post visibility, follow, report, comment, and action flows; do not duplicate their data layer.

## Scope

| In | Out / dependency |
|---|---|
| Shorts tab, paged player, reactions, creation entry, video-only picker, recording handoff, Short editor and publishing | Music library (TODO); shared fixed Facebook-style navigation update belongs to `control` |

The shared nav is fixed on every page; in Shorts the video lays out only in the area above it, never underneath it [user]. This supersedes the control feature's floating/glass-nav behavior and must be planned as a dependency.

## Screens

| ID | Name | Source | Route |
|---|---|---|---|
| S1 | Shorts feed | `screenshots/s1-shorts-feed.png` | Shorts tab root |
| S2 | New short | `screenshots/s2-new-short.png` | `/create/short` |
| S3 | Short editor | no screenshot; reuse New post composition patterns | `/create/short/edit` |

## Navigation map

```text
Shared nav → Shorts tab → S1
S1 camera → S2
S2 Record → shared Story video recorder (title: “New short”) → S3
S2 Upload/recent video → video-only picker → S3
S3 Share → publish short → S1 (refresh)
S1 creator / Follow → profile / existing follow action
S1 comments / share / overflow → shared comments / system share / post-equivalent options
```

## Data and behavior

- **Following:** newest eligible public Shorts from followed accounts [user].
- **For you:** eligible public Shorts, ordered by engagement and recency [user].
- Page vertically, auto-play and loop the visible item, and tap a video to pause/resume [user].
- Use the video’s original audio only; a selectable music library is explicitly deferred [user].
- Accept non-9:16 clips, preserve the video without cropping, and use padding/background in the vertical player; 9:16 is recommended [user].

## Files

`01-design-tokens.md` · `02-components.md` · `screens/` · `assets.md` · `open-questions.md` · `progress.md`
