# V2 Theme Design Assets

Phase 1 has been redone with built-in Image Gen bitmap outputs. The previous script-generated assets were removed; this folder no longer contains HTML/CSS/Python-generated visual resources.

## Theme Selection

Theme selection must use the phone system language, not the in-app language setting.

- `ja*`: Oshi Pop Neon
- `en*`: Live Stage Console
- `zh-Hans*`, `zh-CN`, `zh-SG`, `zh-Hant*`, `zh-TW`, `zh-HK`, `zh-MO`: Neon Utility Pro
- Other languages: Live Stage Console fallback

## Theme Folders

- `01-oshi-pop-neon`: Japan market, oshi-katsu pop neon.
- `02-live-stage-console`: United States market, live event console.
- `03-neon-utility-pro`: Mainland China and Taiwan, premium utility neon.

Each theme folder contains:

- `high-fidelity-board.png`: Four-screen high-fidelity direction board.
- `backgrounds/app-background@3x.png`: Vertical app-wide background candidate.
- `backgrounds/home-hero@3x.png`: Landscape Home LED preview hero background.
- `backgrounds/paywall-hero@3x.png`: Landscape Pro paywall hero background.
- `prompts/*.prompt.txt`: Final Image Gen prompts used to generate each asset.
- `theme-manifest.json`: Stable design metadata for the future implementation stage.

## Implementation Guardrails

- Keep the free core path complete: text input, free template/style/color selection, and full-screen LED display.
- Pro styling must enhance the app, not block basic LED sign usage.
- Preserve the regional personality of each theme instead of making one shared neon skin with different colors.
- The next phase should refactor theme selection and UI composition only after these visuals are approved.
