/// Supported currencies
enum Currency {
  usd('USD', '\$', 'US Dollar'),
  eur('EUR', '€', 'Euro'),
  gbp('GBP', '£', 'British Pound'),
  inr('INR', '₹', 'Indian Rupee'),
  jpy('JPY', '¥', 'Japanese Yen'),
  cny('CNY', '¥', 'Chinese Yuan'),
  aud('AUD', 'A\$', 'Australian Dollar'),
  cad('CAD', 'C\$', 'Canadian Dollar'),
  chf('CHF', 'CHF', 'Swiss Franc'),
  krw('KRW', '₩', 'South Korean Won');

  final String code;
  final String symbol;
  final String name;

  const Currency(this.code, this.symbol, this.name);

  String get displayName => '$name ($symbol)';
}
