/// bot 配置数据
class BotConfig {
  /// 创建 bot 配置数据
  ///
  /// [userId] bot 归属用户 ID
  /// [nickname] bot 归属用户昵称
  /// [state] 第三方托管状态
  /// [dailyState] 是否自动每日签到
  /// [bonusState] 是否自动领取每周股息
  /// [templeBlacklist] 自动模式圣殿黑名单
  /// [scratchState] 是否自动刮刮乐
  /// [autoStarPower] 是否自动转化星之力
  /// [chaosState] 是否启用混沌魔方
  /// [chaosAutoMode] 混沌魔方是否使用自动模式
  /// [chaosUseTemple] 混沌魔方手动消耗圣殿角色 ID
  /// [guidepostState] 是否启用虚空道标
  /// [guidepostAutoMode] 虚空道标是否使用自动模式
  /// [guidepostGrandetMode] 虚空道标是否使用葛朗台模式
  /// [guidepostUseTemple] 虚空道标手动消耗圣殿角色 ID
  /// [guidepostTarget] 虚空道标目标角色 ID
  /// [fishState] 是否启用鲤鱼之眼
  /// [fishAutoMode] 鲤鱼之眼是否使用自动模式
  /// [fishUseTemple] 鲤鱼之眼手动消耗圣殿角色 ID
  /// [fishTarget] 鲤鱼之眼目标角色 ID
  /// [icoState] 是否启用 ICO 自动凑人头
  /// [icoInvestmentAmount] ICO 投入金额
  /// [icoReserveAmount] ICO 保留金额
  BotConfig({
    required this.userId,
    required this.nickname,
    required this.state,
    required this.dailyState,
    required this.bonusState,
    required this.templeBlacklist,
    required this.scratchState,
    required this.autoStarPower,
    required this.chaosState,
    required this.chaosAutoMode,
    required this.chaosUseTemple,
    required this.guidepostState,
    required this.guidepostAutoMode,
    required this.guidepostGrandetMode,
    required this.guidepostUseTemple,
    required this.guidepostTarget,
    required this.fishState,
    required this.fishAutoMode,
    required this.fishUseTemple,
    required this.fishTarget,
    required this.icoState,
    required this.icoInvestmentAmount,
    required this.icoReserveAmount,
  });

  /// bot 归属用户 ID
  String userId;

  /// bot 归属用户昵称
  String nickname;

  /// 第三方托管状态
  Object? state;

  /// 是否自动每日签到
  bool dailyState;

  /// 是否自动领取每周股息
  bool bonusState;

  /// 自动模式圣殿黑名单
  List<int> templeBlacklist;

  /// 是否自动刮刮乐
  bool scratchState;

  /// 是否自动转化星之力
  bool autoStarPower;

  /// 是否启用混沌魔方
  bool chaosState;

  /// 混沌魔方是否使用自动模式
  bool chaosAutoMode;

  /// 混沌魔方手动消耗圣殿角色 ID
  int? chaosUseTemple;

  /// 是否启用虚空道标
  bool guidepostState;

  /// 虚空道标是否使用自动模式
  bool guidepostAutoMode;

  /// 虚空道标是否使用葛朗台模式
  bool guidepostGrandetMode;

  /// 虚空道标手动消耗圣殿角色 ID
  int? guidepostUseTemple;

  /// 虚空道标目标角色 ID
  int? guidepostTarget;

  /// 是否启用鲤鱼之眼
  bool fishState;

  /// 鲤鱼之眼是否使用自动模式
  bool fishAutoMode;

  /// 鲤鱼之眼手动消耗圣殿角色 ID
  int? fishUseTemple;

  /// 鲤鱼之眼目标角色 ID
  int? fishTarget;

  /// 是否启用 ICO 自动凑人头
  bool icoState;

  /// ICO 投入金额
  double icoInvestmentAmount;

  /// ICO 保留金额
  double icoReserveAmount;

