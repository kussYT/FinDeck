import 'package:findeck/domain/models/asset_reference.dart';
import 'package:findeck/domain/models/purchase.dart';

/// Achat fictif persisté.
///
/// La quantité, le prix et la devise proviennent d'un [Purchase] déjà validé.
/// La date est conservée en UTC. Aucun résultat de valorisation n'est stocké.
final class PortfolioPurchase {
  PortfolioPurchase({
    required this.id,
    required this.asset,
    required Purchase purchase,
    required DateTime executedAt,
  })  : quantity = purchase.quantity,
        unitPrice = purchase.unitPrice,
        currency = purchase.currency,
        executedAtUtc = executedAt.toUtc() {
    if (id.trim().isEmpty) {
      throw ArgumentError('Un achat persisté exige un identifiant.');
    }
    if (purchase.symbol != asset.symbol) {
      throw ArgumentError(
        'Le symbole calculé doit être celui de la référence locale.',
      );
    }
  }

  final String id;
  final AssetReference asset;
  final double quantity;
  final double unitPrice;
  final String currency;
  final DateTime executedAtUtc;

  /// Valeur acceptée par [PortfolioCalculator].
  ///
  /// Elle ne transporte ni l'identifiant local ni la place de cotation.
  Purchase get calculationPurchase {
    final validation = Purchase.validate(
      symbol: asset.symbol,
      quantity: quantity,
      unitPrice: unitPrice,
      currency: currency,
    );
    return (validation as ValidPurchase).purchase;
  }
}
