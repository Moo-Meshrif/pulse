# Shorts feed (S1)

Screenshot: `../screenshots/s1-shorts-feed.png`

Purpose / route: Shorts tab root. A light header sits above a vertically paged video feed. The fixed shared navigation is below, not over, the video [user].

## Layout tree

```text
Scaffold (background)
├─ Header (surface): “Shorts” · Following/For you segment · camera button
├─ Expanded ShortPlayer area (only the space above the fixed shared nav)
│  ├─ elapsed/total chip (start) · mute toggle (end)
│  ├─ vertical video or uncropped padded video
│  ├─ action rail (end): creator/follow · like · comment · share
│  ├─ metadata (bottom-start): handle + Follow · caption · original audio · overflow
│  └─ progress track (bottom)
└─ Shared fixed Facebook-style navigation (control dependency)
```

## Elements

| Element | Text / sample | Size / token | Notes |
|---|---|---|---|
| Header title | Shorts | `title` | [seen] |
| Segment | Following / For you | `segmentTrack`, selected surface | For you selected in the reference [seen] |
| Camera | icon only | 44 target | opens S2 [estimated] |
| Time chip | `0:14 / 0:38` | `videoChip`, `stat` | current and total duration [seen] |
| Mute | icon-only circle | 44 target, dark overlay | toggle audio [seen] |
| Creator rail | avatar, + follow badge | avatar ~72 [estimated] | profile on tap; badge follows [estimated] |
| Like / comment / share | `48.2K` / `1.2K` / Share | white overlay | shared actions [seen] |
| Meta | `@nour.surfs`, Follow, caption, Original sound | white overlay | caption truncates then expands [estimated] |

## States

- Loading: a media-shaped skeleton in the player area [user].
- Error: inline retry over the player [user].
- Empty Following: prompt to discover creators/Shorts [user].
- Offline: retain the latest loaded Short [user].
- Paused: show play affordance; visible Short otherwise auto-plays and loops [user].

## Strings

| Key | en | ar |
|---|---|---|
| `shortsTitle` | Shorts | الفيديوهات القصيرة |
| `shortsFollowing` | Following | أتابعهم |
| `shortsForYou` | For you | لك |
| `shortsFollow` | Follow | متابعة |
| `shortsShare` | Share | مشاركة |
| `shortsOriginalSound` | Original sound · {name} | الصوت الأصلي · {name} |

Counts, durations, @handles, and the media timeline remain LTR per `../_theme/rtl.md`.

## Behavior and navigation

- Vertical one-item paging; a change of visible item starts its playback, loops it, and updates the progress [user].
- Tap media pauses/resumes. Mute is per player/session [estimated].
- Following and For you switch their respective data feeds [user].
- Avatar/handle opens profile; Follow uses the existing follow action; like, comments, and Share use existing shared flows [user].
- Own-item overflow uses post-equivalent Edit, comments toggle, visibility, and Delete actions [user]. Other-user overflow reuses the Post options behavior [estimated].

## Data mapping

`ContentKind.short` and the existing shared post/content entities supply the author, video, caption, audience, counts, comments flag, and publish status. Following returns newest eligible public Shorts from followed accounts; For you ranks eligible public Shorts by engagement then recency [user].

## Responsive / a11y

Phone design only. The player reserves the shared nav height. Targets are >=44 dp, all icon buttons have labels, counts are announced with their action, and player state is announced. RTL mirrors header/action placement but not video, progress, durations, handles, or media controls.

## Acceptance checklist

- [ ] Header and video player match the source hierarchy.
- [ ] No video pixels appear under the fixed nav.
- [ ] Vertical paging, auto-play/loop, pause, mute, and the two feeds work.
- [ ] Action rail and metadata remain readable over video.
- [ ] Non-9:16 video is not cropped; 9:16 fills the player.
