# UI And UX

The product direction is Apple-like and minimalist. The app should feel quiet, precise, and native without copying platform UI blindly.

## Principles

- One screen, one primary job.
- Prefer clarity over decoration.
- Use generous spacing and strong typographic hierarchy.
- Keep primary actions obvious.
- Make destructive actions deliberate.
- Prefer system-native interaction patterns where they improve familiarity.
- Avoid novelty when a standard control is clearer.

## Visual Rules

- Use the app theme as the source of truth.
- Prefer neutral surfaces with one clear accent color.
- Keep corner radius at or below `8`.
- Avoid nested cards.
- Avoid decorative gradient blobs, noisy shadows, and ornamental backgrounds.
- Use motion sparingly and only to clarify state or navigation.

## Copy Rules

- Copy must be user-facing product text only.
- Do not describe the UI itself.
- Keep labels short.
- Prefer verbs for actions.
- Put all copy in localization files.

## Accessibility

- Respect platform text scaling.
- Maintain sufficient contrast.
- Ensure tappable targets are at least `44x44`.
- Do not communicate state with color alone.
- Provide semantic labels for icon-only controls.

## Responsive Layout

- Design for phones first, then tablet and desktop.
- Constrain wide content so reading lines stay comfortable.
- Avoid viewport-scaled font sizes.
- Ensure text wraps safely in English and Russian.
