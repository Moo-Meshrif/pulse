# Onboarding: design tokens

All tokens come from `../_theme/` (colors.md, typography.md, spacing-radius-shadows.md). Feature-specific values:

| Token | Value | Source |
|---|---|---|
| Panel radius | 32 (`radius/onboardingPanel`) | [user] |
| Panel height | 420 | [user] |
| Panel margin | CSS shorthand `20 20 0`: top 20, left/right 20, bottom 0 | [user] (corrected: verified against the screenshot, panel top at 80 dp) |
| Panel fill S1, S3 | colors/primarySoft | [user] |
| Panel fill S2 | colors/textPrimary | [user] |
| Title style | typography/onboardingTitle, color textPrimary | [user] + [seen] color |
| Body | typography/subtitle (Noto Sans 15/400, lh 1.55), color textSecondary | [user] |
| Skip | Noto Sans 15 w600, textSecondary, 44 high | [user] |
| Dot active | 24 x 8, radius 4, colors/primary | [user] |
| Dot inactive | 8 x 8, radius 4, colors/switchOff | [user] |
| Dot gap | 6 | [user] |
| Button height | 56, radius 28 (pill), fill primary, pressed primaryPressed, label button style in textOnPrimary | [user] |
| Next button padding | 0 28 horizontal, arrow 20 | [user] |
| Get started | full width of footer (390 - 2*24 = 342), 56 | [user] |
| Sign-in link row | 44 high | [user] |
