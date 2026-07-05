import 'package:flutter/material.dart';
import 'package:magrail_app/core/theme/app_blur_style.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/core/viewer/fullscreen_image_viewer_page.dart';
import 'package:magrail_app/core/widgets/level_badge.dart';
import 'package:magrail_app/core/widgets/snapping_horizontal_list_view.dart';
import 'package:magrail_app/core/widgets/temple_cover_image.dart';
import 'package:magrail_app/features/chara/top_week/model/top_week_entry.dart';
import 'package:skeletonizer/skeletonizer.dart';

part 'top_week_card.dart';
part 'top_week_skeleton.dart';

/// 每周萌王横向轮播
class TopWeekCarousel extends StatelessWidget {
  /// 创建每周萌王横向轮播
  ///
  /// [key] Flutter 组件标识
  /// [entries] 每周萌王条目
  /// [isLoading] 是否正在首次加载
  /// [onCharacterPressed] 角色详情点击回调
  /// [onAuctionPressed] 拍卖按钮点击回调
  const TopWeekCarousel({
    super.key,
    required this.entries,
    required this.isLoading,
    required this.onCharacterPressed,
    required this.onAuctionPressed,
  });

  /// 每周萌王条目
  final List<TopWeekEntry>? entries;

  /// 是否正在首次加载
  final bool isLoading;

  /// 角色详情点击回调
  final ValueChanged<TopWeekEntry> onCharacterPressed;

  /// 拍卖按钮点击回调
  final ValueChanged<TopWeekEntry> onAuctionPressed;

  /// 构建每周萌王横向轮播
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    if (isLoading && entries == null) {
      return const _TopWeekSkeletonCarousel();
    }

    final visibleEntries = entries ?? const <TopWeekEntry>[];

    return SnappingHorizontalListView(
      height: 364,
      itemCount: visibleEntries.length,
      itemExtent: _TopWeekCard.cardWidth,
      separatorExtent: 12,
      padding: AppSafeAreaInsets.symmetricHorizontal(
        context,
        horizontal: 24,
        vertical: 6,
      ),
      clipBehavior: Clip.none,
      itemBuilder: (context, index) {
        return _TopWeekCard(
          entry: visibleEntries[index],
          onCharacterPressed: onCharacterPressed,
          onAuctionPressed: onAuctionPressed,
        );
      },
    );
  }
}
