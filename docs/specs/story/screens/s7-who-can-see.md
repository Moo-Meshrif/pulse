# Who can see this and its lists (S7)
Screenshot: `../screenshots/stories-board-v3.png` panels 11 and 12 (and panel 2 for the dark viewers sheet).
Opened from your own story: "···" > **Who can see this** (answers Q18 [user]: the picker and the audience column are in).

## Panel 11: Who can see this (dark sheet, `storySheet`)
Title "Who can see this", note "Changes apply to this story right away. People who already saw it keep it in their viewers list."
Group 1: **Followers** (sub "312 people", green check when chosen) · **Close friends** (green star tile, sub "12 people", an **Edit** pill, then the round selector). Group 2: **Hide story from** (sub "2 people", chevron). White **Done** pill.
- A choice is saved at once (shared `SetContentAudienceUseCase` -> `set_content_audience(p_kind: 'story')`, was `set_story_audience`) and applies to the story already posted; Done only closes. A failed save goes back to the old choice and says so inside the sheet.
- **Edit** opens the Close friends list; **Hide story from** opens its list. Counts reload when a list is saved.

## Panel 12: list screen (`/audience/close-friends`, `/audience/hidden`, background `textPrimary`)
Header: back, title ("Close friends" / "Hide story from"), "N selected" at the end. Search "Search followers"; hint "Only you can see this list. People aren't told when you add or remove them." Tabs **Suggested** | **Selected · N**. Rows: avatar, name, @username, round selector (green check / empty ring). White **Done** pill.
- Only your followers are listed. Suggested = people who viewed your stories most recently first. Taps are kept on the screen and saved together by Done (`update_audience_list`); the header and tab counts follow the taps.
- Hide story from is a list for all your stories, not one story.
- **One list per person:** a person on Close friends is shown like anyone in Hide story from (and the other way round). Ticking them asks first: "X is in your Close friends. Hiding your stories from them takes them off that list." (Hide / Cancel; on Close friends: "Add"). Done then saves, and the server moves them (`update_audience_list` takes them off the other list).
- **Done** is dimmed until something was ticked or unticked.
- **Empty Close friends list:** the stories set to Close friends go back to Followers (the server does it when the list is emptied; the sheet does it on load for a story already in that state). With nobody on the list, the Close friends row is a chevron that opens the list.
- The sheet shows a loader until its counts arrive (Retry on failure).

## Panel 2: viewers sheet
Dark (`storySheet`), grabber white @ 25%, eye + "24 viewers" in white, delete circle `dangerOnDark` @ 18% with a `dangerOnDark` trash, save circle `storySheetRow`, white names, @handles white @ 60%, red heart for people who liked.

## Backend (`supabase/migrations/20261015120000_story_audience.sql`, `20261016120000_story_audience_lists.sql` and `20261017120000_story_audience_move.sql` and `20261016120000_story_audience_lists.sql`)
`stories.audience` ('followers' | 'close_friends'), `close_friends`, `story_hidden_from`, `can_view_story(author, audience)` used by the stories read policy, likes, views, `report_content` (kind story) and `story_rail`; RPCs `set_content_audience` (shared, replaces `set_story_audience`), `audience_summary` (read through the shared `GetAudienceSummaryUseCase`), `audience_people`, `update_audience_list`; `author_stories` also returns `audience`.

## Strings
`storyAudienceBody`, `storyAudienceCloseFriends`, `storyAudienceHideFrom`, `storyAudiencePeople`, `storyAudienceEdit`, `storyAudienceDone`, `storyAudienceSaveFailed`, `storyCloseFriendsTitle`, `storyCloseFriendsHint`, `storyHiddenTitle`, `storyHiddenHint`, `storyAudienceSelected`, `storyAudienceSearch`, `storyAudienceTabSuggested`, `storyAudienceTabSelected`, `storyAudienceEmpty`, `storyAudienceLoadFailed`, `storyAudienceSelectPerson`. Arabic drafts `x-review`.

## Acceptance checklist
- [ ] The row opens the sheet; the chosen audience has the green check; the options row subtitle follows it.
- [ ] Close friends: choose, Edit, search, tabs, Done; a Close friends story is seen only by them.
- [ ] Hide story from: those people see none of your stories and do not get a rail entry.
- [ ] The viewers sheet is dark like panel 2.
