import 'dart:async';

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:magrail_app/core/network/tinygrail_page.dart';
import 'package:magrail_app/core/theme/app_blur_style.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/core/utils/formatters.dart';
import 'package:magrail_app/core/utils/tinygrail_asset_urls.dart';
import 'package:magrail_app/core/utils/tinygrail_formatters.dart';
import 'package:magrail_app/core/widgets/app_bottom_sheet_drag_handle.dart';
import 'package:magrail_app/core/widgets/app_load_failed_state.dart';
import 'package:magrail_app/core/widgets/pagination_footer_sliver.dart';
import 'package:magrail_app/core/widgets/temple_card.dart';
import 'package:magrail_app/features/bot/model/bot_models.dart';
import 'package:magrail_app/features/chara/detail/repository/character_detail_repository.dart';
import 'package:magrail_app/features/temple/model/temple_asset_magic_assets.dart';
import 'package:magrail_app/features/temple/widgets/temple_asset_magic_character_search_panel.dart';
import 'package:magrail_app/features/user/repository/user_repository.dart';
import 'package:skeletonizer/skeletonizer.dart';

part 'bot_magic_character_picker_sheet.dart';
part 'bot_temple_blacklist_sheet_widgets.dart';
part 'bot_temple_picker_sheet.dart';

const double _botTempleBlacklistGridSpacing = 10;
const double _botTempleBlacklistMinTileWidth = 132;
const double _botTempleBlacklistBodyVisibleMinHeight = 160;
const int _botTempleBlacklistPageSize = 20;

/// 混沌魔方道具图标资源
const String botChaosCubeActionIconAsset =
    TempleAssetMagicAssets.chaosCubeIcon;

/// 虚空道标道具图标资源
const String botGuidepostActionIconAsset =
    TempleAssetMagicAssets.guidepostIcon;

/// 鲤鱼之眼道具图标资源
const String botFisheyeActionIconAsset = TempleAssetMagicAssets.fisheyeIcon;

/// bot 圣殿分页搜索加载回调
typedef BotTemplePagedSearchLoader = Future<TinygrailPage<BotTempleOption>>
    Function({
  required int page,
  required int pageSize,
  required String keyword,
});

/// 打开 bot 圣殿单选抽屉
///
/// [context] 当前组件树上下文
/// [title] 抽屉标题
/// [search] 圣殿分页搜索回调
/// [selected] 当前已选圣殿
/// [imageAsset] 标题图片资源
/// [fallbackIcon] 标题图片失败图标
Future<BotTempleOption?> showBotTemplePickerSheet(
  BuildContext context, {
  required String title,
  required BotTemplePagedSearchLoader search,
  required String imageAsset,
  required IconData fallbackIcon,
  BotTempleOption? selected,
}) {
  return showModalBottomSheet<BotTempleOption>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    showDragHandle: false,
    elevation: 0,
    constraints: BoxConstraints.tightFor(
      width: MediaQuery.sizeOf(context).width,
    ),
    builder: (context) {
      final mediaQuery = MediaQuery.of(context);
      const topGap = 32.0;
      final availableHeight =
          mediaQuery.size.height - mediaQuery.padding.top - topGap;
      final heightCap = mediaQuery.size.height *
          (mediaQuery.orientation == Orientation.landscape ? 0.9 : 0.86);
      final maxHeight = availableHeight.clamp(0.0, heightCap).toDouble();

      return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: _BotTempleMultiSearchSheet(
          title: title,
          headerSubtitle: '消耗圣殿',
          description: '选择手动模式消耗的圣殿',
          emptyText: selected == null ? '输入关键词搜索圣殿' : '暂无已选圣殿',
          icon: fallbackIcon,
          imageAsset: imageAsset,
          useErrorColor: false,
          search: search,
          selected: selected == null
              ? const <BotTempleOption>[]
              : <BotTempleOption>[selected],
          onSelected: (item) => Navigator.of(context).pop(item),
        ),
      );
    },
  );
}

