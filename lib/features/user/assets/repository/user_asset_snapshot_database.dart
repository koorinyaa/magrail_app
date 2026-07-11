import 'package:magrail_app/features/user/assets/model/user_asset_snapshot.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

const String _metaTableName = 'user_asset_snapshot_meta';
const String _characterTableName = 'user_asset_snapshot_characters';
const String _templeTableName = 'user_asset_snapshot_temples';
const String _characterHeaderTableName =
    'user_asset_snapshot_character_headers';
const String _sourceStateTableName = 'user_asset_snapshot_source_state';
// 每批 500 行用于控制 3 万条快照写入时的 SQLite 参数与内存占用
const int _insertBatchSize = 500;

/// 用户资产快照数据库
class UserAssetSnapshotDatabase {
  /// 创建用户资产快照数据库
  UserAssetSnapshotDatabase();

  sqflite.Database? _database;
  Future<sqflite.Database>? _openingDatabase;

  /// 写入用户资产快照行
  ///
  /// [entry] 用户资产快照行
  /// [charactersUpdatedAtMilliseconds] 用户角色更新时间戳
  /// [templesUpdatedAtMilliseconds] 用户圣殿更新时间戳
  /// [characterHeadersUpdatedAtMilliseconds] 全部角色资料更新时间戳
  Future<UserAssetSourceState> upsertSnapshotEntry(
    UserAssetSnapshotEntry entry, {
    required int charactersUpdatedAtMilliseconds,
    required int templesUpdatedAtMilliseconds,
    required int characterHeadersUpdatedAtMilliseconds,
  }) async {
    final database = await _openDatabase();
    return database.transaction((transaction) async {
      final sourceState = await _nextSourceState(
        transaction,
        entry.username,
        charactersUpdatedAtMilliseconds,
        templesUpdatedAtMilliseconds,
        characterHeadersUpdatedAtMilliseconds,
      );
      await transaction.insert(
        _metaTableName,
        {
          'username': entry.username,
          'nickname': entry.nickname,
          'character_total_items': entry.characterTotalItems,
          'temple_total_items': entry.templeTotalItems,
        },
        conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
      );
      await transaction.delete(
        _characterTableName,
        where: 'username = ?',
        whereArgs: [entry.username],
      );
      await transaction.delete(
        _templeTableName,
        where: 'username = ?',
        whereArgs: [entry.username],
      );
      await transaction.delete(
        _characterHeaderTableName,
        where: 'username = ?',
        whereArgs: [entry.username],
      );
      await _insertPayloadRows(
        transaction,
        tableName: _characterTableName,
        keyColumn: 'character_id',
        username: entry.username,
        rows: entry.characterRows,
      );
      await _insertPayloadRows(
        transaction,
        tableName: _templeTableName,
        keyColumn: 'temple_id',
        username: entry.username,
        rows: entry.templeRows,
      );
      await _insertPayloadRows(
        transaction,
        tableName: _characterHeaderTableName,
        keyColumn: 'character_id',
        username: entry.username,
        rows: entry.characterHeaderRows,
      );
      await transaction.insert(
        _sourceStateTableName,
        {
          'username': entry.username,
          'character_revision': sourceState.revisions.characters,
          'temple_revision': sourceState.revisions.temples,
          'character_header_revision': sourceState.revisions.characterHeaders,
          'character_updated_at_milliseconds':
              sourceState.charactersUpdatedAtMilliseconds,
          'temple_updated_at_milliseconds':
              sourceState.templesUpdatedAtMilliseconds,
          'character_header_updated_at_milliseconds':
              sourceState.characterHeadersUpdatedAtMilliseconds,
        },
        conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
      );
      return sourceState;
    });
  }

  /// 读取用户资产原始数据状态
  ///
  /// [username] 用户名
  Future<UserAssetSourceState?> readSourceState(String username) async {
    final database = await _openDatabase();
    return _readSourceState(database, username);
  }

  /// 读取用户资产快照行
  ///
  /// [username] 用户名
  Future<UserAssetSnapshotEntry?> readSnapshotEntry(String username) async {
    final database = await _openDatabase();
    return database.transaction((transaction) async {
      final metadataRows = await transaction.query(
        _metaTableName,
        where: 'username = ?',
        whereArgs: [username],
        limit: 1,
      );
      if (metadataRows.isEmpty) {
        return null;
      }

      final sourceState = await _readSourceState(transaction, username);
      if (sourceState == null || !sourceState.revisions.isComplete) {
        return null;
      }

      final metadata = metadataRows.first;
      final characterRows = await _readPayloadRows(
        transaction,
        tableName: _characterTableName,
        keyColumn: 'character_id',
        username: username,
      );
      final templeRows = await _readPayloadRows(
        transaction,
        tableName: _templeTableName,
        keyColumn: 'temple_id',
        username: username,
      );
      final characterHeaderRows = await _readPayloadRows(
        transaction,
        tableName: _characterHeaderTableName,
        keyColumn: 'character_id',
        username: username,
      );

      return UserAssetSnapshotEntry(
        username: metadata['username'] as String? ?? '',
        nickname: metadata['nickname'] as String? ?? '',
        characterRows: characterRows,
        templeRows: templeRows,
        characterHeaderRows: characterHeaderRows,
        characterTotalItems: _rowInt(metadata['character_total_items']),
        templeTotalItems: _rowInt(metadata['temple_total_items']),
        sourceState: sourceState,
      );
    });
  }

