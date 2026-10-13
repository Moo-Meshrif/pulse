# Control page: components
Reuse: `AppSafeArea`, `AppSvgIcon`, `PlaceholderScreen`, existing bottom-sheet shell if any (`AppDialogShell` is for dialogs; the Create sheet shell is shared with the post options sheet (post feature S2): build one shared `AppBottomSheet` in `lib/core/widgets/` [proposal]).

| ID | Component | Where | Notes |
|---|---|---|---|
| C1 | MainShell | feature | `Scaffold` + `Stack`: `IndexedStack` of 4 tab Navigators (state kept) + nav overlay. Back behavior: pop inside the tab; on a non-Home tab root go to Home; on Home root leave the app (Android). Re-tap active tab: pop to root; if already root, scroll to top (+ refresh on Home) |
| C2 | GlassNavBar | feature | Floating pill, 5 items, no labels (Semantics only). Blur + fill + border + shadow + highlight gradient border |
| C3 | NavItem | feature | 56 high, flex 1, icon 22 (plus 26), inactive `iconInactive`, active `primary` filled variant |
| C4 | NavBubble | feature | 44 white @85% circle behind the active tab; slides 220 ms; hidden when Create is the only touched item (Create is never selected) |
| C5 | NavBadge | feature | Count badge on Chat (value from `ShellCubit.unreadChat`, **hardcoded 4 for now** [user], remove when chat exists) |
| C6 | CreateSheet | feature | Title row + 2 option rows (C7); modal bottom sheet over the shell |
| C7 | CreateOptionRow | feature | Icon tile 48 + title/subtitle + chevron; RTL chevron mirrors |

## States
| Component | States |
|---|---|
| NavItem | inactive, active (filled + bubble), pressed (ripple-free; 90% opacity [user]) |
| NavBadge | hidden (0), 1-99, "99+" |
| GlassNavBar | visible, hidden (keyboard / full-screen route, 200 ms slide down) |
| CreateOptionRow | default, pressed |
