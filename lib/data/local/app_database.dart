import 'dart:io';

import 'package:findeck/data/local/schema_migrator.dart';
import 'package:sqflite/sqflite.dart';

/// Base SQLite des données utilisateur.
///
/// Le fichier normal est [fileName], dans le répertoire persistant fourni par
/// sqflite. L'ouverture ne supprime jamais ce fichier et n'y écrit aucune
/// donnée de démonstration.
final class AppDatabase {
  AppDatabase._(this._database, this.path);

  final Database _database;
  final String path;

  static const String fileName = 'findeck.db';

  Database get database => _database;

  static Future<AppDatabase> openDefault() async {
    return open(await defaultPath());
  }

  static Future<String> defaultPath() async {
    return joinDatabasePath(await getDatabasesPath(), fileName);
  }

  static Future<AppDatabase> open(
    String path, {
    int version = SchemaMigrator.currentVersion,
  }) async {
    if (version != SchemaMigrator.currentVersion) {
      throw StateError(
        'La version $version n\'est pas prise en charge. '
        'La base ne doit pas être créée ni modifiée pour compenser.',
      );
    }
    final storedVersion = await _storedUserVersion(path);
    if (storedVersion != null &&
        storedVersion > SchemaMigrator.currentVersion) {
      throw StateError(
        'La base est en version $storedVersion, plus récente que la version '
        '${SchemaMigrator.currentVersion}. Son fichier n\'est pas modifié.',
      );
    }

    final database = await openDatabase(
      path,
      version: version,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, _) async {
        await SchemaMigrator.create(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await SchemaMigrator.upgrade(db, oldVersion, newVersion);
      },
      onDowngrade: (db, oldVersion, newVersion) {
        throw StateError(
          'La base est en version $oldVersion, plus récente que la version '
          '$newVersion. Son fichier n\'est pas modifié.',
        );
      },
    );
    return AppDatabase._(database, path);
  }

  /// Lit le numéro déjà écrit, sans migration.
  ///
  /// L'absence de fichier retourne `null`. Une base plus récente doit pouvoir
  /// être refusée avant que sqflite ne réécrive `user_version`.
  static Future<int?> _storedUserVersion(String path) async {
    if (!File(path).existsSync()) {
      return null;
    }
    final probe = await openDatabase(
      path,
      readOnly: true,
      singleInstance: false,
    );
    try {
      final rows = await probe.rawQuery('PRAGMA user_version');
      final value = rows.single['user_version'];
      if (value is int) {
        return value;
      }
      if (value is num) {
        return value.toInt();
      }
      throw StateError('Numéro de version illisible.');
    } finally {
      await probe.close();
    }
  }

  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) {
    return _database.transaction(action);
  }

  Future<void> close() {
    return _database.close();
  }
}

String joinDatabasePath(String directory, String fileName) {
  if (directory.endsWith(Platform.pathSeparator)) {
    return '$directory$fileName';
  }
  return '$directory${Platform.pathSeparator}$fileName';
}
