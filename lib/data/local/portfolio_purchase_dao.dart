import 'package:sqflite/sqflite.dart';

final class PurchaseRow {
  const PurchaseRow({
    required this.id,
    required this.assetId,
    required this.symbol,
    required this.exchange,
    required this.quantity,
    required this.unitPrice,
    required this.currency,
    required this.executedAt,
  });

  final String id;
  final String assetId;
  final String symbol;
  final String exchange;
  final double quantity;
  final double unitPrice;
  final String currency;
  final String executedAt;
}

final class PortfolioPurchaseDao {
  const PortfolioPurchaseDao();

  Future<List<PurchaseRow>> list(DatabaseExecutor database) async {
    final rows = await database.rawQuery('''
      SELECT
        portfolio_purchase.id,
        portfolio_purchase.asset_id,
        portfolio_purchase.quantity,
        portfolio_purchase.unit_price,
        portfolio_purchase.currency,
        portfolio_purchase.executed_at,
        user_asset.symbol,
        user_asset.exchange
      FROM portfolio_purchase
      INNER JOIN user_asset ON user_asset.id = portfolio_purchase.asset_id
      ORDER BY portfolio_purchase.executed_at, portfolio_purchase.id
    ''');
    return [for (final row in rows) _map(row)];
  }

  Future<void> insert(
    DatabaseExecutor database, {
    required String id,
    required String assetId,
    required double quantity,
    required double unitPrice,
    required String currency,
    required String executedAt,
  }) {
    return database.insert('portfolio_purchase', {
      'id': id,
      'asset_id': assetId,
      'quantity': quantity,
      'unit_price': unitPrice,
      'currency': currency,
      'executed_at': executedAt,
    });
  }

  PurchaseRow _map(Map<String, Object?> row) {
    return PurchaseRow(
      id: row['id'] as String,
      assetId: row['asset_id'] as String,
      symbol: row['symbol'] as String,
      exchange: row['exchange'] as String,
      quantity: _readDouble(row['quantity']),
      unitPrice: _readDouble(row['unit_price']),
      currency: row['currency'] as String,
      executedAt: row['executed_at'] as String,
    );
  }

  double _readDouble(Object? value) {
    if (value is int) {
      return value.toDouble();
    }
    if (value is double) {
      return value;
    }
    throw FormatException('Nombre SQLite illisible: $value');
  }
}
