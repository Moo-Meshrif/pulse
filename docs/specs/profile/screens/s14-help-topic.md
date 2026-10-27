# Help topic (S14)
Screenshot: none (no design supplied; built from S9 [user]).
Purpose / route: `/settings/help/topic?slug=<slug>`, opened from an S9 topic card.
## Layout tree
```
├─ AppTopBar back + topic name (e.g. "Account & profile")
└─ Card (white r22, margin 12): FaqAccordion of that topic's questions (all, not only common)
```
## States
Loading skeleton; empty: `AppEmpty` "No questions here yet"; error retry. All collapsed on open [Q-S14-1].
## Strings
| key | en | ar (x-review) |
|---|---|---|
| helpTopicEmpty | No questions here yet | لا توجد أسئلة هنا بعد |
## Behavior and navigation
Accordion as S9. Topic name and questions from `help_topics` / `help_articles` (language columns).
## Data mapping
`help_articles` where `topic_id` = slug's topic, ordered by `position`.
## Responsive / a11y
As S9.
## Acceptance checklist
- Same accordion rows as S9; title is the topic name.
