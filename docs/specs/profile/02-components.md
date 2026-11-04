# Profile: components

Shared across the screens; each lives in `features/profile/presentation/widgets/` unless used by another feature (then `core/widgets/`). Values: `01-design-tokens.md`.

| Component | Anatomy | Variants / states | Used in |
|---|---|---|---|
| ProfileHeader | cover, 2 round buttons, avatar, name (+verified, +"Follows you"), @handle, bio, location, followed-by row | own / other; cover default illustration or gradient | S1, S12 |
| StatsCard | 3 columns with dividers: number (Sora 18/700) + label | numbers abbreviated 12.4K; tappable Followers/Following | S1, S12 |
| ProfileTabs | text tabs, active underline | own: Posts/Shorts/Saved; other: Posts/Shorts/Tagged (icon + label) | S1, S12 |
| PostGrid | 3-col square grid, r10, gap 4 | loading skeleton, empty, paged | S1, S12 |
| FollowButtons | primary button + outline Message | Follow / Follow back / Following ⌄ (primarySoft + primary text) / Requested (divider fill, iconInactive text); pressed 90% | S12 |
| LockedCard | white r22, 56 icon, title, text (+ Unblock pill) | private / requested / blocked | S12 |
| SettingsGroup | white r22 card with optional section label above | | S2-S5, S7, S8, S11 |
| SettingsRow | icon tile, title, trailing value, chevron | with/without icon tile; with value; tap | S2, S5, S11 |
| SwitchRow | title + subtitle + switch | on / off / disabled (coming soon, 40% opacity) | S2, S4, S5, S7 |
| RadioRow | title + radio | selected / unselected | S5 |
| PillOutlineButton | outline pill | Log out, Unblock, Follow in lists, Report a problem | S4, S6, S9, S13 |
| DangerButtonCard | full-width white card, red label (+ icon) | Log out, Log out of all other devices | S2, S4 |
| PersonRow | avatar 40-ish, name 15/700, @handle + meta 13, trailing pill | blocked / follow states | S6, S13 |
| FaqAccordion | rows with chevron, expands answer | one open at a time [estimated] | S9, S14 |
| BottomSheet rows | existing `AppBottomSheet`, rows as in the post options sheet | | S12 sheets |

Reuse from core: `AppTopBar`, `AppBackButton`, `AvatarInitials`, `AppTextField`, `PrimaryButton`, `PillButton`, `SelectableChip`, `ConfirmationDialog`, `AppBottomSheet`, `SearchPillField`, `PagedScrollView`, `PhotoSourceSheet`, `Notice`.
