import 'package:flutter/material.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/core/utils/formatters.dart';
import 'package:magrail_app/core/utils/tinygrail_asset_urls.dart';
import 'package:magrail_app/core/utils/tinygrail_formatters.dart';
import 'package:magrail_app/core/utils/tinygrail_ico_time.dart';
import 'package:magrail_app/features/chara/detail/character_detail_hero.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_ico_prediction.dart';
import 'package:magrail_app/features/chara/widgets/character_asset_chips.dart';
import 'package:magrail_app/features/chara/widgets/character_asset_preview_carousel.dart';
import 'package:magrail_app/features/chara/widgets/character_asset_row_components.dart';
import 'package:magrail_app/features/ico/model/ico_character_entry.dart';

/// ICO 角色横向预览栏
class IcoCharacterCarousel extends StatelessWidget {
  /// 创建 ICO 角色横向预览栏
  ///
  /// [key] Flutter 组件标识
  /// [items] ICO 角色预览条目
  /// [isLoading] 是否正在加载
  /// [emptyMessage] 空状态文案
  /// [onIcoTap] ICO 条目点击回调
  const IcoCharacterCarousel({
    super.key,
    required this.items,
    required this.isLoading,
    required this.emptyMessage,
    this.onIcoTap,
  });

  /// ICO 角色预览条目
  final List<IcoCharacterEntry>? items;

  /// 是否正在加载
  final bool isLoading;

  /// 空状态文案
  final String emptyMessage;

  /// ICO 条目点击回调
  final void Function(IcoCharacterEntry item, String? avatarHeroTag)? onIcoTap;

  /// 构建 ICO 角色横向预览栏
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return CharacterAssetPreviewCarousel<IcoCharacterEntry>(
      items: items,
      isLoading: isLoading,
      emptyMessage: emptyMessage,
      skeletonTrailingWidth: 84,
      itemBuilder: (context, item) {
        final avatarUrl = TinygrailAssetUrls.normalizeAvatar(item.icon);
        final avatarHeroTag = createCharacterDetailAvatarHeroTag(
          characterId: item.characterId,
          avatarUrl: avatarUrl,
          source: item,
        );

        return IcoCharacterRow(
          item: item,
          avatarHeroTag: avatarHeroTag,
          onTap: onIcoTap == null
              ? null
              : () => onIcoTap?.call(item, avatarHeroTag),
        );
      },
    );
  }
}

/// ICO 角色 sliver 列表
class IcoCharacterSliverList extends StatelessWidget {
  /// 创建 ICO 角色 sliver 列表
  ///
  /// [key] Flutter 组件标识
  /// [items] ICO 角色条目
  /// [onIcoTap] ICO 条目点击回调
  const IcoCharacterSliverList({super.key, required this.items, this.onIcoTap});

  /// ICO 角色条目
  final List<IcoCharacterEntry> items;

  /// ICO 条目点击回调
  final void Function(IcoCharacterEntry item, String? avatarHeroTag)? onIcoTap;

  /// 构建 ICO 角色 sliver 列表
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SliverFixedExtentList(
      itemExtent: _IcoCharacterListMetrics.itemExtent,
      delegate: SliverChildBuilderDelegate((context, index) {
        final item = items[index];
        final avatarUrl = TinygrailAssetUrls.normalizeAvatar(item.icon);
        final avatarHeroTag = createCharacterDetailAvatarHeroTag(
          characterId: item.characterId,
          avatarUrl: avatarUrl,
          source: item,
        );

        return CharacterAssetListItemShell(
          showDivider: index < items.length - 1,
          child: IcoCharacterRow(
            item: item,
            avatarHeroTag: avatarHeroTag,
            onTap: onIcoTap == null
                ? null
                : () => onIcoTap?.call(item, avatarHeroTag),
            contentPadding: AppSafeAreaInsets.fromLTRB(
              context,
              left: 18,
              top: 0,
              right: 18,
              bottom: 0,
            ),
            tapBorderRadius: BorderRadius.zero,
          ),
        );
      }, childCount: items.length),
    );
  }
}

/// ICO 角色行
class IcoCharacterRow extends StatelessWidget {
  /// 创建 ICO 角色行
  ///
  /// [key] Flutter 组件标识
  /// [item] ICO 角色条目
  /// [avatarHeroTag] 头像转场标识
  /// [onTap] 条目点击回调
  /// [contentPadding] 行内容内边距
  /// [tapBorderRadius] 点击反馈圆角
  const IcoCharacterRow({
    super.key,
    required this.item,
    this.avatarHeroTag,
    this.onTap,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 6),
    this.tapBorderRadius,
  });

  /// ICO 角色条目
  final IcoCharacterEntry item;

  /// 头像转场标识
  final String? avatarHeroTag;

  /// 条目点击回调
  final VoidCallback? onTap;

  /// 行内容内边距
  final EdgeInsetsGeometry contentPadding;

  /// 点击反馈圆角
  final BorderRadius? tapBorderRadius;

  /// 构建 ICO 角色行
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final avatarUrl = TinygrailAssetUrls.normalizeAvatar(item.icon);
    final prediction = CharacterDetailIcoPrediction.fromTotals(
      total: item.total,
      users: item.users,
    );
    final remainingTime = resolveTinygrailIcoRemainingTime(item.end);

    return CharacterAssetRowShell(
      name: TinygrailFormatters.decodeHtmlEntities(item.name),
      avatarUrl: avatarUrl,
      avatarHeroTag: avatarHeroTag,
      level: prediction.level,
      metrics: [
        CharacterAssetMetric(
          value:
              '${Formatters.tinygrailCurrency(item.total)} / ${_formatUsers(item.users)}人',
          isValueMuted: true,
        ),
        CharacterAssetMetric(
          value: '${prediction.percent}%',
          isValueMuted: true,
        ),
      ],
      trailing: CharacterAssetTrailingChip(
        text: remainingTime.text,
        accentColor: remainingTime.accentColor,
      ),
      onTap: onTap,
      contentPadding: contentPadding,
      tapBorderRadius: tapBorderRadius,
    );
  }

  /// 格式化 ICO 参与人数
  ///
  /// [value] 原始人数
  String _formatUsers(int value) {
    if (value <= 0) {
      return '0';
    }

    return Formatters.groupedNumber(value);
  }
}

/// ICO 角色列表尺寸
final class _IcoCharacterListMetrics {
  /// 禁止创建 ICO 角色列表尺寸实例
  const _IcoCharacterListMetrics._();

  /// 列表条目高度
  static const double itemExtent = 68;
}
