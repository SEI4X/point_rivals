import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:point_rivals/app/app.dart';

void main() {
  testWidgets('renders the English home screen by default', (tester) async {
    await tester.pumpWidget(const PointRivalsApp());

    expect(find.text('Ready for the next match'), findsOneWidget);
    expect(
      find.text('Build every feature in small, tested layers.'),
      findsOneWidget,
    );
  });

  testWidgets('renders the Russian home screen when locale is Russian', (
    tester,
  ) async {
    await tester.pumpWidget(const PointRivalsApp(locale: Locale('ru')));

    expect(find.text('Готовы к следующему матчу'), findsOneWidget);
    expect(
      find.text('Каждая функция создается маленькими тестируемыми слоями.'),
      findsOneWidget,
    );
  });
}
