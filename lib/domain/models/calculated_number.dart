/// Nombre produit par une formule, ou raison explicite pour laquelle elle
/// n'a pas été exécutée.
///
/// L'absence de résultat n'est jamais représentée par zéro.
sealed class CalculatedNumber {
  const CalculatedNumber();
}

final class KnownNumber extends CalculatedNumber {
  const KnownNumber(this.value);

  final double value;
}

final class UnavailableNumber extends CalculatedNumber {
  const UnavailableNumber(this.reason);

  final UnavailableReason reason;
}

enum UnavailableReason {
  /// Aucun cours utilisable n'a été fourni pour la position.
  missingQuote,

  /// Le cours est négatif, infini ou NaN. Il n'est pas remplacé par zéro.
  invalidQuote,

  /// Un cours existe pour le symbole, mais pas dans la devise de la position.
  currencyMismatch,

  /// Plusieurs devises empêchent un total unique. Elles ne sont pas additionnées.
  mixedCurrencies,

  /// La performance diviserait par un montant investi nul.
  zeroInvested,

  /// Au moins une position du groupe n'a pas de valeur, donc la somme n'est pas un total.
  incompleteValuation,

  /// La valeur totale est un zéro connu : aucun pourcentage de répartition n'existe.
  zeroTotalValue,

  /// Donnée d'entrée inutilisable, contradictoire ou non finie.
  invalidInput,
}
