# Pulse · Main shell + Home feed — design tokens

Source: canvas boards **3.1 Home feed**, **3.5 Create sheet**, **3.8 Activity**, **5.6 Page loading**. Frame 390 × 844, 1 px = 1 dp. Values are exact from the design unless marked `[est]`.
Colors refer to the existing `AppColors` (primary `#2E6B63`, background `#F3F4F3`, surface `#FFFFFF`, textPrimary `#161A19`, textSecondary `#5B6461`, iconInactive `#3D4644`, border `#D5DAD8`, divider `#E3E6E4`, like `#E0323C`, scrim `#161A19` @ 40%). Only **new** tokens are listed as new.

---

## 1. Main shell (control page)

`MainShell` owns the 4 tabs and the floating nav. Tabs keep their state (`IndexedStack` or `StatefulShellRoute`-style), each tab has its own `Navigator` so sub-pages push *inside* the tab and the nav stays visible.

| Slot | Tab | Icon (inactive → active) | Notes |
|---|---|---|---|
| 0 | Home | `ic_home` → `ic_home_filled` | default tab |
| 1 | Shorts | `ic_shorts` → `ic_shorts_filled` | light page, same nav |
| 2 | **Create** (not a tab) | `ic_plus` 26, stroke 1.9 | opens the Create sheet (3.5), never selected |
| 3 | Chat | `ic_chat` → `ic_chat_filled` | unread count badge |
| 4 | Profile | `ic_profile` → `ic_profile_filled` | |

No text labels under icons (labels are Semantics only).

### 1.1 Floating "liquid glass" nav bar

| Token | Value |
|---|---|
| Position | `left 16 · right 16 · bottom 18` + `MediaQuery.viewPadding.bottom` |
| Height | **68** |
| Inner padding | 6 all sides |
| Radius | 34 (pill) |
| Fill | `#FFFFFF` @ **55%** |
| Blur | `BackdropFilter` σ **22** (+ saturation 1.8 on web/CSS; Flutter: blur only) |
| Border | 1 px `#FFFFFF` @ 80% |
| Shadow | `0 12 32` `#161A19` @ 16% |
| Inner highlight | top 1 px `#FFFFFF` @ 95%, bottom 1 px `#FFFFFF` @ 35% (paint as a gradient border or skip on low-tier devices) |
| Item | flex 1, height 56, gap between items 4 |
| Icon size | 22 (stroke 1.8); Create plus 26 (stroke 1.9) |
| Inactive icon color | `iconInactive` `#3D4644` |
| Active icon color | `primary` (filled variant) |
| **Active bubble** | 44 circle, `#FFFFFF` @ 85%, shadow `0 3 10` `#161A19` @ 12%, inner top highlight `#FFFFFF` |
| Bubble motion | slides to the new item 220 ms `Curves.easeOutCubic`; icon cross-fades to filled 150 ms |
| Tap target | full item (≥ 56 × 56) |

**Content clearance:** every tab's scroll view needs bottom padding **104** (68 + 18 + 18) + `viewPadding.bottom`, so the last item scrolls above the bar.

**Low-tier devices:** drop the blur and use `#FFFFFF` @ 92% with the same border and shadow (blur is the most expensive layer on scroll).

### 1.2 Badges

| Badge | Spec |
|---|---|
| Count (Chat) | min 18 × 18, radius 9, `like` `#E0323C`, text 10 / 700 white, horizontal padding 4, border 2 `#FFFFFF` @ 90%; anchor `top 9`, start `50% + 3` of the item. `99+` above 99. |
| Dot (Home header bell) | 9 × 9, `#E0323C`, border 2 `background`; anchor `top 9 · end 10` inside the 44 button |

RTL: the count badge anchors at `50% − 3` from the *end* (mirrors). The nav order mirrors (Home is on the right in AR).

### 1.3 Create sheet (from the plus)

