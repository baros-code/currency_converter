part of 'currency_cubit.dart';

class CurrencyState extends Equatable {
  const CurrencyState({
    this.stateType = CurrencyStateType.initial,
    this.baseCurrency = AppConfig.baseCurrency,
    this.targetCurrency,
    this.amount,
    this.convertedAmount,
    this.selectedPeriod,
    this.isHistoricFetch = false,
    this.currencyRates = const {},
  });

  final CurrencyStateType stateType;
  final String baseCurrency;
  final String? targetCurrency;
  final double? amount;
  final double? convertedAmount;
  final DateTime? selectedPeriod;
  final bool isHistoricFetch;
  final Map<String, double> currencyRates;

  bool get isLoading => stateType == CurrencyStateType.loading;

  String? get errorMessage => stateType == CurrencyStateType.error
      ? 'The rates could not be fetched.'
      : null;

  CurrencyState copyWith({
    CurrencyStateType? stateType,
    String? baseCurrency,
    String? targetCurrency,
    double? amount,
    double? convertedAmount,
    DateTime? selectedPeriod,
    bool? isHistoricFetch,
    Map<String, double>? currencyRates,
  }) {
    return CurrencyState(
      stateType: stateType ?? this.stateType,
      baseCurrency: baseCurrency ?? this.baseCurrency,
      targetCurrency: targetCurrency ?? this.targetCurrency,
      amount: amount ?? this.amount,
      convertedAmount: convertedAmount ?? this.convertedAmount,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      isHistoricFetch: isHistoricFetch ?? this.isHistoricFetch,
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
        isHistoricFetch,
        currencyRates,
      ];
}

enum CurrencyStateType {
  initial,
  loading,
  loaded,
  error,
}
