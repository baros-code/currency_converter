import 'package:currency_converter/app/data/repositories/currency_repository.dart';
import 'package:currency_converter/app/presentation/cubit/currency_cubit.dart';
import 'package:currency_converter/core/api_manager.dart';
import 'package:currency_converter/core/connectivity_manager.dart';
import 'package:currency_converter/core/logger.dart';
import 'package:get_it/get_it.dart';

final locator = GetIt.instance;

abstract class Locator {
  static void initialize() {
    // Register core dependencies
    locator
      ..registerSingleton<Logger>(LoggerImpl())
      ..registerSingleton<ConnectivityManager>(ConnectivityManagerImpl())
      ..registerSingleton<ApiManager>(ApiManagerImpl(locator(), locator()));

    // Register repositories
    locator.registerSingleton(() => CurrencyRepository(locator()));

    // Register cubits
    locator.registerFactory(() => CurrencyCubit(locator()));
  }
}
