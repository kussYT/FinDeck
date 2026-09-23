import 'package:sqflite/sqflite.dart';

final class UserAssetDao {
  const UserAssetDao();

  Future<String?> findId(
    DatabaseExecutor database, {
    required String symbol,
    required String exchange,
  }) async {
    final rows = await database.query(
      'user_asset',
      columns: const ['id'],
      where: 'symbol = ? AND exchange = ?',
      whereArgs: [symbol, exchange],
    );
    if (rows.isEmpty) {
      return null;
    }
    return rows.first['id'] as String;
  }

  Future<void> insert(
    DatabaseExecutor database, {
    required String id,
    required String symbol,
    required String exchange,
  }) {
    return database.insert('user_asset', {
      'id': id,
      'symbol': symbol,
      'exchange': exchange,
    });
  }
}
