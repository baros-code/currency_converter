import 'dart:async';

import 'package:currency_converter/app/presentation/cubit/currency_cubit.dart';
import 'package:currency_converter/app/presentation/currency_converter_page.dart';
import 'package:currency_converter/app/utils/app_router.dart';
import 'package:currency_converter/app/utils/locator.dart';
import 'package:currency_converter/core/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    return MultiBlocProvider(
      providers: _buildCubitProviders(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        onGenerateRoute: AppRouter.generateRoute,
        home: CurrencyConverterPage(),
        builder: _buildApp,
      ),
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

List<BlocProvider> _buildCubitProviders() {
  return <BlocProvider>[
    BlocProvider(
      create: (context) => locator<CurrencyCubit>(),
    ),
  ];
}
