part of 'user_asset_snapshot_repository.dart';

/// 序列化用户资产快照明细
///
/// [request] 待序列化资产列表
_SerializedSnapshotRows _serializeUserAssetSnapshotRows(
  _SnapshotRowsSerializeRequest request,
) {
  final characterRows = [
    for (final item in request.characters)
      UserCharacterSnapshotPayload(
        id: item.characterId,
        payloadJson: jsonEncode(item.toJson()),
        name: item.name,
        icon: item.icon,
        level: item.level,
        zeroCount: item.zeroCount,
        starForces: item.starForces,
        stars: item.stars,
        userAmount: item.userAmount,
        userTotal: item.userTotal,
        sacrifices: item.sacrifices,
        current: item.current,
        fluctuation: item.fluctuation,
        state: item.state,
        price: item.price,
        rate: item.rate,
        rank: item.rank,
        singleDividend: item.singleDividend,
        totalDividend: item.totalDividend,
      ),
  ];
  final templeRows = [
    for (final item in request.temples)
      UserAssetSnapshotPayload(
        id: item.id,
        payloadJson: jsonEncode(item.toJson()),
        starForces: item.starForces,
      ),
  ];
  final characterHeaderRows = <UserCharacterHeaderSnapshotPayload>[
    for (final item in request.characterHeaders)
      UserCharacterHeaderSnapshotPayload(
        id: item.characterId,
        payloadJson: jsonEncode(item.toJson()),
        rank: item.rank,
      ),
  ];
  return _SerializedSnapshotRows(
    characterRows: characterRows,
    templeRows: templeRows,
    characterHeaderRows: characterHeaderRows,
    characterContentHash: _contentHash(
      characterRows.map((row) => '${row.id}:${row.payloadJson}'),
      totalItems: request.characterTotalItems,
    ),
    templeContentHash: _contentHash(
      templeRows.map((row) => '${row.id}:${row.payloadJson}'),
      totalItems: request.templeTotalItems,
    ),
    characterHeaderContentHash: _contentHash(
      characterHeaderRows.map((row) => '${row.id}:${row.payloadJson}'),
      totalItems: request.characterHeaders.length,
    ),
  );
}

/// 序列化用户角色快照明细
///
/// [request] 待序列化角色列表
_SerializedCharacterRows _serializeUserCharacterSnapshotRows(
  _CharacterRowsSerializeRequest request,
) {
  final rows = <UserCharacterSnapshotPayload>[];
  for (final item in request.characters) {
    final payloadJson = jsonEncode(item.toJson());
    rows.add(
      UserCharacterSnapshotPayload(
        id: item.characterId,
        payloadJson: payloadJson,
        name: item.name,
        icon: item.icon,
        level: item.level,
        zeroCount: item.zeroCount,
        starForces: item.starForces,
        stars: item.stars,
        userAmount: item.userAmount,
        userTotal: item.userTotal,
        sacrifices: item.sacrifices,
        current: item.current,
        fluctuation: item.fluctuation,
        state: item.state,
        price: item.price,
        rate: item.rate,
        rank: item.rank,
        singleDividend: item.singleDividend,
        totalDividend: item.totalDividend,
      ),
    );
  }
  return _SerializedCharacterRows(
    rows: List<UserCharacterSnapshotPayload>.unmodifiable(rows),
    contentHash: _contentHash(
      rows.map((row) => '${row.id}:${row.payloadJson}'),
      totalItems: request.totalItems,
    ),
  );
}

/// 计算有序快照内容哈希
///
/// [entries] 按展示顺序排列的快照内容
/// [totalItems] 接口返回总数
String _contentHash(Iterable<String> entries, {required int totalItems}) {
  final buffer = StringBuffer()..writeln(totalItems);
  for (final entry in entries) {
    buffer.writeln(entry);
  }
  return sha256.convert(utf8.encode(buffer.toString())).toString();
}

/// 反序列化用户资产快照明细
///
/// [record] 本地资产快照持久化记录
_DeserializedSnapshotRows _deserializeUserAssetSnapshotRows(
  UserAssetSnapshotRecord record,
) {
  return _DeserializedSnapshotRows(
    characters: [
      for (final row in record.characterRows)
        _decodeSnapshotRow(
          row,
          UserCharacterApiItem.fromJson,
          (item) => item.characterId,
        ),
    ],
    temples: [
      for (final row in record.templeRows)
        _decodeSnapshotRow(
          row,
          UserTempleApiItem.fromJson,
          (item) => item.id,
        ),
    ],
    characterHeaders: [
      for (final row in record.characterHeaderRows)
        _decodeSnapshotRow(
          row,
          CharacterDetailTradeHeader.fromJson,
          (item) => item.characterId,
        ),
    ],
  );
}

