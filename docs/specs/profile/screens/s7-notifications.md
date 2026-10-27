# Notifications (S7)
Screenshot: `../screenshots/s7-notifications.png`
Purpose / route: `/settings/notifications`.

## Layout tree
```
├─ AppTopBar back + "Notifications"
├─ Card: SwitchRow "Push notifications" / "Get alerts on this device"
├─ Section "ACTIVITY": card [Likes, Comments & replies, Mentions & tags, New followers]
├─ Section "MESSAGES": card [Direct messages, Group chats]
└─ Section "FROM PULSE": card [Shorts from people you follow, Weekly email digest, Product updates]
```
Defaults in the screenshot: all on except Group chats, Weekly email digest, Product updates (they match `notification_prefs` defaults).

## States
Switches save at once via `set_notification_prefs` (partial JSON), optimistic with rollback + error notice. When Push is off, the other rows stay editable (they also control in-app) [Q-S7-1]. OS permission denied: Push switch turning on opens the system permission request; if blocked, notice "Enable notifications in system settings".

## Strings
| key | en | ar (x-review) |
|---|---|---|
| notificationsTitle | Notifications | الإشعارات |
| pushNotifications / Sub | Push notifications / Get alerts on this device | الإشعارات الفورية / استلم التنبيهات على هذا الجهاز |
| sectionActivity / Messages / FromPulse | Activity / Messages / From Pulse | النشاط / الرسائل / من بولس |
| likes / Sub | Likes / On your posts and shorts | الإعجابات / على منشوراتك وشورتسك |
| commentsReplies / Sub | Comments & replies / When someone joins the conversation | التعليقات والردود / عندما يشارك أحد في المحادثة |
| mentionsTags / Sub | Mentions & tags / When you're tagged in a post | الإشارات والوسوم / عند الإشارة إليك في منشور |
| newFollowers / Sub | New followers / When someone follows you | متابعون جدد / عندما يتابعك أحد |
| directMessages / Sub | Direct messages / One-on-one chats | الرسائل المباشرة / المحادثات الفردية |
| groupChats / Sub | Group chats / Every message in groups you're in | محادثات المجموعات / كل رسالة في المجموعات التي أنت فيها |
| shortsFollowing / Sub | Shorts from people you follow / When they post something new | شورتس من تتابعهم / عندما ينشرون شيئًا جديدًا |
| emailDigest / Sub | Weekly email digest / Highlights you might have missed | ملخص أسبوعي بالبريد / أبرز ما فاتك |
| productUpdates / Sub | Product updates / New features and tips | تحديثات المنتج / ميزات جديدة ونصائح |

## Data mapping
`notification_prefs`: push_enabled, likes, comments, mentions, followers, messages, group_chats, shorts, email_digest, product. Read: select own row (missing row = defaults). Write: `set_notification_prefs({"likes": false})`. Device token registration (`device_tokens`) follows the Push switch.

## Responsive / a11y
Switch label = row title + subtitle. RTL: switches on the start side.

## Acceptance checklist
- 4 cards in the order above; on/off states as the screenshot.
