import 'dart:io';

import 'package:findeck/data/local/app_database.dart';
import 'package:findeck/data/local/schema_migrator.dart';
import 'package:findeck/data/repositories/favorite_repository.dart';
import 'package:findeck/data/repositories/portfolio_purchase_repository.dart';
import 'package:findeck/domain/models/calculated_number.dart';
import 'package:findeck/domain/models/market_quote.dart';
import 'package:findeck/domain/models/purchase.dart';
import 'package:findeck/domain/services/portfolio_calculator.dart';
import 'package:findeck/domain/services/purchase_valuation_input.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late Directory directory;
  late AppDatabase database;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('findeck_user_data_');
    database = await AppDatabase.open(
      joinDatabasePath(directory.path, 'user_data.db'),
    );
    expect(database.path.endsWith(AppDatabase.fileName), isFalse);
  });

  tearDown(() async {
    try {
      await database.close();
    } catch (_) {
      // La base a déjà été fermée par le test de lecture en erreur.
    }
    if (directory.existsSync()) {
      await directory.delete(recursive: true);
    }
  });

  test('crée une base versionnée, vide, avec les clés étrangères', () async {
    final version = await database.database.rawQuery('PRAGMA user_version');
    final foreignKeys = await database.database.rawQuery('PRAGMA foreign_keys');
    final tables = await database.database.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%' ORDER BY name",
    );

    expect(version.single['user_version'], 1);
    expect(foreignKeys.single['foreign_keys'], 1);
    expect(
      tables.map((row) => row['name']),
      ['favorite', 'portfolio_purchase', 'user_asset'],
    );

    final purchases = await PortfolioPurchaseRepository(database).loadAll();
    final favorites = await FavoriteRepository(database).loadAll();
    expect(purchases, isA<PurchasesLoaded>());
    expect((purchases as PurchasesLoaded).purchases, isEmpty);
    expect(favorites, isA<FavoritesLoaded>());
    expect((favorites as FavoritesLoaded).favorites, isEmpty);
  });

  test('relit fidèlement un achat après écriture', () async {
    final executedAt = DateTime(2024, 6, 1, 15, 30, 45);
    final saved = await PortfolioPurchaseRepository(database).save(
      symbol: ' acme ',
      exchange: ' xpar ',
      quantity: 2,
      unitPrice: 200.5,
      currency: ' eur ',
      executedAt: executedAt,
    );

    expect(saved, isA<PurchaseSaved>());
    final purchase = (saved as PurchaseSaved).purchase;
    final loaded = await PortfolioPurchaseRepository(database).loadAll();
    final read = (loaded as PurchasesLoaded).purchases.single;

    expect(read.id, purchase.id);
    expect(read.asset.id, purchase.asset.id);
    expect(read.asset.symbol, 'ACME');
    expect(read.asset.exchange, 'XPAR');
    expect(read.quantity, 2);
    expect(read.unitPrice, 200.5);
    expect(read.currency, 'EUR');
    expect(read.executedAtUtc.isUtc, isTrue);
    expect(read.executedAtUtc, executedAt.toUtc());
  });

  test('conserve plusieurs achats indépendants du même fichier', () async {
    final repository = PortfolioPurchaseRepository(database);
    final first = await repository.save(
      symbol: 'ACME',
      exchange: 'XPAR',
      quantity: 2,
      unitPrice: 200,
      currency: 'EUR',
      executedAt: DateTime.utc(2024, 1, 1),
    );
    final second = await repository.save(
      symbol: 'ACME',
      exchange: 'XPAR',
      quantity: 1,
      unitPrice: 0.1,
      currency: 'EUR',
      executedAt: DateTime.utc(2024, 2, 1),
    );
    final third = await repository.save(
      symbol: 'BETA',
      exchange: '',
      quantity: 4,
      unitPrice: 25,
      currency: 'USD',
      executedAt: DateTime.utc(2024, 3, 1),
    );

    final loaded = await repository.loadAll() as PurchasesLoaded;
    expect(loaded.purchases, hasLength(3));
    expect(
      loaded.purchases.map((purchase) => purchase.id).toSet(),
      hasLength(3),
    );
    expect(
      (first as PurchaseSaved).purchase.asset.id,
      (second as PurchaseSaved).purchase.asset.id,
    );
    expect(
      (third as PurchaseSaved).purchase.asset.id,
      isNot((first).purchase.asset.id),
    );
    expect(
      loaded.purchases
          .singleWhere((purchase) => purchase.quantity == 1)
          .unitPrice,
      0.1,
    );
  });

  test('refuse un achat invalide sans écriture', () async {
    final repository = PortfolioPurchaseRepository(database);
    final rejected = await repository.save(
      symbol: 'ACME',
      exchange: 'XPAR',
      quantity: double.nan,
      unitPrice: 200,
      currency: 'EUR',
      executedAt: DateTime.utc(2024, 1, 1),
    );

    expect(rejected, isA<PurchaseRejected>());
    expect(
      (rejected as PurchaseRejected).reason,
      PurchaseRejection.nonFiniteQuantity,
    );
    expect(await _count(database, 'user_asset'), 0);
    expect(await _count(database, 'portfolio_purchase'), 0);
  });

  test('ajoute, retire et ne duplique pas les favoris', () async {
    final repository = FavoriteRepository(database);
    final createdAt = DateTime.utc(2024, 4, 1, 8);
    final first = await repository.add(
      symbol: 'acme',
      exchange: 'xpar',
      createdAt: createdAt,
    );
    final second = await repository.add(
      symbol: 'ACME',
      exchange: 'XPAR',
      createdAt: DateTime.utc(2025, 1, 1),
    );

    expect(first, isA<FavoriteAdded>());
    expect((first as FavoriteAdded).alreadyStored, isFalse);
    expect(second, isA<FavoriteAdded>());
    expect((second as FavoriteAdded).alreadyStored, isTrue);
    expect(second.favorite.createdAtUtc, first.favorite.createdAtUtc);
    expect(second.favorite.asset.id, first.favorite.asset.id);

    final otherVenue = await repository.add(
      symbol: 'ACME',
      exchange: 'NASDAQ',
      createdAt: createdAt,
    );
    expect((otherVenue as FavoriteAdded).favorite.asset.id,
        isNot(first.favorite.asset.id));

    final listed = await repository.loadAll() as FavoritesLoaded;
    expect(listed.favorites, hasLength(2));

    expect(
      await repository.remove(symbol: 'ACME', exchange: 'XPAR'),
      isA<FavoriteRemoved>(),
    );
    expect(
      await repository.remove(symbol: 'ACME', exchange: 'XPAR'),
      isA<FavoriteAbsent>(),
    );
    final afterRemoval = await repository.loadAll() as FavoritesLoaded;
    expect(afterRemoval.favorites, hasLength(1));
    expect(afterRemoval.favorites.single.asset.exchange, 'NASDAQ');
  });

  test('un favori invalide ne crée pas de ligne', () async {
    final result = await FavoriteRepository(database).add(
      symbol: ' ',
      exchange: 'XPAR',
      createdAt: DateTime.utc(2024, 1, 1),
    );

    expect(result, isA<FavoriteRejected>());
    expect(await _count(database, 'user_asset'), 0);
    expect(await _count(database, 'favorite'), 0);
  });

  test('une clé étrangère invalide annule toute la transaction', () async {
    await expectLater(
      database.database.transaction((txn) async {
        await txn.insert('user_asset', {
          'id': 'asset-ok',
          'symbol': 'ACME',
          'exchange': '',
        });
        await txn.insert('portfolio_purchase', {
          'id': 'purchase-bad',
          'asset_id': 'missing-asset',
          'quantity': 1,
          'unit_price': 10,
          'currency': 'EUR',
          'executed_at': '2024-01-01T00:00:00.000Z',
        });
      }),
      throwsA(isA<DatabaseException>()),
    );

    expect(await _count(database, 'user_asset'), 0);
    expect(await _count(database, 'portfolio_purchase'), 0);
  });

  test('une référence utilisée ne peut pas être supprimée', () async {
    final saved = await PortfolioPurchaseRepository(database).save(
      symbol: 'ACME',
      exchange: 'XPAR',
      quantity: 1,
      unitPrice: 10,
      currency: 'EUR',
      executedAt: DateTime.utc(2024, 1, 1),
    ) as PurchaseSaved;

    await expectLater(
      database.database.delete(
        'user_asset',
        where: 'id = ?',
        whereArgs: [saved.purchase.asset.id],
      ),
      throwsA(isA<DatabaseException>()),
    );
    final loaded = await PortfolioPurchaseRepository(database).loadAll();
    expect((loaded as PurchasesLoaded).purchases, hasLength(1));
  });

  test('ferme puis rouvre le même fichier avec de nouvelles instances',
      () async {
    final path = database.path;
    await PortfolioPurchaseRepository(database).save(
      symbol: 'ACME',
      exchange: 'XPAR',
      quantity: 2,
      unitPrice: 200,
      currency: 'EUR',
      executedAt: DateTime.utc(2024, 5, 2, 9, 15),
    );
    await FavoriteRepository(database).add(
      symbol: 'ACME',
      exchange: 'XPAR',
      createdAt: DateTime.utc(2024, 5, 2),
    );
    await database.close();

    final reopened = await AppDatabase.open(path);
    database = reopened;
    final purchases = await PortfolioPurchaseRepository(reopened).loadAll()
        as PurchasesLoaded;
    final favorites =
        await FavoriteRepository(reopened).loadAll() as FavoritesLoaded;

    expect(purchases.purchases.single.quantity, 2);
    expect(purchases.purchases.single.unitPrice, 200);
    expect(purchases.purchases.single.executedAtUtc,
        DateTime.utc(2024, 5, 2, 9, 15));
    expect(favorites.favorites.single.asset.symbol, 'ACME');
  });

  test('une migration inconnue échoue et conserve le fichier', () async {
    final path = database.path;
    await FavoriteRepository(database).add(
      symbol: 'ACME',
      exchange: '',
      createdAt: DateTime.utc(2024, 1, 1),
    );
    await database.close();

    await expectLater(
      AppDatabase.open(path, version: 2),
      throwsA(isA<StateError>()),
    );
    expect(File(path).existsSync(), isTrue);

    final reopened = await AppDatabase.open(path);
    database = reopened;
    final favorites =
        await FavoriteRepository(reopened).loadAll() as FavoritesLoaded;
    expect(favorites.favorites, hasLength(1));
  });

  test('refuse de créer une base avec une version cible inconnue', () async {
    final path = joinDatabasePath(directory.path, 'unknown_target.db');

    await expectLater(
      AppDatabase.open(path, version: 2),
      throwsA(isA<StateError>()),
    );

    expect(File(path).existsSync(), isFalse);
  });

  test('refuse d\'ouvrir une base marquée d\'une version future', () async {
    final path = joinDatabasePath(directory.path, 'future_open.db');
    await _writeFutureFixture(path);

    await expectLater(
      AppDatabase.open(path),
      throwsA(isA<StateError>()),
    );
  });

  test('un refus conserve les données et le numéro d\'une version future',
      () async {
    final path = joinDatabasePath(directory.path, 'future_keep.db');
    await _writeFutureFixture(path);
    final before = await _readFutureFixture(path);

    await expectLater(
      AppDatabase.open(path),
      throwsA(isA<StateError>()),
    );

    final after = await _readFutureFixture(path);
    expect(after.version, before.version);
    expect(after.version, _futureVersion);
    expect(after.label, before.label);
    expect(after.schemaSql, before.schemaSql);
    expect(File(path).existsSync(), isTrue);
  });

  test('crée et rouvre une base en version 1', () async {
    final path = joinDatabasePath(directory.path, 'version_1.db');
    final created = await AppDatabase.open(path);
    try {
      expect(await _userVersion(created), SchemaMigrator.currentVersion);
      await FavoriteRepository(created).add(
        symbol: 'ACME',
        exchange: 'XPAR',
        createdAt: DateTime.utc(2024, 1, 1),
      );
    } finally {
      await created.close();
    }

    final reopened = await AppDatabase.open(path);
    try {
      expect(await _userVersion(reopened), SchemaMigrator.currentVersion);
      final favorites =
          await FavoriteRepository(reopened).loadAll() as FavoritesLoaded;
      expect(favorites.favorites.single.asset.symbol, 'ACME');
      expect(favorites.favorites.single.asset.exchange, 'XPAR');
    } finally {
      await reopened.close();
    }
  });

  test('une base fermée produit une erreur de lecture, pas une liste vide',
      () async {
    final repository = PortfolioPurchaseRepository(database);
    await database.close();

    final result = await repository.loadAll();

    expect(result, isA<PurchasesUnreadable>());
    expect(result, isNot(isA<PurchasesLoaded>()));
  });

  test('un achat relu alimente le calculateur sans stocker la valorisation',
      () async {
    final path = database.path;
    await PortfolioPurchaseRepository(database).save(
      symbol: 'ACME',
      exchange: 'XPAR',
      quantity: 2,
      unitPrice: 200,
      currency: 'EUR',
      executedAt: DateTime.utc(2024, 5, 2),
    );
    await database.close();
    final reopened = await AppDatabase.open(path);
    database = reopened;

    final loaded = await PortfolioPurchaseRepository(reopened).loadAll()
        as PurchasesLoaded;
    final input = preparePurchaseValuation(loaded.purchases);
    expect(input, isA<ReadyPurchaseValuation>());
    final valuation = const PortfolioCalculator().evaluate(
      purchases: (input as ReadyPurchaseValuation).purchases,
      quotes: const [
        MarketQuote(symbol: 'ACME', currency: 'EUR', price: 227),
      ],
    );

    expect((valuation.investedAmount as KnownNumber).value, 400);
    expect((valuation.currentValue as KnownNumber).value, 454);
    expect((valuation.gain as KnownNumber).value, 54);
    expect((valuation.performancePercent as KnownNumber).value, 13.5);
    final columns = await reopened.database.rawQuery(
      'PRAGMA table_info(portfolio_purchase)',
    );
    expect(
      columns.map((column) => column['name']),
      isNot(contains('current_value')),
    );
  });

  test('deux places distinctes ne sont pas envoyées ensemble au calculateur',
      () async {
    final repository = PortfolioPurchaseRepository(database);
    await repository.save(
      symbol: 'AAPL',
      exchange: 'NASDAQ',
      quantity: 1,
      unitPrice: 100,
      currency: 'USD',
      executedAt: DateTime.utc(2024, 1, 1),
    );
    await repository.save(
      symbol: 'AAPL',
      exchange: 'XETRA',
      quantity: 1,
      unitPrice: 90,
      currency: 'USD',
      executedAt: DateTime.utc(2024, 1, 2),
    );

    final loaded = await repository.loadAll() as PurchasesLoaded;
    expect(loaded.purchases, hasLength(2));
    expect(
      loaded.purchases.map((purchase) => purchase.asset.id).toSet(),
      hasLength(2),
    );
    expect(
      preparePurchaseValuation(loaded.purchases),
      isA<DistinctInstrumentsShareSymbol>(),
    );
  });
}

