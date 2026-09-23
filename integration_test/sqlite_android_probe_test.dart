import 'package:findeck/data/local/app_database.dart';
import 'package:findeck/data/repositories/portfolio_purchase_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sqflite/sqflite.dart';

/// Vérifie sqflite sur l'appareil Android.
///
/// Ce n'est pas le scénario hors ligne de l'application : aucun écran, cache
/// de marché ni redémarrage complet du produit n'est exercé ici.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('conserve un achat après fermeture du fichier SQLite', (
    tester,
  ) async {
    final path = joinDatabasePath(
      await getDatabasesPath(),
      'findeck_sqlite_probe.db',
    );
    await deleteDatabase(path);

    final first = await AppDatabase.open(path);
    final saved = await PortfolioPurchaseRepository(first).save(
      symbol: 'ACME',
      exchange: 'XPAR',
      quantity: 2,
      unitPrice: 200,
      currency: 'EUR',
      executedAt: DateTime.utc(2024, 5, 1, 12),
    );
    expect(saved, isA<PurchaseSaved>());
    await first.close();

    final second = await AppDatabase.open(path);
    final loaded = await PortfolioPurchaseRepository(second).loadAll();
    await second.close();
    await deleteDatabase(path);

    expect(loaded, isA<PurchasesLoaded>());
    final purchase = (loaded as PurchasesLoaded).purchases.single;
    expect(purchase.quantity, 2);
    expect(purchase.unitPrice, 200);
    expect(purchase.currency, 'EUR');
    expect(purchase.asset.symbol, 'ACME');
    expect(purchase.asset.exchange, 'XPAR');
    expect(purchase.executedAtUtc, DateTime.utc(2024, 5, 1, 12));
  });
}
