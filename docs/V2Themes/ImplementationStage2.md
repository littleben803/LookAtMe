# Stage 2 Implementation Notes

## Scope Completed

Stage 2 introduces the runtime skin layer and connects the first visible UI surfaces to the approved V2 theme assets.

## Runtime Theme Selection

Implementation file:

- `LookAtMe/Theme/LookSkin.swift`

Rules:

- Use `Locale.preferredLanguages` from the phone system.
- Do not use the in-app language setting for theme selection.
- `ja*` -> Oshi Pop Neon.
- `zh*` -> Neon Utility Pro.
- Everything else, including `en*`, -> Live Stage Console.

## Root Injection

Implementation file:

- `LookAtMe/App/LookAppApp.swift`

The app root owns `LookSkinManager`, injects it as an environment object, and also injects the active `lookSkin` environment value.

## Asset Catalog Names

Oshi Pop Neon:

- `OshiPopNeonAppBackground`
- `OshiPopNeonHomeHero`
- `OshiPopNeonPaywallHero`

Live Stage Console:

- `LiveStageConsoleAppBackground`
- `LiveStageConsoleHomeHero`
- `LiveStageConsolePaywallHero`

Neon Utility Pro:

- `NeonUtilityProAppBackground`
- `NeonUtilityProHomeHero`
- `NeonUtilityProPaywallHero`

## Current UI Coverage

Theme-aware in this stage:

- Global `LookScreenBackground`
- Root tint
- Home background and Home hero
- Home start button and key header accents
- Shared neon card, primary button, text input, template chip, Pro badge, scene shortcut, and style card shells
- Template Center scene tabs and row accents
- Style Picker segmented tint and Pro teaser
- Pro Paywall hero, badges, status, and secondary actions

## Page-Level Polish Pass

Additional polish after the runtime theme layer:

- `LookSkin.Chrome` now owns page-level visual tokens: card radius, control radius, density, background image strength, glass opacity, and theme-specific symbols.
- Home hero now prioritizes a live LED preview panel using the current draft text, so the first screen reads as an LED sign tool rather than a decorative title screen.
- Home hot templates moved away from pill buttons into compact LED preset cards.
- Template Center rows now use expression cards with explicit scene, access state, action affordance, and a large LED phrase preview.
- Style cards now use a larger preview area and a single bottom metadata row, avoiding the old stacked title/free/pro layout that left the lower-right area empty.
- Style Picker Pro teaser now uses theme-specific symbols and skin radius tokens.
- Pro Paywall hero is shorter, benefits are compressed into two-column value cards, and action buttons appear earlier in the scroll.

## Page Consistency Pass

Additional consistency work:

- Root `TabView` now applies `UITabBarAppearance` from the active `LookSkin` at runtime instead of using a fixed pink/purple UIKit appearance.
- `NeonPageHeader` now uses skin colors and keeps the shared `InteractiveSwipeBackEnabler`, so secondary pages preserve edge-swipe back while matching the active theme.
- Shared secondary-page components now consume `lookSkin`: `SettingsRow`, `SettingsToggleRow`, `SectionHeader`, `FeatureGridCardLabel`, `EmptyStateView`, `ColorSwatchButton`, `ToastView`, and placeholder surfaces.
- Settings, Favorites, Appearance, Display Settings, Language, Help, Legal, About, and Purchase Success visible text/accent surfaces now use skin tokens.
- Destructive, warning, success, and LED effect-preview colors intentionally stay semantic/effect-specific rather than being fully remapped by theme.

Not fully converted yet:

- Full-screen LED display effects still use their established effect palettes.
- Full-screen display control overlays still use their established LED playback palette.

## Debug Theme Switcher

Debug builds expose `Settings -> Debug -> Theme` for fast V2 theme QA.

- Release behavior stays unchanged: theme selection follows the phone system language, not the in-app language setting.
- Debug behavior uses a persisted local theme override in `LookSkinManager`; system-locale change notifications do not replace the manually selected skin while the Debug theme entry is enabled.
- The Debug Theme page also lets QA lock the app language to `zh-Hans`, `zh-Hant`, `en`, or `ja`. Entering the page converts `System` language mode to the current resolved language so Debug QA does not continue following the system language implicitly.
