import 'package:magrail_app/core/network/tinygrail_page.dart';
import 'package:magrail_app/features/user/assets/model/user_character_snapshot_query.dart';
import 'package:magrail_app/features/user/assets/model/user_asset_snapshot.dart';
import 'package:magrail_app/features/user/assets/model/user_temple_snapshot_query.dart';
import 'package:magrail_app/features/user/assets/repository/user_asset_snapshot_database_models.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

part 'user_asset_snapshot_database_persistence.dart';
part 'user_asset_snapshot_database_queries.dart';
part 'user_asset_snapshot_database_schema.dart';

const String _metaTableName = 'user_asset_snapshot_meta';
const String _characterTableName = 'user_asset_snapshot_characters';
const String _templeTableName = 'user_asset_snapshot_temples';
const String _sourceStateTableName = 'user_asset_snapshot_source_state';

/// 用户资产快照数据库
class UserAssetSnapshotDatabase {
  /// 创建用户资产快照数据库
  UserAssetSnapshotDatabase();

  // 用户资产快照在应用进程内共享单连接，避免页面与启动刷新并发打开数据库
  static sqflite.Database? _database;
  static Future<sqflite.Database>? _openingDatabase;

  /// 写入完整用户资产快照
  ///
  /// [record] 用户资产快照持久化记录
  /// [charactersUpdatedAtMilliseconds] 用户角色更新时间戳
  /// [templesUpdatedAtMilliseconds] 用户圣殿更新时间戳
  /// [characterContentHash] 用户角色内容哈希
  /// [templeContentHash] 用户圣殿内容哈希
  Future<UserAssetSourceState> upsertSnapshotRecord(
    UserAssetSnapshotRecord record, {
    required int charactersUpdatedAtMilliseconds,
    required int templesUpdatedAtMilliseconds,
    required String characterContentHash,
    required String templeContentHash,
  }) async {
    final database = await _openDatabase();
    return database.transaction((transaction) async {
      final current =
          await _readStoredSourceState(transaction, record.username);
      final metadata = await _readMetadata(transaction, record.username);
      final resolvedWrite = _resolveSnapshotWrite(
        current: current,
        charactersUpdatedAtMilliseconds: charactersUpdatedAtMilliseconds,
        templesUpdatedAtMilliseconds: templesUpdatedAtMilliseconds,
        characterContentHash: characterContentHash,
        templeContentHash: templeContentHash,
      );
      final sourceState = _buildSourceState(
        current: current,
        characterChanged: resolvedWrite.characterChanged,
        templeChanged: resolvedWrite.templeChanged,
        charactersUpdatedAtMilliseconds:
            resolvedWrite.charactersUpdatedAtMilliseconds,
        templesUpdatedAtMilliseconds:
            resolvedWrite.templesUpdatedAtMilliseconds,
      );

      await _upsertMetadata(
        transaction,
        username: record.username,
        nickname: record.nickname,
        characterTotalItems: resolvedWrite.applyCharacters
            ? record.characterTotalItems
            : _rowInt(metadata?['character_total_items']),
        templeTotalItems: resolvedWrite.applyTemples
            ? record.templeTotalItems
            : _rowInt(metadata?['temple_total_items']),
      );
      if (resolvedWrite.characterChanged) {
        await _replaceCharacterRows(
          transaction,
          username: record.username,
          rows: record.characterRows,
        );
      }
      if (resolvedWrite.templeChanged) {
        await _replaceTempleRows(
          transaction,
          username: record.username,
          rows: record.templeRows,
        );
      }
      await _writeSourceState(
        transaction,
        username: record.username,
        sourceState: sourceState,
        characterContentHash: resolvedWrite.characterContentHash,
        templeContentHash: resolvedWrite.templeContentHash,
      );
      return sourceState;
    });
  }

