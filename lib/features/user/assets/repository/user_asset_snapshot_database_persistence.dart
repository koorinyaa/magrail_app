part of 'user_asset_snapshot_database.dart';

// 每批 500 行用于控制快照写入时的 SQLite 参数与内存占用
const int _insertBatchSize = 500;

/// 判断来源刷新结果是否仍可写入快照
///
/// [incomingUpdatedAtMilliseconds] 待写入批次完成时间戳
/// [storedUpdatedAtMilliseconds] 已持久化批次完成时间戳
bool _canApplySourceUpdate({
  required int incomingUpdatedAtMilliseconds,
  required int? storedUpdatedAtMilliseconds,
}) {
  return storedUpdatedAtMilliseconds == null ||
      incomingUpdatedAtMilliseconds >= storedUpdatedAtMilliseconds;
}

/// 解析完整快照各来源的可写入状态
///
/// [current] 当前数据库状态
/// [charactersUpdatedAtMilliseconds] 待写入用户角色完成时间戳
/// [templesUpdatedAtMilliseconds] 待写入用户圣殿完成时间戳
/// [characterContentHash] 待写入用户角色内容哈希
/// [templeContentHash] 待写入用户圣殿内容哈希
({
  bool applyCharacters,
  bool applyTemples,
  bool characterChanged,
  bool templeChanged,
  int charactersUpdatedAtMilliseconds,
  int templesUpdatedAtMilliseconds,
  String characterContentHash,
  String templeContentHash,
}) _resolveSnapshotWrite({
  required _StoredUserAssetSourceState? current,
  required int charactersUpdatedAtMilliseconds,
  required int templesUpdatedAtMilliseconds,
  required String characterContentHash,
  required String templeContentHash,
}) {
  // 较慢的旧刷新不得覆盖已由更新批次写入的同来源快照
  final applyCharacters = _canApplySourceUpdate(
    incomingUpdatedAtMilliseconds: charactersUpdatedAtMilliseconds,
    storedUpdatedAtMilliseconds:
        current?.sourceState.charactersUpdatedAtMilliseconds,
  );
  final applyTemples = _canApplySourceUpdate(
    incomingUpdatedAtMilliseconds: templesUpdatedAtMilliseconds,
    storedUpdatedAtMilliseconds:
        current?.sourceState.templesUpdatedAtMilliseconds,
  );
  final resolvedCharacterContentHash = applyCharacters
      ? characterContentHash
      : current?.characterContentHash ?? '';
  final resolvedTempleContentHash =
      applyTemples ? templeContentHash : current?.templeContentHash ?? '';
  return (
    applyCharacters: applyCharacters,
    applyTemples: applyTemples,
    characterChanged: applyCharacters &&
        current?.characterContentHash != resolvedCharacterContentHash,
    templeChanged:
        applyTemples && current?.templeContentHash != resolvedTempleContentHash,
    charactersUpdatedAtMilliseconds: applyCharacters
        ? charactersUpdatedAtMilliseconds
        : current?.sourceState.charactersUpdatedAtMilliseconds ?? 0,
    templesUpdatedAtMilliseconds: applyTemples
        ? templesUpdatedAtMilliseconds
        : current?.sourceState.templesUpdatedAtMilliseconds ?? 0,
    characterContentHash: resolvedCharacterContentHash,
    templeContentHash: resolvedTempleContentHash,
  );
}

/// 用户资产快照数据库持久化操作
extension _UserAssetSnapshotDatabasePersistence on UserAssetSnapshotDatabase {
  /// 生成写入后的原始数据状态
  ///
  /// [current] 当前数据库状态
  /// [characterChanged] 用户角色是否变化
  /// [templeChanged] 用户圣殿是否变化
  /// [charactersUpdatedAtMilliseconds] 用户角色更新时间戳
  /// [templesUpdatedAtMilliseconds] 用户圣殿更新时间戳
  UserAssetSourceState _buildSourceState({
    required _StoredUserAssetSourceState? current,
    required bool characterChanged,
    required bool templeChanged,
    required int charactersUpdatedAtMilliseconds,
    required int templesUpdatedAtMilliseconds,
  }) {
    final revisions = current?.sourceState.revisions;
    return UserAssetSourceState(
      revisions: UserAssetDataRevisions(
        characters: _nextRevision(revisions?.characters, characterChanged),
        temples: _nextRevision(revisions?.temples, templeChanged),
        schemaVersion: userAssetSnapshotSchemaVersion,
      ),
      charactersUpdatedAtMilliseconds: charactersUpdatedAtMilliseconds,
      templesUpdatedAtMilliseconds: templesUpdatedAtMilliseconds,
    );
  }

  /// 写入用户资产元数据
  Future<void> _upsertMetadata(
    sqflite.Transaction transaction, {
    required String username,
    required String nickname,
    required int characterTotalItems,
    required int templeTotalItems,
  }) {
    return transaction.insert(
      _metaTableName,
      {
        'username': username,
        'nickname': nickname,
        'character_total_items': characterTotalItems,
        'temple_total_items': templeTotalItems,
      },
      conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
    );
  }

