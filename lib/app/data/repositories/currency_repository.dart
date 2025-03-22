import 'package:currency_converter/app/constants.dart';
import 'package:currency_converter/app/data/models/currency_rates_response.dart';
import 'package:currency_converter/core/api_manager_helpers.dart';
import 'package:currency_converter/core/failure.dart';
import 'package:currency_converter/core/result.dart';

import '../../../core/api_manager.dart';

class CurrencyRepository {
  CurrencyRepository(this._apiManager);

  final ApiManager _apiManager;

  // Since the Frankfurter api updates daily, we can benefit from caching,
  // this will help us to reduce the number of api calls.
  final Map<String, Map<String, double>> _latestRatesCache = {};

  Future<Result<CurrencyRatesResponse, Failure>> getCurrencyRates({
    String baseCurrency = AppConfig.baseCurrency,
    // We can limit the target currencies in order to reduce the response size.
    List<String>? targetCurrencies,
  }) async {
    try {
      if (_latestRatesCache[baseCurrency] != null) {
        return Result.success(
          value: CurrencyRatesResponse(
            base: baseCurrency,
            date: DateTime.now(),
            rates: _latestRatesCache[baseCurrency],
          ),
        );
      }
      final queryParams = {
        'base': baseCurrency,
        'symbols': targetCurrencies?.join(','),
      };
      queryParams.removeWhere((key, value) => value == null);
      final response = await _apiManager.call(
        ApiCall(
          method: ApiMethod.get,
          queryParams: queryParams,
          path: '/latest',
          responseMapper: (response) =>
              CurrencyRatesResponse.fromJson(response),
        ),
      );
      if (response.isSuccessful) {
        _latestRatesCache[baseCurrency] = response.value!.rates!;
        return Result.success(value: response.value!);
      }
      return Result.failure(Failure(message: response.error!.message));
    } catch (e) {
      return Result.failure(Failure(message: e.toString()));
    }
  }
}