  /// 单独写入用户角色快照并判断是否需要重新读取页面
  ///
  /// [username] 用户名
  /// [nickname] 用户昵称
  /// [rows] 用户角色快照明细
  /// [totalItems] 角色接口总数
  /// [updatedAtMilliseconds] 用户角色更新时间戳
  /// [contentHash] 用户角色内容哈希
  /// 返回是否需要重新读取快照窗口
  Future<bool> upsertCharacterSnapshot({
    required String username,
    required String nickname,
    required List<UserCharacterSnapshotPayload> rows,
    required int totalItems,
    required int updatedAtMilliseconds,
    required String contentHash,
  }) async {
    final database = await _openDatabase();
    return database.transaction((transaction) async {
      final current = await _readStoredSourceState(transaction, username);
      if (!_canApplySourceUpdate(
        incomingUpdatedAtMilliseconds: updatedAtMilliseconds,
        storedUpdatedAtMilliseconds:
            current?.sourceState.charactersUpdatedAtMilliseconds,
      )) {
        return current?.characterContentHash != contentHash;
      }
      final changed = current?.characterContentHash != contentHash;
      final sourceState = _buildSourceState(
        current: current,
        characterChanged: changed,
        templeChanged: false,
        charactersUpdatedAtMilliseconds: updatedAtMilliseconds,
        templesUpdatedAtMilliseconds:
            current?.sourceState.templesUpdatedAtMilliseconds ?? 0,
      );
      final metadata = await _readMetadata(transaction, username);
      await _upsertMetadata(
        transaction,
        username: username,
        nickname: nickname,
        characterTotalItems: totalItems,
        templeTotalItems: _rowInt(metadata?['temple_total_items']),
      );
      if (changed) {
        await _replaceCharacterRows(
          transaction,
          username: username,
          rows: rows,
        );
      }
      await _writeSourceState(
        transaction,
        username: username,
        sourceState: sourceState,
        characterContentHash: contentHash,
        templeContentHash: current?.templeContentHash ?? '',
      );
      return changed;
    });
  }

  /// 写入用户圣殿快照并判断是否需要重新读取页面
  ///
  /// [username] 用户名
  /// [nickname] 用户昵称
  /// [templeRows] 用户圣殿快照明细
  /// [templeTotalItems] 圣殿接口总数
  /// [templesUpdatedAtMilliseconds] 用户圣殿更新时间戳
  /// [templeContentHash] 用户圣殿内容哈希
  /// 返回是否需要重新读取快照窗口
  Future<bool> upsertTempleSnapshot({
    required String username,
    required String nickname,
    required List<UserTempleSnapshotPayload> templeRows,
    required int templeTotalItems,
    required int templesUpdatedAtMilliseconds,
    required String templeContentHash,
  }) async {
    final database = await _openDatabase();
    return database.transaction((transaction) async {
      final current = await _readStoredSourceState(transaction, username);
      if (!_canApplySourceUpdate(
        incomingUpdatedAtMilliseconds: templesUpdatedAtMilliseconds,
        storedUpdatedAtMilliseconds:
            current?.sourceState.templesUpdatedAtMilliseconds,
      )) {
        return current?.templeContentHash != templeContentHash;
      }
      final templeChanged = current?.templeContentHash != templeContentHash;
      final sourceState = _buildSourceState(
        current: current,
        characterChanged: false,
        templeChanged: templeChanged,
        charactersUpdatedAtMilliseconds:
            current?.sourceState.charactersUpdatedAtMilliseconds ?? 0,
        templesUpdatedAtMilliseconds: templesUpdatedAtMilliseconds,
      );
      final metadata = await _readMetadata(transaction, username);
      await _upsertMetadata(
        transaction,
        username: username,
        nickname: nickname,
        characterTotalItems: _rowInt(metadata?['character_total_items']),
        templeTotalItems: templeTotalItems,
      );
      if (templeChanged) {
        await _replaceTempleRows(
          transaction,
          username: username,
          rows: templeRows,
        );
      }
      await _writeSourceState(
        transaction,
        username: username,
        sourceState: sourceState,
        characterContentHash: current?.characterContentHash ?? '',
        templeContentHash: templeContentHash,
      );
      return templeChanged;
    });
  }

  /// 读取用户资产原始数据状态
  ///
  /// [username] 用户名
  Future<UserAssetSourceState?> readSourceState(String username) async {
    final database = await _openDatabase();
    return (await _readStoredSourceState(database, username))?.sourceState;
  }

