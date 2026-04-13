# Coding Rules

## Dart Style

- Follow `analysis_options.yaml`.
- Prefer explicit return types.
- Prefer `final` locals and fields.
- Prefer `const` constructors and values.
- Keep functions short enough that their intent is obvious.
- Avoid `dynamic`; use generics, sealed classes, or typed models.
- Avoid global mutable state and hidden singletons.
- Avoid static service access from feature code.

## Flutter Style

- Keep widgets focused. Extract widgets when build methods become hard to scan.
- Use `StatelessWidget` when possible.
- Keep business logic out of `build`.
- Use `BuildContext` only where UI context is actually needed.
- Never store a `BuildContext` in long-lived objects.
- Avoid layout that depends on magic numbers when theme spacing or constraints communicate intent better.

## Models

- Prefer immutable value objects.
- Keep DTOs separate from domain entities.
- Keep serialization in `data`.
- Avoid nullable fields for required product concepts.

## Dependencies

- Add packages only when they remove meaningful complexity or provide a proven implementation.
- Prefer well-maintained packages with active Flutter support.
- Keep package usage behind interfaces when the dependency touches IO, storage, platform APIs, analytics, or networking.

## Naming

- Name features by product concept: `matches`, `players`, `profile`.
- Name use cases by action: `CreateMatch`, `LoadPlayers`.
- Name repositories by domain concept: `MatchRepository`.
- Name DTOs with the external shape suffix: `MatchDto`.
- Name widgets by role, not styling: `MatchCard`, `ScoreInput`.

## Comments

- Write comments for intent, tradeoffs, and non-obvious constraints.
- Do not narrate obvious code.
- Keep TODOs actionable and owner-friendly.
