import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/core/utils/formatters.dart';
import 'package:magrail_app/core/utils/tinygrail_asset_urls.dart';
import 'package:magrail_app/core/utils/tinygrail_formatters.dart';
import 'package:magrail_app/core/widgets/app_load_failed_state.dart';
import 'package:magrail_app/core/widgets/character_avatar.dart';
import 'package:magrail_app/core/widgets/pagination_footer.dart';
import 'package:magrail_app/core/widgets/secondary_page_refresh_view.dart';
import 'package:magrail_app/features/chara/detail/character_detail_hero.dart';
import 'package:magrail_app/features/chara/detail/character_detail_navigation.dart';
import 'package:magrail_app/features/chara/tower/controller/tower_log_controller.dart';
import 'package:magrail_app/features/chara/tower/model/tower_log_api_item.dart';
import 'package:skeletonizer/skeletonizer.dart';

part 'tower_log_content.dart';
part 'tower_log_item.dart';
part 'tower_log_states.dart';

const double _towerLogHorizontalPadding = 12;
const double _towerLogAvatarSize = 40;
const double _towerLogAvatarTextGap = 10;
const double _towerLogDividerIndent =
    _towerLogHorizontalPadding + _towerLogAvatarSize + _towerLogAvatarTextGap;

/// 通天塔日志页面内容面板
class TowerLogPanel extends StatelessWidget {
  /// 创建通天塔日志页面内容面板
  ///
  /// [key] Flutter 组件标识
  /// [controller] 通天塔日志控制器
  /// [scrollController] 日志列表滚动控制器
  /// [onHistoryItemBuilt] 历史日志条目构建回调
  const TowerLogPanel({
    super.key,
    required this.controller,
    required this.scrollController,
    required this.onHistoryItemBuilt,
  });

  /// 通天塔日志控制器
  final TowerLogController controller;

  /// 日志列表滚动控制器
  final ScrollController scrollController;

  /// 历史日志条目构建回调
  final ValueChanged<int> onHistoryItemBuilt;

  /// 构建通天塔日志页面内容面板
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        final isStateOnlyContent = !controller.isInitialLoading &&
            (controller.initialError != null ||
                (controller.realtimeItems.isEmpty &&
                    controller.historyItems.isEmpty &&
                    !controller.hasLargeRealtimeUpdate));

        return SecondaryPageRefreshView(
          title: '通天塔日志',
          onRefresh: controller.refreshLatest,
          scrollController: scrollController,
          slivers: [
            if (controller.hasLargeRealtimeUpdate)
              SliverToBoxAdapter(
                child: Padding(
                  padding: AppSafeAreaInsets.fromLTRB(
                    context,
                    left: _towerLogHorizontalPadding,
                    top: 10,
                    right: _towerLogHorizontalPadding,
                    bottom: 10,
                  ),
                  child: _TowerLogLargeUpdateBanner(
                    count: controller.realtimeUpdateCount,
                    onRefresh: controller.refreshLatest,
                  ),
                ),
              ),
            ..._TowerLogContent(
              controller: controller,
              onHistoryItemBuilt: onHistoryItemBuilt,
            ).buildSlivers(context),
            if (!isStateOnlyContent)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 16 + MediaQuery.paddingOf(context).bottom,
                ),
              ),
          ],
        );
      },
    );
  }
}
