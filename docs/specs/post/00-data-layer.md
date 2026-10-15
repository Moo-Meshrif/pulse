# Post feature: data layer (no UI yet)

Status: short spec, written 2026-10-13 [user asked]. UI of the post feature (New post, post detail, comments) comes later as its own specs. Consumers today: `home` (feed), `control-page` (Create routes). Presentation shared with other features: `02-components.md`. Schema: `../home/schema.sql` + `../home/schema-post-options.sql` (applied), then `schema-post-visibility.sql` + `schema-shared-content-actions.sql` (this folder; applied 2026-10-14, in that order).
Rules: `.claude/conventions/architecture.md`: datasource interface + Supabase adapter in one file, wire models in `data/model`, enums in `data/enums`, throws `Failure`, `Guard.run`. Features trade only through `domain/use_case/`.

## Layout
```
lib/features/post/
  data/
    datasource/posts_datasource.dart      # interface + Supabase adapter (feed, signed media links, files, create)
    datasource/post_actions_datasource.dart  # like, save, hide, comments toggle, delete (post-only; see Q13 update)
    datasource/visibility_notice_datasource.dart  # local one-time flags for the Close friends / Only me notice
    model/post_model.dart                 # one home_feed row
    model/post_media_model.dart           # one media item
    model/feed_page_model.dart            # List<PostModel> + next cursor (null = end)
    enums/media_type.dart                 # image | video
    # report reasons: core `ReportReason`; audience: shared `ContentAudience` (lib/shared/content)
  domain/
    entity/                               # see Q-A
    use_case/
```

## Models (wire, from `home_feed` in schema-post-options.sql)
`PostModel`: id, authorId, username, fullName, avatarUrl?, caption?, location?, likeCount, commentCount, commentsEnabled, visibility (`ContentAudience`), createdAt, likedByMe, savedByMe, media: List<PostMediaModel>.
`PostMediaModel`: position, type (`MediaType`), path, thumbPath?, width, height, durationMs?, blurhash?.
Cursor = (createdAt, id) of the last row; page size 20 (max 50 server-side).

## Datasource: `PostsDatasource`
| Method | Supabase call | Returns |
|---|---|---|
| `getHomeFeed({limit, beforeCreated, beforeId})` | `rpc('home_feed', …)` | `FeedPageModel` |
| `setLike(postId, liked)` | `rpc('set_post_like', {p_post, p_liked})` | new like count (int) |
| `setSave(postId, saved)` | `rpc('set_post_save', {p_post, p_saved})` | bool |
| `hidePost(postId, hidden)` | `rpc('hide_post', {p_post, p_hidden})` | void |
| ~~`reportPost`~~ | moved: shared `report_content` (see *Shared code update*) | void |
| `setCommentsEnabled(postId, enabled)` | `from('posts').update({'comments_enabled': enabled}).eq('id', postId)` | void |
| `deletePost(postId)` | `from('posts').delete().eq('id', postId)` + remove storage objects under `{uid}/{postId}/` | void |
| `signMediaUrls(paths)` | `storage.from('post-media').createSignedUrls(paths, 3600)` | `Map<path, url>`; cache key = path |

## Use cases (public API for other features; `@injectable`, named by intent)
`GetHomeFeedUseCase({cursor})`, `SetPostLikeUseCase(postId, liked)`, `SetPostSaveUseCase(postId, saved)`, `HidePostUseCase(postId, hidden)` (hidden=false is Undo), `ReportContentUseCase(ContentKind.post, id, reason, {note})` (shared), `SetCommentsEnabledUseCase(postId, enabled)`, `DeletePostUseCase(postId)`, `SignPostMediaUrlsUseCase(paths)` (post-owned; story has its own).
`CreatePostUseCase(NewPost)` [added]: uploads media to `post-media/{uid}/{postId}/…`, then `rpc('create_post', {p_id, p_kind, p_caption, p_location, p_media, p_comments_enabled})`; removes uploaded files if the RPC fails. Input type `NewPostEntity` (caption, location?, commentsEnabled, picked media files with width/height/duration/blurhash).
Not here: Mute and Unfollow are about people: **follow** feature (`ToggleFollowUseCase`); Mute is the shared `SetMuteUseCase` with `MuteScope.posts`. Pending-count for the Activity bell: `GetFollowRequestCountUseCase` (follow, exists).

## Q13 update [user]
Like, save, hide, report, comments toggle and delete moved out of `PostsDatasource` into `PostActionsDatasource` with use cases (`SetPostLikeUseCase`, `SetPostSaveUseCase`, `HidePostUseCase`, `SetCommentsEnabledUseCase`, `DeletePostUseCase`). `PostsDatasource` keeps feed, signed URLs and create.

