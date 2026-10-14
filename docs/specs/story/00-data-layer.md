# Story feature: data layer (no UI yet)

Status: short spec, written 2026-10-13 [user asked]. UI (create story, story viewer) comes later; video via `video_flux` [user]. Consumer today: `home` (rail only). Schema: `../home/schema.sql` (stories, story_views, `story_rail`) + `../home/schema-post-options.sql` (`story_rail` re-created with mute filter).
Rules: same as `../post/00-data-layer.md`.

## Layout
```
lib/features/story/
  data/
    datasource/stories_datasource.dart    # interface + Supabase adapter
    model/story_rail_item_model.dart
    enums/story_media_type.dart           # image | video (own copy, no post import)
  domain/use_case/
```

## Models
`StoryRailItemModel` (one `story_rail` row): authorId, username, fullName, avatarUrl?, isMe, storyCount, latestAt, allSeen.

## Datasource: `StoriesDatasource` (needed now)
| Method | Call | Returns |
|---|---|---|
| `getStoryRail({limit = 30})` | `rpc('story_rail', {p_limit})` | `List<StoryRailItemModel>`: me first (only with an active story), then unseen, then latest |

## Use cases (needed now)
`GetStoryRailUseCase()`. Presentation (home) adds the always-first "Your story" dashed tile [user], builds the label (`username`, truncated [user]) and the ring state (`allSeen` → seen ring).

## Now specced (UI in `screens/`)
`GetAuthorStoriesUseCase(authorId)` (`author_stories` + signed URLs), `MarkStoryViewedUseCase(storyId)` (insert `story_views` after 1 s), `CreateStoryUseCase(file, overlays?)` (upload `post-media/{uid}/stories/{id}.jpg|mp4` then insert `stories`; exposes upload progress for S4), `DeleteStoryUseCase(storyId)`, `GetStoryViewersUseCase(storyId)` (`story_viewers`), `SetStoryLikeUseCase(storyId, liked)` (`set_story_like`), `SaveStoryToDeviceUseCase`. Schema: `schema-story-extras.sql` (overlays, story_likes, RPCs; spec-level, not applied). Not built: replies (Chat). [2026-10-14] Report, mute, change audience and the file cleanup after a delete go through the shared use cases in `lib/shared/content` (`ReportContentUseCase`, `SetMuteUseCase`, `SetContentAudienceUseCase`, `RemoveMediaFilesUseCase`); the audience counts through `GetAudienceSummaryUseCase`; `StoryAudience` is replaced by the shared `ContentAudience`. Their RPCs are `report_content`, `set_mute(p_scope)`, `set_content_audience` (`../post/schema-shared-content-actions.sql`).

## Open questions
| # | Question | Status |
|---|---|---|
| Q-A | Public return type | **answered** [user]: `StoryRailItemEntity` in `domain/entity` (same rule as post) |
| Q-B | Story media signing | **answered** [user]: story signs its own URLs; story keeps its own `StoryMediaType` enum (no import from post) |
| Q-C | Rail shows the author's avatar only (no story thumbnail) | **decided** [user] |

## Presentation owned by this feature [user]
Story viewer screen (opening a story) and create-story screen, with their routes (`/story/:authorId`, `/create/story`); video via `video_flux`. Not specced yet (needs screenshots). Home's rail taps call these routes: avatar -> viewer, "Your story" + -> create.
