/// Référence locale minimale d'un instrument suivi par l'utilisateur.
///
/// [id] est stable et local. [symbol] ne suffit pas à identifier une place
/// de cotation : [exchange] vide signifie que la place n'est pas connue,
/// pas qu'elle a été inventée. Aucun nom, pays ou catégorie n'est stocké ici.
final class AssetReference {
  const AssetReference({
    required this.id,
    required this.symbol,
    required this.exchange,
  });

  final String id;
  final String symbol;
  final String exchange;
}
