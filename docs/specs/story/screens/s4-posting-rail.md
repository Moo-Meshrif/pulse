# Posting state on the Home rail (S4)
Screenshot: board panel 6 (Home with the rail). Shown on `/home` after Share; the rail itself is home's UI, this state is specced here because the story feature drives it.

- The first item (your story) shows a **progress ring** while uploading (64, stroke 3, `primary` on `border`) with the label **"Posting…"**; your avatar/last frame inside.
- Success: the ring becomes a normal unseen ring and the label returns to "Your story" (or your username).
- Failure: **`warningInk` ring (`#B26F12`) with label "Retry"** + error notice with **Retry** [board].
- The board's rail shows the title **"Stories"** and usernames as labels (nour.adel, yousef.s, mariam.h, omarkh): see Q1 (conflicts with Home S1 "Trending").
- State comes from a story upload controller owned by the story feature; home observes it (use case / stream), never the datasource.
