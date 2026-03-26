import 'dart:convert';

import 'package:skelter/utils/currency_converter/domain/entities/currency_rate.dart';
import 'package:skelter/utils/typedef.dart';

class CurrencyRateModel extends CurrencyRate {
  const CurrencyRateModel({
    required super.amount,
    required super.base,
    required super.date,
    required super.rates,
  });

  CurrencyRateModel copyWith({
    double? amount,
    String? base,
    String? date,
    Map<String, double>? rates,
  }) {
    return CurrencyRateModel(
      amount: amount ?? this.amount,
      base: base ?? this.base,
      date: date ?? this.date,
      rates: rates ?? this.rates,
    );
  }

  factory CurrencyRateModel.fromJson(String source) =>
      CurrencyRateModel.fromMap(jsonDecode(source) as DataMap);

  factory CurrencyRateModel.fromMap(DataMap map) => CurrencyRateModel(
    amount: (map['amount'] as num).toDouble(),
    base: map['base'] as String,
    date: map['date'] as String,
    rates: Map<String, double>.from(
      (map['rates'] as Map).map(
        (key, value) => MapEntry(key.toString(), (value as num).toDouble()),
      ),
    ),
  );

  DataMap toMap() => {
    'amount': amount,
    'base': base,
    'date': date,
    'rates': rates,
  };

  String toJson() => jsonEncode(toMap());
}
