# Splash (S13): loading, offline, can't reach
Screenshots (390 x 844, 1x): ../screenshots/s13-splash-loading.png, ../screenshots/s13-splash-offline.png, ../screenshots/s13-splash-error.png [user]
Purpose / route: `/` after onboarding was seen. Decides the first route (Sign in, Home or the sign-up step) from the stored session; see `00-overview.md`. `SplashScreen` (`features/splash`). All values are `[estimated]` from the screenshots unless tagged.

## States
| State | Shown when |
|---|---|
| Loading | Deciding the route (the session is read, the profile step is requested) |
| Offline | Reading the profile failed with a lost connection (`NetworkFailure`) and the device has no Wi-Fi and no mobile data |
| No internet | Same failure, a Wi-Fi or mobile network is on, but the backend cannot be reached (no uplink, captive portal) [user, 2026-10-11] |
| Weak connection | Same failure, the backend answers but slowly, [user, 2026-10-11] |
| Can't reach Pulse | Reading the profile failed for another reason (`ServerFailure`, `NotFoundFailure`, `ParseFailure`, `UnexpectedFailure`) |

A start-up request slower than 5 s (`TimeoutFailure`) is not an error screen either: the session is ended and Sign in opens with the expired banner [user, 2026-10-23].
When the profile saved on the phone says sign-up is finished, the server is not asked: splash goes Home at once [user, 2026-10-23]. A dead session or deleted account is then found by Home's first request.

A revoked or expired session (`AuthFailure(sessionExpired)`) is not an error screen: it goes to Sign in. "Try again" runs the decision again and shows Loading. [estimated mapping, see Q25]

## Layout: Loading
```
Scaffold (bg background) > SafeArea
├─ Center column
│   ├─ Logo tile 72 x 72, radius 22 (the logo file on `primary`, as `LogoTile` but 72)
│   ├─ 14
│   └─ wordmark "pulse" (Sora 30/700, `textPrimary`; the `display` style)
└─ heartbeat line (`PulseLineLoader`, the loading overlay's Lottie line), 140 wide, centered, 36 under the wordmark [user, 2026-10-11: replaces the bottom spinner of the screenshot]; the tile and wordmark stay centered in the screen (a spacer above them balances the line)
```

## Layout: Offline and Can't reach Pulse (same layout, different icon and copy)
```
Scaffold (bg background) > SafeArea
├─ Header: logo mark + wordmark, centered, top ~ 72 (tile 28, gap 8, "pulse" Sora 20/700; the onboarding top-bar logo variant, not mirrored)
├─ Center column (vertically centered between the header and the button)
│   ├─ Circle 96, `primarySoft`, icon 40 `primary` (`ic_wifi_off` | `ic_cloud_alert`)
│   ├─ 24
│   ├─ title (Sora 26/700 centered, `textPrimary`; the `messagesTitle` size)
│   ├─ 8
│   └─ body (`bodySm` centered, `textSecondary`; 2 lines offline, 3 lines can't-reach; ~ 40 side padding)
└─ PinnedBottomCta: PrimaryButton "Try again" (342 x 56, pill), bottom ~ 48 from the frame bottom (24 side padding)
```

## Strings
| Key | en | ar [draft, x-review] |
|---|---|---|
| offlineTitle | You're offline | أنت غير متصل بالإنترنت |
| offlineBody | Check your Wi-Fi or mobile data. We'll try again as soon as you're back online. | تحقق من شبكة Wi-Fi أو بيانات الجوال. سنحاول مرة أخرى فور عودة الاتصال. |
| noInternetTitle | No internet | لا يوجد إنترنت |
| noInternetBody | You're connected to a network, but it has no internet. | أنت متصل بشبكة لكنها لا تتصل بالإنترنت. |
| weakConnectionTitle | Weak connection | اتصال ضعيف |
| weakConnectionBody | Your connection is too slow. Try again in a moment. | اتصالك بطيء جدًا. حاول مرة أخرى بعد قليل. |
| cantReachTitle | Can't reach Pulse | تعذّر الوصول إلى Pulse |
| cantReachBody | Something went wrong on our side. Your account is safe — please try again in a moment. | حدث خطأ من جانبنا. حسابك بأمان، يرجى المحاولة مرة أخرى بعد قليل. |
| tryAgain | Try again | حاول مرة أخرى |
| loading | Loading | جارٍ التحميل (existing; the spinner's label) |

## Behavior and navigation
- Loading -> `resetTo` the route when decided (as today). Offline / Can't reach: stay on the screen; "Try again" returns to Loading and decides again. System back leaves the app (no stack below).
- A lost connection or timeout is told apart by checking the connection (`ConnectivityService.check`): no Wi-Fi/mobile data -> Offline; a network but the backend unreachable -> No internet; a slow answer (over 1.5 s to open a TLS connection to the backend), or a network error with a slow connection -> Weak connection; a network error with a good connection -> Can't reach Pulse. The start-up request (asked only when the saved sign-up is not finished) times out after 5 s and signs out to Sign in (expired).
- The offline and can't-reach screens never show a raw error text or a status code.

## Responsive / a11y
Scrolls on small screens and large text; the button is pinned and rises with nothing (no keyboard). Header logo is decorative. Title is a header (Semantics); the line is announced "Loading". RTL: the layout is centered, so nothing mirrors; the logo mark never flips.

## Acceptance checklist
- [ ] Loading: 72 logo tile with the wordmark below it, centered; the heartbeat line under the wordmark (replaces the small spinner of the screenshot)
- [ ] Offline: centered "pulse" header, 96 soft-green circle with the wifi-off icon, bold title, 2-line grey body, full-width green "Try again" pinned bottom
- [ ] No internet and Weak connection: same layout with the cloud-alert icon and the short copy above
- [ ] Can't reach Pulse: same layout with the cloud-alert icon and the 3-line body
- [ ] "Try again" shows Loading again and re-runs the decision
- [ ] RTL: same layout, Arabic copy
