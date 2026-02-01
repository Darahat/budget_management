import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/currency_provider.dart';
import '../../core/utils/currency_formatter.dart';

/// Widget that automatically formats currency based on user settings
class FormattedCurrency extends ConsumerWidget {
  final double amount;
  final TextStyle? style;
  final bool compact;

  const FormattedCurrency({
    super.key,
    required this.amount,
    this.style,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(currencyProvider);
    final formatted = compact
        ? CurrencyFormatter.formatCompact(amount, symbol: currency.symbol)
        : CurrencyFormatter.format(amount, symbol: currency.symbol);

    return Text(formatted, style: style);
  }
}
