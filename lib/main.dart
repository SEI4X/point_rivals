import 'package:flutter/widgets.dart';
import 'package:point_rivals/app/app.dart';
import 'package:point_rivals/app/bootstrap/firebase_bootstrap.dart';
import 'package:point_rivals/app/dependencies/app_dependencies.dart';
import 'package:point_rivals/app/session/app_session_controller.dart';
import 'package:point_rivals/app/settings/app_settings_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseBootstrap.initialize();
  final dependencies = AppDependencies.firebase();
  final settingsController = await AppSettingsController.load();
  final sessionController = AppSessionController(
    authRepository: dependencies.authRepository,
  );

  runApp(
    PointRivalsApp(
      dependencies: dependencies,
      sessionController: sessionController,
      settingsController: settingsController,
    ),
  );
}
