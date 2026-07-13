part of 'user_asset_snapshot_database.dart';

/// 用户资产快照数据库结构操作
extension _UserAssetSnapshotDatabaseSchema on UserAssetSnapshotDatabase {
  /// 打开用户资产快照数据库
  Future<sqflite.Database> _openDatabase() {
    final database = UserAssetSnapshotDatabase._database;
    if (database != null && database.isOpen) {
      return Future.value(database);
    }
    final openingDatabase = UserAssetSnapshotDatabase._openingDatabase;
    if (openingDatabase != null) {
      return openingDatabase;
    }
    final nextOpeningDatabase = sqflite
        .openDatabase(
      'user_assets.sqlite',
      version: userAssetSnapshotSchemaVersion,
      singleInstance: true,
      onCreate: _createSchema,
      onUpgrade: _recreateSchemaForVersionChange,
      onDowngrade: _recreateSchemaForVersionChange,
    )
        .then((database) {
      UserAssetSnapshotDatabase._database = database;
      return database;
    });
    UserAssetSnapshotDatabase._openingDatabase = nextOpeningDatabase;
    return nextOpeningDatabase.whenComplete(() {
      UserAssetSnapshotDatabase._openingDatabase = null;
    });
  }

  /// 在结构版本变化时重建快照数据库
  ///
  /// [database] 用户资产快照数据库
  /// [oldVersion] 本地结构版本
  /// [newVersion] 当前结构版本
  Future<void> _recreateSchemaForVersionChange(
    sqflite.Database database,
    int oldVersion,
    int newVersion,
  ) async {
    // 任意结构版本变化都丢弃旧快照，避免维护多套字段迁移逻辑
    final tableRows = await database.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table' "
      "AND name NOT LIKE 'sqlite_%' AND name != 'android_metadata'",
    );
    for (final row in tableRows) {
      final tableName = row['name'] as String? ?? '';
      if (tableName.isEmpty) {
        continue;
      }
      final quotedName = tableName.replaceAll('"', '""');
      await database.execute('DROP TABLE IF EXISTS "$quotedName"');
    }
    await _createSchema(database, newVersion);
  }

  /// 创建当前用户资产快照结构
  ///
  /// [database] 用户资产快照数据库
  /// [version] 当前结构版本
  Future<void> _createSchema(sqflite.Database database, int version) async {
    await database.execute('''
      CREATE TABLE $_metaTableName (
        username TEXT NOT NULL PRIMARY KEY,
        nickname TEXT NOT NULL,
        character_total_items INTEGER NOT NULL,
        temple_total_items INTEGER NOT NULL
      )
      ''');
    await database.execute('''
      CREATE TABLE $_characterTableName (
        username TEXT NOT NULL,
        character_id INTEGER NOT NULL,
        row_order INTEGER NOT NULL,
        name TEXT NOT NULL,
        icon TEXT NOT NULL,
        level INTEGER NOT NULL,
        zero_count INTEGER NOT NULL,
        star_forces INTEGER NOT NULL,
        stars INTEGER NOT NULL,
        user_amount INTEGER NOT NULL,
        user_total INTEGER NOT NULL,
        sacrifices INTEGER NOT NULL,
        current_value REAL NOT NULL,
        fluctuation REAL NOT NULL,
        state_value INTEGER NOT NULL,
        price_value REAL NOT NULL,
        rate_value REAL NOT NULL,
        rank INTEGER NOT NULL,
        single_dividend REAL NOT NULL,
        total_dividend REAL NOT NULL,
        payload_json TEXT NOT NULL,
        PRIMARY KEY (username, character_id)
      )
      ''');
    await database.execute('''
      CREATE TABLE $_templeTableName (
        username TEXT NOT NULL,
        temple_id INTEGER NOT NULL,
        row_order INTEGER NOT NULL,
        character_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        assets INTEGER NOT NULL,
        sacrifices INTEGER NOT NULL,
        character_level INTEGER NOT NULL,
        damaged INTEGER NOT NULL,
        single_dividend REAL NOT NULL,
        total_dividend REAL NOT NULL,
        star_forces INTEGER NOT NULL,
        refine INTEGER NOT NULL,
        create_value TEXT NOT NULL,
        payload_json TEXT NOT NULL,
        PRIMARY KEY (username, temple_id)
      )
      ''');
    await database.execute('''
      CREATE TABLE $_sourceStateTableName (
        username TEXT NOT NULL PRIMARY KEY,
        schema_version INTEGER NOT NULL,
        character_revision INTEGER NOT NULL,
        temple_revision INTEGER NOT NULL,
        character_updated_at_milliseconds INTEGER NOT NULL,
        temple_updated_at_milliseconds INTEGER NOT NULL,
        character_content_hash TEXT NOT NULL,
        temple_content_hash TEXT NOT NULL
      )
      ''');
    await database.execute(
      'CREATE INDEX idx_asset_snapshot_character_order '
      'ON $_characterTableName (username, row_order)',
    );
    await database.execute(
      'CREATE INDEX idx_asset_snapshot_character_holdings '
      'ON $_characterTableName (username, user_total, row_order)',
    );
    await database.execute(
      'CREATE INDEX idx_asset_snapshot_character_holdings_desc '
      'ON $_characterTableName (username, user_total DESC, row_order ASC)',
    );
    await database.execute(
      'CREATE INDEX idx_asset_snapshot_character_level '
      'ON $_characterTableName (username, level, row_order)',
    );
    await database.execute(
      'CREATE INDEX idx_asset_snapshot_character_level_desc '
      'ON $_characterTableName (username, level DESC, row_order ASC)',
    );
    await database.execute(
      'CREATE INDEX idx_asset_snapshot_character_sacrifices '
      'ON $_characterTableName (username, sacrifices DESC, row_order ASC)',
    );
    await database.execute(
      'CREATE INDEX idx_asset_snapshot_character_sacrifices_asc '
      'ON $_characterTableName (username, sacrifices ASC, row_order ASC)',
    );
    await database.execute(
      'CREATE INDEX idx_asset_snapshot_character_rank '
      'ON $_characterTableName (username, rank ASC, row_order ASC)',
    );
    await database.execute(
      'CREATE INDEX idx_asset_snapshot_character_rank_desc '
      'ON $_characterTableName (username, rank DESC, row_order ASC)',
    );
    await database.execute(
      'CREATE INDEX idx_asset_snapshot_character_stars '
      'ON $_characterTableName (username, stars DESC, row_order ASC)',
    );
    await database.execute(
      'CREATE INDEX idx_asset_snapshot_character_stars_asc '
      'ON $_characterTableName (username, stars ASC, row_order ASC)',
    );
    await database.execute(
      'CREATE INDEX idx_asset_snapshot_character_current '
      'ON $_characterTableName (username, current_value DESC, row_order ASC)',
    );
    await database.execute(
      'CREATE INDEX idx_asset_snapshot_character_current_asc '
      'ON $_characterTableName (username, current_value ASC, row_order ASC)',
    );
    await database.execute(
      'CREATE INDEX idx_asset_snapshot_character_single_dividend '
      'ON $_characterTableName '
      '(username, single_dividend DESC, row_order ASC)',
    );
    await database.execute(
      'CREATE INDEX idx_asset_snapshot_character_single_dividend_asc '
      'ON $_characterTableName '
      '(username, single_dividend ASC, row_order ASC)',
    );
    await database.execute(
      'CREATE INDEX idx_asset_snapshot_character_total_dividend '
      'ON $_characterTableName '
      '(username, total_dividend DESC, row_order ASC)',
    );
    await database.execute(
      'CREATE INDEX idx_asset_snapshot_character_total_dividend_asc '
      'ON $_characterTableName '
      '(username, total_dividend ASC, row_order ASC)',
    );
    await database.execute(
      'CREATE INDEX idx_asset_snapshot_temple_order '
      'ON $_templeTableName (username, row_order)',
    );
    await database.execute(
      'CREATE INDEX idx_asset_snapshot_temple_star_forces '
      'ON $_templeTableName (username, star_forces)',
    );
    await database.execute(
      'CREATE INDEX idx_asset_snapshot_temple_sacrifices '
      'ON $_templeTableName (username, sacrifices DESC, row_order ASC)',
    );
    await database.execute(
      'CREATE INDEX idx_asset_snapshot_temple_character_level '
      'ON $_templeTableName (username, character_level DESC, row_order ASC)',
    );
  }
}
