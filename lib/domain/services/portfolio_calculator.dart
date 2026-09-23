import 'package:findeck/domain/models/calculated_number.dart';
import 'package:findeck/domain/models/market_quote.dart';
import 'package:findeck/domain/models/portfolio_valuation.dart';
import 'package:findeck/domain/models/purchase.dart';

/// Formules pures de valorisation d'un portefeuille fictif.
///
/// Les montants sont des [double]. Le format binaire n'est pas un arrondi
/// monétaire : 0,1 et 0,2 ne donnent pas exactement 0,3. Les résultats
/// intermédiaires ne sont donc pas arrondis. Le formatage d'affichage reste
/// hors du domaine.
///
/// Un cours absent reste [UnavailableReason.missingQuote]. Il ne devient pas
/// zéro. Le total d'une devise n'existe que si chacune de ses positions a une
/// valeur connue. Les devises différentes ne sont pas additionnées et aucun
/// taux de change n'est appliqué.
final class PortfolioCalculator {
  const PortfolioCalculator();

  CalculatedNumber investedAmount({
    required double quantity,
    required double unitPrice,
  }) {
    if (!quantity.isFinite || !unitPrice.isFinite) {
      return const UnavailableNumber(UnavailableReason.invalidInput);
    }
    if (quantity <= 0 || unitPrice <= 0) {
      return const UnavailableNumber(UnavailableReason.invalidInput);
    }
    final amount = quantity * unitPrice;
    if (!amount.isFinite) {
      return const UnavailableNumber(UnavailableReason.invalidInput);
    }
    return KnownNumber(amount);
  }

  CalculatedNumber currentValue({
    required double quantity,
    required double? quote,
  }) {
    if (quote == null) {
      return const UnavailableNumber(UnavailableReason.missingQuote);
    }
    if (!quote.isFinite || quote < 0) {
      return const UnavailableNumber(UnavailableReason.invalidQuote);
    }
    if (!quantity.isFinite || quantity <= 0) {
      return const UnavailableNumber(UnavailableReason.invalidInput);
    }
    final value = quantity * quote;
    if (!value.isFinite) {
      return const UnavailableNumber(UnavailableReason.invalidInput);
    }
    return KnownNumber(value);
  }

  CalculatedNumber gain({
    required CalculatedNumber currentValue,
    required double investedAmount,
  }) {
    if (currentValue is! KnownNumber) {
      return currentValue;
    }
    if (!investedAmount.isFinite) {
      return const UnavailableNumber(UnavailableReason.invalidInput);
    }
    final result = currentValue.value - investedAmount;
    if (!result.isFinite) {
      return const UnavailableNumber(UnavailableReason.invalidInput);
    }
    return KnownNumber(result);
  }

  /// `(gain / montant investi) × 100`.
  ///
  /// La division n'est pas exécutée lorsque le montant investi est nul.
  CalculatedNumber performancePercent({
    required CalculatedNumber gain,
    required double investedAmount,
  }) {
    if (gain is! KnownNumber) {
      return gain;
    }
    if (!investedAmount.isFinite) {
      return const UnavailableNumber(UnavailableReason.invalidInput);
    }
    if (investedAmount == 0) {
      return const UnavailableNumber(UnavailableReason.zeroInvested);
    }
    final result = gain.value / investedAmount * 100;
    if (!result.isFinite) {
      return const UnavailableNumber(UnavailableReason.invalidInput);
    }
    return KnownNumber(result);
  }

  /// `(valeur de la position / valeur totale de la même devise) × 100`.
  CalculatedNumber weightPercent({
    required double partValue,
    required double totalValue,
  }) {
    if (!partValue.isFinite || !totalValue.isFinite) {
      return const UnavailableNumber(UnavailableReason.invalidInput);
    }
    if (totalValue == 0) {
      return const UnavailableNumber(UnavailableReason.zeroTotalValue);
    }
    final result = partValue / totalValue * 100;
    if (!result.isFinite) {
      return const UnavailableNumber(UnavailableReason.invalidInput);
    }
    return KnownNumber(result);
  }