  /// 读取用户资产元数据
  Future<Map<String, Object?>?> _readMetadata(
    sqflite.DatabaseExecutor executor,
    String username,
  ) async {
    final rows = await executor.query(
      _metaTableName,
      where: 'username = ?',
      whereArgs: [username],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  /// 替换用户角色明细
  Future<void> _replaceCharacterRows(
    sqflite.Transaction transaction, {
    required String username,
    required List<UserCharacterSnapshotPayload> rows,
  }) async {
    await transaction.delete(
      _characterTableName,
      where: 'username = ?',
      whereArgs: [username],
    );
    for (var start = 0; start < rows.length; start += _insertBatchSize) {
      final batch = transaction.batch();
      final end = (start + _insertBatchSize).clamp(0, rows.length);
      for (var index = start; index < end; index += 1) {
        final row = rows[index];
        batch.insert(_characterTableName, {
          'username': username,
          'character_id': row.id,
          'row_order': index,
          'name': row.name,
          'icon': row.icon,
          'level': row.level,
          'zero_count': row.zeroCount,
          'star_forces': row.starForces,
          'stars': row.stars,
          'user_amount': row.userAmount,
          'user_total': row.userTotal,
          'sacrifices': row.sacrifices,
          'current_value': row.current,
          'fluctuation': row.fluctuation,
          'state_value': row.state,
          'price_value': row.price,
          'rate_value': row.rate,
          'rank': row.rank,
          'single_dividend': row.singleDividend,
          'total_dividend': row.totalDividend,
          'payload_json': row.payloadJson,
        });
      }
      await batch.commit(noResult: true);
    }
  }

  /// 替换用户圣殿明细
  Future<void> _replaceTempleRows(
    sqflite.Transaction transaction, {
    required String username,
    required List<UserTempleSnapshotPayload> rows,
  }) async {
    await transaction.delete(
      _templeTableName,
      where: 'username = ?',
      whereArgs: [username],
    );
    for (var start = 0; start < rows.length; start += _insertBatchSize) {
      final batch = transaction.batch();
      final end = (start + _insertBatchSize).clamp(0, rows.length);
      for (var index = start; index < end; index += 1) {
        final row = rows[index];
        batch.insert(_templeTableName, {
          'username': username,
          'temple_id': row.id,
          'row_order': index,
          'character_id': row.characterId,
          'name': row.name,
          'assets': row.assets,
          'sacrifices': row.sacrifices,
          'character_level': row.characterLevel,
          'damaged': row.damaged,
          'single_dividend': row.singleDividend,
          'total_dividend': row.totalDividend,
          'star_forces': row.starForces,
          'refine': row.refine,
          'create_value': row.create,
          'payload_json': row.payloadJson,
        });
      }
      await batch.commit(noResult: true);
    }
  }

  /// 写入两类原始数据状态
  Future<void> _writeSourceState(
    sqflite.Transaction transaction, {
    required String username,
    required UserAssetSourceState sourceState,
    required String characterContentHash,
    required String templeContentHash,
  }) {
    return transaction.insert(
      _sourceStateTableName,
      {
        'username': username,
        'schema_version': sourceState.revisions.schemaVersion,
        'character_revision': sourceState.revisions.characters,
        'temple_revision': sourceState.revisions.temples,
        'character_updated_at_milliseconds':
            sourceState.charactersUpdatedAtMilliseconds,
        'temple_updated_at_milliseconds':
            sourceState.templesUpdatedAtMilliseconds,
        'character_content_hash': characterContentHash,
        'temple_content_hash': templeContentHash,
      },
      conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
    );
  }

  /// 读取两类原始数据持久化状态
  Future<_StoredUserAssetSourceState?> _readStoredSourceState(
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
    return _StoredUserAssetSourceState(
      sourceState: UserAssetSourceState(
        revisions: UserAssetDataRevisions(
          characters: _rowInt(row['character_revision']),
          temples: _rowInt(row['temple_revision']),
          schemaVersion: _rowInt(row['schema_version']),
        ),
        charactersUpdatedAtMilliseconds:
            _rowInt(row['character_updated_at_milliseconds']),
        templesUpdatedAtMilliseconds:
            _rowInt(row['temple_updated_at_milliseconds']),
      ),
      characterContentHash: row['character_content_hash'] as String? ?? '',
      templeContentHash: row['temple_content_hash'] as String? ?? '',
    );
  }

  /// 读取用户角色快照明细
  Future<List<UserCharacterSnapshotPayload>> _readCharacterRows(
    sqflite.DatabaseExecutor executor,
    String username,
  ) async {
    final rows = await executor.query(
      _characterTableName,
      where: 'username = ?',
      whereArgs: [username],
      orderBy: 'row_order ASC',
    );
    return List<UserCharacterSnapshotPayload>.unmodifiable(
      rows.map(
        (row) => UserCharacterSnapshotPayload(
          id: _rowInt(row['character_id']),
          payloadJson: row['payload_json'] as String? ?? '',
          name: row['name'] as String? ?? '',
          icon: row['icon'] as String? ?? '',
          level: _rowInt(row['level']),
          zeroCount: _rowInt(row['zero_count']),
          starForces: _rowInt(row['star_forces']),
          stars: _rowInt(row['stars']),
          userAmount: _rowInt(row['user_amount']),
          userTotal: _rowInt(row['user_total']),
          sacrifices: _rowInt(row['sacrifices']),
          current: _rowDouble(row['current_value']),
          fluctuation: _rowDouble(row['fluctuation']),
          state: _rowInt(row['state_value']),
          price: _rowDouble(row['price_value']),
          rate: _rowDouble(row['rate_value']),
          rank: _rowInt(row['rank']),
          singleDividend: _rowDouble(row['single_dividend']),
          totalDividend: _rowDouble(row['total_dividend']),
        ),
      ),
    );
  }

  /// 读取用户圣殿快照明细
  ///
  /// [executor] SQLite 执行器
  /// [username] 用户名
  Future<List<UserTempleSnapshotPayload>> _readTempleRows(
    sqflite.DatabaseExecutor executor,
    String username,
  ) async {
    final rows = await executor.query(
      _templeTableName,
      where: 'username = ?',
      whereArgs: [username],
      orderBy: 'row_order ASC',
    );
    return List<UserTempleSnapshotPayload>.unmodifiable(
      rows.map(
        (row) => UserTempleSnapshotPayload(
          id: _rowInt(row['temple_id']),
          payloadJson: row['payload_json'] as String? ?? '',
          characterId: _rowInt(row['character_id']),
          name: row['name'] as String? ?? '',
          assets: _rowInt(row['assets']),
          sacrifices: _rowInt(row['sacrifices']),
          characterLevel: _rowInt(row['character_level']),
          damaged: _rowInt(row['damaged']),
          singleDividend: _rowDouble(row['single_dividend']),
          totalDividend: _rowDouble(row['total_dividend']),
          starForces: _rowInt(row['star_forces']),
          refine: _rowInt(row['refine']),
          create: row['create_value'] as String? ?? '',
        ),
      ),
    );
  }

  /// 统计用户在指定快照表中的明细数量
  Future<int> _countRows(
    sqflite.DatabaseExecutor executor, {
    required String tableName,
    required String username,
  }) async {
    final rows = await executor.rawQuery(
      'SELECT COUNT(*) AS total_count FROM $tableName WHERE username = ?',
      [username],
    );
    return rows.isEmpty ? 0 : _rowInt(rows.first['total_count']);
  }
}

/// 两类原始数据持久化状态
class _StoredUserAssetSourceState {
  /// 创建两类原始数据持久化状态
  const _StoredUserAssetSourceState({
    required this.sourceState,
    required this.characterContentHash,
    required this.templeContentHash,
  });

  final UserAssetSourceState sourceState;
  final String characterContentHash;
  final String templeContentHash;
}

/// 生成下一来源版本
int _nextRevision(int? current, bool changed) {
  final resolved = current ?? 0;
  if (!changed) {
    return resolved;
  }
  return resolved + 1;
}

/// 将 SQLite 数值转换为整数
int _rowInt(Object? value) {
  return switch (value) {
    int number => number,
    num number => number.toInt(),
    String text => int.tryParse(text) ?? 0,
    _ => 0,
  };
}

/// 将 SQLite 数值转换为浮点数
double _rowDouble(Object? value) {
  return switch (value) {
    num number => number.toDouble(),
    String text => double.tryParse(text) ?? 0,
    _ => 0,
  };
}

/// 生成当前用户角色排序 SQL
String _characterOrderBy(
  UserCharacterSnapshotSort sort,
  UserCharacterSnapshotSortDirection direction,
) {
  final resolvedDirection = _sqlDirection(direction);
  final rankDirection =
      direction == UserCharacterSnapshotSortDirection.descending
          ? 'ASC'
          : 'DESC';
  return switch (sort) {
    UserCharacterSnapshotSort.holdings =>
      'c.user_total $resolvedDirection, c.row_order ASC',
    UserCharacterSnapshotSort.level =>
      'c.level $resolvedDirection, c.row_order ASC',
    UserCharacterSnapshotSort.sacrifices =>
      'c.sacrifices $resolvedDirection, c.row_order ASC',
    UserCharacterSnapshotSort.towerRank =>
      'CASE WHEN c.rank <= 0 THEN 1 ELSE 0 END ASC, '
          'c.rank $rankDirection, c.row_order ASC',
    UserCharacterSnapshotSort.stars =>
      'c.stars $resolvedDirection, c.row_order ASC',
    UserCharacterSnapshotSort.singleDividend =>
      'c.single_dividend $resolvedDirection, c.row_order ASC',
    UserCharacterSnapshotSort.totalDividend =>
      'c.total_dividend $resolvedDirection, c.row_order ASC',
    UserCharacterSnapshotSort.currentPrice =>
      'c.current_value $resolvedDirection, c.row_order ASC',
  };
}

/// 生成受控排序方向 SQL
String _sqlDirection(UserCharacterSnapshotSortDirection direction) {
  return direction == UserCharacterSnapshotSortDirection.ascending
      ? 'ASC'
      : 'DESC';
}
