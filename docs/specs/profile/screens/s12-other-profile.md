# Other profile (S12)
Screenshot: none saved (board pasted in chat: 7 states, Following sheet, Options sheet). Source of all values below [user] unless tagged.
Purpose / route: `/u/:username`, opened from any name or avatar. Own username resolves to S1. Same layout as S1 with follow states instead of settings.

## Layout tree
```
Scaffold (background), scroll
├─ Cover 170 (gradient default or user cover) + buttons: back (left, 44), "…" options (right, 44)
├─ Avatar 96 (overlap 48) · Name Sora 22/700 (+verified) (+ chip "Follows you")
├─ @username · bio line · Followed-by row (3 avatars 22, overlap -6, "Followed by omarkh, mariam.h and 3 others")
├─ StatsCard (Posts | Followers | Following)
├─ FollowButtons: [Follow | Follow back | Following ⌄ | Requested] + Message (outline)
├─ Tabs: Posts | Shorts | Tagged (icon + label)
└─ Body: PostGrid  OR  LockedCard (private / requested)  OR  blocked state
```

## States (board panels)
| # | State | Header | Button | Body |
|---|---|---|---|---|
| 1 | Public, not following | normal | Follow (primary) + Message | grid |
| 2 | They follow you | chip "Follows you" | Follow back + Message | grid |
| 3 | Following | normal | "Following ⌄" (primarySoft fill, primary text) + Message | grid; tap opens Following sheet |
| 4 | Private, not following | stats and bio still show | Follow + Message (Message hidden unless they allow messages from everyone) | LockedCard: ic_lock_closed, "This account is private", "Follow to see their posts, shorts and stories." |
| 5 | Requested | normal | "Requested" (divider fill, iconInactive text), full width | LockedCard: "This account is private", "Request sent. You'll see their posts once <Name> accepts."; toast "Follow request sent / Tap Requested to cancel." |
| 6 | Options sheet open | scrim over the page | - | - |
| 7 | Blocked (I blocked them) | greyed avatar and cover, no stats, no buttons | - | card: ic_block large, "You blocked this account", "They can't see your profile, posts or message you.", outline "Unblock" |
If they blocked me: screen shows "User not found" (as for a missing user) so blocking can't be detected.

## Sheets
- Following sheet (`AppBottomSheet`, title "@nour.adel"): row "Add to close friends" / "See their stories with the green ring" (ic_star, switch off); row "Post notifications" / "Get notified when they post" (ic_bell, switch on); row "Mute" / "Hide their posts and stories" (ic_volume_off); separate red row "Unfollow" (ic_user_minus). Unfollow on a private account asks for confirmation (you'd have to request again).
- Options sheet: rows Share profile (ic_share_forward), Copy profile link (ic_link), Mute (ic_volume_off); separate group: Block @nour.adel / "They won't be able to find you or message you" (ic_block, danger), Report (ic_flag, danger). Block -> confirm dialog -> state 7.
- Cancel request dialog: tap Requested -> "Cancel request?" confirm.

## Strings
| key | en | ar (x-review) |
|---|---|---|
| follow / followBack / following / requested | Follow / Follow back / Following / Requested | متابعة / رد المتابعة / تتابعه / تم الطلب |
| message | Message | رسالة |
| followsYou | Follows you | يتابعك |
| followedBy | Followed by {names} and {count} others | يتابعه {names} و{count} آخرون |
| tabTagged | Tagged | الوسوم |
| privateTitle / Follow / Requested | This account is private / Follow to see their posts, shorts and stories. / Request sent. You'll see their posts once {name} accepts. | هذا الحساب خاص / تابعه لترى منشوراته وشورتسه وقصصه. / تم إرسال الطلب. سترى منشوراته بعد أن يقبل {name}. |
| requestSent / Hint | Follow request sent / Tap Requested to cancel. | تم إرسال طلب المتابعة / اضغط "تم الطلب" للإلغاء. |
| cancelRequest | Cancel request? | إلغاء الطلب؟ |
| addCloseFriends / Sub | Add to close friends / See their stories with the green ring | إضافة إلى الأصدقاء المقرّبين / شاهد قصصهم بالحلقة الخضراء |
| postNotifications / Sub | Post notifications / Get notified when they post | إشعارات المنشورات / احصل على إشعار عندما ينشرون |
| mute / Sub | Mute / Hide their posts and stories | كتم / إخفاء منشوراتهم وقصصهم |
| unfollow | Unfollow | إلغاء المتابعة |
| unfollowPrivateTitle | Unfollow {name}? | إلغاء متابعة {name}؟ |
| unfollowPrivateBody | This account is private. You'd have to request to follow again. | هذا الحساب خاص. ستحتاج إلى طلب المتابعة مرة أخرى. |
| shareProfile / copyLink | Share profile / Copy profile link | مشاركة الملف الشخصي / نسخ رابط الملف |
| block / blockSub | Block @{username} / They won't be able to find you or message you | حظر @{username} / لن يتمكن من إيجادك أو مراسلتك |
| report | Report | إبلاغ |
| blockTitle / Body / Confirm | Block @{username}? / They won't see your profile or posts and can't message you. They aren't told. / Block | حظر @{username}؟ / لن يرى ملفك ومنشوراتك ولن يستطيع مراسلتك. ولن يتم إخباره. / حظر |
| blockedTitle / Body | You blocked this account / They can't see your profile, posts or message you. | لقد حظرت هذا الحساب / لا يستطيع رؤية ملفك أو منشوراتك أو مراسلتك. |
| userNotFound | User not found | المستخدم غير موجود |
| linkCopied | Profile link copied | تم نسخ رابط الملف |
| messageSoon | Messages are coming soon | الرسائل قادمة قريبًا |

## Behavior and navigation
Follow is optimistic (count +1, button flips) and rolls back with an error notice. Public account: follow is accepted at once. Private: Follow -> request (pending) + notification to them (follow_request); Requested tap -> cancel dialog; when accepted the page becomes state 3 and the grid loads. Unfollow from the Following sheet. Message: hidden if they don't accept messages from me, otherwise "coming soon" notice until Chat exists. Tagged tab respects post visibility (`post_tags`); tile tap opens the post. Tabs: Posts, Shorts (coming soon), Tagged. "Followed by" tap -> S13 mutual; stats Followers/Following -> S13. Back button pops. Report -> existing report sheet extended to profiles (reasons as post reports) [Q-S12-1].

## Data mapping
`profile_by_username(p_username)` -> profile + counts + `i_follow` (none | pending | accepted) + `follows_me` + `can_message` + `is_blocked_by_me` (null when blocked me). `mutual_followers_preview(p_user)` -> 2 names + 3 avatars + total. Grid `user_posts(p_user, p_kind, p_before)` (RLS hides private accounts). Sheet toggles: `close_friends`, `post_subscriptions(user_id, author_id)` (new), `mutes`; block: `blocks(blocker, blocked)` (new).

## Responsive / a11y
Same as S1. Following button announces "Following, double tap for options". RTL: back arrow mirrors, options button on the start side.

## Acceptance checklist
- Each of the 7 states matches the board; Following sheet and Options sheet rows as listed; grey states 7 and the scrim for 3 and 6.
