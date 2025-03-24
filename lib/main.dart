import 'dart:async';

import 'package:flutter/material.dart';

import 'app/app_config.dart';
import 'app/utils/app_router.dart';
import 'app/utils/locator.dart';
import 'core/logger.dart';
import 'core/network/api_manager.dart';

void main() {
  runZonedGuarded(
    () {
      // Initialize the app components.
      _initializeDependencies();
      // Handle Flutter errors.
      FlutterError.onError = _onFlutterError;
      // Run the app.
      runApp(const MainApp());
    },
    // Handle Dart errors.
    _onDartError,
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: AppRouter.initialRoute,
      builder: _buildApp,
    );
  }

  Widget _buildApp(BuildContext context, Widget? child) {
    return MediaQuery(
      // Prevent system settings change font size of the app.
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
      child: Scaffold(body: child),
    );
  }
}

void _initializeDependencies() {
  WidgetsFlutterBinding.ensureInitialized();
  Locator.initialize();
  locator<ApiManager>().setup(AppConfig.apiSetupParams);
}

void _onFlutterError(FlutterErrorDetails details) {
  FlutterError.presentError(details);
  locator<Logger>().error(
    '${details.exceptionAsString()}\n${details.stack.toString()}',
  );
}

void _onDartError(Object error, StackTrace stackTrace) {
  locator<Logger>().error(
    '${error.toString()}\n${stackTrace.toString()}',
  );
}
