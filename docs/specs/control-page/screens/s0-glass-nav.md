# Glass nav bar + shell (S0)
Screenshot: `../screenshots/ref-nav-on-home.png` (bar at the bottom; home content scrolls behind it). Tokens: `../01-design-tokens.md`.
Purpose / route: `MainShell` at `/home`; floating iOS-style liquid-glass nav bar [user].

## Layout tree
```
MainShell
└─ Stack
   ├─ IndexedStack: Navigator(Home) | Navigator(Shorts) | Navigator(Chat) | Navigator(Profile)
   └─ Positioned(start 16, end 16, bottom 18 + viewPadding.bottom): GlassNavBar (h 68, r34)
        └─ Row(padding 6, gap 4): [Home][Shorts][+][Chat + badge][Profile]  (bubble behind active)
```

## Elements
| Element | Icon | Size | Color | Notes |
|---|---|---|---|---|
| Home | `ic_home` → `ic_home_filled` | 22 | iconInactive → primary | default tab |
| Shorts | `ic_shorts` → `ic_shorts_filled` | 22 | same | light page, same nav |
| Create | `ic_plus` | 26 stroke 1.9 | iconInactive | not a tab, opens S1, never selected |
| Chat | `ic_chat` → `ic_chat_filled` | 22 | same | count badge (4 hardcoded) |
| Profile | `ic_profile` → `ic_profile_filled` | 22 | same | |
| Bubble | - | 44 | white @85% | slides 220 ms |

## States
Visible / hidden (keyboard open or full-screen route: slides down 200 ms). Badge hidden at 0, "99+" above 99.

## Strings (en | ar draft `x-review`; Semantics only, no visible text)
| Key | en | ar |
|---|---|---|
| navHome | Home | الرئيسية |
| navShorts | Shorts | الفيديوهات القصيرة |
| navCreate | Create | إنشاء |
| navChat | Chat | الدردشة |
| navProfile | Profile | الملف الشخصي |
| navUnread | {count} unread | {count} غير مقروءة |

## Behavior and navigation
- Tap tab: switch (bubble slide 220 ms, icon cross-fade 150 ms), haptic selectionClick [user]. Tap "+": haptic, open S1.
- Each tab has its own Navigator; sub-pages push inside it and the nav stays visible.
- Back: pop inside the tab; on a tab root other than Home go to Home; on Home root leave the app (Android).
- Re-tap active tab: pop to root, else scroll to top (+ refresh on Home).
- Nav hides when the keyboard is open and on full-screen routes (story viewer, create, comments) [user]; tab sub-pages keep it.
- Always blur (sigma 22); flat fallback constant kept, no detection [user].
- Every tab scroll view reserves bottom padding 104 + viewPadding.bottom.

## Data mapping
Chat badge: `ShellCubit.unreadChat`, hardcoded 4 for now [user]; later supplied by the chat feature. No other data.

## Responsive / a11y
- Wide screens: bar capped at the shared max content width and centered (`ContentWidth`) [user].
- Tap targets >= 56 x 56. Each item has a Semantics label + selected state; badge announces "{count} unread".
- RTL: item order mirrors (Home on the right in AR); badge anchors at 50% − 3 from the end; icons are not mirrored except per `rtl.md`.
- Reduce motion: bubble moves instantly, no icon cross-fade [user].

## Acceptance checklist
- [ ] Pill floats 16/16/18 above the bottom inset, height 68, content visibly blurred behind it.
- [ ] Active tab: filled icon in primary on a white bubble; others iconInactive.
- [ ] "+" is bigger (26) and never shows the bubble.
- [ ] Chat badge "4": red, white 2 px ring, top of the item, near its centre.
- [ ] Last list item scrolls fully above the bar.
- [ ] Hides under the keyboard and on full-screen routes.
- [ ] AR: order and badge mirror.
