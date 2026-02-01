import 'package:budget_manage/core/utils/currency_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CurrencyFormatter', () {
    test('should format currency correctly', () {
      expect(CurrencyFormatter.format(100.0), '\$100.00');
      expect(CurrencyFormatter.format(1234.56), '\$1,234.56');
      expect(CurrencyFormatter.format(0.99), '\$0.99');
    });

    test('should format compact currency for large amounts', () {
      expect(CurrencyFormatter.formatCompact(1000.0), '\$1.0K');
      expect(CurrencyFormatter.formatCompact(5500.0), '\$5.5K');
      expect(CurrencyFormatter.formatCompact(1000000.0), '\$1.0M');
      expect(CurrencyFormatter.formatCompact(2500000.0), '\$2.5M');
    });

    test('should format small amounts normally in compact format', () {
      expect(CurrencyFormatter.formatCompact(500.0), '\$500.00');
      expect(CurrencyFormatter.formatCompact(99.99), '\$99.99');
    });
  });
}
