import 'package:findeck/domain/models/calculated_number.dart';

/// Valorisation d'une position agrégée, dans une seule devise.
final class PositionValuation {
  const PositionValuation({
    required this.symbol,
    required this.currency,
    required this.quantity,
    required this.investedAmount,
    required this.currentValue,
    required this.gain,
    required this.performancePercent,
  });

  final String symbol;
  final String currency;
  final double quantity;
  final double investedAmount;
  final CalculatedNumber currentValue;
  final CalculatedNumber gain;
  final CalculatedNumber performancePercent;
}

/// Poids d'une position dans la valeur d'une seule devise.
final class AllocationShare {
  const AllocationShare({
    required this.symbol,
    required this.currency,
    required this.weightPercent,
  });

  final String symbol;
  final String currency;
  final double weightPercent;
}

sealed class CalculatedWeights {
  const CalculatedWeights();
}

final class KnownWeights extends CalculatedWeights {
  KnownWeights(List<AllocationShare> shares)
      : shares = List<AllocationShare>.unmodifiable(shares);

  final List<AllocationShare> shares;
}

final class UnavailableWeights extends CalculatedWeights {
  const UnavailableWeights(this.reason);

  final UnavailableReason reason;
}

/// Sous-total d'une devise. Il n'est jamais additionné à une autre devise.
final class CurrencyBook {
  const CurrencyBook({
    required this.currency,
    required this.investedAmount,
    required this.currentValue,
    required this.gain,
    required this.performancePercent,
    required this.weights,
  });

  final String currency;
  final double investedAmount;
  final CalculatedNumber currentValue;
  final CalculatedNumber gain;
  final CalculatedNumber performancePercent;
  final CalculatedWeights weights;
}

/// Résultat d'une valorisation.
///
/// [books] contient un sous-total par devise. Aucun champ ne les additionne.
/// [positions] et [books] sont des copies non modifiables : changer les listes
/// passées au constructeur ne change plus ce résultat.
final class PortfolioValuation {
  PortfolioValuation({
    required List<PositionValuation> positions,
    required List<CurrencyBook> books,
    this.rejectedBecause,
  })  : positions = List<PositionValuation>.unmodifiable(positions),
        books = List<CurrencyBook>.unmodifiable(books);

  final List<PositionValuation> positions;
  final List<CurrencyBook> books;
  final UnavailableReason? rejectedBecause;

  bool get isEmpty => positions.isEmpty;

  bool get isRejected => rejectedBecause != null;

  /// Valeur actuelle du portefeuille lorsqu'une seule devise est complète.
  ///
  /// Un portefeuille vide vaut 0. Des devises différentes ou une position
  /// non valorisée ne produisent pas de total.
  CalculatedNumber get currentValue {
    if (rejectedBecause != null) {
      return UnavailableNumber(rejectedBecause!);
    }
    if (isEmpty) {
      return const KnownNumber(0);
    }
    if (books.length != 1) {
      return const UnavailableNumber(UnavailableReason.mixedCurrencies);
    }
    return _withoutNonFinite(books.single.currentValue);
  }

  CalculatedNumber get investedAmount {
    if (rejectedBecause != null) {
      return UnavailableNumber(rejectedBecause!);
    }
    if (isEmpty) {
      return const KnownNumber(0);
    }
    if (books.length != 1) {
      return const UnavailableNumber(UnavailableReason.mixedCurrencies);
    }
    final amount = books.single.investedAmount;
    if (!amount.isFinite) {
      return const UnavailableNumber(UnavailableReason.invalidInput);
    }
    return KnownNumber(amount);
  }

  CalculatedNumber get gain {
    if (rejectedBecause != null) {
      return UnavailableNumber(rejectedBecause!);
    }
    if (isEmpty) {
      return const KnownNumber(0);
    }
    if (books.length != 1) {
      return const UnavailableNumber(UnavailableReason.mixedCurrencies);
    }
    return _withoutNonFinite(books.single.gain);
  }

  CalculatedNumber get performancePercent {
    if (rejectedBecause != null) {
      return UnavailableNumber(rejectedBecause!);
    }
    if (isEmpty) {
      return const UnavailableNumber(UnavailableReason.zeroInvested);
    }
    if (books.length != 1) {
      return const UnavailableNumber(UnavailableReason.mixedCurrencies);
    }
    return _withoutNonFinite(books.single.performancePercent);
  }

  CalculatedWeights get weights {
    if (rejectedBecause != null) {
      return UnavailableWeights(rejectedBecause!);
    }
    if (isEmpty) {
      return const UnavailableWeights(UnavailableReason.zeroTotalValue);
    }
    if (books.length != 1) {
      return const UnavailableWeights(UnavailableReason.mixedCurrencies);
    }
    return books.single.weights;
  }
}

CalculatedNumber _withoutNonFinite(CalculatedNumber number) {
  if (number is KnownNumber && !number.value.isFinite) {
    return const UnavailableNumber(UnavailableReason.invalidInput);
  }
  return number;
}
