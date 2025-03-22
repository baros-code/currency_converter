part of 'currency_cubit.dart';

class CurrencyState extends Equatable {
  const CurrencyState({
    this.stateType = CurrencyStateType.initial,
    this.baseCurrency = AppConfig.baseCurrency,
    this.targetCurrency,
    this.amount,
    this.convertedAmount,
    this.selectedPeriod,
    this.currencyRates = const {},
  });

  final CurrencyStateType stateType;
  final String baseCurrency;
  final String? targetCurrency;
  final double? amount;
  final double? convertedAmount;
  final DateTime? selectedPeriod;
  final Map<String, double> currencyRates;

  bool get isLoading => stateType == CurrencyStateType.loading;

  CurrencyState copyWith({
    CurrencyStateType? stateType,
    String? baseCurrency,
    String? targetCurrency,
    double? amount,
    double? convertedAmount,
    DateTime? selectedPeriod,
    Map<String, double>? currencyRates,
  }) {
    return CurrencyState(
      stateType: stateType ?? this.stateType,
      baseCurrency: baseCurrency ?? this.baseCurrency,
      targetCurrency: targetCurrency ?? this.targetCurrency,
      amount: amount ?? this.amount,
      convertedAmount: convertedAmount ?? this.convertedAmount,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      currencyRates: currencyRates ?? this.currencyRates,
    );
  }

  @override
  List<Object?> get props => [
        stateType,
        baseCurrency,
        targetCurrency,
        amount,
        convertedAmount,
        selectedPeriod,
        currencyRates,
      ];
}

enum CurrencyStateType {
  initial,
  loading,
  loaded,
  error,
}
