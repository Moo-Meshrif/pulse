# Profile, own (S1)
Screenshot: `../screenshots/s1-profile.png`
Purpose / route: the signed-in user's profile; Profile tab root. `/u/:username` with the user's own username resolves here.

## Layout tree
```
Scaffold (background), scroll, content clears the nav bar (NavClearance)
├─ Cover 170 (user cover or default illustration) + buttons: share (left), sliders (right)
├─ Avatar 96 (ring), overlaps cover by 48
├─ Name (Sora 22/700) + verified badge (if is_verified)
├─ @username (bodySm textSecondary)
├─ Bio (body 15, max 3 lines)  [hidden when empty]
├─ Row ic_location 18 + city (bodySm textSecondary) [hidden when empty]
├─ StatsCard: Posts | Followers | Following
├─ Tabs: Posts | Shorts | Saved
└─ PostGrid 3 columns
```

## Elements
| Element | Text | Size | Token | Notes |
|---|---|---|---|---|
| share button | - | 44 circle | white @ 88%, icon textPrimary 22 | top-left, system share sheet with profile link |
| sliders button | - | 44 circle | same | top-right, opens S2 |
| name | full name | - | title Sora 22/700 | one line, ellipsis |
| username | "@dipprokash" | - | bodySm textSecondary | |
| stats | 248 / 12.4K / 386 | card ~68 | see tokens | K and M abbreviations |
| tab Posts/Shorts/Saved | - | ~45 | 15/600 | active underline primary |

## States
Loading: skeleton (header blocks + grid tiles). Empty Posts: `AppEmpty` ic_inbox "No posts yet" (+ "Share your first post" button to /create/post). Saved empty: "Nothing saved yet". Shorts: "coming soon" empty state. Error: retry. Offline: saved copy (existing profile local cache) for header; grid keeps last page.

## Strings
| key | en | ar (x-review) |
|---|---|---|
| profilePosts | Posts | المنشورات |
| profileFollowers | Followers | المتابعون |
| profileFollowing | Following | يتابع |
| profileTabPosts / Shorts / Saved | Posts / Shorts / Saved | المنشورات / الشورتس / المحفوظات |
| profileNoPosts | No posts yet | لا توجد منشورات بعد |
| profileNoSaved | Nothing saved yet | لا يوجد شيء محفوظ بعد |
| profileShortsSoon | Shorts are coming soon | الشورتس قادمة قريبًا |
| profileShareLink | link text for the share sheet | رابط الملف الشخصي |

## Behavior and navigation
Share: system share sheet with `https://<host>/u/<username>` [host unknown, Q-S1-1]. Sliders -> `/settings`. Followers / Following -> S13. Tile tap -> post page (existing). Saved tab = own saved posts (`post_saves`), private to the owner. Pull to refresh (`PagedScrollView`). Avatar tap: opens the photo full screen [user]: black background, the photo centered and pinch-zoomable, close button top-start; no photo (initials) = no action. Viewer design is UNKNOWN beyond this, see Q-S1-3.

## Data mapping
`profiles`: full_name, username, bio, city, avatar_url, cover_url (new), is_verified (new, admin-set). Counts: posts, followers (accepted follows), following via the profile RPC. Grid: `user_posts` RPC (own includes all visibilities); Saved: `post_saves` joined to posts.

## Responsive / a11y
Text scale 1.5: name wraps to 2 lines, stats label wraps. RTL: buttons swap sides, grid order mirrors, chevrons mirror. Labels: share "Share profile", sliders "Settings", tabs as buttons with selected state.

## Acceptance checklist
- Cover 170, avatar 96 overlaps 48, both round buttons 44 at 12 dp inset.
- Verified badge only for verified users; bio and location rows disappear when empty.
- Stats card r20 with 2 dividers; tab underline primary under the active tab.
- Grid 3 square tiles, gap 4, r10; nav bar floats over the last row without hiding it.