  /// 从接口 JSON 创建 bot 配置
  ///
  /// [json] 接口返回的 data 字段
  factory BotConfig.fromJson(Map<String, Object?> json) {
    return BotConfig(
      userId: _asString(json['userId']),
      nickname: _asString(json['nickname']),
      state: json['state'],
      dailyState: _asBool(json['dailyState']),
      bonusState: _asBool(json['bonusState']),
      templeBlacklist: _asIntList(json['templeBlacklist']),
      scratchState: _asBool(json['scratchState']),
      autoStarPower: _asBool(json['autoStarPower']),
      chaosState: _asBool(json['chaosState']),
      chaosAutoMode: _asBool(json['chaosAutoMode']),
      chaosUseTemple: _asNullableInt(json['chaosUseTemple']),
      guidepostState: _asBool(json['guidepostState']),
      guidepostAutoMode: _asBool(json['guidepostAutoMode']),
      guidepostGrandetMode: _asBool(json['guidepostGrandetMode']),
      guidepostUseTemple: _asNullableInt(json['guidepostUseTemple']),
      guidepostTarget: _asNullableInt(json['guidepostTarget']),
      fishState: _asBool(json['fishState']),
      fishAutoMode: _asBool(json['fishAutoMode']),
      fishUseTemple: _asNullableInt(json['fishUseTemple']),
      fishTarget: _asNullableInt(json['fishTarget']),
      icoState: _asBool(json['icoState']),
      icoInvestmentAmount: _asDouble(json['icoInvestmentAmount'], 5000),
      icoReserveAmount: _asDouble(json['icoReserveAmount'], 0),
    );
  }

  /// 转换为保存接口表单字段
  List<MapEntry<String, String>> toFormFields() {
    final fields = <MapEntry<String, String>>[
      MapEntry('Name', userId),
      MapEntry('DailyState', dailyState.toString()),
      MapEntry('BonusState', bonusState.toString()),
      MapEntry('ScratchState', scratchState.toString()),
      MapEntry('AutoStarPower', autoStarPower.toString()),
      MapEntry('ChaosState', chaosState.toString()),
      MapEntry('ChaosAutoMode', chaosAutoMode.toString()),
      MapEntry('ChaosUseTemple', _idForForm(chaosUseTemple)),
      MapEntry('GuidepostState', guidepostState.toString()),
      MapEntry('GuidepostAutoMode', guidepostAutoMode.toString()),
      MapEntry('GuidepostGrandetMode', guidepostGrandetMode.toString()),
      MapEntry('GuidepostUseTemple', _idForForm(guidepostUseTemple)),
      MapEntry('GuidepostTarget', _idForForm(guidepostTarget)),
      MapEntry('FishState', fishState.toString()),
      MapEntry('FishAutoMode', fishAutoMode.toString()),
      MapEntry('FishUseTemple', _idForForm(fishUseTemple)),
      MapEntry('FishTarget', _idForForm(fishTarget)),
      MapEntry('IcoState', icoState.toString()),
      MapEntry('IcoInvestmentAmount', icoInvestmentAmount.toString()),
      MapEntry('IcoReserveAmount', icoReserveAmount.toString()),
    ];

    for (final characterId in templeBlacklist) {
      fields.add(MapEntry('TempleBlacklist', characterId.toString()));
    }

    return fields;
  }

  /// 转换表单 ID 字段
  ///
  /// [value] 原始 ID
  static String _idForForm(int? value) {
    if (value == null || value == 0) {
      return '';
    }

    return value.toString();
  }
}

/// bot 圣殿选择项
class BotTempleOption {
  /// 创建 bot 圣殿选择项
  ///
  /// [characterId] 圣殿角色 ID
  /// [name] 圣殿角色名称
  /// [assets] 固定资产数量
  /// [sacrifices] 精炼数量
  /// [level] 圣殿等级
  /// [avatar] 用户头像地址
  /// [cover] 圣殿封面地址
  /// [characterLevel] 角色等级
  /// [zeroCount] ST 等级
  /// [starForces] 圣殿星之力
  /// [refine] 精炼等级
  const BotTempleOption({
    required this.characterId,
    required this.name,
    required this.assets,
    required this.sacrifices,
    required this.level,
    this.avatar = '',
    this.cover = '',
    this.characterLevel = 0,
    this.zeroCount = 0,
    this.starForces = 0,
    this.refine = 0,
  });

  /// 圣殿角色 ID
  final int characterId;

  /// 圣殿角色名称
  final String name;

  /// 固定资产数量
  final double assets;

  /// 精炼数量
  final double sacrifices;

  /// 圣殿等级
  final int level;

  /// 用户头像地址
  final String avatar;

  /// 圣殿封面地址
  final String cover;

  /// 角色等级
  final int characterLevel;

  /// ST 等级
  final int zeroCount;

  /// 圣殿星之力
  final int starForces;

  /// 精炼等级
  final int refine;

