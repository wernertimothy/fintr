import 'package:intl/intl.dart';

import '../data/finance_repository.dart';

final NumberFormat _currency =
    NumberFormat.currency(locale: 'de_DE', symbol: '€', decimalDigits: 0);

final NumberFormat _currencyPrecise =
    NumberFormat.currency(locale: 'de_DE', symbol: '€', decimalDigits: 2);

/// Formats an amount as euros, e.g. `1.000 €`. Drops cents when whole.
String formatMoney(double amount) {
  final hasCents = amount != amount.roundToDouble();
  return (hasCents ? _currencyPrecise : _currency).format(amount);
}

/// `2026-06` -> `June 2026`.
String formatMonth(String monthKey) {
  final date = FinanceRepository.monthDate(monthKey);
  return DateFormat.yMMMM().format(date);
}
