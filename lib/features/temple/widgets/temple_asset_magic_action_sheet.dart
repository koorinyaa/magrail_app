import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:magrail_app/core/feedback/app_toast.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/core/utils/formatters.dart';
import 'package:magrail_app/core/utils/tinygrail_asset_urls.dart';
import 'package:magrail_app/core/utils/tinygrail_formatters.dart';
import 'package:magrail_app/core/utils/user_error_message.dart';
import 'package:magrail_app/core/widgets/app_bottom_sheet_drag_handle.dart';
import 'package:magrail_app/core/widgets/app_confirm_dialog.dart';
import 'package:magrail_app/core/widgets/character_avatar.dart';
import 'package:magrail_app/core/widgets/temple_cover_image.dart';
import 'package:magrail_app/features/chara/model/tinygrail_character_reward_item.dart';
import 'package:magrail_app/features/chara/widgets/tinygrail_character_reward_card.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_search_item.dart';
import 'package:magrail_app/features/temple/controller/temple_asset_magic_action_controller.dart';
import 'package:magrail_app/features/temple/model/temple_asset_card_data.dart';
import 'package:magrail_app/features/temple/model/temple_asset_magic_assets.dart';
import 'package:magrail_app/features/temple/widgets/temple_asset_magic_character_search_panel.dart';

part 'magic_action_sheet/temple_asset_magic_confirm_contents.dart';
part 'magic_action_sheet/temple_asset_magic_stardust_confirm_contents.dart';
part 'magic_action_sheet/temple_asset_magic_previews.dart';
part 'magic_action_sheet/temple_asset_magic_result_dialog.dart';
part 'magic_action_sheet/temple_asset_magic_controls.dart';
part 'magic_action_sheet/temple_asset_magic_stats.dart';
part 'magic_action_sheet/temple_asset_magic_action_sheet_state.dart';
part 'magic_action_sheet/temple_asset_magic_chaos_flow.dart';
part 'magic_action_sheet/temple_asset_magic_guidepost_flow.dart';
part 'magic_action_sheet/temple_asset_magic_starbreak_flow.dart';
part 'magic_action_sheet/temple_asset_magic_stardust_flow.dart';
part 'magic_action_sheet/temple_asset_magic_search_config.dart';
part 'magic_action_sheet/temple_asset_magic_submit_logic.dart';
part 'magic_action_sheet/temple_asset_magic_state_queries.dart';
part 'magic_action_sheet/temple_asset_magic_dialog_flow.dart';

/// 圣殿资产魔法道具操作类型
enum TempleAssetMagicAction {
  /// 虚空道标
  guidepost,

  /// 混沌魔方
  chaosCube,

  /// 鲤鱼之眼
  fisheye,

  /// 星光碎片
  stardust,

  /// 闪光结晶
  starbreak,

  /// 星之力
  starForces,
}

/// 显示圣殿资产魔法道具操作底部抽屉
///
/// [context] 当前组件树上下文
/// [action] 操作类型
/// [data] 圣殿资产卡片展示数据
Future<void> showTempleAssetMagicActionSheet(
  BuildContext context, {
  required TempleAssetMagicAction action,
  required TempleAssetCardData data,
}) {
  final actionContext = data.actionContext;
  if (actionContext == null) {
    AppToast.error(context, text: '缺少操作上下文');
    return Future<void>.value();
  }

  return showModalBottomSheet<void>(
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
      // 列表型抽屉保留顶部拖拽空间，避免内容贴到屏幕顶部
      final heightCap = mediaQuery.size.height *
          (mediaQuery.orientation == Orientation.landscape ? 0.9 : 0.86);
      final maxHeight = availableHeight.clamp(0.0, heightCap).toDouble();

      return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: _TempleAssetMagicActionSheet(
          action: action,
          data: data,
        ),
      );
    },
  );
}

/// 圣殿资产魔法道具操作底部抽屉
class _TempleAssetMagicActionSheet extends StatefulWidget {
  /// 创建圣殿资产魔法道具操作底部抽屉
  ///
  /// [action] 操作类型
  /// [data] 圣殿资产卡片展示数据
  const _TempleAssetMagicActionSheet({
    required this.action,
    required this.data,
  });

  /// 操作类型
  final TempleAssetMagicAction action;

  /// 圣殿资产卡片展示数据
  final TempleAssetCardData data;

  /// 创建圣殿资产魔法道具操作底部抽屉状态
  @override
  State<_TempleAssetMagicActionSheet> createState() =>
      _TempleAssetMagicActionSheetState();
}
