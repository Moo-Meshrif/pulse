# Control page: open questions
| # | Question | Options | Status |
|---|---|---|---|
| Q1 | Create sheet icons | - | **answered**: user added `assets/icons/ic_create_post.svg` and `ic_create_short.svg` (verified present) |
| Q2 | Sheet bottom padding: tokens say 10 16 32 16, the Post options board says 34 | 32 / 34 | **answered** [user]: 34 for both sheets (shared shell) |
| Q3 | Shell tab Navigator index mapping and the exact public API features use to register a tab root | decide in plan | pending (plan) |
| Q4 | Low-tier fallback | - | **answered, then changed [user, 2026-10-19]**: low-tier Android (low-RAM flag, <= 3 GB RAM or SDK < 29) keeps the same look with a lighter blur (sigma x 0.45, fixed instead of animated); `glassFillFlat` stays unused unless the blur still janks on a real device (`core/services/device_tier.dart`, `BackdropBlur`) |
| Q5 | Chat badge value | - | **answered**: hardcoded 4 for now [user] |
| Q6 | Haptics | - | **answered**: selectionClick on tab change and "+" [user] |
| Q7 | Create taps | - | **answered**: close sheet, push full-screen over the shell, nav hidden [user] |
| Q8 | New post screen | - | **done**: specced in `../post/screens/s1-new-post.md` (post feature), with Add location S3 |
| Q9 | New short screen | - | **closed** [user]: belongs to the shorts feature, specced later there; the shell only routes `/create/short` to a placeholder |
| Q10 | Arabic strings | review | `x-review` |
| Q11 | Wide-screen and reduce-motion behavior | - | **answered** [user]: nav capped at the shared max width and centered; reduce motion = instant bubble move, no icon cross-fade |
