import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:magrail_app/core/feedback/app_toast.dart';
import 'package:magrail_app/core/theme/app_blur_style.dart';
import 'package:magrail_app/core/utils/formatters.dart';
import 'package:magrail_app/core/utils/tinygrail_asset_urls.dart';
import 'package:magrail_app/core/utils/tinygrail_formatters.dart';
import 'package:magrail_app/core/viewer/fullscreen_image_viewer_page.dart';
import 'package:magrail_app/core/widgets/level_badge.dart';
import 'package:magrail_app/core/widgets/temple_cover_image.dart';
import 'package:magrail_app/features/temple/model/temple_asset_card_data.dart';
import 'package:magrail_app/features/temple/widgets/temple_asset_cover_reset_flow.dart';
import 'package:magrail_app/features/temple/widgets/temple_asset_cover_update_flow.dart';
import 'package:magrail_app/features/temple/widgets/temple_asset_destroy_flow.dart';
import 'package:magrail_app/features/temple/widgets/temple_asset_line_update_flow.dart';
import 'package:magrail_app/features/temple/widgets/temple_asset_link_sheet.dart';
import 'package:magrail_app/features/temple/widgets/temple_asset_magic_action_sheet.dart';
import 'package:magrail_app/features/temple/widgets/temple_asset_refine_sheet.dart';
import 'package:skeletonizer/skeletonizer.dart';

part 'temple_asset_card_actions.dart';
part 'temple_asset_card_layout.dart';
part 'temple_asset_card_metrics.dart';
part 'temple_asset_card_skeleton.dart';
part 'temple_asset_card_visual.dart';

// 圣殿资产卡片封面保持接近 3:4 比例，右侧数据区使用同一高度对齐
const double _templeAssetThumbnailWidth = 112;
const double _templeAssetThumbnailHeight = 150;
const double _templeAssetVisualHeight = _templeAssetThumbnailHeight;
// LINK 堆叠在原缩略图宽高内偏移，避免挤压右侧信息区
const double _templeAssetLinkedThumbnailXOffset = 8;
const double _templeAssetLinkedThumbnailYOffset = 10;
const double _templeAssetLinkedThumbnailWidth =
    _templeAssetThumbnailWidth - _templeAssetLinkedThumbnailXOffset;
const double _templeAssetLinkedThumbnailHeight =
    _templeAssetThumbnailHeight - _templeAssetLinkedThumbnailYOffset;
// 内部圣殿封面圆角小于外部卡片，保持嵌套层级
const double _templeAssetThumbnailRadius = 12;
// 用户昵称水印最大宽度，顶部主文案会按该宽度预留空间
const double _templeAssetWatermarkMaxWidth = 96;
const double _templeAssetWatermarkGap = 8;

// Tinygrail 圣殿道具操作使用站点静态图标
const String _templeActionPostIconUrl =
    'https://tinygrail.mange.cn/image/sign.png!w120';
const String _templeActionChaosCubeIconUrl =
    'https://tinygrail.mange.cn/image/cube.png!w120';
const String _templeActionFisheyeIconUrl =
    'https://tinygrail.mange.cn/image/eye2.png!w120';
const String _templeActionStardustIconUrl =
    'https://tinygrail.mange.cn/image/star.png!w120';
const String _templeActionAttackIconUrl =
    'https://tinygrail.mange.cn/image/fire.png!w120';

/// 圣殿资产卡片
class TempleAssetCard extends StatelessWidget {
  /// 创建圣殿资产卡片
  ///
  /// [key] Flutter 组件标识
  /// [data] 圣殿资产卡片展示数据
  /// [enableCoverPreview] 是否允许点击圣殿封面查看大图
  const TempleAssetCard({
    super.key,
    required this.data,
    this.enableCoverPreview = true,
  });

  /// 圣殿资产卡片展示数据
  final TempleAssetCardData data;

  /// 是否允许点击圣殿封面查看大图
  final bool enableCoverPreview;

  /// 构建圣殿资产卡片
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return _TempleAssetMediaCard(
      visual: SizedBox(
        width: _templeAssetThumbnailWidth,
        child: _TempleAssetVisual(
          data: data,
          enableCoverPreview: enableCoverPreview,
        ),
      ),
      metrics: _TempleAssetMetrics(
        data: data,
        reservedTrailingWidth: data.watermarkText.trim().isNotEmpty
            ? _templeAssetWatermarkMaxWidth + _templeAssetWatermarkGap
            : 0,
      ),
      actions: _TempleAssetActions(data: data),
      watermarkText: data.watermarkText,
      showActions: data.hasVisibleActions,
    );
  }
}

/// 圣殿资产卡片加载骨架
class TempleAssetCardSkeleton extends StatelessWidget {
  /// 创建圣殿资产卡片加载骨架
  ///
  /// [key] Flutter 组件标识
  /// [showActions] 是否显示底部圣殿操作区骨架
  /// [showResetAction] 是否只显示重置圣殿图片骨架
  const TempleAssetCardSkeleton({
    super.key,
    this.showActions = true,
    this.showResetAction = false,
  });

  /// 是否显示底部圣殿操作区骨架
  final bool showActions;

  /// 是否只显示重置圣殿图片骨架
  final bool showResetAction;

  /// 构建圣殿资产卡片加载骨架
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Skeletonizer.zone(
      child: _TempleAssetMediaCard(
        visual: const SizedBox(
          width: _templeAssetThumbnailWidth,
          height: _templeAssetVisualHeight,
          child: Bone(
            width: double.infinity,
            height: double.infinity,
            borderRadius: BorderRadius.all(
              Radius.circular(_templeAssetThumbnailRadius),
            ),
          ),
        ),
        metrics: const _TempleAssetSkeletonMetrics(),
        actions: _TempleAssetActionsSkeleton(
          showResetAction: showResetAction && !showActions,
        ),
        watermarkText: '',
        showActions: showActions || showResetAction,
      ),
    );
  }
}

/// 解析圣殿等级主题色
///
/// [level] 圣殿等级
Color _templeLevelColor(int level) {
  return switch (level) {
    2 => const Color(0xFFEAB308),
    3 => const Color(0xFFA855F7),
    _ => const Color(0xFF9CA3AF),
  };
}
