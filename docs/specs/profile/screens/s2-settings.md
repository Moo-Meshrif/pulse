# Settings (S2)
Screenshot: `../screenshots/s2-settings.png`
Purpose / route: `/settings`, opened from S1 sliders button.

## Layout tree
```
Scaffold (background)
├─ AppTopBar: back + "Settings" (Sora title)
└─ Scroll, side margin 12
   ├─ Section "ACCOUNT": card [Personal info ›, Password & security ›, Privacy "Public" ›, Blocked accounts "3" ›]
   ├─ Section "PREFERENCES": card [Notifications "On" ›, Language "English" ›, SwitchRow Autoplay shorts, SwitchRow Data saver, SwitchRow Dark mode]
   ├─ Section "SUPPORT": card [Help center ›, Report a problem ›, Terms & policies ›]
   ├─ DangerButtonCard: ic_logout + "Log out"
   ├─ Text button "Delete account" (textSecondary 15/600, centered)
   └─ "Pulse · version X.Y.Z" (caption, centered)
```

## Elements
| Element | Text | Token | Notes |
|---|---|---|---|
| row icon tile | ic_user, ic_lock, ic_eye, ic_block, ic_bell, ic_globe, ic_help, ic_flag, ic_document | 36 r12 primarySoft, icon 18 primary | |
| value | Public / Private; blocked count; On / Off; English / العربية | bodySm textSecondary | |
| switch rows | title + subtitle (no icon tile) | see tokens | Dark mode disabled, shows "coming soon" notice on tap |
| version | `Pulse · version <version>` | caption textSecondary | from package info |

## States
Loading values: show rows with no value (values fade in). Switch saving: instant, device-stored. Disabled (Dark mode): 40% opacity.

## Strings
| key | en | ar (x-review) |
|---|---|---|
| settingsTitle | Settings | الإعدادات |
| settingsAccount / Preferences / Support | Account / Preferences / Support | الحساب / التفضيلات / الدعم |
| settingsPersonalInfo | Personal info | المعلومات الشخصية |
| settingsPasswordSecurity | Password & security | كلمة المرور والأمان |
| settingsPrivacy | Privacy | الخصوصية |
| settingsBlocked | Blocked accounts | الحسابات المحظورة |
| settingsNotifications | Notifications | الإشعارات |
| settingsLanguage | Language | اللغة |
| settingsAutoplay / Sub | Autoplay shorts / Play videos automatically on Wi-Fi | تشغيل الشورتس تلقائيًا / شغّل الفيديوهات تلقائيًا عبر الواي فاي |
| settingsDataSaver / Sub | Data saver / Load lower-quality media on mobile data | توفير البيانات / حمّل وسائط بجودة أقل عند استخدام بيانات الجوال |
| settingsDarkMode / Sub | Dark mode / Easier on the eyes at night | الوضع الداكن / أريح للعين ليلًا |
| settingsHelp / Report / Terms | Help center / Report a problem / Terms & policies | مركز المساعدة / الإبلاغ عن مشكلة / الشروط والسياسات |
| settingsLogOut | Log out | تسجيل الخروج |
| settingsDelete | Delete account | حذف الحساب |
| settingsVersion | Pulse · version {version} | بولس · الإصدار {version} |
| valuePublic / Private / On / Off | Public / Private / On / Off | عام / خاص / مفعّل / متوقف |
| darkModeSoon | Dark mode is coming soon | الوضع الداكن قادم قريبًا |
| logOutTitle / Body / Confirm | Log out? / You will need to sign in again. / Log out | تسجيل الخروج؟ / ستحتاج إلى تسجيل الدخول مرة أخرى. / تسجيل الخروج |
| deleteTitle / Body | Delete your account? / This permanently deletes your profile, posts and stories. This cannot be undone. | حذف حسابك؟ / سيؤدي هذا إلى حذف ملفك ومنشوراتك وقصصك نهائيًا ولا يمكن التراجع. |
| deletePasswordHint / Confirm / Wrong | Enter your password / Delete account / Wrong password | أدخل كلمة المرور / حذف الحساب / كلمة المرور غير صحيحة |

## Behavior and navigation
Row tap -> page (navigation map). Autoplay and Data saver: stored on the device (`SharedPreferences` through a datasource); Autoplay default on, Data saver default off. Dark mode: switch is shown off and disabled; tap -> notice. Log out: `ConfirmationDialog` (danger) -> sign out -> `/sign-in` via `AppNavigator.resetTo`. Delete account: `ConfirmationDialog` with a password field; wrong password = inline error; success -> server deletes the account, local data cleared, `/sign-in`.

## Data mapping
Privacy value = `profiles.is_private` (Public / Private). Blocked count = `blocks` count. Notifications value = `notification_prefs.push_enabled`. Language = current locale.

## Responsive / a11y
Rows min 56 tall, whole row is the tap target. Switches have the row title as label. RTL: chevrons mirror, tiles on the start side.

## Acceptance checklist
- Three section cards r22, 36 teal tiles, values aligned before the chevron.
- Switch rows have no icon tile and a 2-line text block.
- Log out card is red text with icon; Delete account is grey text only.
