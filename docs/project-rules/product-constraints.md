# Product Constraints

## Product

- Point Rivals is a focused, minimalist Flutter app.
- The experience should feel fast, calm, and deliberate.
- Avoid adding screens, prompts, settings, onboarding, or explanations unless they directly serve a real user job.

## Platforms

- Flutter is the primary implementation surface.
- Platform-specific code belongs behind narrow adapters.
- Platform-specific UI should be used only when it improves native feel without fragmenting behavior.

## Localization

- English and Russian are required.
- Localization must be file-based and easy to extend.
- Feature code must not need edits when adding a new language, except when a new language changes product behavior.

## Quality

- Every feature must be testable.
- Every behavior change must include tests.
- Analyzer issues block completion.
- Avoid hidden runtime behavior that cannot be verified locally.

## UX

- Minimalist UX is a product constraint, not a styling preference.
- Do not add extra choices when a sensible default exists.
- Do not expose technical implementation details to users.
- Keep copy concise and localized.
