import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/currency_provider.dart';
import '../utils/currency_formatter.dart';

/// Extension for easy currency formatting
extension CurrencyFormatting on double {
  String toCurrency(WidgetRef ref, {bool compact = false}) {
    final currency = ref.read(currencyProvider);
    return compact
        ? CurrencyFormatter.formatCompact(this, symbol: currency.symbol)
        : CurrencyFormatter.format(this, symbol: currency.symbol);
  }
}
