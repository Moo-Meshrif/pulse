# Short editor (S3)

Screenshot: none. Purpose / route: edit a selected or recorded Short at `/create/short/edit`, then publish it. Visual composition reuses the New Post editor and its shared subflows, adapted to one video [user].

## Layout tree

```text
Scaffold (background, AppSafeArea)
├─ Title row: “Edit short” · X close
├─ Scrollable composer card: author + “Who can watch” chip · video preview · trim · original audio · caption
├─ “ADD TO YOUR SHORT” options: Tag people · Location · Feeling / activity · Allow comments
└─ Pinned “Share short” button
```

## Elements and behavior

| Element | Requirement | Source |
|---|---|---|
| Video preview | exactly one selected video; preserve non-9:16 media uncropped | [user] |
| Trim | duration cannot exceed 60 seconds | [user] |
| Sound | display/use original video audio only | [user] |
| Caption | use New Post caption behavior and limit | [user] |
| Visibility | reuse Post visibility picker, title “Who can watch” | [user] |
| Add-on rows | Tag people, Location, Feeling/activity, Allow comments | [user] |
| Share | publishes with `ContentKind.short`, then returns to/refreshes S1 | [user] |

## States

- Share is disabled while uploading/publishing; failure retains the editor and offers retry [user].
- X/back with edits confirms discard [estimated].
- A valid selected video enables sharing; caption and other metadata are optional under the New Post validation approach [estimated].

## Data mapping

Reuse the Post feature's public visibility, tag, location, feeling/activity, comments, report/options, and publishing interfaces. A Short creates one `kind = short` video with duration <=60 seconds; the shared media policy must enforce that maximum [user].

## Responsive / a11y

Reuse New Post keyboard, semantic, tap-target, and RTL behavior. The video preview has an accessible title and trim controls expose current/start/end duration.

## Acceptance checklist

- [ ] A single video can be trimmed, captioned, attributed to original audio, and published.
- [ ] Every requested New Post add-on is available.
- [ ] “Who can watch” uses the existing audience controls.
- [ ] Share error can retry without losing edits.
