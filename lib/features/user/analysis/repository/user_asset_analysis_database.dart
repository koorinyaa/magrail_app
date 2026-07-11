import 'package:sqflite/sqflite.dart' as sqflite;

const String _analysisTableName = 'user_asset_analysis_cache';

/// 用户资产分析缓存数据库
class UserAssetAnalysisDatabase {
  /// 创建用户资产分析缓存数据库
  UserAssetAnalysisDatabase();

  sqflite.Database? _database;
  Future<sqflite.Database>? _openingDatabase;

  /// 读取用户资产分析缓存行
  ///
  /// [username] 用户名
  Future<UserAssetAnalysisCacheEntry?> readEntry(String username) async {
    final database = await _openDatabase();
    final rows = await database.query(
      _analysisTableName,
      columns: const [
        'username',
        'updated_at_milliseconds',
        'payload_json',
      ],
      where: 'username = ?',
      whereArgs: [username],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return UserAssetAnalysisCacheEntry.fromRow(rows.first);
  }

  /// 写入用户资产分析缓存行
  ///
  /// [entry] 用户资产分析缓存行
  Future<void> upsertEntry(UserAssetAnalysisCacheEntry entry) async {
    final database = await _openDatabase();
    await database.insert(
      _analysisTableName,
      {
        'username': entry.username,
        'updated_at_milliseconds': entry.updatedAtMilliseconds,
        'payload_json': entry.payloadJson,
      },
      conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
    );
  }

  /// 删除用户资产分析缓存行
  ///
  /// [username] 用户名
  Future<void> deleteEntry(String username) async {
    final database = await _openDatabase();
    await database.delete(
      _analysisTableName,
      where: 'username = ?',
      whereArgs: [username],
    );
  }

  /// 关闭用户资产分析缓存数据库
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

  /// 打开用户资产分析缓存数据库
  Future<sqflite.Database> _openDatabase() {
    final database = _database;
    if (database != null && database.isOpen) {
      return Future.value(database);
    }

    final openingDatabase = _openingDatabase;
    if (openingDatabase != null) {
      return openingDatabase;
    }

    final nextOpeningDatabase = sqflite
        .openDatabase(
      'user_asset_analysis.sqlite',
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

  /// 创建用户资产分析缓存表
  ///
  /// [database] 用户资产分析缓存数据库
  Future<void> _createSchema(sqflite.Database database) async {
    await database.execute('''
      CREATE TABLE $_analysisTableName (
        username TEXT NOT NULL PRIMARY KEY,
        updated_at_milliseconds INTEGER NOT NULL,
        payload_json TEXT NOT NULL
      )
      ''');
  }
}

/// 用户资产分析缓存行
class UserAssetAnalysisCacheEntry {
  /// 创建用户资产分析缓存行
  ///
  /// [username] 用户名
  /// [updatedAtMilliseconds] 分析更新时间戳
  /// [payloadJson] 分析结果 JSON
  const UserAssetAnalysisCacheEntry({
    required this.username,
    required this.updatedAtMilliseconds,
    required this.payloadJson,
  });

  /// 用户名
  final String username;

  /// 分析更新时间戳
  final int updatedAtMilliseconds;

  /// 分析结果 JSON
  final String payloadJson;

  /// 从 SQLite 行创建用户资产分析缓存行
  ///
  /// [row] SQLite 查询结果
  factory UserAssetAnalysisCacheEntry.fromRow(Map<String, Object?> row) {
    return UserAssetAnalysisCacheEntry(
      username: row['username'] as String? ?? '',
      updatedAtMilliseconds: row['updated_at_milliseconds'] as int? ?? 0,
      payloadJson: row['payload_json'] as String? ?? '',
    );
  }
}