/// 解码并校验单条资产快照明细
///
/// [row] 资产快照明细
/// [fromJson] JSON 模型转换函数
/// [idOf] 模型主键读取函数
T _decodeSnapshotRow<T>(
  UserAssetSnapshotPayload row,
  T Function(Map<String, Object?> json) fromJson,
  int Function(T item) idOf,
) {
  final json = TinygrailResponseParser.asObjectMap(
    jsonDecode(row.payloadJson),
  );
  if (json == null) {
    throw const FormatException('资产快照明细 JSON 损坏');
  }
  final item = fromJson(json);
  if (idOf(item) != row.id) {
    throw const FormatException('资产快照明细主键不匹配');
  }
  return item;
}

/// 用户资产快照序列化请求
class _SnapshotRowsSerializeRequest {
  /// 创建用户资产快照序列化请求
  ///
  /// [characters] 用户全部角色
  /// [temples] 用户全部圣殿
  /// [characterHeaders] 全部角色头部资料
  /// [characterTotalItems] 角色接口总数
  /// [templeTotalItems] 圣殿接口总数
  const _SnapshotRowsSerializeRequest({
    required this.characters,
    required this.temples,
    required this.characterHeaders,
    required this.characterTotalItems,
    required this.templeTotalItems,
  });

  /// 用户全部角色
  final List<UserCharacterApiItem> characters;

  /// 用户全部圣殿
  final List<UserTempleApiItem> temples;

  /// 全部角色头部资料
  final List<CharacterDetailTradeHeader> characterHeaders;

  /// 角色接口总数
  final int characterTotalItems;

  /// 圣殿接口总数
  final int templeTotalItems;
}

/// 用户角色快照序列化请求
class _CharacterRowsSerializeRequest {
  /// 创建用户角色快照序列化请求
  ///
  /// [characters] 用户全部角色
  /// [totalItems] 接口返回总数
  const _CharacterRowsSerializeRequest({
    required this.characters,
    required this.totalItems,
  });

  /// 用户全部角色
  final List<UserCharacterApiItem> characters;

  /// 接口返回总数
  final int totalItems;
}

/// 用户资产快照序列化结果
class _SerializedSnapshotRows {
  /// 创建用户资产快照序列化结果
  ///
  /// [characterRows] 用户角色快照明细
  /// [templeRows] 用户圣殿快照明细
  /// [characterHeaderRows] 角色头部资料快照明细
  /// [characterContentHash] 用户角色内容哈希
  /// [templeContentHash] 用户圣殿内容哈希
  /// [characterHeaderContentHash] 全部角色资料内容哈希
  const _SerializedSnapshotRows({
    required this.characterRows,
    required this.templeRows,
    required this.characterHeaderRows,
    required this.characterContentHash,
    required this.templeContentHash,
    required this.characterHeaderContentHash,
  });

  /// 用户角色快照明细
  final List<UserCharacterSnapshotPayload> characterRows;

  /// 用户圣殿快照明细
  final List<UserAssetSnapshotPayload> templeRows;

  /// 角色头部资料快照明细
  final List<UserCharacterHeaderSnapshotPayload> characterHeaderRows;

  /// 用户角色内容哈希
  final String characterContentHash;

  /// 用户圣殿内容哈希
  final String templeContentHash;

  /// 全部角色资料内容哈希
  final String characterHeaderContentHash;
}

/// 用户角色快照序列化结果
class _SerializedCharacterRows {
  /// 创建用户角色快照序列化结果
  ///
  /// [rows] 用户角色快照明细
  /// [contentHash] 用户角色内容哈希
  const _SerializedCharacterRows({
    required this.rows,
    required this.contentHash,
  });

  /// 用户角色快照明细
  final List<UserCharacterSnapshotPayload> rows;

  /// 用户角色内容哈希
  final String contentHash;
}

/// 用户资产快照反序列化结果
class _DeserializedSnapshotRows {
  /// 创建用户资产快照反序列化结果
  ///
  /// [characters] 用户全部角色
  /// [temples] 用户全部圣殿
  /// [characterHeaders] 全部角色头部资料
  const _DeserializedSnapshotRows({
    required this.characters,
    required this.temples,
    required this.characterHeaders,
  });

  /// 用户全部角色
  final List<UserCharacterApiItem> characters;

  /// 用户全部圣殿
  final List<UserTempleApiItem> temples;

  /// 全部角色头部资料
  final List<CharacterDetailTradeHeader> characterHeaders;
}
