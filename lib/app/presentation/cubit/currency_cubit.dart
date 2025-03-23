import 'package:currency_converter/app/app_config.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/currency_repository.dart';

part 'currency_state.dart';

class CurrencyCubit extends Cubit<CurrencyState> {
  CurrencyCubit(this._currencyRepository) : super(CurrencyState());

  final CurrencyRepository _currencyRepository;

  List<String> get currencies => state.currencyRates.keys.toList();

  Future<void> fetchCurrencies({String? base}) async {
    emit(state.copyWith(stateType: CurrencyStateType.loading));
    final result = await _currencyRepository.getCurrencyRates(
      baseCurrency: base ?? state.baseCurrency,
    );
    if (result.isSuccessful) {
      emit(state.copyWith(
        stateType: CurrencyStateType.loaded,
        baseCurrency: result.value!.base,
        currencyRates: {
          // Include the base currency to show in the list.
          result.value!.base!: 1,
          ...?result.value!.rates,
        },
      ));
      return;
    }
    emit(state.copyWith(stateType: CurrencyStateType.error));
  }

  void onSwapInputChanged(String amount) {
    if (amount.isEmpty) {
      emit(state.copyWith(amount: 0, convertedAmount: 0));
      return;
    }
    final value = double.tryParse(amount);
    if (value == null) return;
    emit(state.copyWith(amount: value, convertedAmount: _convertAmount(value)));
  }

  void onBaseCurrencyChanged(String currency) {
    emit(state.copyWith(baseCurrency: currency));
    fetchCurrencies(base: currency);
  }

  void onTargetCurrencyChanged(String currency) {
    emit(state.copyWith(targetCurrency: currency));
    emit(state.copyWith(convertedAmount: _convertAmount(state.amount)));
  }

  void onSwitchCurrency() async {
    final baseCurrency = state.baseCurrency;
    final targetCurrency = state.targetCurrency;
    emit(
      state.copyWith(
        baseCurrency: targetCurrency,
        targetCurrency: baseCurrency,
      ),
    );
    await fetchCurrencies(base: targetCurrency);
    emit(state.copyWith(convertedAmount: _convertAmount(state.amount)));
  }

  double _convertAmount(double? amount) {
    if (amount == null) return 0;
    final rate = state.currencyRates[state.targetCurrency];
    if (rate == null) return 0;
    return amount * rate;
  }
}
