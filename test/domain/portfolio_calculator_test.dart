import 'package:findeck/domain/models/calculated_number.dart';
import 'package:findeck/domain/models/market_quote.dart';
import 'package:findeck/domain/models/portfolio_valuation.dart';
import 'package:findeck/domain/models/purchase.dart';
import 'package:findeck/domain/services/portfolio_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const calculator = PortfolioCalculator();

  Purchase buy({
    required String symbol,
    required double quantity,
    required double unitPrice,
    String currency = 'EUR',
  }) {
    final validation = Purchase.validate(
      symbol: symbol,
      quantity: quantity,
      unitPrice: unitPrice,
      currency: currency,
    );
    expect(validation, isA<ValidPurchase>());
    return (validation as ValidPurchase).purchase;
  }

  void expectKnown(CalculatedNumber number, double value) {
    expect(number, isA<KnownNumber>());
    expect((number as KnownNumber).value, value);
  }

  void expectUnavailable(CalculatedNumber number, UnavailableReason reason) {
    expect(number, isA<UnavailableNumber>());
    expect((number as UnavailableNumber).reason, reason);
  }

  test('valorise 2 actions achetées à 200 avec un cours de 227', () {
    final valuation = calculator.evaluate(
      purchases: [
        buy(symbol: 'ACME', quantity: 2, unitPrice: 200),
      ],
      quotes: const [
        MarketQuote(symbol: 'ACME', currency: 'EUR', price: 227),
      ],
    );

    expectKnown(valuation.investedAmount, 400);
    expectKnown(valuation.currentValue, 454);
    expectKnown(valuation.gain, 54);
    expectKnown(valuation.performancePercent, 13.5);
    final weights = valuation.weights;
    expect(weights, isA<KnownWeights>());
    expect((weights as KnownWeights).shares.single.weightPercent, 100);
  });

  test('deux achats unitaires à 200 donnent le même résultat que 2 × 200', () {
    final valuation = calculator.evaluate(
      purchases: [
        buy(symbol: 'acme', quantity: 1, unitPrice: 200, currency: 'eur'),
        buy(symbol: 'ACME', quantity: 1, unitPrice: 200, currency: 'EUR'),
      ],
      quotes: const [
        MarketQuote(symbol: 'acme', currency: 'eur', price: 227),
      ],
    );

    expect(valuation.positions.single.quantity, 2);
    expectKnown(valuation.investedAmount, 400);
    expectKnown(valuation.currentValue, 454);
    expectKnown(valuation.performancePercent, 13.5);
  });

  test('un gain nul donne une performance de 0 %', () {
    final valuation = calculator.evaluate(
      purchases: [
        buy(symbol: 'ACME', quantity: 2, unitPrice: 200),
      ],
      quotes: const [
        MarketQuote(symbol: 'ACME', currency: 'EUR', price: 200),
      ],
    );

    expectKnown(valuation.gain, 0);
    expectKnown(valuation.performancePercent, 0);
  });

  test('une valeur inférieure donne un gain et une performance négatifs', () {
    final valuation = calculator.evaluate(
      purchases: [
        buy(symbol: 'ACME', quantity: 2, unitPrice: 200),
      ],
      quotes: const [
        MarketQuote(symbol: 'ACME', currency: 'EUR', price: 150),
      ],
    );

    expectKnown(valuation.investedAmount, 400);
    expectKnown(valuation.currentValue, 300);
    expectKnown(valuation.gain, -100);
    expectKnown(valuation.performancePercent, -25);
  });

  test('un portefeuille vide vaut 0 et ne divise pas', () {
    final valuation = calculator.evaluate(
      purchases: const [],
      quotes: const [],
    );

    expect(valuation.isEmpty, isTrue);
    expect(valuation.books, isEmpty);
    expectKnown(valuation.investedAmount, 0);
    expectKnown(valuation.currentValue, 0);
    expectKnown(valuation.gain, 0);
    expectUnavailable(
      valuation.performancePercent,
      UnavailableReason.zeroInvested,
    );
    expect(valuation.weights, isA<UnavailableWeights>());
  });

  test('une performance sur un investi nul est indéfinie', () {
    final result = calculator.performancePercent(
      gain: const KnownNumber(54),
      investedAmount: 0,
    );

    expectUnavailable(result, UnavailableReason.zeroInvested);
    expect(result, isNot(isA<KnownNumber>()));
  });

  test('un cours absent ne devient pas zéro et bloque le total', () {
    final valuation = calculator.evaluate(
      purchases: [
        buy(symbol: 'ACME', quantity: 2, unitPrice: 200),
        buy(symbol: 'BETA', quantity: 1, unitPrice: 100),
      ],
      quotes: const [
        MarketQuote(symbol: 'ACME', currency: 'EUR', price: 227),
      ],
    );

    final beta = valuation.positions.singleWhere(
      (position) => position.symbol == 'BETA',
    );
    expectUnavailable(beta.currentValue, UnavailableReason.missingQuote);
    expectUnavailable(beta.gain, UnavailableReason.missingQuote);
    expect(beta.investedAmount, 100);

    expect(valuation.books.single.investedAmount, 500);
    expectUnavailable(
      valuation.currentValue,
      UnavailableReason.incompleteValuation,
    );
    expectUnavailable(
      valuation.performancePercent,
      UnavailableReason.incompleteValuation,
    );
    expect(valuation.weights, isA<UnavailableWeights>());
  });

  test('un prix nul dans le cours signifie un cours absent', () {
    final valuation = calculator.evaluate(
      purchases: [
        buy(symbol: 'ACME', quantity: 2, unitPrice: 200),
      ],
      quotes: const [
        MarketQuote(symbol: 'ACME', currency: 'EUR', price: null),
      ],
    );

    expectUnavailable(
      valuation.positions.single.currentValue,
      UnavailableReason.missingQuote,
    );
  });

  test('un cours à zéro est conservé et empêche une répartition', () {
    final valuation = calculator.evaluate(
      purchases: [
        buy(symbol: 'ACME', quantity: 2, unitPrice: 200),
      ],
      quotes: const [
        MarketQuote(symbol: 'ACME', currency: 'EUR', price: 0),
      ],
    );

    expectKnown(valuation.currentValue, 0);
    expectKnown(valuation.gain, -400);
    expectKnown(valuation.performancePercent, -100);
    expect(
      (valuation.weights as UnavailableWeights).reason,
      UnavailableReason.zeroTotalValue,
    );
  });

  test(
      'plusieurs achats et positions donnent des sommes et des poids cohérents',
      () {
    final valuation = calculator.evaluate(
      purchases: [
        buy(symbol: 'ACME', quantity: 1, unitPrice: 100),
        buy(symbol: 'ACME', quantity: 1, unitPrice: 300),
        buy(symbol: 'BETA', quantity: 4, unitPrice: 25),
      ],
      quotes: const [
        MarketQuote(symbol: 'ACME', currency: 'EUR', price: 200),
        MarketQuote(symbol: 'BETA', currency: 'EUR', price: 50),
      ],
    );

    expect(valuation.positions, hasLength(2));
    expect(valuation.positions.first.quantity, 2);
    expect(valuation.positions.first.investedAmount, 400);
    expectKnown(valuation.positions.first.currentValue, 400);
    expectKnown(valuation.positions.last.currentValue, 200);
    expectKnown(valuation.investedAmount, 500);
    expectKnown(valuation.currentValue, 600);
    expectKnown(valuation.gain, 100);
    expectKnown(valuation.performancePercent, 20);

    final weights = valuation.weights as KnownWeights;
    final weightSum = weights.shares.fold<double>(
      0,
      (sum, share) => sum + share.weightPercent,
    );
    expect(weightSum, closeTo(100, 1e-9));
    expect(weights.shares.first.weightPercent, closeTo(400 / 600 * 100, 1e-9));
    expect(weights.shares.last.weightPercent, closeTo(200 / 600 * 100, 1e-9));
  });

  test('les poids de valeurs non dyadiques restent proches de 100 %', () {
    final valuation = calculator.evaluate(
      purchases: [
        buy(symbol: 'A', quantity: 1, unitPrice: 1),
        buy(symbol: 'B', quantity: 1, unitPrice: 1),
        buy(symbol: 'C', quantity: 1, unitPrice: 1),
      ],
      quotes: const [
        MarketQuote(symbol: 'A', currency: 'EUR', price: 1),
        MarketQuote(symbol: 'B', currency: 'EUR', price: 2),
        MarketQuote(symbol: 'C', currency: 'EUR', price: 3),
      ],
    );

    final weights = valuation.weights as KnownWeights;
    final weightSum = weights.shares.fold<double>(
      0,
      (sum, share) => sum + share.weightPercent,
    );
    expect(weightSum, closeTo(100, 1e-9));
  });

  test('un produit décimal intermédiaire n\'est pas arrondi', () {
    final valuation = calculator.evaluate(
      purchases: [
        buy(symbol: 'ACME', quantity: 1, unitPrice: 0.1),
        buy(symbol: 'ACME', quantity: 1, unitPrice: 0.2),
      ],
      quotes: const [
        MarketQuote(symbol: 'ACME', currency: 'EUR', price: 0.3),
      ],
    );

    expect(valuation.positions.single.investedAmount, 0.1 + 0.2);
    expect(valuation.positions.single.investedAmount == 0.3, isFalse);
  });

  test('des devises différentes ne sont pas additionnées', () {
    final valuation = calculator.evaluate(
      purchases: [
        buy(symbol: 'ACME', quantity: 2, unitPrice: 200, currency: 'USD'),
        buy(symbol: 'SAP', quantity: 1, unitPrice: 100, currency: 'EUR'),
      ],
      quotes: const [
        MarketQuote(symbol: 'ACME', currency: 'USD', price: 227),
        MarketQuote(symbol: 'SAP', currency: 'EUR', price: 110),
      ],
    );

    expect(valuation.books, hasLength(2));
    expectUnavailable(
      valuation.currentValue,
      UnavailableReason.mixedCurrencies,
    );
    expectUnavailable(
      valuation.investedAmount,
      UnavailableReason.mixedCurrencies,
    );
    expectUnavailable(
      valuation.performancePercent,
      UnavailableReason.mixedCurrencies,
    );

    final eur = valuation.books.singleWhere((book) => book.currency == 'EUR');
    final usd = valuation.books.singleWhere((book) => book.currency == 'USD');
    expectKnown(eur.currentValue, 110);
    expect(eur.investedAmount, 100);
    expectKnown(usd.currentValue, 454);
    expect(usd.investedAmount, 400);
  });

  test('un cours dans une autre devise ne convertit pas la position', () {
    final valuation = calculator.evaluate(
      purchases: [
        buy(symbol: 'ACME', quantity: 2, unitPrice: 200, currency: 'USD'),
      ],
      quotes: const [
        MarketQuote(symbol: 'ACME', currency: 'EUR', price: 227),
      ],
    );

    expectUnavailable(
      valuation.positions.single.currentValue,
      UnavailableReason.currencyMismatch,
    );
    expectUnavailable(
      valuation.currentValue,
      UnavailableReason.incompleteValuation,
    );
  });

  test('quantité, prix et valeurs non finies sont refusés', () {
    expect(
      (Purchase.validate(
        symbol: 'ACME',
        quantity: 0,
        unitPrice: 200,
        currency: 'EUR',
      ) as InvalidPurchase)
          .reason,
      PurchaseRejection.nonPositiveQuantity,
    );
    expect(
      (Purchase.validate(
        symbol: 'ACME',
        quantity: -1,
        unitPrice: 200,
        currency: 'EUR',
      ) as InvalidPurchase)
          .reason,
      PurchaseRejection.nonPositiveQuantity,
    );
    expect(
      (Purchase.validate(
        symbol: 'ACME',
        quantity: double.nan,
        unitPrice: 200,
        currency: 'EUR',
      ) as InvalidPurchase)
          .reason,
      PurchaseRejection.nonFiniteQuantity,
    );
    expect(
      (Purchase.validate(
        symbol: 'ACME',
        quantity: double.infinity,
        unitPrice: 200,
        currency: 'EUR',
      ) as InvalidPurchase)
          .reason,
      PurchaseRejection.nonFiniteQuantity,
    );
    expect(
      (Purchase.validate(
        symbol: 'ACME',
        quantity: 2,
        unitPrice: 0,
        currency: 'EUR',
      ) as InvalidPurchase)
          .reason,
      PurchaseRejection.nonPositiveUnitPrice,
    );
    expect(
      (Purchase.validate(
        symbol: 'ACME',
        quantity: 2,
        unitPrice: -5,
        currency: 'EUR',
      ) as InvalidPurchase)
          .reason,
      PurchaseRejection.nonPositiveUnitPrice,
    );
    expect(
      (Purchase.validate(
        symbol: 'ACME',
        quantity: 2,
        unitPrice: double.nan,
        currency: 'EUR',
      ) as InvalidPurchase)
          .reason,
      PurchaseRejection.nonFiniteUnitPrice,
    );
    expect(
      (Purchase.validate(
        symbol: ' ',
        quantity: 2,
        unitPrice: 200,
        currency: 'EUR',
      ) as InvalidPurchase)
          .reason,
      PurchaseRejection.blankSymbol,
    );
    expect(
      (Purchase.validate(
        symbol: 'ACME',
        quantity: 2,
        unitPrice: 200,
        currency: ' ',
      ) as InvalidPurchase)
          .reason,
      PurchaseRejection.blankCurrency,
    );

    expectUnavailable(
      calculator.investedAmount(quantity: double.nan, unitPrice: 10),
      UnavailableReason.invalidInput,
    );
    expectUnavailable(
      calculator.currentValue(quantity: 2, quote: double.negativeInfinity),
      UnavailableReason.invalidQuote,
    );

    final rejected = calculator.evaluate(
      purchases: [
        buy(symbol: 'ACME', quantity: 2, unitPrice: 200),
      ],
      quotes: const [
        MarketQuote(symbol: 'ACME', currency: 'EUR', price: -1),
      ],
    );
    expect(rejected.rejectedBecause, UnavailableReason.invalidQuote);
    expect(rejected.positions, isEmpty);
    expectUnavailable(rejected.currentValue, UnavailableReason.invalidQuote);
  });

  test('deux cours contradictoires pour le même symbole sont refusés', () {
    final valuation = calculator.evaluate(
      purchases: [
        buy(symbol: 'ACME', quantity: 2, unitPrice: 200),
      ],
      quotes: const [
        MarketQuote(symbol: 'ACME', currency: 'EUR', price: 227),
        MarketQuote(symbol: 'ACME', currency: 'EUR', price: 100),
      ],
    );

    expect(valuation.rejectedBecause, UnavailableReason.invalidInput);
    expect(valuation.positions, isEmpty);
  });

  test('une répartition n\'existe pas lorsque le total de la devise est nul',
      () {
    final weight = calculator.weightPercent(partValue: 0, totalValue: 0);

    expectUnavailable(weight, UnavailableReason.zeroTotalValue);
  });

  test('une somme d\'investis infinie reste non calculable, même sans cours',
      () {
    final purchases = [
      buy(symbol: 'ACME', quantity: 1, unitPrice: 1e308),
      buy(symbol: 'BETA', quantity: 1, unitPrice: 1e308),
    ];

    void expectNoInfiniteKnownAmount(PortfolioValuation valuation) {
      expectUnavailable(
          valuation.investedAmount, UnavailableReason.invalidInput);
      expectUnavailable(valuation.currentValue, UnavailableReason.invalidInput);
      expect(valuation.rejectedBecause, UnavailableReason.invalidInput);
      for (final book in valuation.books) {
        expect(book.investedAmount.isFinite, isTrue);
      }
      for (final position in valuation.positions) {
        expect(position.investedAmount.isFinite, isTrue);
        for (final number in [
          position.currentValue,
          position.gain,
          position.performancePercent,
        ]) {
          if (number is KnownNumber) {
            expect(number.value.isFinite, isTrue);
          }
        }
      }
    }

    expectNoInfiniteKnownAmount(
      calculator.evaluate(
        purchases: purchases,
        quotes: const [
          MarketQuote(symbol: 'ACME', currency: 'EUR', price: 1),
          MarketQuote(symbol: 'BETA', currency: 'EUR', price: 1),
        ],
      ),
    );
    expectNoInfiniteKnownAmount(
      calculator.evaluate(
        purchases: purchases,
        quotes: const [
          MarketQuote(symbol: 'ACME', currency: 'EUR', price: 1),
        ],
      ),
    );
    expectNoInfiniteKnownAmount(
      calculator.evaluate(
        purchases: purchases,
        quotes: const [],
      ),
    );
  });

  test('les listes du résultat ne suivent pas les listes d\'origine', () {
    const position = PositionValuation(
      symbol: 'ACME',
      currency: 'EUR',
      quantity: 1,
      investedAmount: 10,
      currentValue: KnownNumber(12),
      gain: KnownNumber(2),
      performancePercent: KnownNumber(20),
    );
    const share = AllocationShare(
      symbol: 'ACME',
      currency: 'EUR',
      weightPercent: 100,
    );
    final positions = [position];
    final shares = [share];
    final books = [
      CurrencyBook(
        currency: 'EUR',
        investedAmount: 10,
        currentValue: const KnownNumber(12),
        gain: const KnownNumber(2),
        performancePercent: const KnownNumber(20),
        weights: KnownWeights(shares),
      ),
    ];
    final valuation = PortfolioValuation(positions: positions, books: books);
    final storedShares = (books.single.weights as KnownWeights).shares;

    positions.add(position);
    books.add(books.single);
    shares.add(share);

    expect(valuation.positions, hasLength(1));
    expect(valuation.books, hasLength(1));
    expect(storedShares, hasLength(1));
    expect(() => valuation.positions.add(position), throwsUnsupportedError);
    expect(() => valuation.books.clear(), throwsUnsupportedError);
    expect(() => storedShares.add(share), throwsUnsupportedError);

    final calculated = calculator.evaluate(
      purchases: [
        buy(symbol: 'ACME', quantity: 2, unitPrice: 200),
      ],
      quotes: const [
        MarketQuote(symbol: 'ACME', currency: 'EUR', price: 227),
      ],
    );
    expect(
      () => calculated.positions.clear(),
      throwsUnsupportedError,
    );
    expect(() => calculated.books.clear(), throwsUnsupportedError);
    expect(
      () => (calculated.weights as KnownWeights).shares.clear(),
      throwsUnsupportedError,
    );
  });
}
