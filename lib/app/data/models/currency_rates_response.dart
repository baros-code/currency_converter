import 'package:json_annotation/json_annotation.dart';

part 'currency_rates_response.g.dart';

@JsonSerializable()
class CurrencyRatesResponse {
  CurrencyRatesResponse({
    required this.base,
    required this.date,
    required this.rates,
  });

  final String? base;
  final DateTime? date;
  final Map<String, double>? rates;

  factory CurrencyRatesResponse.fromJson(Map<String, dynamic> json) =>
      _$CurrencyRatesResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CurrencyRatesResponseToJson(this);
}
