import 'package:findeck/data/local/app_database.dart';
import 'package:findeck/data/local/favorite_dao.dart';
import 'package:findeck/data/local/local_id.dart';
import 'package:findeck/data/local/user_asset_dao.dart';
import 'package:findeck/domain/market_code.dart';
import 'package:findeck/domain/models/asset_reference.dart';
import 'package:findeck/domain/models/favorite.dart';

sealed class AddFavoriteResult {
  const AddFavoriteResult();
}

final class FavoriteAdded extends AddFavoriteResult {
  const FavoriteAdded(this.favorite, {required this.alreadyStored});

  final Favorite favorite;
  final bool alreadyStored;
}

final class FavoriteRejected extends AddFavoriteResult {
  const FavoriteRejected();
}

final class FavoriteWriteFailed extends AddFavoriteResult {
  const FavoriteWriteFailed(this.cause);

  final Object cause;
}

sealed class RemoveFavoriteResult {
  const RemoveFavoriteResult();
}

final class FavoriteRemoved extends RemoveFavoriteResult {
  const FavoriteRemoved();
}

final class FavoriteAbsent extends RemoveFavoriteResult {
  const FavoriteAbsent();
}

final class FavoriteRemoveFailed extends RemoveFavoriteResult {
  const FavoriteRemoveFailed(this.cause);

  final Object cause;
}

sealed class LoadFavoritesResult {
  const LoadFavoritesResult();
}

final class FavoritesLoaded extends LoadFavoritesResult {
  const FavoritesLoaded(this.favorites);

  final List<Favorite> favorites;
}

final class FavoritesUnreadable extends LoadFavoritesResult {
  const FavoritesUnreadable(this.cause);

  final Object? cause;
}

/// Favoris locaux. Un second ajout du même actif ne crée pas de doublon.
final class FavoriteRepository {
  FavoriteRepository(
    this._database, {
    UserAssetDao? assets,
    FavoriteDao? favorites,
  })  : _assets = assets ?? const UserAssetDao(),
        _favorites = favorites ?? const FavoriteDao();

  final AppDatabase _database;
  final UserAssetDao _assets;
  final FavoriteDao _favorites;

  Future<AddFavoriteResult> add({
    required String symbol,
    required String exchange,
    required DateTime createdAt,
  }) async {
    final normalizedSymbol = normalizeMarketCode(symbol);
    if (normalizedSymbol == null) {
      return const FavoriteRejected();
    }
    final normalizedExchange = normalizeExchange(exchange);
    final createdAtUtc = createdAt.toUtc();

    try {
      final favorite = await _database.transaction((txn) async {
        final existingAssetId = await _assets.findId(
          txn,
          symbol: normalizedSymbol,
          exchange: normalizedExchange,
        );
        if (existingAssetId != null) {
          final existing = await _favorites.findByAsset(txn, existingAssetId);
          if (existing != null) {
            return (
              favorite: _toFavorite(existing),
              alreadyStored: true,
            );
          }
        }
        final assetId = existingAssetId ?? createLocalId();
        if (existingAssetId == null) {
          await _assets.insert(
            txn,
            id: assetId,
            symbol: normalizedSymbol,
            exchange: normalizedExchange,
          );
        }
        final createdAtText = createdAtUtc.toIso8601String();
        await _favorites.insert(
          txn,
          assetId: assetId,
          createdAt: createdAtText,
        );
        return (
          favorite: Favorite(
            asset: AssetReference(
              id: assetId,
              symbol: normalizedSymbol,
              exchange: normalizedExchange,
            ),
            createdAt: createdAtUtc,
          ),
          alreadyStored: false,
        );
      });
      return FavoriteAdded(
        favorite.favorite,
        alreadyStored: favorite.alreadyStored,
      );
    } catch (error) {
      return FavoriteWriteFailed(error);
    }
  }

  Future<RemoveFavoriteResult> remove({
    required String symbol,
    required String exchange,
  }) async {
    final normalizedSymbol = normalizeMarketCode(symbol);
    if (normalizedSymbol == null) {
      return const FavoriteAbsent();
    }
    final normalizedExchange = normalizeExchange(exchange);
    try {
      final removed = await _database.transaction((txn) async {
        final assetId = await _assets.findId(
          txn,
          symbol: normalizedSymbol,
          exchange: normalizedExchange,
        );
        if (assetId == null) {
          return false;
        }
        final count = await _favorites.deleteByAsset(txn, assetId);
        return count > 0;
      });
      if (!removed) {
        return const FavoriteAbsent();
      }
      return const FavoriteRemoved();
    } catch (error) {
      return FavoriteRemoveFailed(error);
    }
  }

  Future<LoadFavoritesResult> loadAll() async {
    try {
      final rows = await _favorites.list(_database.database);
      return FavoritesLoaded([for (final row in rows) _toFavorite(row)]);
    } catch (error) {
      return FavoritesUnreadable(error);
    }
  }

  Favorite _toFavorite(FavoriteRow row) {
    return Favorite(
      asset: AssetReference(
        id: row.assetId,
        symbol: row.symbol,
        exchange: row.exchange,
      ),
      createdAt: DateTime.parse(row.createdAt).toUtc(),
    );
  }
}
