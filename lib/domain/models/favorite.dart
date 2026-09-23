import 'package:findeck/domain/models/asset_reference.dart';

/// Favori local. Il ne contient aucune donnée de marché.
final class Favorite {
  Favorite({
    required this.asset,
    required DateTime createdAt,
  }) : createdAtUtc = createdAt.toUtc();

  final AssetReference asset;
  final DateTime createdAtUtc;
}
