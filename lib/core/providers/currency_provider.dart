import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/salary/presentation/providers/salary_providers.dart';
import '../constants/currencies.dart';

const _currencyKey = 'selected_currency';

/// Provider for currency settings
final currencyProvider = StateNotifierProvider<CurrencyNotifier, Currency>((
  ref,
) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  return CurrencyNotifier(sharedPreferences);
});

/// Notifier for managing currency settings
class CurrencyNotifier extends StateNotifier<Currency> {
  final SharedPreferences _sharedPreferences;

  CurrencyNotifier(this._sharedPreferences) : super(Currency.usd) {
    _loadCurrency();
  }

  void _loadCurrency() {
    final savedCode = _sharedPreferences.getString(_currencyKey);
    if (savedCode != null) {
      try {
        state = Currency.values.firstWhere(
          (currency) => currency.code == savedCode,
          orElse: () => Currency.usd,
        );
      } catch (e) {
        state = Currency.usd;
      }
    }
  }

  Future<void> setCurrency(Currency currency) async {
    await _sharedPreferences.setString(_currencyKey, currency.code);
    state = currency;
  }
}