  PortfolioValuation evaluate({
    required List<Purchase> purchases,
    required List<MarketQuote> quotes,
  }) {
    final indexedQuotes = _indexQuotes(quotes);
    if (indexedQuotes is _RejectedQuotes) {
      return PortfolioValuation(
        positions: const [],
        books: const [],
        rejectedBecause: indexedQuotes.reason,
      );
    }
    final acceptedQuotes = indexedQuotes as _IndexedQuotes;
    final quoteIndex = acceptedQuotes.bySymbolAndCurrency;
    final quotesBySymbol = acceptedQuotes.currenciesBySymbol;

    final grouped = _groupPurchases(purchases);
    if (grouped is _RejectedPurchases) {
      return PortfolioValuation(
        positions: const [],
        books: const [],
        rejectedBecause: grouped.reason,
      );
    }

    final acceptedPurchases = grouped as _GroupedPurchases;
    final positions = <PositionValuation>[];
    for (final position in acceptedPurchases.positions) {
      positions.add(
        _valuePosition(
          position: position,
          quoteIndex: quoteIndex,
          quotesBySymbol: quotesBySymbol,
        ),
      );
    }
    positions.sort((a, b) {
      final bySymbol = a.symbol.compareTo(b.symbol);
      if (bySymbol != 0) {
        return bySymbol;
      }
      return a.currency.compareTo(b.currency);
    });

    final books = _buildBooks(positions);
    if (books == null) {
      return PortfolioValuation(
        positions: const [],
        books: const [],
        rejectedBecause: UnavailableReason.invalidInput,
      );
    }
    return PortfolioValuation(positions: positions, books: books);
  }

  PositionValuation _valuePosition({
    required _GroupedPosition position,
    required Map<String, double?> quoteIndex,
    required Map<String, Set<String>> quotesBySymbol,
  }) {
    final key = '${position.symbol}|${position.currency}';
    final CalculatedNumber value;
    if (quoteIndex.containsKey(key)) {
      value = currentValue(
        quantity: position.quantity,
        quote: quoteIndex[key],
      );
    } else if (quotesBySymbol.containsKey(position.symbol)) {
      value = const UnavailableNumber(UnavailableReason.currencyMismatch);
    } else {
      value = const UnavailableNumber(UnavailableReason.missingQuote);
    }

    final positionGain = gain(
      currentValue: value,
      investedAmount: position.investedAmount,
    );
    return PositionValuation(
      symbol: position.symbol,
      currency: position.currency,
      quantity: position.quantity,
      investedAmount: position.investedAmount,
      currentValue: value,
      gain: positionGain,
      performancePercent: performancePercent(
        gain: positionGain,
        investedAmount: position.investedAmount,
      ),
    );
  }

  List<CurrencyBook>? _buildBooks(List<PositionValuation> positions) {
    final byCurrency = <String, List<PositionValuation>>{};
    for (final position in positions) {
      byCurrency.putIfAbsent(position.currency, () => []).add(position);
    }

    final currencies = byCurrency.keys.toList()..sort();
    final books = <CurrencyBook>[];
    for (final currency in currencies) {
      final book = _buildBook(currency, byCurrency[currency]!);
      if (book == null) {
        return null;
      }
      books.add(book);
    }
    return books;
  }

  /// Retourne `null` lorsque la somme des montants investis n'est pas finie.
  ///
  /// Ce contrôle précède la lecture des cours : un cours manquant ne doit pas
  /// laisser un infini présenté comme un montant connu.
  CurrencyBook? _buildBook(String currency, List<PositionValuation> positions) {
    var invested = 0.0;
    for (final position in positions) {
      invested += position.investedAmount;
    }
    if (!invested.isFinite) {
      return null;
    }

    final values = <KnownNumber>[];
    for (final position in positions) {
      final value = position.currentValue;
      if (value is! KnownNumber) {
        return CurrencyBook(
          currency: currency,
          investedAmount: invested,
          currentValue: const UnavailableNumber(
            UnavailableReason.incompleteValuation,
          ),
          gain: const UnavailableNumber(UnavailableReason.incompleteValuation),
          performancePercent: const UnavailableNumber(
            UnavailableReason.incompleteValuation,
          ),
          weights: const UnavailableWeights(
            UnavailableReason.incompleteValuation,
          ),
        );
      }
      values.add(value);
    }

    var total = 0.0;
    for (final value in values) {
      total += value.value;
    }
    if (!invested.isFinite || !total.isFinite) {
      return CurrencyBook(
        currency: currency,
        investedAmount: invested,
        currentValue: const UnavailableNumber(UnavailableReason.invalidInput),
        gain: const UnavailableNumber(UnavailableReason.invalidInput),
        performancePercent: const UnavailableNumber(
          UnavailableReason.invalidInput,
        ),
        weights: const UnavailableWeights(UnavailableReason.invalidInput),
      );
    }

    final totalValue = KnownNumber(total);
    final bookGain = gain(currentValue: totalValue, investedAmount: invested);
    final bookPerformance = performancePercent(
      gain: bookGain,
      investedAmount: invested,
    );
    return CurrencyBook(
      currency: currency,
      investedAmount: invested,
      currentValue: totalValue,
      gain: bookGain,
      performancePercent: bookPerformance,
      weights: _weights(positions, total),
    );
  }

