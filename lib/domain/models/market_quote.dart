/// Cours observé pour un symbole et une devise.
///
/// [price] nul signifie que le cours est absent. Ce n'est pas un cours à zéro.
final class MarketQuote {
  const MarketQuote({
    required this.symbol,
    required this.currency,
    required this.price,
  });

  final String symbol;
  final String currency;
  final double? price;
}
