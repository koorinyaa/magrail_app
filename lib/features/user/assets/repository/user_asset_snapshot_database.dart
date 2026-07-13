import 'package:magrail_app/core/network/tinygrail_page.dart';
import 'package:magrail_app/features/user/assets/model/user_character_snapshot_query.dart';
import 'package:magrail_app/features/user/assets/model/user_asset_snapshot.dart';
import 'package:magrail_app/features/user/assets/repository/user_asset_snapshot_database_models.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

part 'user_asset_snapshot_database_persistence.dart';
part 'user_asset_snapshot_database_schema.dart';

const String _metaTableName = 'user_asset_snapshot_meta';
const String _characterTableName = 'user_asset_snapshot_characters';
const String _templeTableName = 'user_asset_snapshot_temples';
const String _characterHeaderTableName =
    'user_asset_snapshot_character_headers';
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
  /// [characterHeadersUpdatedAtMilliseconds] 全部角色资料更新时间戳
  /// [characterContentHash] 用户角色内容哈希
  /// [templeContentHash] 用户圣殿内容哈希
  /// [characterHeaderContentHash] 全部角色资料内容哈希
  Future<UserAssetSourceState> upsertSnapshotRecord(
    UserAssetSnapshotRecord record, {
    required int charactersUpdatedAtMilliseconds,
    required int templesUpdatedAtMilliseconds,
    required int characterHeadersUpdatedAtMilliseconds,
    required String characterContentHash,
    required String templeContentHash,
    required String characterHeaderContentHash,
  }) async {
    final database = await _openDatabase();
    return database.transaction((transaction) async {
      final current = await _readStoredSourceState(
        transaction,
        record.username,
      );
      final characterChanged =
          current?.characterContentHash != characterContentHash;
      final templeChanged = current?.templeContentHash != templeContentHash;
      final headerChanged =
          current?.characterHeaderContentHash != characterHeaderContentHash;
      final sourceState = _buildSourceState(
        current: current,
        characterChanged: characterChanged,
        templeChanged: templeChanged,
        characterHeaderChanged: headerChanged,
        charactersUpdatedAtMilliseconds: charactersUpdatedAtMilliseconds,
        templesUpdatedAtMilliseconds: templesUpdatedAtMilliseconds,
        characterHeadersUpdatedAtMilliseconds:
            characterHeadersUpdatedAtMilliseconds,
      );

      await _upsertMetadata(
        transaction,
        username: record.username,
        nickname: record.nickname,
        characterTotalItems: record.characterTotalItems,
        templeTotalItems: record.templeTotalItems,
      );
      if (characterChanged) {
        await _replaceCharacterRows(
          transaction,
          username: record.username,
          rows: record.characterRows,
        );
      }
      if (templeChanged) {
        await _replaceTempleRows(
          transaction,
          username: record.username,
          rows: record.templeRows,
        );
      }
      if (headerChanged) {
        await _replaceCharacterHeaderRows(
          transaction,
          username: record.username,
          rows: record.characterHeaderRows,
        );
      }
      await _writeSourceState(
        transaction,
        username: record.username,
        sourceState: sourceState,
        characterContentHash: characterContentHash,
        templeContentHash: templeContentHash,
        characterHeaderContentHash: characterHeaderContentHash,
      );
      return sourceState;
    });
  }

  /// 单独写入用户角色快照
  ///
  /// [username] 用户名
  /// [nickname] 用户昵称
  /// [rows] 用户角色快照明细
  /// [totalItems] 角色接口总数
  /// [updatedAtMilliseconds] 用户角色更新时间戳
  /// [contentHash] 用户角色内容哈希
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
      final changed = current?.characterContentHash != contentHash;
      final sourceState = _buildSourceState(
        current: current,
        characterChanged: changed,
        templeChanged: false,
        characterHeaderChanged: false,
        charactersUpdatedAtMilliseconds: updatedAtMilliseconds,
        templesUpdatedAtMilliseconds:
            current?.sourceState.templesUpdatedAtMilliseconds ?? 0,
        characterHeadersUpdatedAtMilliseconds:
            current?.sourceState.characterHeadersUpdatedAtMilliseconds ?? 0,
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
        characterHeaderContentHash: current?.characterHeaderContentHash ?? '',
      );
      return changed;
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
  Future<TinygrailPage<UserAssetSnapshotPayload>?> readCharacterPage({
    required String username,
    required int page,
    required int pageSize,
    required UserCharacterSnapshotSort sort,
    required UserCharacterSnapshotSortDirection direction,
    required String searchKeyword,
  }) async {
    if (page <= 0 || pageSize <= 0) {
      throw ArgumentError('用户角色分页参数无效');
    }
    final database = await _openDatabase();
    return database.transaction((transaction) async {
      final sourceState = await _readStoredSourceState(transaction, username);
      if (sourceState == null ||
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

  /// 读取等级排序下的快速跳转位置
  ///
  /// [username] 用户名
  /// [direction] 等级排序方向
  /// [searchKeyword] 角色 ID 或名称筛选词
  Future<List<UserCharacterLevelPosition>> readCharacterLevelPositions({
    required String username,
    required UserCharacterSnapshotSortDirection direction,
    required String searchKeyword,
  }) async {
    final database = await _openDatabase();
    final searchFilter = _characterSearchFilter(searchKeyword);
    final rows = await database.rawQuery(
      'SELECT level, COUNT(*) AS item_count '
      'FROM $_characterTableName c '
      'WHERE c.username = ? ${searchFilter.clause} '
      'GROUP BY level ORDER BY level ${_sqlDirection(direction)}',
      [username, ...searchFilter.arguments],
    );
    var absoluteIndex = 0;
    final positions = <UserCharacterLevelPosition>[];
    for (final row in rows) {
      positions.add(
        UserCharacterLevelPosition(
          level: _rowInt(row['level']),
          absoluteIndex: absoluteIndex,
        ),
      );
      absoluteIndex += _rowInt(row['item_count']);
    }
    return List<UserCharacterLevelPosition>.unmodifiable(positions);
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
        templeRows: await _readPayloadRows(
          transaction,
          tableName: _templeTableName,
          keyColumn: 'temple_id',
          username: username,
        ),
        characterHeaderRows:
            await _readCharacterHeaderRows(transaction, username),
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

  /// 生成写入后的原始数据状态
  ///
  /// [current] 当前数据库状态
  /// [characterChanged] 用户角色是否变化
  /// [templeChanged] 用户圣殿是否变化
  /// [characterHeaderChanged] 全部角色资料是否变化
  /// [charactersUpdatedAtMilliseconds] 用户角色更新时间戳
  /// [templesUpdatedAtMilliseconds] 用户圣殿更新时间戳
  /// [characterHeadersUpdatedAtMilliseconds] 全部角色资料更新时间戳
  UserAssetSourceState _buildSourceState({
    required _StoredUserAssetSourceState? current,
    required bool characterChanged,
    required bool templeChanged,
    required bool characterHeaderChanged,
    required int charactersUpdatedAtMilliseconds,
    required int templesUpdatedAtMilliseconds,
    required int characterHeadersUpdatedAtMilliseconds,
  }) {
    final revisions = current?.sourceState.revisions;
    return UserAssetSourceState(
      revisions: UserAssetDataRevisions(
        characters: _nextRevision(revisions?.characters, characterChanged),
        temples: _nextRevision(revisions?.temples, templeChanged),
        characterHeaders: _nextRevision(
          revisions?.characterHeaders,
          characterHeaderChanged,
        ),
        schemaVersion: userAssetSnapshotSchemaVersion,
      ),
      charactersUpdatedAtMilliseconds: charactersUpdatedAtMilliseconds,
      templesUpdatedAtMilliseconds: templesUpdatedAtMilliseconds,
      characterHeadersUpdatedAtMilliseconds:
          characterHeadersUpdatedAtMilliseconds,
    );
  }
}

/// 生成角色 ID 与名称筛选 SQL
///
/// [searchKeyword] 角色 ID 或名称筛选词
({String clause, List<Object?> arguments}) _characterSearchFilter(
  String searchKeyword,
) {
  final keyword = searchKeyword.trim();
  if (keyword.isEmpty) {
    return (clause: '', arguments: const <Object?>[]);
  }
  // 角色 ID 常用 #123 形式输入，仅纯数字编号去掉前缀参与模糊匹配
  final normalizedKeyword =
      RegExp(r'^#[0-9]+$').hasMatch(keyword) ? keyword.substring(1) : keyword;
  // LIKE 通配符按字面量搜索，避免扩大筛选范围
  final escapedKeyword = normalizedKeyword
      .replaceAll(r'\', r'\\')
      .replaceAll('%', r'\%')
      .replaceAll('_', r'\_');
  final searchPattern = '%$escapedKeyword%';
  return (
    clause: r"AND (CAST(c.character_id AS TEXT) LIKE ? ESCAPE '\' "
        r"OR c.name LIKE ? ESCAPE '\')",
    arguments: <Object?>[searchPattern, searchPattern],
  );
}