  CalculatedWeights _weights(
    List<PositionValuation> positions,
    double totalValue,
  ) {
    if (totalValue == 0) {
      return const UnavailableWeights(UnavailableReason.zeroTotalValue);
    }

    final shares = <AllocationShare>[];
    for (final position in positions) {
      final value = position.currentValue;
      if (value is! KnownNumber) {
        return const UnavailableWeights(UnavailableReason.incompleteValuation);
      }
      final weight = weightPercent(
        partValue: value.value,
        totalValue: totalValue,
      );
      if (weight is! KnownNumber) {
        return UnavailableWeights((weight as UnavailableNumber).reason);
      }
      shares.add(
        AllocationShare(
          symbol: position.symbol,
          currency: position.currency,
          weightPercent: weight.value,
        ),
      );
    }
    return KnownWeights(shares);
  }

  _QuoteIndexResult _indexQuotes(List<MarketQuote> quotes) {
    final bySymbolAndCurrency = <String, double?>{};
    final currenciesBySymbol = <String, Set<String>>{};

    for (final quote in quotes) {
      final symbol = quote.symbol.trim().toUpperCase();
      final currency = quote.currency.trim().toUpperCase();
      if (symbol.isEmpty || currency.isEmpty) {
        return const _RejectedQuotes(UnavailableReason.invalidInput);
      }
      final price = quote.price;
      if (price != null && (!price.isFinite || price < 0)) {
        return const _RejectedQuotes(UnavailableReason.invalidQuote);
      }

      final key = '$symbol|$currency';
      if (bySymbolAndCurrency.containsKey(key) &&
          bySymbolAndCurrency[key] != price) {
        return const _RejectedQuotes(UnavailableReason.invalidInput);
      }
      bySymbolAndCurrency[key] = price;
      currenciesBySymbol.putIfAbsent(symbol, () => {}).add(currency);
    }

    return _IndexedQuotes(
      bySymbolAndCurrency: bySymbolAndCurrency,
      currenciesBySymbol: currenciesBySymbol,
    );
  }

  _PurchaseGrouping _groupPurchases(List<Purchase> purchases) {
    final grouped = <String, _GroupedPosition>{};
    for (final purchase in purchases) {
      final line = investedAmount(
        quantity: purchase.quantity,
        unitPrice: purchase.unitPrice,
      );
      if (line is! KnownNumber) {
        return const _RejectedPurchases(UnavailableReason.invalidInput);
      }
      final key = '${purchase.symbol}|${purchase.currency}';
      final current = grouped[key];
      if (current == null) {
        grouped[key] = _GroupedPosition(
          symbol: purchase.symbol,
          currency: purchase.currency,
          quantity: purchase.quantity,
          investedAmount: line.value,
        );
        continue;
      }
      final quantity = current.quantity + purchase.quantity;
      final invested = current.investedAmount + line.value;
      if (!quantity.isFinite || !invested.isFinite) {
        return const _RejectedPurchases(UnavailableReason.invalidInput);
      }
      grouped[key] = _GroupedPosition(
        symbol: purchase.symbol,
        currency: purchase.currency,
        quantity: quantity,
        investedAmount: invested,
      );
    }
    return _GroupedPurchases(grouped.values.toList());
  }
}

final class _GroupedPosition {
  const _GroupedPosition({
    required this.symbol,
    required this.currency,
    required this.quantity,
    required this.investedAmount,
  });

  final String symbol;
  final String currency;
  final double quantity;
  final double investedAmount;
}

sealed class _QuoteIndexResult {
  const _QuoteIndexResult();
}

final class _IndexedQuotes extends _QuoteIndexResult {
  const _IndexedQuotes({
    required this.bySymbolAndCurrency,
    required this.currenciesBySymbol,
  });

  final Map<String, double?> bySymbolAndCurrency;
  final Map<String, Set<String>> currenciesBySymbol;
}

final class _RejectedQuotes extends _QuoteIndexResult {
  const _RejectedQuotes(this.reason);

  final UnavailableReason reason;
}

sealed class _PurchaseGrouping {
  const _PurchaseGrouping();
}

final class _GroupedPurchases extends _PurchaseGrouping {
  const _GroupedPurchases(this.positions);

  final List<_GroupedPosition> positions;
}

final class _RejectedPurchases extends _PurchaseGrouping {
  const _RejectedPurchases(this.reason);

  final UnavailableReason reason;
}
