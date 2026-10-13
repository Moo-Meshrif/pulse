# Create story: edit and share (S3)
Screenshot: board panel 5. Route `/create/story/edit`.

## Layout tree
```
Stack: captured media full-bleed + shades
├─ X close (top start)
├─ Tool column (end): Aa text · location sticker · mute (video) · save (44 circle, black @35%)
├─ Stickers: text "Golden hour 🌅" (Sora 30/700 white, soft shadow), location sticker "ZAMALEK, CAIRO" (tilted -4°)
└─ Bottom: "Your story" pill (avatar + label, white @18%) · Share pill 52 white "Share ›"
```
## Behavior
- Aa adds text; location sticker opens **Add location** (post feature S3) and places a sticker; mute toggles audio on videos; save downloads the media. Drag / pinch stickers.
- "Your story" pill shows who will see it (audience: Q7).
- Share: pop to Home, upload in the background (S4): upload to `post-media/{uid}/stories/{id}.jpg|mp4`, then insert `stories`. Overlays are saved as JSON in `stories.overlays` (type text|location, text, x/y as fractions of the frame, scale, rotation, color) and drawn by the viewer; media is uploaded untouched [user].
- X: discard confirm [estimated].

## Strings
| Key | en | ar |
|---|---|---|
| storyShare | Share | مشاركة |
| storyYourStoryPill | Your story | قصتك |
| tools (semantics) | Text, Location, Mute / Unmute, Save | نص، الموقع، كتم / إلغاء الكتم، حفظ |

## Acceptance checklist
- [ ] Tool buttons stacked at the end, 44 on black @35%.
- [ ] Text sticker Sora 30/700 with shadow; location sticker white with uppercase green text.
- [ ] "Your story" pill left, white "Share ›" pill right.
