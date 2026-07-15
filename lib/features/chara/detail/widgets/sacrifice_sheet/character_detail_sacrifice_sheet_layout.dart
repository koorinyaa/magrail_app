part of '../character_detail_sacrifice_sheet.dart';

class _SacrificeMainPanel extends StatelessWidget {
  /// 创建资产重组抽屉主体面板
  ///
  /// [controller] 资产重组抽屉控制器
  /// [onSubmit] 提交回调
  const _SacrificeMainPanel({
    required this.controller,
    required this.onSubmit,
  });

  /// 资产重组抽屉控制器
  final CharacterDetailSacrificeSheetController controller;

  /// 提交回调
  final VoidCallback onSubmit;

  /// 构建资产重组抽屉主体面板
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SacrificeModeCards(controller: controller),
        const SizedBox(height: 14),
        _SacrificeStats(controller: controller),
        const SizedBox(height: 14),
        _SacrificeAmountField(controller: controller),
        const SizedBox(height: 10),
        _SacrificeQuickButtons(controller: controller),
        const SizedBox(height: 16),
        _SacrificeSubmitButton(
          controller: controller,
          onSubmit: onSubmit,
        ),
      ],
    );
  }
}

/// 获取资产重组内嵌表面样式
///
/// [context] 当前组件树上下文
/// [radius] 圆角半径
BoxDecoration _sacrificeInsetDecoration(
  BuildContext context, {
  required double radius,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  final isDark = colorScheme.brightness == Brightness.dark;

  return BoxDecoration(
    color: colorScheme.surfaceContainerHighest.withValues(
      alpha: isDark ? 0.18 : 0.36,
    ),
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(
      color: colorScheme.outlineVariant.withValues(
        alpha: isDark ? 0.20 : 0.36,
      ),
    ),
  );
}

/// 资产重组抽屉标题
class _SacrificeSheetHeader extends StatelessWidget {
  /// 创建资产重组抽屉标题
  ///
  /// [controller] 资产重组抽屉控制器
  /// [mode] 标题展示的提交类型
  const _SacrificeSheetHeader({
    required this.controller,
    this.mode,
  });

  /// 资产重组抽屉控制器
  final CharacterDetailSacrificeSheetController controller;

  /// 标题展示的提交类型
  final CharacterDetailSacrificeMode? mode;

  /// 构建资产重组抽屉标题
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final header = controller.header;
    final characterName = TinygrailFormatters.decodeHtmlEntities(
      header?.name ?? '',
    ).trim();
    final resolvedCharacterName =
        characterName.isEmpty ? '角色名称' : characterName;
    final characterSubtitle =
        '#${header?.characterId ?? 0} 「$resolvedCharacterName」';
    final titleMode = mode ?? controller.mode;
    final title =
        titleMode == CharacterDetailSacrificeMode.financing ? '股权融资' : '资产重组';

    return AppBottomSheetHeader(
      icon: LucideIcons.repeat2,
      title: title,
      subtitle: characterSubtitle,
    );
  }
}

/// 资产重组数据概览
class _SacrificeStats extends StatelessWidget {
  /// 创建资产重组数据概览
  ///
  /// [controller] 资产重组抽屉控制器
  const _SacrificeStats({
    required this.controller,
  });

  /// 资产重组抽屉控制器
  final CharacterDetailSacrificeSheetController controller;

  /// 构建资产重组数据概览
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: _sacrificeInsetDecoration(context, radius: 14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: _SacrificeStatItem(
                label: '可用活股',
                value: Formatters.groupedNumber(controller.availableAmount),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _SacrificeStatItem(
                label: '圣殿',
                value: '${Formatters.groupedNumber(controller.templeAssets)} / '
                    '${Formatters.groupedNumber(controller.templeSacrifices)}',
                level: controller.templeLevel,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 资产重组数据条目
class _SacrificeStatItem extends StatelessWidget {
  /// 创建资产重组数据条目
  ///
  /// [label] 标签文案
  /// [value] 数值文案
  /// [level] 圣殿等级
  const _SacrificeStatItem({
    required this.label,
    required this.value,
    this.level,
  });

  /// 标签文案
  final String label;

  /// 数值文案
  final String value;

  /// 圣殿等级
  final int? level;

  /// 构建资产重组数据条目
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accentColor = switch (level) {
      2 => const Color(0xFFEAB308),
      3 => const Color(0xFFA855F7),
      _ => colorScheme.onSurface,
    };

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: accentColor,
              fontSize: 13,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ),
      ],
    );
  }
}
