# Post options (S2)
Screenshot: `../screenshots/s2-post-options.png` (moved from home; owned by the post feature) (board v2: panels 1-6 plus 3b, 3c + 3 notes). Opened from the "···" on a post card (P2, shown on Home and other lists).
Purpose / route: bottom sheet over Home; two variants (someone else's post / your own), report flow, in-place results. Tokens that are not listed: reuse `../01-design-tokens.md` and `../../home/01-design-tokens.md`.

## Layout tree
```
Sheet (shell = Create sheet: surface, top radius 28, padding 10 16 34, grabber 40x5 r3 `border`, scrim 40%)
├─ Quick row: 3 tiles Save | Copy link | Share  (76 high, r18, `background` fill, icon 24, label 13/600, gap between 12)
├─ Group A (r18, `background`, rows >= 56, icon 22, label 15/600, sub 12 textSecondary, divider `divider`)
│    others: Not interested (sub "See fewer posts like this") · Unfollow @user · Mute @user (sub "Hide their posts without unfollowing")
│    own:    Edit post · Change who can see (S4, board s4-visibility panel 4) · Turn off comments
└─ Group B (own group, danger #C42B34 icon + label)
     others: Report post (ic_flag)     own: Delete post (ic_trash)
gap between groups 12
```
Opens from the post's "···": button turns `primarySoft` while open (44 button). Drag down or tap scrim closes.

## Panels
| # | Panel | Content |
|---|---|---|
| 1 | Someone else's post | as tree (others) |
| 2 | Your own post | same layout; header author "You" |
| 3 | Report reasons | Second step of the same sheet, slides in from the end. Title "Report post" (Sora 20/700 style) + close X 44 at end; body "Why are you reporting this post? Your report is anonymous."; list group rows with chevron: Spam · Nudity or sexual content · Hate speech or symbols · Bullying or harassment · Violence or dangerous acts · False information · Something else. Each reason submits; "Something else" pushes panel 3b |
| 3b | Something else (empty) | Pushed in the same sheet, slides in from the end; back arrow (44, start) returns to the reasons. Title "Something else" (Sora 20/700 style). Body "Describe the problem in a few words. Your report is anonymous." Multiline field (r~14, 1 px `border`, placeholder "Tell us what's wrong with this post…", counter "0 / 500" 12 textSecondary bottom-end), autofocus. "Send report" full-width primary button, **disabled** (primary faded) until 5+ characters [user] |
| 3c | Something else, typing | Sheet rides above the keyboard; field gets a 2 px `primary` focus border and grows to 5 lines, then scrolls; counter "72 / 500" turns `danger` at 500. Send enabled; tap shows a loader in the button, then panel 4 [user] |
| 4 | Report sent | Sheet content: check icon (primary, large), title "Thanks for letting us know" (Sora 18/700), body "We'll review this post. You won't see it in your feed anymore.", group rows Mute @user / Unfollow @user, primary full-width button "Done". No notice; post removed from the feed behind |
| 5 | Not interested | The card collapses in place (240 ms) into a row: `ic_eye_off`, "Post hidden" bold + "You'll see fewer posts like this." + "Undo" soft pill (`primarySoft` fill, primary text) at end. Undo window 5 s, then the row disappears on the next refresh |
| 6 | Delete confirm | Existing `ConfirmationDialog.destructive`: red tile with trash, "Delete this post?", "It will be removed from your profile and everyone's feed. You can't undo this.", buttons Cancel (outlined) / Delete (danger fill). After delete: success notice "Post deleted" |

## Actions and result [seen]
| Action | Result |
|---|---|
| Save | icon fills, label becomes "Saved", sheet closes, no notice (toggles; same as the card's save) |
| Copy link | **Coming soon** notice for now (post deep links not built, Q-V3 [user]); later: closes, "Link copied", link `https://pulse.app/p/{post_id}`. Hidden when the post is not Public (S4) |
| Share | **Coming soon** notice for now (Q-V3 [user]); later: system share sheet with the post link. Hidden when the post is not Public (S4) |
| Not interested | card collapses to the hidden row + Undo |
| Unfollow | closes; the author's posts leave the feed on refresh; notice "Unfollowed @x" + Undo |
| Mute | notice "@x muted" + Undo |
| Report | reasons step, then sent step ("Something else" adds the note step) |
| Edit post | Edit post screen (`s5-edit-post.md`) |
| Change who can see | opens S4 panel 4 ("Currently: X", Save -> shared `SetContentAudienceUseCase` (`set_content_audience`), notice "Visibility updated") |
| Turn off comments | toggles; label becomes "Turn on comments" |
| Delete | confirm dialog |

## Strings (en | ar draft `x-review`)
| Key | en | ar |
|---|---|---|
| postSave / postSaved | Save / Saved | حفظ / تم الحفظ |
| postCopyLink | Copy link | نسخ الرابط |
| postShare | Share | مشاركة |
| postNotInterested / sub | Not interested / See fewer posts like this | غير مهتم / شاهد منشورات أقل مثل هذا |
| postUnfollow | Unfollow @{username} | إلغاء متابعة @{username} |
| postMute / sub | Mute @{username} / Hide their posts without unfollowing | كتم @{username} / إخفاء منشوراته دون إلغاء المتابعة |
| postReport | Report post | الإبلاغ عن المنشور |
| postEditPost | Edit post | تعديل المنشور |
| postCommentsOff / On | Turn off comments / Turn on comments | إيقاف التعليقات / تشغيل التعليقات |
| postDelete | Delete post | حذف المنشور |
| reportTitle / body | Report post / Why are you reporting this post? Your report is anonymous. | الإبلاغ عن المنشور / لماذا تبلغ عن هذا المنشور؟ بلاغك مجهول. |
| reasons | Spam · Nudity or sexual content · Hate speech or symbols · Bullying or harassment · Violence or dangerous acts · False information · Something else | spam: محتوى مزعج · عري أو محتوى جنسي · خطاب كراهية أو رموز · تنمر أو مضايقة · عنف أو أفعال خطيرة · معلومات مضللة · شيء آخر |
| reportSentTitle / body | Thanks for letting us know / We'll review this post. You won't see it in your feed anymore. | شكرًا لإبلاغنا / سنراجع هذا المنشور ولن تراه في خلاصتك بعد الآن. |
| reportElse / body / placeholder | Something else / Describe the problem in a few words. Your report is anonymous. / Tell us what's wrong with this post… | شيء آخر / صف المشكلة في بضع كلمات. بلاغك مجهول. / أخبرنا بما يزعجك في هذا المنشور… |
| reportSend | Send report | إرسال البلاغ |
| reportDone | Done | تم |
| postHidden / sub / undo | Post hidden / You'll see fewer posts like this. / Undo | تم إخفاء المنشور / سترى منشورات أقل مثل هذا. / تراجع |
| notices | Link copied · Unfollowed @{u} · @{u} muted · Post deleted | تم نسخ الرابط · تم إلغاء متابعة @{u} · تم كتم @{u} · تم حذف المنشور |
| deleteDialog | Delete this post? / It will be removed from your profile and everyone's feed. You can't undo this. / Cancel / Delete | حذف هذا المنشور؟ / ستتم إزالته من ملفك الشخصي ومن خلاصة الجميع. لا يمكنك التراجع. / إلغاء / حذف |

## Data mapping
| Action | Backend (`../../home/schema-post-options.sql`, applied; report, mute and audience changes are now the shared RPCs in `../schema-shared-content-actions.sql`) |
|---|---|
| Not interested / hide | `rpc('hide_post', {p_post, p_hidden})` (Undo = false), filtered in `home_feed` |
| Mute | shared `SetMuteUseCase` -> `rpc('set_mute', {p_user, p_muted, p_scope: 'posts'})` (Undo = false), filtered in the feed (stories are muted on their own, `p_scope: 'stories'`) |
| Report | shared `ReportContentUseCase` -> `rpc('report_content', {p_kind: 'post', p_id, p_reason, p_note})` stores the report and hides the post; reasons: spam, nudity, hate, bullying, violence, false_info, other; note 500 chars (min 5 chars enforced in the app only) |
| Turn off comments | `posts.comments_enabled boolean`, enforced in the comments insert policy |
| Unfollow | existing follows datasource (via a profile use case) |
| Copy link | deep link `https://pulse.app/p/{post_id}` |

## Responsive / a11y
Sheet uses `AppSafeArea` (bottomSpace 34). Rows >= 56 high; semantics labels = visible labels; X close 44. RTL: second step slides in from the end; chevrons mirror. Wide screens: sheet capped at shared max width.

## Acceptance checklist
- [ ] Others' variant shows quick row, Not interested/Unfollow/Mute group, red Report group.
- [ ] Own variant shows Edit post/Turn off comments and red Delete.
- [ ] "···" turns primarySoft while open; scrim tap and drag close.
- [ ] Something else: note step with back arrow, autofocus, 0/500 counter, Send disabled under 5 chars, loader on send, counter danger at 500.
- [ ] Report step slides in; each reason submits; sent step with Mute/Unfollow and Done.
- [ ] Not interested collapses in 240 ms with a 5 s Undo.
- [ ] Delete uses the existing destructive dialog, then "Post deleted".