  /// 从接口 JSON 创建圣殿选择项
  ///
  /// [json] 接口返回的圣殿条目
  factory BotTempleOption.fromJson(Map<String, Object?> json) {
    return BotTempleOption(
      characterId: _asInt(_jsonField(json, 'characterId', 'CharacterId')),
      name: _asString(_jsonField(json, 'name', 'Name')),
      assets: _asDouble(_jsonField(json, 'assets', 'Assets'), 0),
      sacrifices: _asDouble(_jsonField(json, 'sacrifices', 'Sacrifices'), 0),
      level: _asInt(_jsonField(json, 'level', 'Level')),
      avatar: _asString(_jsonField(json, 'avatar', 'Avatar')),
      cover: _asString(_jsonField(json, 'cover', 'Cover')),
      characterLevel: _asInt(
        _jsonField(json, 'characterLevel', 'CharacterLevel'),
      ),
      zeroCount: _asInt(_jsonField(json, 'zeroCount', 'ZeroCount')),
      starForces: _asInt(_jsonField(json, 'starForces', 'StarForces')),
      refine: _asInt(_jsonField(json, 'refine', 'Refine')),
    );
  }
}

/// bot 角色选择项
class BotCharacterOption {
  /// 创建 bot 角色选择项
  ///
  /// [characterId] 角色 ID
  /// [name] 角色名称
  /// [level] 角色等级
  /// [icon] 角色头像地址
  const BotCharacterOption({
    required this.characterId,
    required this.name,
    required this.level,
    this.icon = '',
  });

  /// 角色 ID
  final int characterId;

  /// 角色名称
  final String name;

  /// 角色等级
  final int level;

  /// 角色头像地址
  final String icon;
}

/// bot 操作日志条目
class BotLogEntry {
  /// 创建 bot 操作日志条目
  ///
  /// [logType] 日志类型
  /// [message] 日志正文
  /// [date] 日志时间
  const BotLogEntry({
    required this.logType,
    required this.message,
    required this.date,
  });

  /// 日志类型
  final int logType;

  /// 日志正文
  final String message;

  /// 日志时间
  final DateTime? date;

  /// 从接口 JSON 创建操作日志条目
  ///
  /// [json] 接口返回的日志条目
  factory BotLogEntry.fromJson(Map<String, Object?> json) {
    return BotLogEntry(
      logType: _asInt(json['logType']),
      message: _asString(json['message']),
      date: DateTime.tryParse(_asString(json['date'])),
    );
  }
}

/// 读取接口字段并兼容大小写命名
///
/// [json] 接口返回对象
/// [camelName] 小驼峰字段名
/// [pascalName] 大驼峰字段名
Object? _jsonField(
  Map<String, Object?> json,
  String camelName,
  String pascalName,
) {
  return json[camelName] ?? json[pascalName];
}

/// 转换字符串值
///
/// [value] 原始值
String _asString(Object? value) {
  if (value is String) {
    return value;
  }

  return value?.toString() ?? '';
}

/// 转换布尔值
///
/// [value] 原始值
bool _asBool(Object? value) {
  if (value is bool) {
    return value;
  }

  if (value is num) {
    return value != 0;
  }

  if (value is String) {
    final normalized = value.toLowerCase().trim();
    return normalized == 'true' || normalized == '1';
  }

  return false;
}

/// 转换整数值
///
/// [value] 原始值
int _asInt(Object? value) {
  return _asNullableInt(value) ?? 0;
}

/// 转换可空整数值
///
/// [value] 原始值
int? _asNullableInt(Object? value) {
  if (value is int) {
    return value == 0 ? null : value;
  }

  if (value is double) {
    final intValue = value.toInt();
    return intValue == 0 ? null : intValue;
  }

  if (value is String) {
    final intValue = int.tryParse(value);
    if (intValue == null || intValue == 0) {
      return null;
    }

    return intValue;
  }

  return null;
}

/// 转换浮点值
///
/// [value] 原始值
/// [fallback] 兜底值
double _asDouble(Object? value, double fallback) {
  if (value is double) {
    return value;
  }

  if (value is int) {
    return value.toDouble();
  }

  if (value is String) {
    return double.tryParse(value.replaceAll(',', '')) ?? fallback;
  }

  return fallback;
}

/// 转换整数列表
///
/// [value] 原始值
List<int> _asIntList(Object? value) {
  if (value is! List) {
    return const <int>[];
  }

  return value.map(_asNullableInt).whereType<int>().toList(growable: false);
}
