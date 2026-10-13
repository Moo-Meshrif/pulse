# Create sheet (S1)
Screenshot: `../screenshots/s1-create-sheet.png` (720 px wide). Opened from the nav "+" (S0). Tokens: `../01-design-tokens.md` > Create sheet.

## Layout tree
```
Scrim (40%, tap closes) + bottom sheet (surface, top r28, shadow, AppSafeArea bottomSpace = sheet bottom padding)
├─ Grabber 40 x 5
├─ Row: "Create" (Sora 20/700)  ............  X (44 circle, background fill) at end
├─ CreateOptionRow: [48 tile primarySoft: `ic_create_post` 24 primary] "Post" / "Share photos, videos or text in your feed"  ›
└─ CreateOptionRow: [48 tile primarySoft: `ic_create_short` 24 primary] "Short" / "Record or upload a vertical video, up to 60s"  ›
```

## Elements
| Element | Text | Size | Color | Font | Spacing |
|---|---|---|---|---|---|
| Title | "Create" | - | textPrimary | `titleSm` Sora 20/700 ls -0.3 | |
| Close | - | 44 circle, X 18 stroke 2.4 | background / textPrimary | - | end |
| Row | - | r20, padding 16 | background | - | rows gap 10, content gap 14 |
| Icon tile | - | 48 r16, icon 24 | primarySoft / primary | - | |
| Row title | "Post" / "Short" | - | textPrimary | 16/700 | |
| Row subtitle | see above | - | textSecondary | 13/400 | gap 2; wraps to 2 lines |
| Chevron | - | 18 | textSecondary | - | end, mirrors in RTL |

## Strings (en | ar draft `x-review`)
| Key | en | ar |
|---|---|---|
| createTitle | Create | إنشاء |
| createPost | Post | منشور |
| createPostSub | Share photos, videos or text in your feed | شارك صورًا أو فيديوهات أو نصًا في خلاصتك |
| createShort | Short | فيديو قصير |
| createShortSub | Record or upload a vertical video, up to 60s | سجّل أو ارفع فيديو عموديًا حتى 60 ثانية |
| close (semantics) | Close | إغلاق |

## Behavior and navigation
Scrim tap, drag down, X or system back close it. Post → close, push `/create/post` full screen (post feature, nav hidden). Short → close, push `/create/short` full screen (shorts feature, nav hidden); both are placeholders until those features exist [user]. The sheet slides up over the nav.

## Data mapping
Static; none.

## Responsive / a11y
Sheet capped at the shared max width on wide screens, centered. Rows >= 56 high, Semantics = title + subtitle, button role. RTL: close X at the end (left in AR), chevrons mirror.

## States
Closed, open, row pressed.

## Acceptance checklist
- [ ] Dim scrim, white sheet r28 with grabber.
- [ ] "Create" title with 44 grey X at the end.
- [ ] Two grey rows with soft-green icon tiles, 16/700 title and 13 grey wrapping subtitle, chevron at the end.
- [ ] Both rows close the sheet and open their full-screen route.
