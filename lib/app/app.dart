import 'package:flutter/material.dart';
import 'package:point_rivals/app/theme/app_theme.dart';
import 'package:point_rivals/core/l10n/l10n.dart';
import 'package:point_rivals/features/home/presentation/home_page.dart';

class PointRivalsApp extends StatelessWidget {
  const PointRivalsApp({super.key, this.locale});

  final Locale? locale;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      onGenerateTitle: (context) => context.l10n.appTitle,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: const HomePage(),
    );
  }
}
