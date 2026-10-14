# New post (S1)
Screenshot: `../screenshots/s1-new-post.png` (720 px wide). Opened from the Create sheet (`../../control/screens/s1-create-sheet.md`).
Purpose / route: compose and share a post (caption, photos/videos, location, comments on/off); `/create/post`, full screen, nav hidden [user].

## Layout tree
```
Scaffold (background)  [AppSafeArea]
└─ Column
   ├─ Title row: "New post" (start) ......... X close (end)
   ├─ Expanded SingleChildScrollView
   │  ├─ Composer card (surface r22): author row (avatar 44, name, visibility chip) / caption field / media strip / counter
   │  ├─ Section label "ADD TO YOUR POST"
   │  └─ Options card: Photo / video · Tag people · Location · Feeling / activity · Allow comments (switch)
   └─ "Share post" button pinned at the bottom (above keyboard/inset)
```

## Elements
| Element | Text | Size | Token | Notes |
|---|---|---|---|---|
| Title | "New post" | | title 22/700 | |
| Close | | 44 target, X 22 | textPrimary | `ic_close` |
| Avatar | initials "DS" or photo | 44 | `AvatarInitials` | the signed-in user |
| Name | "Dipprokash Sardar" | | name 15/700 | |
| Visibility chip | choice label ("Public" default) | h 28 | see tokens + S4 | icon per choice (`ic_globe` / `ic_audience` / `ic_star` / `ic_lock`) + `ic_chevron_down`; opens S4 (`s4-visibility.md`); narrowed choice = primary chip |
| Input | placeholder "What's on your mind?" | min ~96 | 17/400 | multiline, max 2000, autofocus off |
| Media strip | thumbs + Add tile | 104 | | horizontal scroll; thumb remove X; video duration chip |
| Counter | "0/2000" | | caption 12 | `danger` at 2000 |
| Photo / video row | "Photo / video", value "2 added" | 54 | | `ic_image` tile; opens picker |
| Tag people row | "Tag people" | | | `ic_tag_person`; **coming soon** [user] |
| Location row | "Location", value = chosen place ("Kolkata") | | | `ic_location`; opens S3 Add location (`s3-add-location.md`) |
| Feeling row | "Feeling / activity" | | | `ic_smile`; **coming soon** [user] |
| Allow comments | "Allow comments" | | | switch, default on |
| Share | "Share post" | h 56 | primary pill | |

## States
| State | UI |
|---|---|
| Empty | Share disabled; counter 0/2000; no media (strip shows only Add) |
| Has content | Share enabled when caption has text or >= 1 media [user] |
| Uploading | `PrimaryButton(loading: true)` (existing flag: disabled + pulse-line loader) and the rest of the screen non-interactive; no per-file progress [user] |
| Success | close screen, notice "Post shared"; Home feed refreshes [user] |
| Error | stay on screen, error notice with Retry (re-uploads only missing files) [user, default accepted] |
| Limit | counter turns `danger` at 2000; at 10 media the Add tile disappears |
| Coming soon | Tag people, Feeling rows tap -> notice "Coming soon" [user]. The chip opens S4 (Q1 answered) |
| Dirty close | X / system back with content -> discard confirm (ConfirmationDialog); no confirm when empty [user] |

## Strings (en | ar draft `x-review`)
| Key | en | ar |
|---|---|---|
| newPostTitle | New post | منشور جديد |
| newPostHint | What's on your mind? | بماذا تفكر؟ |
| visibility labels | see `s4-visibility.md` Strings (Public / Followers / Close friends / Only me) | |
| newPostAdd | Add | إضافة |
| newPostAddToPost | Add to your post | أضف إلى منشورك |
| newPostPhotoVideo | Photo / video | صورة / فيديو |
| newPostAdded | {count} added | تمت إضافة {count} |
| newPostTag | Tag people | وسم الأشخاص |
| newPostLocation | Location | الموقع |
| newPostFeeling | Feeling / activity | الشعور / النشاط |
| newPostAllowComments | Allow comments | السماح بالتعليقات |
| newPostShare | Share post | مشاركة المنشور |
| newPostShared (notice) | Post shared | تمت مشاركة المنشور |
| comingSoon (notice) | Coming soon | قريبًا |
| newPostDiscardTitle / body / keep / discard | Discard post? / Your post won't be saved. / Keep editing / Discard | تجاهل المنشور؟ / لن يتم حفظ منشورك. / متابعة التعديل / تجاهل |
| shareFailed (notice) | Couldn't share your post. Retry | تعذّرت مشاركة منشورك. أعد المحاولة |
Counter "72 / 500" style numerals follow the locale rule in `rtl.md`.

## Behavior and navigation
- X / back: close, or discard confirm if there is any content [estimated].
- Add tile and "Photo / video" row open the gallery picker (photos + videos, multi-select up to the remaining slots); camera not included now [user default]. Selected items appear as thumbs; X removes; order = selection order (reorder not specced).
- Location row: opens S3 (list picker: current, nearby, recent, search) and returns the place name or none. Allow comments writes `posts.comments_enabled` (needs `create_post` param, Q2).
- Share: client generates the post id (uuid v4), compresses/measures media (width, height, duration, blurhash for images), uploads to `post-media/{uid}/{postId}/{n}.ext` (video poster `{n}_thumb.jpg`), then calls `create_post` once [schema]. Atomic server-side; client cleans uploaded files if the call fails [estimated].

## Data mapping
| UI | Source |
|---|---|
| Avatar, name | signed-in profile (profile use case; no `auth` or profile model imports) |
| Caption | input -> `p_caption` (trim) |
| Media | picker -> uploads -> `p_media` jsonb |
| Location value | S3 result (display name) -> `p_location` |
| Allow comments | `comments_enabled` (Q2) |
| Visibility | S4 choice -> `p_visibility`; default from `profiles.default_post_visibility` (Public; Followers when the account is private) |
| Create | `CreatePostUseCase` (post feature, to add to `00-data-layer.md`) |

## Responsive / a11y
`ContentWidth` on wide screens. Keyboard: Share stays visible above it; fields scroll into view. Targets >= 44. Semantics: remove buttons "Remove photo {n}", switch with label, counter announced at limit. RTL: title/X, chip, thumbs strip, chevrons mirror; the input aligns to the text direction.

## Acceptance checklist
- [ ] Title row, white composer card, grey section label, white options card, green pill at the bottom.
- [ ] Thumbs 104 r16 with dark X and duration chip on the video; dashed green "+ Add" tile.
- [ ] Counter bottom-end, "0/2000".
- [ ] Switch green when on, default on.
- [ ] Share disabled when empty; enabled with text or media.
- [ ] Coming-soon rows give a notice and do nothing else.
- [ ] AR: mirrored layout, Arabic font.
