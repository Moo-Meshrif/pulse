# Typography [user]

Fonts: **Sora** (headings, numbers, logo; weights 600, 700) and **Noto Sans** (everything else; weights 400, 500, 600, 700). **Noto Sans Arabic** (400, 500, 600, 700) replaces both families for Arabic: same size and weight, letterSpacing 0, line height +0.1 (see rtl.md) [user]. Fonts are bundled in `assets/fonts/` and declared in `pubspec.yaml` [user]; done. The user says the design kit also ships `app_colors.dart`, `app_text_styles.dart`, `app_dimens.dart`, `app_assets.dart`; they are not in this repo, so create equivalents from these specs (or ask the user to add the kit files).

| Style | Font | Size | Weight | Letter spacing | Line height |
|---|---|---|---|---|---|
| logo | Sora | 24 | 700 | -0.5 | - |
| display (auth/registration titles) | Sora | 30 | 700 | -0.6 | 1.2 |
| onboardingTitle | Sora | 28 | 700 | -0.6 | 1.2 |
| title (screen titles) | Sora | 22 | 700 | -0.4 | - |
| titleSm | Sora | 20 | 700 | -0.3 | - |
| messagesTitle | Sora | 26 | 700 | -0.5 | - |
| stat | Sora | 18 | 700 | 0 | - |
| button | Noto Sans | 16 | 700 | 0 | - |
| body (list row titles, menu items) | Noto Sans | 15 | 500 | 0 | 1.5 |
| subtitle (onboarding body, screen subtitles, intro text) | Noto Sans | 15 | 400 | 0 | 1.55 |
| bodySm | Noto Sans | 14 | 400 | 0 | 1.45 |
| name | Noto Sans | 15 | 700 | 0 | - |
| label | Noto Sans | 13 | 600 | 0 | - |
| section (UPPERCASE) | Noto Sans | 13 | 700 | 0.4 | - |
| meta | Noto Sans | 13 | 600 | 0 | - |
| caption | Noto Sans | 12 | 400 | 0 | - |
| badge | Noto Sans | 10-11 | 700 | 0 | - |