| Token | Value |
|---|---|
| Scrim | `scrim` (#161A19 @ 40%), tap closes |
| Sheet | `surface`, top radius 28, padding 10 16 32 16, shadow `0 -10 40` @ 18% |
| Grabber | 40 × 5, radius 3, `border` |
| Title | "Create", Sora 20 / 700, letter-spacing −0.3 |
| Close | 44 circle, `background` fill, X 18 stroke 2.4 — at the **end** |
| Option row | padding 16, radius 20, fill `background`, gap 14, chevron 18 `textSecondary` |
| Option icon tile | 48, radius 16, `primarySoft` fill, icon 24 `primary` |
| Title / subtitle | 16 / 700 · 13 / 400 `textSecondary`, gap 2 |
| Rows gap | 10 |

### 1.4 Back behavior

- System back on a tab's sub-page pops inside that tab.
- On a tab root other than Home → go to Home.
- On Home root → leave the app (Android).
- Re-tapping the active tab: pop that tab to root; if already root, scroll to top (+ refresh on Home).

---

## 2. Home feed

### 2.1 Header

| Token | Value |
|---|---|
| Padding | 20 16 8 16 (+ status bar inset) |
| Logo tile | 28, radius 9 (existing mark) |
| Wordmark | "pulse", Sora 24 / 700, letter-spacing −0.5, gap 8 |
| Actions | Search, Activity bell — 44 circle buttons, icon 24, gap 4 |
| Bell dot | see 1.2; shown when activity unread > 0 (= unread notifications + follow requests, `GetUnreadActivityCountUseCase`) |
| Behavior | scrolls away with content; reappears on scroll-up `[est]` (SliverAppBar floating, snap) |

### 2.2 Story rail ("Trending" row)

| Token | Value |
|---|---|
| Section title | "Trending" → rename to **"Stories"** `[proposal]`; 17 / 600, margin 4 16 10 16 |
| Row | horizontal list, padding 4 16 12 16, item gap 14 |
| Item | avatar 64 + label 12 `textSecondary`, gap 6, label max 1 line, width 64 |
| Unseen ring | 2.5 `primary`, inner padding 3 |
| Seen ring | 2.5 `border` `#D5DAD8` `[est]` |
| "Your story" | 64 circle, `primarySoft` fill, dashed 2 `primary` border, plus 24 stroke 2 `primary` |
| Data | `story_rail()` — me first, then unseen, then latest |
| Empty | only "Your story" shows |

### 2.3 Post card

| Token | Value |
|---|---|
| List padding | 4 12 0 12, card gap **12** |
| Card | `surface`, radius **22**, padding 12 12 6 12, no shadow |
| **Author row** | gap 10 |
| Avatar | 40 circle; ring = 2 `surface` gap + 2 **`avatarRing` `#9DBDB7`** (new) |
| Avatar fallback | initials 15 / 700 white on the stable-hash palette color |
| Name | 15 / 700 `textPrimary`, 1 line, ellipsis |
| Meta | 12 / 400 `textSecondary` — `{city} · {relative time}` (city omitted when empty) |
| Options | 44 button, dots icon 22 `textSecondary` |
| **Caption** | 14 / 400, line-height 1.45, margin 10 2 10 2; collapse after 3 lines with "more" 14 / 600 `textSecondary` `[est]` |
| Caption only (no media) | margin 10 2 4 2 |
| **Media** | width = card inner width (366 − 24 = **342** at 390), radius **16** |
| Media height | from aspect ratio of item 0, clamped **4:5 (portrait) … 1.91:1 (landscape)**; `[est]` 200 shown in mock = 1.71:1 |
| Multiple media | horizontal `PageView`, page dots below: 6 × 6, gap 4, active `primary`, inactive `border`; counter chip top-end "1/4": 12 / 600 white on `#161A19` @ 55%, radius 10, padding 4 8 `[est]` |
| Video | autoplay muted when ≥ 60% visible, one at a time; mute toggle 32 circle bottom-end, `#161A19` @ 55%, icon 16 white; duration chip bottom-start same style `[est]` |
| Placeholder | `blurhash` painted at media size until the first frame/image is ready |
| **Action bar** | padding-top 4, gap 4, height 44 |
| Like / Comment | 44 high, min-width 44, padding 0 8, radius 22, icon 24 stroke 1.8, count 13 / 600, gap 6 |
| Share | 44 circle, icon 23 |
| Save | 44 circle at the end, icon 22; saved = filled `textPrimary` |
| Liked | heart filled + stroke `like` `#E0323C`; pop 1 → 1.2 → 1, 180 ms; double-tap on media likes + big heart 80 white @ 90% fading 600 ms `[est]` |
| Counts | `1.2K`, `7.5K`, `2.1M` (one decimal under 10, none above); 0 shows no number |
| Relative time | `now`, `5m`, `2h`, `1d`, `3w`, then `12 Mar` (AR localized) |

### 2.4 States (use 5.6 Page loading)

| State | UI |
|---|---|
| First load | header + nav visible; `PulseLoader(width: 120)` centered + "Loading your feed…" 14 `textSecondary`, 16 below; after 300 ms |
| Pull to refresh | 64 band under the header, `PulseLoader(width: 56)`; content keeps its place |
| Load more | 72 band at the end, `PulseLoader(width: 44)`; trigger 3 cards before the end |
| Empty (follows nobody / no posts) | icon tile 80 `primarySoft` + "Your feed is quiet" Sora 18 / 700 + "Follow people to see their posts here." 14 `textSecondary` + soft pill "Find people" → suggestions (`GetSuggestedProfilesUseCase`) |
| Error first load | same layout as empty with `ic_cloud_alert` / `ic_wifi_off`, "Try again" primary button |
| Error on load more | inline row "Couldn't load more · Retry" 13 / 600 `primary` |
| End of feed | "You're all caught up" 13 `textSecondary`, centered, 48 band |

### 2.5 New tokens to add

```dart
// app_colors.dart (new)
static const avatarRing = Color(0xFF9DBDB7);
static const glassFill  = Color(0x8CFFFFFF); // white 55%
static const glassBorder= Color(0xCCFFFFFF); // white 80%
static const mediaChip  = Color(0x8C161A19); // #161A19 55%

// app_dimens.dart (new, scaled with AppScale except tap targets)
class NavDimens {
  static const height = 68.0, sideInset = 16.0, bottomInset = 18.0;
  static const padding = 6.0, itemHeight = 56.0, itemGap = 4.0;
  static const bubble = 44.0, icon = 22.0, plusIcon = 26.0;
  static const blurSigma = 22.0, radius = 34.0;
  static const contentClearance = 104.0; // + viewPadding.bottom
  static const badgeMin = 18.0, dot = 9.0;
}
class FeedDimens {
  static const listPadH = 12.0, cardGap = 12.0, cardRadius = 22.0;
  static const cardPad = EdgeInsets.fromLTRB(12, 12, 12, 6);
  static const avatar = 40.0, avatarRingGap = 2.0, avatarRingWidth = 2.0;
  static const mediaRadius = 16.0;
  static const mediaMinAspect = 4 / 5, mediaMaxAspect = 1.91;
  static const actionHeight = 44.0, actionIcon = 24.0;
  static const story = 64.0, storyRing = 2.5, storyGap = 14.0;
}
```

Text styles (all existing scale): name `bodyStrong` 15/700 · meta `caption` 12/400 · caption `body` 14/400 h1.45 · counts 13/600 · section 17/600 · wordmark Sora 24/700.

---

## 3. Data the screens need (→ `20261012120000_home_feed.sql`)

| UI | Call | Returns |
|---|---|---|
| Feed page | `rpc('home_feed', {p_limit: 20, p_before_created, p_before_id})` | posts with author, counts, `liked_by_me`, `saved_by_me`, `media[]` |
| Like / unlike | `rpc('set_post_like', {p_post, p_liked})` | new `like_count` (optimistic UI, reconcile) |
| Save / unsave | `rpc('set_post_save', {p_post, p_saved})` | bool |
| Story rail | `rpc('story_rail')` | authors + `story_count`, `all_seen` |
| Media URLs | `storage.from('post-media').createSignedUrls(paths, 3600)` | signed URLs; use the **path** as the image/video cache key |
| Create post | upload to `post-media/{uid}/{postId}/{n}.ext` → `rpc('create_post', …)` | post id |

Not in this migration (later): notifications/activity feed, blocks, hashtags/search, shares count, Shorts feed RPC (table already supports `kind = 'short'`), expired-story cleanup job.
