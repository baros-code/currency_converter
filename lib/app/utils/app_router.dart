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
          builder: (_) => CurrencyConverterPage(),
        );
      case historicalRatesPage:
        return MaterialPageRoute(
          builder: (_) => HistoricalRatesPage(),
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