const int _futureVersion = 4;

Future<void> _writeFutureFixture(String path) async {
  final database = await openDatabase(
    path,
    version: _futureVersion,
    singleInstance: false,
    onCreate: (db, version) async {
      await db.execute(
        'CREATE TABLE future_note (id TEXT PRIMARY KEY, label TEXT NOT NULL)',
      );
      await db.insert('future_note', {
        'id': 'keep',
        'label': 'conserver',
      });
    },
  );
  await database.close();
}

Future<({int version, String label, String schemaSql})> _readFutureFixture(
  String path,
) async {
  final database = await openDatabase(
    path,
    readOnly: true,
    singleInstance: false,
  );
  try {
    final versionRows = await database.rawQuery('PRAGMA user_version');
    final notes = await database.query('future_note');
    final schema = await database.rawQuery(
      "SELECT sql FROM sqlite_master WHERE type = 'table' AND name = 'future_note'",
    );
    final version = versionRows.single['user_version'];
    return (
      version: version is int ? version : (version as num).toInt(),
      label: notes.single['label'] as String,
      schemaSql: schema.single['sql'] as String,
    );
  } finally {
    await database.close();
  }
}

Future<int> _userVersion(AppDatabase database) async {
  final rows = await database.database.rawQuery('PRAGMA user_version');
  final value = rows.single['user_version'];
  if (value is int) {
    return value;
  }
  return (value as num).toInt();
}

Future<int> _count(AppDatabase database, String table) async {
  final rows = await database.database.rawQuery(
    'SELECT COUNT(*) AS count FROM $table',
  );
  final value = rows.single['count'];
  if (value is int) {
    return value;
  }
  return (value as num).toInt();
}