## Shared code update [user, 2026-10-14]: what story, post and short do the same way lives in `lib/shared/content/{data,domain}` with generic names; feature Cubits call its use cases. Report -> `ReportContentUseCase(kind, id, reason, note)` over `rpc('report_content', {p_kind, p_id, p_reason, p_note})` (post/short also hide the post for the reporter). Change audience -> `SetContentAudienceUseCase(kind, id, ContentAudience)` over `rpc('set_content_audience', {p_kind, p_id, p_audience})`. Mute -> `SetMuteUseCase(userId, muted, MuteScope)` over `rpc('set_mute', {p_user, p_muted, p_scope})` (`posts` and `stories` stay independent). File cleanup -> `RemoveMediaFilesUseCase`. Counts -> `GetAudienceSummaryUseCase` (`audience_summary`). Account privacy -> `GetPrivacyUseCase` / `SaveDefaultAudienceUseCase`. `ReportPostUseCase`, `SetPostVisibilityUseCase` and the follow feature's `SetMuteUseCase` are gone (replaced by the shared ones). Like, save, hide, comments toggle and delete stay post-only: `PostActionsDatasource` and its use cases are in `features/post` (not core), their use cases are post's public API. Backend: `20261018120000_post_visibility.sql` + `20261019120000_shared_content_actions.sql`, validated and applied 2026-10-14.

## Behavior notes
- Like and save are optimistic in the Cubit; reconcile with the returned count/bool, roll back on `Failure`.
- Counts and relative time are formatted in presentation (home), not here.
- Report: the app enforces 5+ chars on the note; server hides the post for the reporter.
- Delete: DB cascades rows; storage files are removed best-effort (Q-B).
- Not specified yet: create post (`create_post` RPC + uploads), comments, post detail, saved list.

## Open questions
| # | Question | Options | Status |
|---|---|---|---|
| Q-A | Use cases hand data to other features | - | **answered** [user]: `domain/entity` types (`PostEntity`, `PostMediaEntity`) are the public return types of the use cases; documented exception in `.claude/conventions/architecture.md`. Models stay private to the feature |
| Q-B | Delete: storage files | - | **answered** [user]: client removes files best-effort after the row delete |
| Q-C | Signed URLs | - | **answered** [user]: each feature signs its own (post datasource `signMediaUrls`; story gets its own); no shared service. Duplication accepted |
| Q-D | `avatar_url` | - | **answered** [user]: full public URL, used directly |

## Places (Add location, S3) [from the board]
Datasource `PlacesDatasource` (interface + adapter): `searchPlaces(query, {lat, lng})`, `getNearby(lat, lng)` (<= 10 within ~5 km), `reverseGeocode(lat, lng)` -> "area, city"; all through a Supabase **Edge Function** `places` (provider key stays server-side; OSM/Photon for now [user], swappable). `RecentPlacesDatasource` (local, last 5, via SharedPreferences, widgets never touch it). Device position: one-time `LocationDatasource` (permission + position; no tracking).
Model `PlaceModel`: name, subtitle (area, city / type), distanceKm?, kind (city, town, neighborhood, poi). Entity `PlaceEntity` (public).
Use cases: `SearchPlacesUseCase(query)`, `GetNearbyPlacesUseCase()`, `GetCurrentPlaceUseCase()`, `GetRecentPlacesUseCase()`, `SaveRecentPlaceUseCase(place)`, `GetLocationPermissionUseCase` / `RequestLocationPermissionUseCase`. Saved value on the post = display name only (<= 80); never exact GPS.

## Tags, mood and comments-off (2026-10-15) [user]
Schema: `schema-post-tags-mood.sql` (spec copy; migration `20261021120000_post_tags_mood.sql`, **not yet validated or applied**). Adds `posts.mood_kind/mood_key/mood_text`, `profiles.allow_tags`, `post_tags`, `tag_removals`, notification type `tag`, RPCs `tag_search`, `can_tag`, `post_tagged_people`, `remove_my_tag`, `tagged_posts`, and replaces `create_post`, `update_post` and `home_feed` (new columns: `mood_kind`, `mood_key`, `mood_text`, `tag_count`, `tags`, `i_am_tagged`).
Wire models: `PostModel` + mood fields and `tags: List<PostTagModel>` (userId, username, fullName, mediaPosition?, x?, y?), `tagCount`, `iAmTagged`; `TagPersonModel` (id, username, fullName, avatarUrl, canTag); `TaggedPersonModel` (+ followState); Enums `MoodKind` (feeling, activity), `FollowState`.
Datasource: `PostTagsDatasource` (interface + adapter): `searchPeople(q)`, `getTaggedPeople(postId)`, `removeMyTag(postId)`, `getTaggedPosts(...)` (for profile later); Static lists (feelings, emoji, EN+AR keywords) in `presentation/utils`.
Use cases: `SearchTagPeopleUseCase`, `GetTaggedPeopleUseCase`, `RemoveMyTagUseCase`; `CreatePostUseCase` / `UpdatePostUseCase` take `PostMood?` and `List<PostTag>` (userId, mediaPosition?, x?, y?). Tagged people sheet Follow/Following goes through the follow feature's use case, never its datasource.
TODO (deferred [user]): activities and their suggestions (S9) come from an API or a database later; the `mood_kind = 'activity'` columns and check stay in the SQL so no migration is needed for the data shape, but no UI, datasource or suggestions table is built now.
Rules: max 20 tags, no duplicates, not yourself; people with `allow_tags` = none (or `following` and you are not followed) cannot be tagged (shown disabled); removal by the owner sends no notification; self-removal deletes your tag notification, tells the owner nothing and blocks re-tagging 24 h. Blocked accounts: not filtered yet (no blocks table; TODO in the SQL) [assumed, confirm]. Tag notification rows (type `tag`) are written by a trigger; the Activity screen shows them when it is built [user]. Feed card headline needs the first two tag names + `tag_count`; labels need `tags` (x/y per media position).
