import 'package:currency_converter/app/presentation/cubit/currency_cubit.dart';
import 'package:currency_converter/app/utils/locator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../presentation/currency_converter_page.dart';
import '../presentation/historical_rates_page.dart';
import 'package:flutter/material.dart';

abstract class AppRouter {
  static const String currencyConverter = '/currency_converter';
  static const String historicalRatesPage = '/historical_rates';

  static const String initialRoute = currencyConverter;

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case currencyConverter:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<CurrencyCubit>(
            create: (context) => locator<CurrencyCubit>(),
            child: CurrencyConverterPage(),
          ),
        );
      case historicalRatesPage:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<CurrencyCubit>(
            create: (context) => locator<CurrencyCubit>(),
            child: HistoricalRatesPage(),
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
