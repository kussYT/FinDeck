import 'package:sqflite/sqflite.dart';

/// Migrations explicites de la base utilisateur.
///
/// La version 1 crée uniquement les tables utilisateur. Aucune étape ne
/// supprime le fichier pour « réparer » un schéma.
final class SchemaMigrator {
  static const int currentVersion = 1;

  static Future<void> create(DatabaseExecutor database) {
    return _createVersion1(database);
  }

  static Future<void> upgrade(
    DatabaseExecutor database,
    int fromVersion,
    int toVersion,
  ) async {
    if (toVersion < fromVersion) {
      throw StateError(
        'Une migration ne revient pas de la version $fromVersion vers $toVersion.',
      );
    }
    for (var version = fromVersion + 1; version <= toVersion; version++) {
      switch (version) {
        case 1:
          await _createVersion1(database);
          break;
        default:
          throw StateError(
            'Aucune migration explicite vers la version $version. '
            'La base ne doit pas être supprimée pour compenser.',
          );
      }
    }
  }

  static Future<void> _createVersion1(DatabaseExecutor database) async {
    await database.execute('''
      CREATE TABLE user_asset (
        id TEXT PRIMARY KEY,
        symbol TEXT NOT NULL,
        exchange TEXT NOT NULL,
        UNIQUE (symbol, exchange)
      )
    ''');
    await database.execute('''
      CREATE TABLE favorite (
        asset_id TEXT PRIMARY KEY,
        created_at TEXT NOT NULL,
        FOREIGN KEY (asset_id) REFERENCES user_asset (id)
      )
    ''');
    await database.execute('''
      CREATE TABLE portfolio_purchase (
        id TEXT PRIMARY KEY,
        asset_id TEXT NOT NULL,
        quantity REAL NOT NULL,
        unit_price REAL NOT NULL,
        currency TEXT NOT NULL,
        executed_at TEXT NOT NULL,
        FOREIGN KEY (asset_id) REFERENCES user_asset (id)
      )
    ''');
  }
}
