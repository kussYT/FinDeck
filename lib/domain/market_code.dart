/// Code de marché normalisé, partagé par les calculs et la persistance.
///
/// Retourne `null` si le texte est vide. Ne complète aucune métadonnée absente.
String? normalizeMarketCode(String raw) {
  final value = raw.trim().toUpperCase();
  if (value.isEmpty) {
    return null;
  }
  return value;
}

/// Place de cotation. Une chaîne vide signifie que la place n'est pas connue.
String normalizeExchange(String raw) {
  return raw.trim().toUpperCase();
}