  /// 分页读取有效的用户角色快照
  ///
  /// [username] 用户名
  /// [page] 页码
  /// [pageSize] 每页角色数量
  /// [sort] 排序字段
  /// [direction] 排序方向
  /// [searchKeyword] 角色 ID 或名称筛选词
  /// [expectedRevision] 必须匹配的角色快照版本
  Future<TinygrailPage<UserAssetSnapshotPayload>?> readCharacterPage({
    required String username,
    required int page,
    required int pageSize,
    required UserCharacterSnapshotSort sort,
    required UserCharacterSnapshotSortDirection direction,
    required String searchKeyword,
    int? expectedRevision,
  }) async {
    if (page <= 0 || pageSize <= 0) {
      throw ArgumentError('用户角色分页参数无效');
    }
    final database = await _openDatabase();
    return database.transaction((transaction) async {
      final sourceState = await _readStoredSourceState(transaction, username);
      if (sourceState == null) {
        return null;
      }
      if (expectedRevision != null &&
          sourceState.sourceState.revisions.characters != expectedRevision) {
        return null;
      }
      // 已展示窗口按版本继续读取，后台刷新完成后再整体替换
      if (expectedRevision == null &&
          !sourceState.sourceState.isCharacterDataFreshAt(DateTime.now())) {
        return null;
      }
      final storedTotalItems = await _countRows(
        transaction,
        tableName: _characterTableName,
        username: username,
      );
      final metadata = await _readMetadata(transaction, username);
      if (metadata == null ||
          _rowInt(metadata['character_total_items']) != storedTotalItems) {
        await transaction.rawUpdate(
          'UPDATE $_sourceStateTableName '
          'SET character_updated_at_milliseconds = 0, '
          'character_content_hash = ? WHERE username = ?',
          ['', username],
        );
        return null;
      }
      final searchFilter = _characterSearchFilter(searchKeyword);
      final totalItems = searchFilter.clause.isEmpty
          ? storedTotalItems
          : _rowInt(
              (await transaction.rawQuery(
                'SELECT COUNT(*) AS total_count '
                'FROM $_characterTableName c '
                'WHERE c.username = ? ${searchFilter.clause}',
                [username, ...searchFilter.arguments],
              ))
                  .firstOrNull?['total_count'],
            );
      final rows = await transaction.rawQuery(
        'SELECT c.character_id, c.payload_json '
        'FROM $_characterTableName c '
        'WHERE c.username = ? ${searchFilter.clause} '
        'ORDER BY ${_characterOrderBy(sort, direction)} '
        'LIMIT ? OFFSET ?',
        [
          username,
          ...searchFilter.arguments,
          pageSize,
          (page - 1) * pageSize,
        ],
      );
      return TinygrailPage(
        items: List<UserAssetSnapshotPayload>.unmodifiable(
          rows.map(
            (row) => UserAssetSnapshotPayload(
              id: _rowInt(row['character_id']),
              payloadJson: row['payload_json'] as String? ?? '',
            ),
          ),
        ),
        currentPage: page,
        totalPages: totalItems == 0 ? 0 : (totalItems / pageSize).ceil(),
        totalItems: totalItems,
        itemsPerPage: pageSize,
      );
    });
  }

  /// 标记用户角色快照失效并保留其他来源数据
  ///
  /// [username] 用户名
  Future<void> invalidateCharacterSnapshot(String username) async {
    final database = await _openDatabase();
    await database.rawUpdate(
      'UPDATE $_sourceStateTableName '
      'SET character_updated_at_milliseconds = 0, '
      'character_content_hash = ? WHERE username = ?',
      ['', username],
    );
  }

  /// 标记用户圣殿快照失效
  ///
  /// [username] 用户名
  Future<void> invalidateTempleSnapshot(String username) async {
    final database = await _openDatabase();
    await database.rawUpdate(
      'UPDATE $_sourceStateTableName '
      'SET temple_updated_at_milliseconds = 0, '
      'temple_content_hash = ? WHERE username = ?',
      ['', username],
    );
  }

  /// 分页读取星光圣殿快照
  ///
  /// [username] 用户名
  /// [page] 页码
  /// [pageSize] 每页圣殿数量
  Future<TinygrailPage<UserAssetSnapshotPayload>> readStarlightTemplePage({
    required String username,
    required int page,
    required int pageSize,
  }) async {
    if (page <= 0 || pageSize <= 0) {
      throw ArgumentError('星光圣殿分页参数无效');
    }
    final database = await _openDatabase();
    return database.transaction((transaction) async {
      final storedState = await _readStoredSourceState(transaction, username);
      if (storedState == null) {
        throw StateError('圣殿快照不存在');
      }
      if (!storedState.sourceState.isTempleDataFreshAt(DateTime.now())) {
        throw StateError('圣殿快照已过期');
      }
      final countRows = await transaction.rawQuery(
        'SELECT COUNT(*) AS total_count FROM $_templeTableName '
        'WHERE username = ? AND star_forces >= ?',
        [username, starlightTempleStarForcesThreshold],
      );
      final totalItems =
          countRows.isEmpty ? 0 : _rowInt(countRows.first['total_count']);
      final rows = await transaction.query(
        _templeTableName,
        columns: const ['temple_id', 'payload_json'],
        where: 'username = ? AND star_forces >= ?',
        whereArgs: [username, starlightTempleStarForcesThreshold],
        orderBy: 'row_order ASC',
        limit: pageSize,
        offset: (page - 1) * pageSize,
      );
      return TinygrailPage(
        items: List<UserAssetSnapshotPayload>.unmodifiable(
          rows.map(
            (row) => UserAssetSnapshotPayload(
              id: _rowInt(row['temple_id']),
              payloadJson: row['payload_json'] as String? ?? '',
            ),
          ),
        ),
        currentPage: page,
        totalPages: totalItems == 0 ? 0 : (totalItems / pageSize).ceil(),
        totalItems: totalItems,
        itemsPerPage: pageSize,
      );
    });
  }

