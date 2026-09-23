import 'package:findeck/domain/models/portfolio_purchase.dart';
import 'package:findeck/domain/models/purchase.dart';

/// Prépare des achats persistés pour le calculateur.
///
/// Le calculateur regroupe par symbole et par devise. Deux références locales
/// distinctes qui partagent ce couple ne doivent pas être fusionnées : toute
/// la préparation est alors refusée, sans liste partielle.
sealed class PurchaseValuationInput {
  const PurchaseValuationInput();
}

final class ReadyPurchaseValuation extends PurchaseValuationInput {
  ReadyPurchaseValuation(List<Purchase> purchases)
      : purchases = List<Purchase>.unmodifiable(purchases);

  final List<Purchase> purchases;
}

final class DistinctInstrumentsShareSymbol extends PurchaseValuationInput {
  DistinctInstrumentsShareSymbol({
    required this.symbol,
    required this.currency,
    required List<String> assetIds,
  }) : assetIds = List<String>.unmodifiable(assetIds);

  final String symbol;
  final String currency;
  final List<String> assetIds;
}

PurchaseValuationInput preparePurchaseValuation(
  List<PortfolioPurchase> storedPurchases,
) {
  final assetIdsBySymbol = <String, Map<String, Set<String>>>{};
  for (final stored in storedPurchases) {
    final byCurrency = assetIdsBySymbol.putIfAbsent(
      stored.asset.symbol,
      () => <String, Set<String>>{},
    );
    byCurrency
        .putIfAbsent(stored.currency, () => <String>{})
        .add(stored.asset.id);
  }

  for (final symbolEntry in assetIdsBySymbol.entries) {
    for (final currencyEntry in symbolEntry.value.entries) {
      if (currencyEntry.value.length > 1) {
        final assetIds = currencyEntry.value.toList()..sort();
        return DistinctInstrumentsShareSymbol(
          symbol: symbolEntry.key,
          currency: currencyEntry.key,
          assetIds: assetIds,
        );
      }
    }
  }

  return ReadyPurchaseValuation([
    for (final stored in storedPurchases) stored.calculationPurchase,
  ]);
}