/// 打开 bot 圣殿多选抽屉
///
/// [context] 当前组件树上下文
/// [title] 抽屉标题
/// [search] 圣殿分页搜索回调
/// [selected] 当前已选圣殿列表
/// [onChanged] 选择变更回调
Future<void> showBotTempleMultiPickerSheet(
  BuildContext context, {
  required String title,
  required BotTemplePagedSearchLoader search,
  required List<BotTempleOption> selected,
  required ValueChanged<List<BotTempleOption>> onChanged,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    showDragHandle: false,
    elevation: 0,
    constraints: BoxConstraints.tightFor(
      width: MediaQuery.sizeOf(context).width,
    ),
    builder: (context) {
      final mediaQuery = MediaQuery.of(context);
      const topGap = 32.0;
      final availableHeight =
          mediaQuery.size.height - mediaQuery.padding.top - topGap;
      final heightCap = mediaQuery.size.height *
          (mediaQuery.orientation == Orientation.landscape ? 0.9 : 0.86);
      final maxHeight = availableHeight.clamp(0.0, heightCap).toDouble();

      return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: _BotTempleMultiSearchSheet(
          title: title,
          headerSubtitle: '已选择 ${selected.length} 个圣殿',
          description: '选择不参与自动模式消耗的圣殿',
          emptyText: '暂无已选圣殿',
          icon: Icons.block_rounded,
          imageAsset: '',
          useErrorColor: true,
          search: search,
          selected: selected,
          onChanged: onChanged,
        ),
      );
    },
  );
}

/// 打开 bot 魔法道具目标角色抽屉
///
/// [context] 当前组件树上下文
/// [title] 抽屉标题
/// [description] 抽屉说明文案
/// [currentUserName] 当前登录用户名
/// [recentStorageKeyPrefix] 最近使用缓存键前缀
/// [characterRepository] 角色仓库
/// [userRepository] 用户仓库
/// [imageAsset] 标题图片资源
/// [fallbackIcon] 标题图片失败图标
/// [secondaryTextBuilder] 第二行文案构造器
/// [supplementLoader] 静默附加数值加载器
Future<BotCharacterOption?> showBotMagicCharacterPickerSheet(
  BuildContext context, {
  required String title,
  required String description,
  required String currentUserName,
  required String recentStorageKeyPrefix,
  required CharacterDetailRepository characterRepository,
  required UserRepository userRepository,
  required String imageAsset,
  required IconData fallbackIcon,
  TempleAssetMagicSearchSecondaryTextBuilder secondaryTextBuilder =
      TempleAssetMagicCharacterSearchPanel.defaultSecondaryText,
  TempleAssetMagicSearchSupplementLoader? supplementLoader,
}) {
  return showModalBottomSheet<BotCharacterOption>(
    context: context,
    isScrollControlled: true,
    showDragHandle: false,
    backgroundColor: Colors.transparent,
    elevation: 0,
    constraints: BoxConstraints.tightFor(
      width: MediaQuery.sizeOf(context).width,
    ),
    builder: (context) {
      final mediaQuery = MediaQuery.of(context);
      const topGap = 32.0;
      final availableHeight =
          mediaQuery.size.height - mediaQuery.padding.top - topGap;
      final heightCap = mediaQuery.size.height *
          (mediaQuery.orientation == Orientation.landscape ? 0.9 : 0.86);
      final maxHeight = availableHeight.clamp(0.0, heightCap).toDouble();

      return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: _BotMagicCharacterSearchSheet(
          title: title,
          description: description,
          currentUserName: currentUserName,
          recentStorageKeyPrefix: recentStorageKeyPrefix,
          characterRepository: characterRepository,
          userRepository: userRepository,
          imageAsset: imageAsset,
          fallbackIcon: fallbackIcon,
          secondaryTextBuilder: secondaryTextBuilder,
          supplementLoader: supplementLoader,
        ),
      );
    },
  );
}
