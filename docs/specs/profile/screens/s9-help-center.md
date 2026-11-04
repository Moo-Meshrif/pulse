# Help center (S9)
Screenshot: `../screenshots/s9-help-center.png`
Purpose / route: `/settings/help`.

## Layout tree
```
├─ AppTopBar back + "Help center"
├─ Section "TOPICS": 2x2 grid of topic cards (icon tile 36 + title): Account & profile (ic_user), Privacy & safety (ic_lock), Posts & shorts (ic_play), Messages (ic_chat_bubble)
├─ Section "COMMON QUESTIONS": card, FaqAccordion rows (first one open in the screenshot)
└─ Row (gap 8): "Chat with us" (primary pill) + "Report a problem" (outline pill), equal width
```

## States
Loading: skeleton cards and rows. Empty questions: hide the section. Error: retry notice. Accordion: tap row toggles; chevron rotates; first question open by default [Q-S9-1].

## Strings
Topic names and questions come from the server (per language `title_en`, `title_ar`). UI strings:
| key | en | ar (x-review) |
|---|---|---|
| helpTitle | Help center | مركز المساعدة |
| helpTopics / CommonQuestions | Topics / Common questions | المواضيع / الأسئلة الشائعة |
| chatWithUs | Chat with us | تحدث معنا |
| reportProblem | Report a problem | الإبلاغ عن مشكلة |
| chatSoon | Chat support is coming soon | الدردشة مع الدعم قادمة قريبًا |
Sample content in the screenshot: "How do I change my username?" / "Go to Settings, then Personal info, and edit the Username field. A green check means the name is free."; "How do I make my account private?"; "Why can't I upload a short?"; "How do I recover a hacked account?".

## Behavior and navigation
Topic card -> S14 (that topic). Chat with us -> "coming soon" notice. Report a problem -> S10.

## Data mapping
New tables `help_topics(id, slug, icon, title_en, title_ar, position)` and `help_articles(id, topic_id, question_en/ar, answer_en/ar, position, is_common)`; "Common questions" = `is_common`; read-only for clients (RLS select to authenticated).

## Responsive / a11y
Accordion rows expose expanded/collapsed state. Topic cards wrap to a single column at text scale >= 1.5.

## Acceptance checklist
- 2x2 cards equal size; one open question with grey answer text; two bottom buttons same height.
