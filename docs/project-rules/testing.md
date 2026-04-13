# Testing

Every new feature and behavior must be testable and tested.

## Test Pyramid

- Unit tests: domain entities, value objects, use cases, repositories with fake data sources, controllers.
- Widget tests: screen rendering, localized text, user interactions, loading/empty/error states.
- Integration tests: critical journeys across multiple screens or platform boundaries.

## Structure

Mirror feature structure in `test/`:

```text
test/
  app/
  core/
  features/
    matches/
      domain/
      data/
      presentation/
```

## Requirements For New Work

- New use case: unit test success and failure paths.
- New repository: unit test mapping and error conversion with fake data sources.
- New controller/view model: unit test state transitions.
- New screen: widget test the main states and user actions.
- New localized copy: widget test at least one locale when rendering changes.

## Testability Rules

- Inject clocks, random generators, IDs, repositories, services, and platform adapters.
- Use fakes for domain tests.
- Use mocks sparingly for interaction verification.
- Avoid real network, real timers, and real storage in unit tests.
- Avoid relying on test order.

## Required Commands

Run before work is considered complete:

```sh
flutter analyze
flutter test
```
