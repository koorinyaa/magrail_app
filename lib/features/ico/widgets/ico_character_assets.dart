import 'package:flutter/material.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/core/utils/formatters.dart';
import 'package:magrail_app/core/utils/tinygrail_asset_urls.dart';
import 'package:magrail_app/core/utils/tinygrail_formatters.dart';
import 'package:magrail_app/core/utils/tinygrail_ico_time.dart';
import 'package:magrail_app/features/chara/detail/character_detail_hero.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_ico_prediction.dart';
import 'package:magrail_app/features/chara/widgets/character_asset_chips.dart';
import 'package:magrail_app/features/chara/widgets/character_asset_row_components.dart';
import 'package:magrail_app/features/ico/model/ico_character_entry.dart';
import 'package:magrail_app/features/ico/repository/ico_character_repository.dart';
import 'package:magrail_app/features/ico/widgets/ico_character_sort_button.dart';

/// ICO 角色区标题
class IcoCharacterHeaderSliver extends StatelessWidget {
  /// 创建 ICO 角色区标题
  ///
  /// [key] Flutter 组件标识
  /// [selectedType] 当前排序类型
  /// [onSelected] 排序选择回调
  const IcoCharacterHeaderSliver({
    super.key,
    required this.selectedType,
    required this.onSelected,
  });

  /// 当前排序类型
  final IcoCharacterSortType selectedType;

  /// 排序选择回调
  final ValueChanged<IcoCharacterSortType> onSelected;

  /// 构建 ICO 角色区标题
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(top: 22),
        child: Padding(
          padding: AppSafeAreaInsets.fromLTRB(
            context,
            left: 24,
            top: 0,
            right: 24,
            bottom: 0,
          ),
          child: SizedBox(
            height: 44,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'ICO · ${selectedType.label}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
                ),
                IcoCharacterSortButton(
                  selectedType: selectedType,
                  onSelected: onSelected,
                ),
              ],
            ),
          ),
        ),
      ),
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
  const IcoCharacterSliverList({
    super.key,
    required this.items,
    this.onIcoTap,
  });

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
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = items[index];
          final avatarUrl = TinygrailAssetUrls.normalizeAvatar(item.icon);
          final avatarHeroTag = createCharacterDetailAvatarHeroTag(
            characterId: item.characterId,
            avatarUrl: avatarUrl,
            source: item,
          );

          return _IcoCharacterListItem(
            child: IcoCharacterRow(
              item: item,
              avatarHeroTag: avatarHeroTag,
              onTap: onIcoTap == null
                  ? null
                  : () => onIcoTap?.call(item, avatarHeroTag),
            ),
          );
        },
        childCount: items.length,
      ),
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
  const IcoCharacterRow({
    super.key,
    required this.item,
    this.avatarHeroTag,
    this.onTap,
  });

  /// ICO 角色条目
  final IcoCharacterEntry item;

  /// 头像转场标识
  final String? avatarHeroTag;

  /// 条目点击回调
  final VoidCallback? onTap;

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
      contentPadding: const EdgeInsets.only(left: 30, right: 16),
      tapBorderRadius: BorderRadius.zero,
      onTap: onTap,
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

/// ICO 角色列表项外层
class _IcoCharacterListItem extends StatelessWidget {
  /// 创建 ICO 角色列表项外层
  ///
  /// [child] 列表项内容
  const _IcoCharacterListItem({
    required this.child,
  });

  final Widget child;

  /// 构建 ICO 角色列表项外层
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSafeAreaInsets.fromLTRB(
        context,
        left: 0,
        top: 0,
        right: 0,
        bottom: 4,
      ),
      child: child,
    );
  }
}

/// ICO 角色列表尺寸
final class _IcoCharacterListMetrics {
  /// 禁止创建 ICO 角色列表尺寸实例
  const _IcoCharacterListMetrics._();

  /// 列表条目高度
  static const double itemExtent = 68;
}
