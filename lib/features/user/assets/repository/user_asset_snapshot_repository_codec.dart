part of 'user_asset_snapshot_repository.dart';

/// 序列化用户资产快照明细
///
/// [request] 待序列化资产列表
_SerializedSnapshotRows _serializeUserAssetSnapshotRows(
  _SnapshotRowsSerializeRequest request,
) {
  return _SerializedSnapshotRows(
    characterRows: [
      for (final item in request.characters)
        UserAssetSnapshotPayload(
          id: item.characterId,
          payloadJson: jsonEncode(item.toJson()),
        ),
    ],
    templeRows: [
      for (final item in request.temples)
        UserAssetSnapshotPayload(
          id: item.id,
          payloadJson: jsonEncode(item.toJson()),
          starForces: item.starForces,
        ),
    ],
    characterHeaderRows: [
      for (final item in request.characterHeaders)
        UserAssetSnapshotPayload(
          id: item.characterId,
          payloadJson: jsonEncode(item.toJson()),
        ),
    ],
  );
}

/// 反序列化用户资产快照明细
///
/// [entry] 本地资产快照行
_DeserializedSnapshotRows _deserializeUserAssetSnapshotRows(
  UserAssetSnapshotEntry entry,
) {
  return _DeserializedSnapshotRows(
    characters: [
      for (final row in entry.characterRows)
        _decodeSnapshotRow(
          row,
          UserCharacterApiItem.fromJson,
          (item) => item.characterId,
        ),
    ],
    temples: [
      for (final row in entry.templeRows)
        _decodeSnapshotRow(
          row,
          UserTempleApiItem.fromJson,
          (item) => item.id,
        ),
    ],
    characterHeaders: [
      for (final row in entry.characterHeaderRows)
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
  const _SnapshotRowsSerializeRequest({
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

/// 用户资产快照序列化结果
class _SerializedSnapshotRows {
  /// 创建用户资产快照序列化结果
  ///
  /// [characterRows] 用户角色快照明细
  /// [templeRows] 用户圣殿快照明细
  /// [characterHeaderRows] 角色头部资料快照明细
  const _SerializedSnapshotRows({
    required this.characterRows,
    required this.templeRows,
    required this.characterHeaderRows,
  });

  /// 用户角色快照明细
  final List<UserAssetSnapshotPayload> characterRows;

  /// 用户圣殿快照明细
  final List<UserAssetSnapshotPayload> templeRows;

  /// 角色头部资料快照明细
  final List<UserAssetSnapshotPayload> characterHeaderRows;
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
