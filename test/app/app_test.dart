import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:point_rivals/app/app.dart';

void main() {
  testWidgets('renders the English onboarding by default', (tester) async {
    await tester.pumpWidget(PointRivalsApp());
    await tester.pumpAndSettle();

    expect(find.text('Friendly wagers, no money'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
  });

  testWidgets('renders the Russian onboarding when locale is Russian', (
    tester,
  ) async {
    await tester.pumpWidget(PointRivalsApp(locale: const Locale('ru')));
    await tester.pumpAndSettle();

    expect(find.text('Дружеские ставки без денег'), findsOneWidget);
    expect(find.text('Дальше'), findsOneWidget);
  });
}
