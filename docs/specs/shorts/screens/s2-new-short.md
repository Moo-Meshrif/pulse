# New short (S2)

Screenshot: `../screenshots/s2-new-short.png`

Purpose / route: choose how to begin a new Short at `/create/short`; full screen with the shared nav hidden [estimated].

## Layout tree

```text
Scaffold (background, AppSafeArea)
└─ Column
   ├─ Title row: “New short” · X close
   ├─ Source row: Record card | Upload card
   ├─ “RECENT VIDEOS” section label
   ├─ Expanded 3-column recent-video grid (duration chips)
   └─ “Shorts can be up to 60 seconds and look best vertical (9:16).”
```

## Elements

| Element | Text | Size / token | Notes |
|---|---|---|---|
| Title | New short | `title` | [seen] |
| Close | X | 44 target | closes [seen] |
| Record | Record / Use your camera | primary card | opens shared Story recorder with this title [user] |
| Upload | Upload / From your gallery | surface card | video-only picker [user] |
| Recent videos | RECENT VIDEOS | `section` | [seen] |
| Video tiles | duration e.g. `0:24` | 3 columns, r16 [estimated] | videos only [user] |
| Help | Shorts can be up to 60 seconds and look best vertical (9:16). | `subtitle` | [seen]; 60 seconds confirmed [user] |

## States

- No recent videos: retain Record/Upload and show an empty picker state [estimated].
- Permission denied: reuse shared camera/media permission UI, with Short-specific copy/title [user].
- Clip over 60 seconds: continue to S3 only with a required trim range of 60 seconds or less [estimated].

## Strings

| Key | en | ar |
|---|---|---|
| `newShortTitle` | New short | فيديو قصير جديد |
| `newShortRecord` / `newShortRecordSub` | Record / Use your camera | سجّل / استخدم الكاميرا |
| `newShortUpload` / `newShortUploadSub` | Upload / From your gallery | رفع / من المعرض |
| `newShortRecent` | Recent videos | الفيديوهات الأخيرة |
| `newShortGuidance` | Shorts can be up to 60 seconds and look best vertical (9:16). | يمكن أن تصل مدة الفيديوهات القصيرة إلى 60 ثانية، وتبدو أفضل عموديًا (9:16). |

## Behavior and navigation

- Record reuses the Story video recorder and its permission flow, changing its title to “New short” [user].
- Upload and recent tiles accept videos only [user].
- A captured or selected clip opens S3. Close/back abandons the empty selection; a dirty flow confirms discard [estimated].

## Data mapping

Recent videos come from the device media picker, never from the network [estimated]. The selected clip is one Short draft, passed to S3 with duration, dimensions, poster, and source metadata.

## Responsive / a11y

Grid tiles and cards have >=44 dp targets; durations announce as video duration. RTL mirrors the content grid/order according to app rules, while duration remains LTR.

## Acceptance checklist

- [ ] Two cards, recent-video grid, duration chips, and 60-second guidance match the reference.
- [ ] Gallery and recents reject images; clips longer than 60 seconds require trimming before Share.
- [ ] Record opens the shared recorder under the Short title.
