# Progress: profile
Current step: 6 (Verify and hand off) - spec files written
Screens: S12 other-profile [observed, from board; 7 states + follow sheet + options sheet], S1 profile [written], S2 settings [written], S3 personal-info [written], S4 password-security [written], S5 privacy [written], S6 blocked-accounts [written], S7 notifications [written], S8 language [written], S9 help-center [written], S10 report-problem [written], S11 terms-policies [written]
## Answers so far
- Slug profile; S1-S11 names confirmed (one feature folder) [user]
- Platform: phone 390x844, light, LTR+RTL, EN+AR, no Figma [user]
- Theme exists (docs/specs/_theme + lib/core/theme): spec deltas only [user]
- Scope: spec everything seen; at the gap check decide per item build now / coming soon / hidden (dark mode, 5 extra languages, 2FA, login alerts, chat, ads, data download) [user]
- Trees S1-S11 confirmed; S1 top-left send button = share account, top-right sliders button = opens settings (S2) [user]
- S1 is own profile; other users' profile = S12 from the user's board (route /u/:username; own username routes to S1) [user]
- S1 share button = system share sheet with profile link; S1 tabs: Posts and Saved built now; Followers/Following stats open existing lists; verified badge from a profile field [user]
- Board notes (tokens, behavior, data RPCs) are [user] values; board image has no file path, so not copied to screenshots/ yet
- S12 scope: build everything on the board (follow states, private/requested, blocked, following sheet incl. close friends / post notifications / mute, options sheet, report); Message = 'coming soon' notice; tabs own = Posts/Shorts/Saved, other = Posts/Shorts/Tagged; 'Followed by' tap opens a mutual followers list built here (S13, design pending) [user]
- Code check: followers/following lists do NOT exist (features/follow has data only); no blocks table, no post_subscriptions, no profile cover/verified/privacy columns, reports only for posts; notification_prefs, mutes, close_friends, follows.status, profiles.is_private, /terms /privacy /cookie-policy /community-guidelines /open-source-licenses routes exist
- Lists: one shared people-list screen S13 (Followers, Following, mutual followers), design pending [user]
- S4: build change password, log out of all other devices, forgot password; 2FA, login alerts, device sessions list = coming soon [user]
- S5 privacy real with new profile columns; S2 Autoplay + Data saver stored on device; Dark mode and 5 extra languages (fr, es, de, tr, hi) coming soon [user]
- S2 Delete account real (confirm dialog + server delete); S3 email read-only, phone and birthday editable [user]
- S13 people list = S6 look + Follow/Following/Requested pill + search field; spec'd from S6 values [user]
- Default cover = S1 mountain illustration (user supplies file) [user]; verified = new profiles.is_verified, admin-set, read-only, ic_verified.svg [user]
- S3 camera badge = change avatar, "Change cover photo" link = change cover; both via existing photo source sheet + crop (avatar square, cover 390:170), remove only when one exists [user]
- Tokens: reuse _theme, estimate the rest as [estimated] and confirm each in the gap check [user]
- S9 content (topics, FAQ Q and A) from a Supabase table [user]
- S10: new problem_reports table + screenshots in Storage; device info and app logs attached when the box is checked [user]
- S8: language kept on the device (SharedPreferences), applies at once, default = device locale; only EN + AR enabled [user]
- S9 topic card tap opens a topic page with its questions = new screen S14 help-topic, design pending [user]
- S10 limits: up to 3 images, 5 MB each; logs = device model, OS, app version, last 50 error lines [user]
- S5 message/comment choices stored on the profile and enforced (comments by existing comment RPCs, messages when Chat exists); 'Turn off comments' = nobody comments on any of my posts [user]
- Block: hides both ways (profile, posts, stories, search), removes follows both ways, no messages; unblock does not restore follows; blocker's profile viewed by the blocked user shows 'User not found'; Unblock has no dialog; new blocks table + RPCs [user]
- S14 help-topic = AppBar topic name + S9 accordion card of that topic's questions [user]
- S3 Save enabled only when changed + valid; leaving with edits asks 'Discard changes?'; username check via username_exists, bio max 150 [user]
- Log out, Delete account, Log out of all other devices use the shared ConfirmationDialog; Delete asks for the password first [user]
- User chose to write files now with estimates tagged; S13 and S14 have no screenshots (built from S6/S9) [user]
- Language (S8): only English and Arabic are listed; the other 5 languages from the screenshot are dropped, not 'coming soon' [user]
- Q-S1-2 avatar tap opens a photo viewer; Q-S3-1 Location uses the place picker; Q-S5-1 pending requests stay pending when Private is turned off; all other open questions use their defaults; share domain and company name = placeholders with TODO markers; plan split by user value (~12 phases), mode one-by-one [user]
## Open questions (pending)
See open-questions.md (Q-S1-1 .. Q-S14-1, assets, company name).
None yet.
## Next action
Interview A-H per screen: tokens/states/behavior/data for S1, S2-S11 (switch, radio, chip, accordion, sections), S12 sheets; then gap check.
