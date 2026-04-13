# Workflow

## Before Starting

1. Identify the feature and expected user behavior.
2. Decide which layer owns each part of the change.
3. Add or update localization keys before wiring UI copy.
4. Plan the tests with the implementation.

## While Building

- Implement domain behavior first when there is business logic.
- Keep data mapping at the data boundary.
- Keep presentation state explicit.
- Add tests close to the behavior being introduced.
- Keep commits small and focused.

## Definition Of Done

- Architecture follows feature-first layered boundaries.
- No user-facing text is hardcoded in Dart.
- English and Russian ARB files are updated.
- New behavior has unit tests.
- UI states that changed have widget tests.
- `flutter analyze` passes.
- `flutter test` passes.
- The change is documented when it adds a new convention or dependency.

## Pull Request Checklist

- What feature or behavior changed?
- Which tests cover it?
- Were localization files updated?
- Were any packages added? Why?
- Are there migration or release notes?