  /// 分页读取有效的用户圣殿快照
  ///
  /// [username] 用户名
  /// [page] 页码
  /// [pageSize] 每页圣殿数量
  /// [sort] 排序字段
  /// [direction] 排序方向
  /// [searchKeyword] 角色 ID 或名称筛选词
  /// [expectedRevision] 必须匹配的圣殿快照版本
  Future<TinygrailPage<UserTempleSnapshotPayload>?> readTemplePage({
    required String username,
    required int page,
    required int pageSize,
    required UserTempleSnapshotSort sort,
    required UserTempleSnapshotSortDirection direction,
    required String searchKeyword,
    int? expectedRevision,
  }) async {
    if (page <= 0 || pageSize <= 0) {
      throw ArgumentError('用户圣殿分页参数无效');
    }
    final database = await _openDatabase();
    return database.transaction((transaction) async {
      final storedState = await _readStoredSourceState(transaction, username);
      if (storedState == null) {
        return null;
      }
      if (expectedRevision != null &&
          storedState.sourceState.revisions.temples != expectedRevision) {
        return null;
      }
      // 已展示窗口按版本继续读取，后台刷新完成后再整体替换
      if (expectedRevision == null &&
          !storedState.sourceState.isTempleDataFreshAt(DateTime.now())) {
        return null;
      }
      final storedTotalItems = await _countRows(
        transaction,
        tableName: _templeTableName,
        username: username,
      );
      final metadata = await _readMetadata(transaction, username);
      if (metadata == null ||
          _rowInt(metadata['temple_total_items']) != storedTotalItems) {
        await transaction.rawUpdate(
          'UPDATE $_sourceStateTableName '
          'SET temple_updated_at_milliseconds = 0, '
          'temple_content_hash = ? WHERE username = ?',
          ['', username],
        );
        return null;
      }
      final searchFilter = _templeSearchFilter(searchKeyword);
      final totalItems = searchFilter.clause.isEmpty
          ? storedTotalItems
          : _rowInt(
              (await transaction.rawQuery(
                'SELECT COUNT(*) AS total_count FROM $_templeTableName t '
                'WHERE t.username = ? ${searchFilter.clause}',
                [username, ...searchFilter.arguments],
              ))
                  .firstOrNull?['total_count'],
            );
      final rows = await transaction.rawQuery(
        'SELECT t.temple_id, t.character_id, t.name, t.assets, '
        't.sacrifices, t.character_level, t.damaged, t.single_dividend, '
        't.total_dividend, t.star_forces, t.refine, t.create_value, '
        't.payload_json FROM $_templeTableName t '
        'WHERE t.username = ? ${searchFilter.clause} '
        'ORDER BY ${_templeOrderBy(sort, direction)} LIMIT ? OFFSET ?',
        [
          username,
          ...searchFilter.arguments,
          pageSize,
          (page - 1) * pageSize,
        ],
      );
      return TinygrailPage(
        items: List<UserTempleSnapshotPayload>.unmodifiable(
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
        ),
        currentPage: page,
        totalPages: totalItems == 0 ? 0 : (totalItems / pageSize).ceil(),
        totalItems: totalItems,
        itemsPerPage: pageSize,
      );
    });
  }

  /// 读取用户资产快照持久化记录
  ///
  /// [username] 用户名
  Future<UserAssetSnapshotRecord?> readSnapshotRecord(String username) async {
    final database = await _openDatabase();
    return database.transaction((transaction) async {
      final metadata = await _readMetadata(transaction, username);
      if (metadata == null) {
        return null;
      }
      final sourceState = await _readStoredSourceState(transaction, username);
      if (sourceState == null ||
          !sourceState.sourceState.revisions.isComplete) {
        return null;
      }
      return UserAssetSnapshotRecord(
        username: metadata['username'] as String? ?? '',
        nickname: metadata['nickname'] as String? ?? '',
        characterRows: await _readCharacterRows(transaction, username),
        templeRows: await _readTempleRows(transaction, username),
        characterTotalItems: _rowInt(metadata['character_total_items']),
        templeTotalItems: _rowInt(metadata['temple_total_items']),
        sourceState: sourceState.sourceState,
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
}
