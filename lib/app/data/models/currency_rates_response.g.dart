// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'currency_rates_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CurrencyRatesResponse _$CurrencyRatesResponseFromJson(
        Map<String, dynamic> json) =>
    CurrencyRatesResponse(
      base: json['base'] as String?,
      date:
          json['date'] == null ? null : DateTime.parse(json['date'] as String),
      rates: (json['rates'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
    );

Map<String, dynamic> _$CurrencyRatesResponseToJson(
        CurrencyRatesResponse instance) =>
    <String, dynamic>{
      'base': instance.base,
      'date': instance.date?.toIso8601String(),
      'rates': instance.rates,
    };
