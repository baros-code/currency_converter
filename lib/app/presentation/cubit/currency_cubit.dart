import 'package:currency_converter/app/constants.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/currency_repository.dart';

part 'currency_state.dart';

class CurrencyCubit extends Cubit<CurrencyState> {
  CurrencyCubit(this._currencyRepository) : super(CurrencyState());

  final CurrencyRepository _currencyRepository;

  Future<void> fetchCurrencies({String? base}) async {
    emit(state.copyWith(stateType: CurrencyStateType.loading));
    final result = await _currencyRepository.getCurrencyRates(
      baseCurrency: base ?? state.baseCurrency,
    );
    if (result.isSuccessful) {
      emit(state.copyWith(
        baseCurrency: result.value!.base,
        currencyRates: result.value!.rates,
      ));
      return;
    }
    emit(state.copyWith(stateType: CurrencyStateType.error));
  }
}
