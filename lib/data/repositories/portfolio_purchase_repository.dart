import 'package:findeck/data/local/app_database.dart';
import 'package:findeck/data/local/local_id.dart';
import 'package:findeck/data/local/portfolio_purchase_dao.dart';
import 'package:findeck/data/local/user_asset_dao.dart';
import 'package:findeck/domain/market_code.dart';
import 'package:findeck/domain/models/asset_reference.dart';
import 'package:findeck/domain/models/portfolio_purchase.dart';
import 'package:findeck/domain/models/purchase.dart';
import 'package:sqflite/sqflite.dart';

sealed class SavePurchaseResult {
  const SavePurchaseResult();
}

final class PurchaseSaved extends SavePurchaseResult {
  const PurchaseSaved(this.purchase);

  final PortfolioPurchase purchase;
}

final class PurchaseRejected extends SavePurchaseResult {
  const PurchaseRejected(this.reason);

  final PurchaseRejection reason;
}

final class PurchaseWriteFailed extends SavePurchaseResult {
  const PurchaseWriteFailed(this.cause);

  final Object cause;
}

sealed class LoadPurchasesResult {
  const LoadPurchasesResult();
}

final class PurchasesLoaded extends LoadPurchasesResult {
  const PurchasesLoaded(this.purchases);

  final List<PortfolioPurchase> purchases;
}

final class PurchasesUnreadable extends LoadPurchasesResult {
  const PurchasesUnreadable(this.cause);

  final Object? cause;
}

/// Enregistre et relit les achats fictifs.
///
/// La validation de quantité, de prix et de devise est celle de [Purchase].
/// L'actif et l'achat sont écrits dans une seule transaction.
final class PortfolioPurchaseRepository {
  PortfolioPurchaseRepository(
    this._database, {
    UserAssetDao? assets,
    PortfolioPurchaseDao? purchases,
  })  : _assets = assets ?? const UserAssetDao(),
        _purchases = purchases ?? const PortfolioPurchaseDao();

  final AppDatabase _database;
  final UserAssetDao _assets;
  final PortfolioPurchaseDao _purchases;

  Future<SavePurchaseResult> save({
    required String symbol,
    required String exchange,
    required double quantity,
    required double unitPrice,
    required String currency,
    required DateTime executedAt,
  }) async {
    final validation = Purchase.validate(
      symbol: symbol,
      quantity: quantity,
      unitPrice: unitPrice,
      currency: currency,
    );
    if (validation is InvalidPurchase) {
      return PurchaseRejected(validation.reason);
    }
    final purchase = (validation as ValidPurchase).purchase;
    final normalizedExchange = normalizeExchange(exchange);
    final executedAtUtc = executedAt.toUtc();

    try {
      final stored = await _database.transaction((txn) async {
        final assetId = await _ensureAsset(
          txn,
          symbol: purchase.symbol,
          exchange: normalizedExchange,
        );
        final id = createLocalId();
        final executedAtText = executedAtUtc.toIso8601String();
        await _purchases.insert(
          txn,
          id: id,
          assetId: assetId,
          quantity: purchase.quantity,
          unitPrice: purchase.unitPrice,
          currency: purchase.currency,
          executedAt: executedAtText,
        );
        return PortfolioPurchase(
          id: id,
          asset: AssetReference(
            id: assetId,
            symbol: purchase.symbol,
            exchange: normalizedExchange,
          ),
          purchase: purchase,
          executedAt: executedAtUtc,
        );
      });
      return PurchaseSaved(stored);
    } catch (error) {
      return PurchaseWriteFailed(error);
    }
  }

  Future<LoadPurchasesResult> loadAll() async {
    try {
      final rows = await _purchases.list(_database.database);
      final purchases = <PortfolioPurchase>[];
      for (final row in rows) {
        final validation = Purchase.validate(
          symbol: row.symbol,
          quantity: row.quantity,
          unitPrice: row.unitPrice,
          currency: row.currency,
        );
        if (validation is! ValidPurchase) {
          return const PurchasesUnreadable(null);
        }
        purchases.add(
          PortfolioPurchase(
            id: row.id,
            asset: AssetReference(
              id: row.assetId,
              symbol: row.symbol,
              exchange: row.exchange,
            ),
            purchase: validation.purchase,
            executedAt: DateTime.parse(row.executedAt).toUtc(),
          ),
        );
      }
      return PurchasesLoaded(purchases);
    } catch (error) {
      return PurchasesUnreadable(error);
    }
  }

  Future<String> _ensureAsset(
    DatabaseExecutor database, {
    required String symbol,
    required String exchange,
  }) async {
    final existing = await _assets.findId(
      database,
      symbol: symbol,
      exchange: exchange,
    );
    if (existing != null) {
      return existing;
    }
    final id = createLocalId();
    await _assets.insert(
      database,
      id: id,
      symbol: symbol,
      exchange: exchange,
    );
    return id;
  }
}
