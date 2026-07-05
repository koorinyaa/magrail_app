import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:magrail_app/core/theme/app_blur_style.dart';
import 'package:magrail_app/core/utils/formatters.dart';
import 'package:magrail_app/core/utils/tinygrail_asset_urls.dart';
import 'package:magrail_app/core/utils/tinygrail_formatters.dart';
import 'package:magrail_app/core/utils/user_error_message.dart';
import 'package:magrail_app/core/widgets/app_load_failed_state.dart';
import 'package:magrail_app/core/widgets/character_avatar.dart';
import 'package:magrail_app/core/widgets/level_badge.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_search_item.dart';
import 'package:magrail_app/features/chara/detail/repository/character_detail_repository.dart';
import 'package:magrail_app/features/user/model/user_character_api_item.dart';
import 'package:magrail_app/features/user/repository/user_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';

part 'magic_character_search_panel/temple_asset_magic_character_search_panel_state.dart';
part 'magic_character_search_panel/temple_asset_magic_character_search_data.dart';
part 'magic_character_search_panel/temple_asset_magic_character_search_models.dart';
part 'magic_character_search_panel/temple_asset_magic_character_search_rows.dart';

const int _magicSearchPageSize = 20;
const int _recentMagicCharacterLimit = 5;
const double _searchBodyVisibleMinHeight = 160;

/// 魔法道具角色搜索附加数值加载器
///
/// [items] 当前批次角色搜索条目
typedef TempleAssetMagicSearchSupplementLoader = Future<Map<int, int>> Function(
  List<TempleAssetMagicCharacterSearchItem> items,
);

/// 魔法道具角色搜索第二行文案构造器
///
/// [item] 角色搜索条目
/// [supplementValue] 当前角色附加数值
typedef TempleAssetMagicSearchSecondaryTextBuilder = String Function(
  TempleAssetMagicCharacterSearchItem item,
  int? supplementValue,
);

/// 魔法道具角色搜索选择回调
///
/// [item] 角色搜索条目
/// [supplementValue] 当前角色附加数值
typedef TempleAssetMagicSearchSelected = void Function(
  TempleAssetMagicCharacterSearchItem item,
  int? supplementValue,
);

/// 保存魔法道具角色搜索最近使用记录
///
/// [storageKeyPrefix] 本地缓存键前缀
/// [username] 当前登录用户名
/// [characterId] 最近使用的角色 ID
Future<void> saveTempleAssetMagicRecentCharacterId({
  required String storageKeyPrefix,
  required String username,
  required int characterId,
}) async {
  final trimmedUsername = username.trim();
  if (storageKeyPrefix.trim().isEmpty ||
      trimmedUsername.isEmpty ||
      characterId <= 0) {
    return;
  }

  final records = await _readRecentMagicCharacterRecords(
    storageKeyPrefix: storageKeyPrefix,
    username: trimmedUsername,
  );
  final nextRecords = <_MagicRecentCharacterRecord>[
    _MagicRecentCharacterRecord(
      characterId: characterId,
      usedAt: DateTime.now().toUtc().toIso8601String(),
    ),
    ...records.where((record) => record.characterId != characterId),
  ].take(_recentMagicCharacterLimit).toList(growable: false);
  final preferences = await SharedPreferences.getInstance();
  await preferences.setStringList(
    _recentMagicCharacterIdsKey(
      storageKeyPrefix: storageKeyPrefix,
      username: trimmedUsername,
    ),
    nextRecords.map((record) => record.toStorage()).toList(growable: false),
  );
}

/// 魔法道具角色搜索面板
class TempleAssetMagicCharacterSearchPanel extends StatefulWidget {
  /// 创建魔法道具角色搜索面板
  ///
  /// [header] 顶部标题区域
  /// [hintText] 搜索列表提示文案
  /// [currentUserName] 当前登录用户名
  /// [recentStorageKeyPrefix] 最近使用缓存键前缀
  /// [characterRepository] 角色详情仓库
  /// [userRepository] 用户仓库
  /// [onSelected] 角色选择回调
  /// [secondaryTextBuilder] 第二行文案构造器
  /// [supplementLoader] 静默附加数值加载器
  const TempleAssetMagicCharacterSearchPanel({
    required this.header,
    required this.hintText,
    required this.currentUserName,
    required this.recentStorageKeyPrefix,
    required this.characterRepository,
    required this.userRepository,
    required this.onSelected,
    this.secondaryTextBuilder = defaultSecondaryText,
    this.supplementLoader,
    super.key,
  });

  /// 顶部标题区域
  final Widget header;

  /// 搜索列表提示文案
  final String hintText;

  /// 当前登录用户名
  final String currentUserName;

  /// 最近使用缓存键前缀
  final String recentStorageKeyPrefix;

  /// 角色详情仓库
  final CharacterDetailRepository characterRepository;

  /// 用户仓库
  final UserRepository userRepository;

  /// 角色选择回调
  final TempleAssetMagicSearchSelected onSelected;

  /// 第二行文案构造器
  final TempleAssetMagicSearchSecondaryTextBuilder secondaryTextBuilder;

  /// 静默附加数值加载器
  final TempleAssetMagicSearchSupplementLoader? supplementLoader;

  /// 默认第二行文案
  ///
  /// [item] 角色搜索条目
  /// [supplementValue] 当前角色附加数值
  static String defaultSecondaryText(
    TempleAssetMagicCharacterSearchItem item,
    int? supplementValue,
  ) {
    return '持股 ${Formatters.groupedNumber(math.max(0, item.userTotal))}';
  }

  /// 创建魔法道具角色搜索面板状态
  @override
  TempleAssetMagicCharacterSearchPanelState createState() =>
      TempleAssetMagicCharacterSearchPanelState();
}
