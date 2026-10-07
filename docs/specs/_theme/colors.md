# Colors (light theme) [user]

Dart: `Color(0xFF......)`. Dark values: `[unknown]` (light only for now).

## Brand
| Token | Hex | Usage |
|---|---|---|
| primary | #2E6B63 | Primary buttons, active icons, links, switch on, selected chips |
| primaryPressed | #1F4D47 | Pressed / hover state of primary |
| primarySoft | #E2EEEB | Icon tiles, onboarding panels, "Your story" fill |
| storyRing | #9DBDB7 | Post avatar ring |

## Surfaces
| Token | Hex | Usage |
|---|---|---|
| background | #F3F4F3 | Screen background |
| surface | #FFFFFF | Cards, sheets, inputs |
| surfaceMuted | #F7F8F7 | Input fill on white cards |
| segmentTrack | #E3E7E5 | Segmented control track |

## Text & icons
| Token | Hex | Usage |
|---|---|---|
| textPrimary | #161A19 | Main text, default icons |
| textSecondary | #5B6461 | Captions, hints, section labels |
| iconInactive | #3D4644 | Inactive bottom-bar icons |
| textOnPrimary | #FFFFFF | Text/icons on primary and on video |

## Lines & controls
| Token | Hex | Usage |
|---|---|---|
| border | #D5DAD8 | Inputs, outline buttons, chips |
| divider | #E3E6E4 | Dividers, outlines on cards |
| switchOff | #C9D3D0 | Switch off, **inactive page dots** |
| dashed | #9AA6A2 | Dashed add borders, radio off |

## Status
| Token | Hex | Usage |
|---|---|---|
| like | #E0323C | Liked heart, unread badge, notification dot |
| danger | #C42B34 | Log out, required * |
| online | #2FA864 | Online dot |
| warning | #D98A1E | Password "Fair" |

## Overlays & glass
| Token | Value | Usage |
|---|---|---|
| scrim | #161A19 @ 40% (0x66161A19) | Bottom-sheet backdrop |
| videoChip | #161A19 @ 45% (0x73161A19) | Chips over video |
| glassFill | #FFFFFF @ 55% (0x8CFFFFFF) | Bottom bar fill |
| glassBorder | #FFFFFF @ 80% (0xCCFFFFFF) | Bottom bar border |
| glassActive | #FFFFFF @ 85% (0xD9FFFFFF) | Active tab circle |

## Avatar backgrounds (white initials)
#7A4E3A, #3E5C76, #2E6B63, #5E4B7A, #6B5B2E, #8A3B4E, #4F6B4A

## Contrast notes [user]
textSecondary on surface ~6:1, on background ~5.5:1 (AA). White on primary ~6:1 (AA). Do not use `dashed` or `switchOff` for text (<3:1).
