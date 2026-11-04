# People list (S13)
Screenshot: none (no design supplied; built from S6 values [user]).
Purpose / route: `/people?kind=followers|following|mutual&user=<id>`. One screen for Followers, Following and the "Followed by" (mutual) list.

## Layout tree
```
├─ AppTopBar back + title ("Followers" | "Following" | "Followed by")
├─ SearchPillField "Search" (followers/following only)
└─ Card (white r22, margin 12): PersonRow x N (PagedScrollView)
   PersonRow: avatar 48 · name 15/700 (+verified) · @handle 13 textSecondary · trailing pill: Follow / Following / Requested (none on your own row)
```
## States
Loading skeleton; empty: `AppEmpty` ic_user_add "No followers yet" / "Not following anyone yet" / "No mutual followers"; private account not followed -> title only + the LockedCard text [Q-S13-1]; paged load-more; error retry.
## Strings
| key | en | ar (x-review) |
|---|---|---|
| followersTitle / followingTitle / mutualTitle | Followers / Following / Followed by | المتابعون / يتابع / يتابعه |
| searchPeople | Search | بحث |
| noFollowers / noFollowing / noMutual | No followers yet / Not following anyone yet / No mutual followers | لا يوجد متابعون بعد / لا يتابع أحدًا بعد / لا يوجد متابعون مشتركون |
## Behavior and navigation
Row tap -> S12 (or S1 for yourself). Pill uses the same follow rules as S12 (public -> Following; private -> Requested). Search filters the loaded list by name or handle; server search later [Q-S13-2].
## Data mapping
New RPCs `followers_of(p_user, p_q, p_before)`, `following_of(...)`, `mutual_followers(p_user, ...)` returning profile + `i_follow`. Existing `follows` + `FollowStatus`.
## Responsive / a11y
As S6. RTL: pill on the start side.
## Acceptance checklist
- Rows look exactly like S6 rows with a Follow pill; search pill like S8.
