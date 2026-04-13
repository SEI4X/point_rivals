# Localization

The app supports English and Russian. Localization must remain easy to extend.

## Files

- English source: `lib/core/l10n/app_en.arb`
- Russian source: `lib/core/l10n/app_ru.arb`
- Generated Dart: `lib/core/l10n/generated/app_localizations.dart`
- Public Dart entrypoint: `lib/core/l10n/l10n.dart`
- Configuration: `l10n.yaml`

## Rules

- No user-facing text in Dart code.
- Add every new key to both ARB files in the same change.
- Add an `@key` metadata entry with a short description for every string.
- Use placeholders for dynamic values.
- Keep placeholders typed in metadata.
- Use ICU plural/select syntax for counts and variants.
- Do not concatenate localized strings in Dart.
- Do not localize logs, debug labels, or internal identifiers unless they are user-facing.

## Key Naming

Use stable, descriptive keys:

```text
<feature><ScreenOrContext><ElementOrMeaning>
```

Examples:

- `matchCreateTitle`
- `matchCreateSaveButton`
- `scoreValidationRequired`
- `profileLanguageEnglish`

## Usage

Import the localization entrypoint:

```dart
import 'package:point_rivals/core/l10n/l10n.dart';
```

Read strings through context:

```dart
final AppLocalizations l10n = context.l10n;
```

Then use `l10n.someKey`.

Do not edit generated localization files by hand.

## Adding A Language

1. Add a new `app_<locale>.arb` file in `lib/core/l10n`.
2. Add the locale to `preferred-supported-locales` in `l10n.yaml`.
3. Run `flutter gen-l10n`.
4. Add a widget test or update an existing localization test when the language affects behavior.
