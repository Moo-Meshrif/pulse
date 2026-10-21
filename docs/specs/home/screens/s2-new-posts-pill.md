# S2: Home, new posts while scrolling

Source: user design image "Home · new posts while scrolling" [user, 2026-10-21]. Tells the user new posts are waiting at the top without moving what they read; one tap takes them there. Part of `docs/plans/content-changes-plan.md` Phase 4.

## States
| # | State | What shows |
|---|---|---|
| 1 | New posts while scrolled | More than 1 screen down and a post waits: pill slides in under the header (from -12 px, fade, 220 ms). Avatars of up to 3 authors + up arrow + "New posts". It never moves the list. |
| 2 | With a count | 2 to 9 posts: "N new posts"; more than 9: "9+ new posts". The pill hides while scrolling down and comes back on scroll up or pause. Auto-hides after 10 s; comes back with the next batch. |
| 3 | After tapping the pill | The waiting posts go on top, then the list scrolls to the top (450 ms, easeOutCubic; if more than 6 screens down, jump to 1 screen first). New cards get a soft ring that fades. The pill goes away. |
| 4 | Deep, nothing new | More than 3 screens down and nothing waits: small round "back to top" button above the nav. Tapping it scrolls to the top (same motion). Tapping the Home tab again also scrolls to top (control shell, already built). |

## Rules
- Waiting posts are kept apart from the feed and never inserted above what is on screen.
- Near the top (1 screen or less) a new post goes in at once; no pill.
- Your own posts (shared or from the upload queue) go in on top at once, no pill.
- A waiting post that is edited or deleted meanwhile is updated or dropped.
- Pill: a button; screen reader "Show N new posts and scroll to top", announced once when it appears. Position is the same in RTL (centered); the arrow does not mirror.

## Tokens
| Item | Value |
|---|---|
| Pill | height 44, radius 22, `primary`, padding 0 16 0 9 (start 9, end 16), gap 8, shadow 0 8 24 `primary` @ 35%; top = header bottom + 12 |
| Avatars | 26 including a 2 `primary` ring, overlap 8 |
| Arrow | 16, white, stroke 2.6 (`ic_arrow_up_bold.svg`) |
| Text | 14 / 700 (`context.text.action`), white |
| New card ring | 2, #9ED3C9 (`newPostRing`), stays 2 s, fades out 600 ms |
| Back to top | 48 circle, white @ 92%, shadow 0 8 24 `ink` @ 18%, arrow 22 (`ic_arrow_up.svg`), end 18, 16 above the nav |

## Not built (from the design, left out on purpose)
- The 60 s poll while Home is visible and `home_feed_new_count`: new posts come from the change check (`docs/plans/content-changes-plan.md`); a live ping is Phase 6.
- "Hides while scrolling down *fast*": it hides on any scroll down (no speed measure).

## Open
- Strings in Arabic are drafts (`x-review`).
