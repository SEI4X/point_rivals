# Point Rivals Flutter Rules

These rules apply to the whole repository.

## Product Direction

- Build a Flutter app with Apple-like visual discipline: calm hierarchy, native-feeling motion, generous spacing, clear typography, and minimal ornament.
- Prefer minimalist UX. Every screen should have one primary job, one obvious next action, and no explanatory copy that belongs in documentation.
- Support English and Russian from the start. New languages must be additive and must not require touching feature code.

## Architecture

- Use feature-first layered architecture.
- Put app-level composition in `lib/app`.
- Put shared, product-agnostic code in `lib/core`.
- Put feature code in `lib/features/<feature_name>`.
- Each feature is split into `data`, `domain`, and `presentation`.
- Presentation depends on domain. Data depends on domain. Domain must not depend on Flutter UI, data sources, or presentation.
- Keep dependencies injected through constructors or narrow interfaces so every behavior can be unit tested.

## Localization

- Never hardcode user-facing text in Dart widgets, services, validators, routes, dialogs, snack bars, errors, or notifications.
- Store all product copy in ARB files under `lib/core/l10n`.
- Update both `app_en.arb` and `app_ru.arb` for every new string.
- Use `AppLocalizations` and `context.l10n` from `lib/core/l10n/l10n.dart`.
- Keep localization keys stable, descriptive, and feature-scoped when needed, for example `profileEditSaveButton`.

## Testing

- Every new feature or behavior must include tests.
- Prefer unit tests for domain logic, use widget tests for presentation states, and add integration tests only for end-to-end flows.
- Do not merge behavior that cannot be tested because dependencies are hidden behind globals, static calls, or hardcoded platform APIs.
- Run `flutter analyze` and `flutter test` before considering work complete.

## Coding Rules

- Follow `analysis_options.yaml`; treat analyzer warnings as work to finish, not noise.
- Keep widgets small and composable.
- Prefer immutable models and explicit result types over nullable error signaling.
- Do not introduce global mutable state.
- Do not add packages without a clear reason and a short note in the relevant PR or change summary.
- Keep files ASCII unless a file is localization content or already uses another character set.

## References

Detailed rules live in `docs/project-rules/`.