  /// 删除用户资产原始数据
  ///
  /// [username] 用户名
  Future<void> deleteSnapshot(String username) async {
    final database = await _openDatabase();
    await database.transaction((transaction) async {
      for (final tableName in const [
        _characterTableName,
        _templeTableName,
        _characterHeaderTableName,
        _sourceStateTableName,
        _metaTableName,
      ]) {
        await transaction.delete(
          tableName,
          where: 'username = ?',
          whereArgs: [username],
        );
      }
    });
  }

  /// 关闭用户资产快照数据库
  Future<void> close() async {
    var database = _database;
    final openingDatabase = _openingDatabase;
    if (database == null && openingDatabase != null) {
      try {
        database = await openingDatabase;
      } catch (_) {
        _openingDatabase = null;
        return;
      }
    }

    _database = null;
    _openingDatabase = null;
    if (database == null || !database.isOpen) {
      return;
    }

    await database.close();
  }

  /// 打开用户资产快照数据库
  Future<sqflite.Database> _openDatabase() {
    final database = _database;
    if (database != null && database.isOpen) {
      return Future.value(database);
    }

    final openingDatabase = _openingDatabase;
    if (openingDatabase != null) {
      return openingDatabase;
    }

    // sqflite 使用平台 SQLite 插件，避免 sqlite3 native assets 热更新缺失导致启动失败
    final nextOpeningDatabase = sqflite
        .openDatabase(
      'user_assets.sqlite',
      version: 1,
      // 页面实例使用独立连接，避免旧页面关闭新页面复用的同路径连接
      singleInstance: false,
      onCreate: (database, _) => _createSchema(database),
    )
        .then((database) {
      _database = database;
      return database;
    });
    _openingDatabase = nextOpeningDatabase;
    return nextOpeningDatabase.whenComplete(() {
      _openingDatabase = null;
    });
  }

