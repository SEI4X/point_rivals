# Architecture

Point Rivals uses feature-first layered architecture. The goal is to keep product work easy to find, easy to test, and safe to change.

## Top-Level Structure

```text
lib/
  app/
    app.dart
    theme/
  core/
    l10n/
    routing/
  features/
    <feature_name>/
      data/
      domain/
      presentation/
```

## Layer Responsibilities

`app`

- Owns app composition: `MaterialApp`, theme, localization delegates, global navigation setup, dependency composition.
- Does not contain feature business logic.

`core`

- Contains shared, feature-neutral building blocks: localization, routing primitives, design tokens, common errors, common result types, platform adapters.
- Must not become a dumping ground for feature-specific code.

`features/<feature>/domain`

- Contains entities, value objects, repository contracts, use cases, domain services, and pure business rules.
- Must be Flutter-free and UI-free.
- Must be straightforward to unit test without test bindings.

`features/<feature>/data`

- Contains repository implementations, DTOs, mappers, local storage, network adapters, platform adapters, and data source implementations.
- Depends on domain contracts.
- Converts infrastructure failures into domain-level failures.

`features/<feature>/presentation`

- Contains screens, widgets, controllers, view models, state classes, and UI-only formatting.
- May depend on domain use cases.
- Must not directly call remote APIs, databases, platform channels, or storage.

## Dependency Direction

Allowed:

- `presentation -> domain`
- `data -> domain`
- `app -> features`
- `app -> core`
- `features -> core` only for generic shared tools

Forbidden:

- `domain -> presentation`
- `domain -> data`
- `data -> presentation`
- Cross-feature imports unless the target code is promoted to `core` or a clearly shared feature contract.

## Feature Template

```text
lib/features/matches/
  data/
    datasources/
    dto/
    repositories/
  domain/
    entities/
    repositories/
    use_cases/
  presentation/
    controllers/
    pages/
    widgets/
```

Start small. Add subfolders only when a feature needs them.

## State Management

- Prefer a simple, testable state holder before introducing heavier tools.
- State objects should be immutable.
- Controllers should receive use cases through constructors.
- Async state must represent loading, success, empty, and failure explicitly.

## Data Boundaries

- Domain objects model product meaning.
- DTOs model external shape.
- Mapping between DTOs and domain entities belongs in `data`.
- Never pass API DTOs into widgets.

## Error Handling

- Represent expected failures as typed failures or result objects.
- Use exceptions only for truly exceptional or infrastructure-level failures.
- Convert infrastructure exceptions at the data boundary.

## Review Checklist

- Can the domain behavior be tested without Flutter?
- Does each import follow the dependency direction?
- Is feature code located under its feature?
- Are app-wide concerns kept out of feature internals?
- Is every dependency replaceable in a test?
