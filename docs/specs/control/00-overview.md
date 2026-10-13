# Control page (MainShell): overview

Platform: Flutter, phone, 390 x 844 frame, **light only**, LTR + RTL, EN + AR [user]. Screenshots 720 px wide (1.846x). Source: `../home/source-tokens.md` section 1 (exact values [user] unless `[est]`) + `screenshots/`.
Theme: reuse `../_theme/` and `lib/core/theme/`; deltas in `01-design-tokens.md`. RTL: `../_theme/rtl.md`.

## Scope [user]
| In | Out |
|---|---|
| `MainShell`: 4 tabs + Create button, floating iOS-style glass nav bar, tab Navigators and state, back behavior, re-tap behavior, nav hiding, badges, Create sheet (opens from "+") | The tab pages themselves: they are features imported by the shell as they get built (Home exists in `../home`). Until then each tab shows a `PlaceholderScreen`. **New post** and **New short** are full screens of their own features (post / shorts), specced later when you re-send their screenshots; the shell only routes to them |

## Screens
| ID | Name | File | Screenshot | Route |
|---|---|---|---|---|
| S0 | Glass nav bar + shell | screens/s0-glass-nav.md | `screenshots/ref-nav-on-home.png` (bar at the bottom) | `/home` (shell root; tabs inside) |
| S1 | Create sheet | screens/s1-create-sheet.md | `screenshots/s1-create-sheet.png` | bottom sheet |

## Navigation map
```
/home (MainShell)  tab 0 Home | tab 1 Shorts | [+ Create] | tab 3 Chat | tab 4 Profile
  tab sub-pages push inside that tab's Navigator, nav stays visible
  "+"   --> S1 Create sheet --Post--> close sheet, push /create/post full screen (nav hidden; post feature)
                            --Short--> close sheet, push /create/short full screen (nav hidden; shorts feature)
                            --X / scrim / drag--> close
  full-screen routes (story viewer, create, comments, ...) are pushed on the root Navigator: nav hidden
  keyboard open: nav hidden
```
Slots: 0 Home, 1 Shorts, 2 Create (not a tab), 3 Chat, 4 Profile. Tab Navigators: Home, Shorts, Chat, Profile; the Create slot is never a tab (index mapping is an implementation detail for the builder).

## Structure advice for the plan (not code)
- `features/control_page` (name per repo convention) owns `MainShell`, nav widget, a small `ShellCubit` (selected tab, unread chat badge, nav visibility). Other features expose their root page via a use-case-free public screen widget registered with the shell; shell never imports their data/domain.
- Keyboard + full-screen hiding via a `NavVisibility` notifier the shell listens to; full-screen routes live on the root Navigator.
- Wrap each tab body in `AppSafeArea` with `bottomSpace` = nav clearance (104).