  /// 创建用户资产快照表
  ///
  /// [database] 用户资产快照数据库
  Future<void> _createSchema(sqflite.Database database) async {
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
        payload_json TEXT NOT NULL,
        PRIMARY KEY (username, character_id)
      )
      ''');
    await database.execute('''
      CREATE TABLE $_templeTableName (
        username TEXT NOT NULL,
        temple_id INTEGER NOT NULL,
        row_order INTEGER NOT NULL,
        payload_json TEXT NOT NULL,
        PRIMARY KEY (username, temple_id)
      )
      ''');
    await database.execute('''
      CREATE TABLE $_characterHeaderTableName (
        username TEXT NOT NULL,
        character_id INTEGER NOT NULL,
        row_order INTEGER NOT NULL,
        payload_json TEXT NOT NULL,
        PRIMARY KEY (username, character_id)
      )
      ''');
    await database.execute('''
      CREATE TABLE $_sourceStateTableName (
        username TEXT NOT NULL PRIMARY KEY,
        character_revision INTEGER NOT NULL,
        temple_revision INTEGER NOT NULL,
        character_header_revision INTEGER NOT NULL,
        character_updated_at_milliseconds INTEGER NOT NULL,
        temple_updated_at_milliseconds INTEGER NOT NULL,
        character_header_updated_at_milliseconds INTEGER NOT NULL
      )
      ''');
    await database.execute('''
      CREATE INDEX idx_asset_snapshot_character_order
      ON $_characterTableName (username, row_order)
      ''');
    await database.execute('''
      CREATE INDEX idx_asset_snapshot_temple_order
      ON $_templeTableName (username, row_order)
      ''');
    await database.execute('''
      CREATE INDEX idx_asset_snapshot_character_header_order
      ON $_characterHeaderTableName (username, row_order)
      ''');
  }

  /// 批量写入资产 payload JSON
  ///
  /// [transaction] SQLite 写入事务
  /// [tableName] 快照明细表名
  /// [keyColumn] 明细主键列名
  /// [username] 用户名
  /// [rows] 快照明细行
  Future<void> _insertPayloadRows(
    sqflite.Transaction transaction, {
    required String tableName,
    required String keyColumn,
    required String username,
    required List<UserAssetSnapshotPayload> rows,
  }) async {
    for (var start = 0; start < rows.length; start += _insertBatchSize) {
      final batch = transaction.batch();
      final end = (start + _insertBatchSize).clamp(0, rows.length);
      for (var index = start; index < end; index += 1) {
        final row = rows[index];
        batch.insert(
          tableName,
          {
            'username': username,
            keyColumn: row.id,
            'row_order': index,
            'payload_json': row.payloadJson,
          },
          conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    }
  }

  /// 生成下一组原始数据状态
  ///
  /// [executor] SQLite 执行器
  /// [username] 用户名
  /// [charactersUpdatedAtMilliseconds] 用户角色更新时间戳
  /// [templesUpdatedAtMilliseconds] 用户圣殿更新时间戳
  /// [characterHeadersUpdatedAtMilliseconds] 全部角色资料更新时间戳
  Future<UserAssetSourceState> _nextSourceState(
    sqflite.DatabaseExecutor executor,
    String username,
    int charactersUpdatedAtMilliseconds,
    int templesUpdatedAtMilliseconds,
    int characterHeadersUpdatedAtMilliseconds,
  ) async {
    final current = await _readSourceState(executor, username);
    return UserAssetSourceState(
      revisions: UserAssetDataRevisions(
        characters: (current?.revisions.characters ?? 0) + 1,
        temples: (current?.revisions.temples ?? 0) + 1,
        characterHeaders: (current?.revisions.characterHeaders ?? 0) + 1,
      ),
      charactersUpdatedAtMilliseconds: charactersUpdatedAtMilliseconds,
      templesUpdatedAtMilliseconds: templesUpdatedAtMilliseconds,
      characterHeadersUpdatedAtMilliseconds:
          characterHeadersUpdatedAtMilliseconds,
    );
  }

  /// 通过 SQLite 执行器读取原始数据状态
  ///
  /// [executor] SQLite 执行器
  /// [username] 用户名
  Future<UserAssetSourceState?> _readSourceState(
    sqflite.DatabaseExecutor executor,
    String username,
  ) async {
    final rows = await executor.query(
      _sourceStateTableName,
      where: 'username = ?',
      whereArgs: [username],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }

    final row = rows.first;
    return UserAssetSourceState(
      revisions: UserAssetDataRevisions(
        characters: _rowInt(row['character_revision']),
        temples: _rowInt(row['temple_revision']),
        characterHeaders: _rowInt(row['character_header_revision']),
      ),
      charactersUpdatedAtMilliseconds: _rowInt(
        row['character_updated_at_milliseconds'],
      ),
      templesUpdatedAtMilliseconds: _rowInt(
        row['temple_updated_at_milliseconds'],
      ),
      characterHeadersUpdatedAtMilliseconds: _rowInt(
        row['character_header_updated_at_milliseconds'],
      ),
    );
  }

  /// 读取快照明细行
  ///
  /// [executor] SQLite 执行器
  /// [tableName] 快照明细表名
  /// [keyColumn] 明细主键列名
  /// [username] 用户名
  Future<List<UserAssetSnapshotPayload>> _readPayloadRows(
    sqflite.DatabaseExecutor executor, {
    required String tableName,
    required String keyColumn,
    required String username,
  }) async {
    final rows = await executor.query(
      tableName,
      columns: [keyColumn, 'payload_json'],
      where: 'username = ?',
      whereArgs: [username],
      orderBy: 'row_order ASC',
    );
    return List<UserAssetSnapshotPayload>.unmodifiable(
      rows.map((row) {
        return UserAssetSnapshotPayload(
          id: _rowInt(row[keyColumn]),
          payloadJson: row['payload_json'] as String? ?? '',
        );
      }),
    );
  }

  /// 将 SQLite 数字字段转换为整数
  ///
  /// [value] SQLite 字段值
  int _rowInt(Object? value) {
    return value is num ? value.toInt() : 0;
  }
}

/// 用户资产快照行
class UserAssetSnapshotEntry {
  /// 创建用户资产快照行
  ///
  /// [username] 用户名
  /// [nickname] 用户昵称
  /// [characterRows] 用户角色快照明细
  /// [templeRows] 用户圣殿快照明细
  /// [characterHeaderRows] 角色头部资料快照明细
  /// [characterTotalItems] 角色接口总数
  /// [templeTotalItems] 圣殿接口总数
  /// [sourceState] 读取时返回的三类原始数据状态
  const UserAssetSnapshotEntry({
    required this.username,
    required this.nickname,
    required this.characterRows,
    required this.templeRows,
    required this.characterHeaderRows,
    required this.characterTotalItems,
    required this.templeTotalItems,
    this.sourceState,
  });

  /// 用户名
  final String username;

  /// 用户昵称
  final String nickname;

  /// 用户角色快照明细
  final List<UserAssetSnapshotPayload> characterRows;

  /// 用户圣殿快照明细
  final List<UserAssetSnapshotPayload> templeRows;

  /// 角色头部资料快照明细
  final List<UserAssetSnapshotPayload> characterHeaderRows;

  /// 角色接口总数
  final int characterTotalItems;

  /// 圣殿接口总数
  final int templeTotalItems;

  /// 读取时返回的三类原始数据状态
  final UserAssetSourceState? sourceState;
}

/// 用户资产快照明细
class UserAssetSnapshotPayload {
  /// 创建用户资产快照明细
  ///
  /// [id] 资产主键
  /// [payloadJson] 资产 JSON
  const UserAssetSnapshotPayload({
    required this.id,
    required this.payloadJson,
  });

  /// 资产主键
  final int id;

  /// 资产 JSON
  final String payloadJson;
}
