# Onboarding: assets

## Icons (exist) [user]
| Asset | Used in | Path |
|---|---|---|
| Back arrow | S2, S3 | assets/icons/ic_arrow_back.svg |
| Forward arrow | Next button (S1, S2) | assets/icons/ic_arrow_forward.svg |
| Logo mark | S1 | assets/icons/logo.svg (clip radius 8; square source, not in pubspec yet) |

## Illustrations [user]
PNG files, one set per language. All text inside them (e.g. "+128 likes", "7.5K", chat messages, JS/NA) is **baked into the art**, so the Arabic set is a separate set of images; do not mirror or overlay live text. Until they arrive, the panel shows only its fill color (placeholder) [user]. The user supplies the files and will edit the paths ("put static paths, then I will edit them"), so reference them only through constants (e.g. `AppAssets.onboarding1(locale)`), never inline strings.

Placeholder paths (user will edit) [user-delegated]:
| Screen | English | Arabic |
|---|---|---|
| S1 (primarySoft panel) | assets/images/onboarding/en/onboarding_1.png | assets/images/onboarding/ar/onboarding_1.png |
| S2 (dark panel) | assets/images/onboarding/en/onboarding_2.png | assets/images/onboarding/ar/onboarding_2.png |
| S3 (primarySoft panel) | assets/images/onboarding/en/onboarding_3.png | assets/images/onboarding/ar/onboarding_3.png |

Delivered [user]: all six PNGs exist at the placeholder paths above, 350 x 420 px at 1x with `2.0x/` (700 x 840) and `3.0x/` (1050 x 1260) variants next to them, RGBA. Each image includes the panel background but has square corners, opaque (the radius 32 is applied in Dart by `OnboardingPanel`'s `ClipRRect`), and the Arabic set has mirrored art. Display: inside the panel, `BoxFit.cover`; the panel still clips to radius 32. On phones wider than 390 dp the panel is wider than 350 dp, so `cover` scales the image up and crops a little at the top and bottom [seen].

Reference of what each image shows [seen]: S1 two tilted white post cards (bridge photo; mountains photo with red heart and "7.5K") and a black pill "+128 likes"; S2 centered phone with sunset and white play circle and progress bar over two angled cards; S3 incoming white bubble (avatar JS) "Are you coming to the hike on Friday?", outgoing green bubble "Wouldn't miss it. Bringing the camera!", avatar NA with beach photo bubble, typing bubble.

## Fonts [user]
Delivered and declared in `pubspec.yaml`, as static files in `assets/fonts/`: Sora 600/700 (`Sora-SemiBold.ttf`, `Sora-Bold.ttf`), Noto Sans 400/500/600/700 (`NotoSans-Regular|Medium|SemiBold|Bold.ttf`), Noto Sans Arabic 400/500/600/700 (`NotoSansArabic-Regular|Medium|SemiBold|Bold.ttf`). Families: `Sora`, `NotoSans`, `NotoSansArabic`.

## pubspec
Register `assets/icons/`, `assets/images/onboarding/` (both language folders) and the fonts (`flutter: assets:` and `fonts:` are currently empty).
