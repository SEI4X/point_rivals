# UI And UX

The product direction is Apple-like and minimalist. The app should feel quiet, precise, and native without copying platform UI blindly.

## Point Rivals Visual Language

- The app is dark-first, sporty, premium, and compact: near-black background, charcoal panels, small yellow pill actions, restrained badges, dense stats, and soft rounded Material icons.
- The primary reference is a fitness/workout dashboard mood: black `#0B0C0D`, charcoal `#141719`, card panel `#202428`, muted pill `#3A3F44`, acid yellow `#FFD426`, and small pink-red `#FF3B64` accents.
- Light theme exists for accessibility and user choice, but all layouts must still preserve the same compact premium system, not become a separate white Material app.
- Icons must use rounded Material symbols where possible, for example `*_rounded`, `*_outline_rounded`, or similarly soft variants. Avoid sharp/filled icons unless they communicate selected state.
- Cards and tiles are quiet charcoal surfaces: no heavy shadows, no gradients, thin outlines, compact padding, strong type hierarchy, rounded corners, and stable layout.
- Primary controls are small but tappable: yellow filled buttons for primary action, dark outlined/text controls for secondary actions, badge-like chips for metrics.
- Empty states should be calm and compact: one soft icon, one title, one short body. No marketing copy.

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
- Prefer dark neutral surfaces with one clear yellow accent color.
- Use rounded geometry throughout. Default app radius is `18`; tiny controls can use `14`; bottom sheets can use larger top corners.
- Buttons, cards, chips, inputs, dialogs, sheets, checkboxes, and custom pills should all feel soft and rounded.
- Avoid nested cards.
- Avoid whole-screen card frames. Content should breathe on the native scaffold.
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
