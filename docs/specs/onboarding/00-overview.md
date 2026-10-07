# Onboarding: overview

Platform: Flutter, phone, 390 x 844 design frame, **light only**, LTR + RTL, English + Arabic [user]. No Figma link; screenshots + user spec are the source.
Theme: shared tokens live in `../_theme/` (none existed in the repo; created from the user's spec). Do not duplicate raw values here.

## Screens
| ID | Name | Spec ref | File | Screenshot |
|---|---|---|---|---|
| S1 | Onboarding 1: "Share the moments that move you" | 1.1 | screens/s1-onboarding-1.md | screenshots/s1-onboarding-1.png |
| S2 | Onboarding 2: "Swipe through short videos" | 1.2 | screens/s2-onboarding-2.md | screenshots/s2-onboarding-2.png |
| S3 | Onboarding 3: "Stay close with chat" | 1.3 | screens/s3-onboarding-3.md | screenshots/s3-onboarding-3.png |

## Navigation map
```
S1 --Next--> S2 --Next--> S3 --Get started--> 2.1 Registration (Account)
S1/S2 --Skip--> 1.4 Sign in        S3 --"Sign in"--> 1.4 Sign in
S2/S3 --Back--> previous page      S1: no back
```
(Skip target, back behavior, swipe, persistence: [user] "all as stated".) Screens 1.4 and 2.1 are outside this feature; routes only.

## Structure
The three screens share one scaffold: top bar, illustration panel, text block, footer. Implement as one `PageView` of 3 pages sharing header/footer state [user, accepted default]; the spec treats them as 3 pages of one flow with a shared page indicator.

## Files
01-design-tokens.md, 02-components.md, screens/*, assets.md, open-questions.md
