import 'package:findeck/domain/market_code.dart';

/// Achat fictif accepté par les formules de valorisation.
///
/// Le symbole, la quantité, le prix unitaire et la devise suffisent au
/// calcul. L'identifiant local, la place de cotation et la date sont portés
/// par l'achat persisté, pas par cette valeur.
final class Purchase {
  const Purchase._({
    required this.symbol,
    required this.quantity,
    required this.unitPrice,
    required this.currency,
  });

  final String symbol;
  final double quantity;
  final double unitPrice;
  final String currency;

  static PurchaseValidation validate({
    required String symbol,
    required double quantity,
    required double unitPrice,
    required String currency,
  }) {
    final normalizedSymbol = normalizeMarketCode(symbol);
    if (normalizedSymbol == null) {
      return const InvalidPurchase(PurchaseRejection.blankSymbol);
    }
    if (!quantity.isFinite) {
      return const InvalidPurchase(PurchaseRejection.nonFiniteQuantity);
    }
    if (quantity <= 0) {
      return const InvalidPurchase(PurchaseRejection.nonPositiveQuantity);
    }
    if (!unitPrice.isFinite) {
      return const InvalidPurchase(PurchaseRejection.nonFiniteUnitPrice);
    }
    if (unitPrice <= 0) {
      return const InvalidPurchase(PurchaseRejection.nonPositiveUnitPrice);
    }
    final normalizedCurrency = normalizeMarketCode(currency);
    if (normalizedCurrency == null) {
      return const InvalidPurchase(PurchaseRejection.blankCurrency);
    }

    return ValidPurchase(
      Purchase._(
        symbol: normalizedSymbol,
        quantity: quantity,
        unitPrice: unitPrice,
        currency: normalizedCurrency,
      ),
    );
  }
}

sealed class PurchaseValidation {
  const PurchaseValidation();
}

final class ValidPurchase extends PurchaseValidation {
  const ValidPurchase(this.purchase);

  final Purchase purchase;
}

final class InvalidPurchase extends PurchaseValidation {
  const InvalidPurchase(this.reason);

  final PurchaseRejection reason;
}

enum PurchaseRejection {
  blankSymbol,
  nonFiniteQuantity,
  nonPositiveQuantity,
  nonFiniteUnitPrice,
  nonPositiveUnitPrice,
  blankCurrency,
}
