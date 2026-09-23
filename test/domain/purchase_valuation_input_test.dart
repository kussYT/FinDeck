import 'package:findeck/domain/models/asset_reference.dart';
import 'package:findeck/domain/models/portfolio_purchase.dart';
import 'package:findeck/domain/models/purchase.dart';
import 'package:findeck/domain/services/purchase_valuation_input.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  PortfolioPurchase stored({
    required String assetId,
    required String symbol,
    required String exchange,
    required double quantity,
    required double unitPrice,
    String currency = 'EUR',
  }) {
    final purchase = (Purchase.validate(
      symbol: symbol,
      quantity: quantity,
      unitPrice: unitPrice,
      currency: currency,
    ) as ValidPurchase)
        .purchase;
    return PortfolioPurchase(
      id: 'purchase-$assetId-$quantity',
      asset: AssetReference(
          id: assetId, symbol: purchase.symbol, exchange: exchange),
      purchase: purchase,
      executedAt: DateTime.utc(2024, 1, 1),
    );
  }

  test('deux places pour le même symbole ne sont pas fusionnées', () {
    final input = preparePurchaseValuation([
      stored(
        assetId: 'nasdaq',
        symbol: 'AAPL',
        exchange: 'NASDAQ',
        quantity: 1,
        unitPrice: 100,
      ),
      stored(
        assetId: 'xetra',
        symbol: 'AAPL',
        exchange: 'XETRA',
        quantity: 1,
        unitPrice: 90,
      ),
    ]);

    expect(input, isA<DistinctInstrumentsShareSymbol>());
    final conflict = input as DistinctInstrumentsShareSymbol;
    expect(conflict.symbol, 'AAPL');
    expect(conflict.currency, 'EUR');
    expect(conflict.assetIds, ['nasdaq', 'xetra']);
  });

  test('deux achats du même actif restent calculables', () {
    final input = preparePurchaseValuation([
      stored(
        assetId: 'asset',
        symbol: 'ACME',
        exchange: 'XPAR',
        quantity: 1,
        unitPrice: 200,
      ),
      stored(
        assetId: 'asset',
        symbol: 'ACME',
        exchange: 'XPAR',
        quantity: 1,
        unitPrice: 200,
      ),
    ]);

    expect(input, isA<ReadyPurchaseValuation>());
    expect((input as ReadyPurchaseValuation).purchases, hasLength(2));
  });
}
