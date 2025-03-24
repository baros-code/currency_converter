import 'package:currency_converter/app/app_config.dart';
import 'package:currency_converter/app/data/models/currency_rates_response.dart';
import 'package:currency_converter/app/utils/date_time_ext.dart';
import 'package:currency_converter/core/network/api_manager_helpers.dart';
import 'package:currency_converter/core/result.dart';

import '../../../core/network/api_manager.dart';

class CurrencyRepository {
  CurrencyRepository(this._apiManager);

  final ApiManager _apiManager;

  // Since the Frankfurter api updates daily, we can benefit from caching,
  // this will help us to reduce the number of api calls.
  final Map<String, Map<String, double>> _latestRatesCache = {};

  Future<Result<CurrencyRatesResponse, Failure>> getCurrencyRates({
    String baseCurrency = AppConfig.baseCurrency,
    DateTime? date,
    // We can limit the target currencies in order to reduce the response size.
    List<String>? targetCurrencies,
  }) async {
    try {
      // We cannot use the cache if we're fetching historical rates.
      if (_latestRatesCache[baseCurrency] != null && date == null) {
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
          path: date == null ? '/latest' : '/${date.formatByYearMonthDay()}',
          responseMapper: (response) =>
              CurrencyRatesResponse.fromJson(response),
        ),
      );
      if (response.isSuccessful) {
        if (date == null) {
          _latestRatesCache[baseCurrency] = response.value!.rates!;
        }
        return Result.success(value: response.value!);
      }
      return Result.failure(Failure(message: response.error!.message));
    } catch (e) {
      return Result.failure(Failure(message: e.toString()));
    }
  }
}
