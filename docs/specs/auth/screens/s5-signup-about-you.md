# Sign-up 3: About you (S5)
Screenshot: ../screenshots/s5-signup-about-you.png
Purpose / route: step 3 of `SignUpFlow`. Resume target after an interrupted sign-up [user].

## Layout tree
```
StepTopBar (Step 3 of 6, 3 filled, "Required")
side padding 24, scrollable
├─ title "About you" > 8 > subtitle
├─ ~24 > "Full name *" field (hint "Your name")
├─ 14 > "Username *" field (prefix "@", hint "username") > 6 > helper (2 lines)
├─ 14 > "Birthday *" read-only field (hint "DD / MM / YYYY") > 6 > helper
├─ 14 > "Gender" + " (optional)" > 8 > chips Wrap: Female | Male | Prefer not to say
PinnedBottomCta: PrimaryButton "Continue"
```

## States
- Continue enabled when full name non-empty, username valid, birthday set.
- Username: pattern `^[A-Za-z0-9._]{3,30}$`, stored lowercase, uniqueness checked on Continue; error "Username is taken" [user]; invalid pattern error uses the helper text in `danger` [estimated].
- Birthday: tap opens the platform date picker (range 1900 .. today); picked value shown "DD / MM / YYYY"; min age 18, error "You must be at least 18" [user].
- Gender: single select, tap again clears, optional; values female / male / prefer_not_to_say [user].

## Strings
| Key | en | ar [draft, x-review] |
|---|---|---|
| aboutTitle | About you | عنك |
| aboutSubtitle | This is how people will find you on Pulse. | بهذه الطريقة سيجدك الناس على Pulse. |
| fullNameLabel / Hint | Full name / Your name | الاسم الكامل / اسمك |
| usernameLabel / Hint | Username / username | اسم المستخدم / اسم المستخدم |
| usernameHelper | Letters, numbers, dots and underscores. At least 3 characters. | الأحرف والأرقام والنقاط والشرطة السفلية. 3 أحرف على الأقل. |
| birthdayLabel / Hint | Birthday / DD / MM / YYYY | تاريخ الميلاد / DD / MM / YYYY |
| birthdayHelper | Used to confirm your age. It isn't shown on your profile. | يُستخدم للتأكد من عمرك. لا يظهر في ملفك الشخصي. |
| genderLabel / optional | Gender / (optional) | الجنس / (اختياري) |
| female / male / preferNot | Female / Male / Prefer not to say | أنثى / ذكر / أفضّل عدم الذكر |
| errorUsernameTaken | Username is taken | اسم المستخدم مستخدم بالفعل |
| errorMinAge | You must be at least 18 | يجب أن يكون عمرك 18 عامًا على الأقل |

## Behavior and navigation
Continue -> save profile fields (Supabase; TODO: schema pending) -> step 4. Back arrow and system back = leave dialog S10 (account verified, S4 not revisitable) [user].

## Data mapping
`full_name`, `username`, `birthday`, `gender` [estimated names; TODO: confirm against the Supabase schema].

## Responsive / a11y
"@" and username LTR in RTL; date picker follows locale (Arabic digits per platform).

## Acceptance checklist
- [ ] Red asterisks on 3 labels; "(optional)" lighter
- [ ] "@" prefix before hint; helpers grey under fields
- [ ] 3 outline chips, none selected, 40 high
