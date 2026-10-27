# Blocked accounts (S6)
Screenshot: `../screenshots/s6-blocked-accounts.png`
Purpose / route: `/settings/blocked`.

## Layout tree
```
Scaffold (background)
├─ AppTopBar back + "Blocked accounts"
├─ Intro text (subtitle 15 textSecondary), side padding 24
└─ Card (white r22, margin 12): PersonRow x N
   PersonRow: AvatarInitials 48, name (15/700, 1 line), "@handle · Blocked 2 weeks ago" (13 textSecondary, wraps), outline pill "Unblock" (end)
```

## States
Loading: skeleton rows. Empty: `AppEmpty` ic_block-large "No blocked accounts". Unblocking: pill spinner. Error notice. Paged (`PagedScrollView`).

## Strings
| key | en | ar (x-review) |
|---|---|---|
| blockedTitle | Blocked accounts | الحسابات المحظورة |
| blockedIntro | Blocked people can't see your profile, message you or find you in search. They aren't told you blocked them. | لا يستطيع المحظورون رؤية ملفك أو مراسلتك أو إيجادك في البحث. ولا يتم إخبارهم بأنك حظرتهم. |
| blockedAgo | @{username} · Blocked {ago} | @{username} · محظور منذ {ago} |
| unblock | Unblock | إلغاء الحظر |
| blockedEmpty | No blocked accounts | لا توجد حسابات محظورة |
| unblocked | Unblocked @{username} | تم إلغاء حظر @{username} |

## Behavior and navigation
Unblock: immediate, no dialog; removes the row; does not restore follows. Row tap (not the pill) -> S12 of that user (shows blocked card with Unblock). Relative time: "2 weeks ago", "1 month ago".

## Data mapping
`blocks(blocker_id, blocked_id, created_at)` (new) joined to profiles; list RPC paged newest first. Names/avatars as elsewhere (initials when no photo).

## Responsive / a11y
Long handles wrap to a second line (as in the screenshot). RTL: pill on the start side.

## Acceptance checklist
- Rows with 48 avatars, bold name, grey meta, outline Unblock pill; card hugs its rows; empty area below.
