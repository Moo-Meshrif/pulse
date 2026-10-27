# Terms & policies (S11)
Screenshot: `../screenshots/s11-terms-policies.png`
Purpose / route: `/settings/terms`.

## Layout tree
```
├─ AppTopBar back + "Terms & policies"
├─ Card: SettingsRow x5 with doc tile (ic_document): Terms of service, Privacy policy, Community guidelines, Cookie policy, Open-source licenses; subtitle "Last updated <date>", chevron
├─ Section "YOUR DATA": card [Download your data / "Get a copy of your posts, shorts and messages" ›, Ad preferences / "Control how your activity shapes ads" ›]
└─ Footer (caption, centered): "Pulse · version X.Y.Z" and "© <year> <company>"
```

## Strings
| key | en | ar (x-review) |
|---|---|---|
| termsPoliciesTitle | Terms & policies | الشروط والسياسات |
| termsOfService / privacyPolicy / communityGuidelines / cookiePolicy / openSourceLicenses | Terms of service / Privacy policy / Community guidelines / Cookie policy / Open-source licenses | شروط الخدمة / سياسة الخصوصية / إرشادات المجتمع / سياسة ملفات تعريف الارتباط / تراخيص المصدر المفتوح |
| lastUpdated | Last updated {date} | آخر تحديث {date} |
| yourData | Your data | بياناتك |
| downloadData / Sub | Download your data / Get a copy of your posts, shorts and messages | نزّل بياناتك / احصل على نسخة من منشوراتك وشورتسك ورسائلك |
| adPreferences / Sub | Ad preferences / Control how your activity shapes ads | تفضيلات الإعلانات / تحكم في كيفية تأثير نشاطك على الإعلانات |
| copyright | © {year} {company} | © {year} {company} |
| dataSoon | This is coming soon | هذه الميزة قادمة قريبًا |

## Behavior and navigation
Five rows open the existing legal routes (`/terms`, `/privacy`, `/community-guidelines`, `/cookie-policy`, `/open-source-licenses`, `features/legal`). "Last updated" from `legal_documents.updated_at`, formatted by locale. Download your data and Ad preferences: "coming soon" notice [Q-S11]. Company name: UNKNOWN (Q-S11-2).

## Data mapping
`legal_documents` (updated_at per type). Version from package info.

## Acceptance checklist
- Five doc-tile rows, two plain rows, footer two lines; chevrons mirror in RTL.
