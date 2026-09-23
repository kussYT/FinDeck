import 'package:sqflite/sqflite.dart';

final class FavoriteRow {
  const FavoriteRow({
    required this.assetId,
    required this.symbol,
    required this.exchange,
    required this.createdAt,
  });

  final String assetId;
  final String symbol;
  final String exchange;
  final String createdAt;
}

final class FavoriteDao {
  const FavoriteDao();

  Future<FavoriteRow?> findByAsset(
    DatabaseExecutor database,
    String assetId,
  ) async {
    final rows = await database.rawQuery(
      '''
      SELECT favorite.asset_id, favorite.created_at, user_asset.symbol, user_asset.exchange
      FROM favorite
      INNER JOIN user_asset ON user_asset.id = favorite.asset_id
      WHERE favorite.asset_id = ?
      ''',
      [assetId],
    );
    if (rows.isEmpty) {
      return null;
    }
    return _map(rows.first);
  }

  Future<List<FavoriteRow>> list(DatabaseExecutor database) async {
    final rows = await database.rawQuery('''
      SELECT favorite.asset_id, favorite.created_at, user_asset.symbol, user_asset.exchange
      FROM favorite
      INNER JOIN user_asset ON user_asset.id = favorite.asset_id
      ORDER BY favorite.created_at, favorite.asset_id
    ''');
    return [for (final row in rows) _map(row)];
  }

  Future<void> insert(
    DatabaseExecutor database, {
    required String assetId,
    required String createdAt,
  }) {
    return database.insert('favorite', {
      'asset_id': assetId,
      'created_at': createdAt,
    });
  }

  Future<int> deleteByAsset(DatabaseExecutor database, String assetId) {
    return database.delete(
      'favorite',
      where: 'asset_id = ?',
      whereArgs: [assetId],
    );
  }

  FavoriteRow _map(Map<String, Object?> row) {
    return FavoriteRow(
      assetId: row['asset_id'] as String,
      symbol: row['symbol'] as String,
      exchange: row['exchange'] as String,
      createdAt: row['created_at'] as String,
    );
  }
}
