part of '../character_detail_sacrifice_sheet.dart';

class _SacrificeModeCards extends StatelessWidget {
  /// 创建资产重组类型卡片组
  ///
  /// [controller] 资产重组抽屉控制器
  const _SacrificeModeCards({
    required this.controller,
  });

  /// 资产重组抽屉控制器
  final CharacterDetailSacrificeSheetController controller;

  /// 构建资产重组类型卡片组
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final restructure = _SacrificeModeCard(
      title: '资产重组',
      description: '将股份转化为固定资产，同时获得现金奖励并掉落道具',
      selectedColor: const Color(0xFF17C964),
      selected: controller.mode == CharacterDetailSacrificeMode.restructure,
      onPressed: () => controller.updateMode(
        CharacterDetailSacrificeMode.restructure,
      ),
    );
    final financing = _SacrificeModeCard(
      title: '股权融资',
      description: '将股份出售给幻想乡，立刻获取现金，不会补充固定资产',
      selectedColor: const Color(0xFFF25C62),
      selected: controller.mode == CharacterDetailSacrificeMode.financing,
      onPressed: () => controller.updateMode(
        CharacterDetailSacrificeMode.financing,
      ),
    );

    return Row(
      children: [
        Expanded(child: restructure),
        const SizedBox(width: 10),
        Expanded(child: financing),
      ],
    );
  }
}

/// 资产重组类型卡片
class _SacrificeModeCard extends StatelessWidget {
  /// 创建资产重组类型卡片
  ///
  /// [title] 卡片标题
  /// [description] 卡片说明
  /// [selectedColor] 选中强调色
  /// [selected] 是否选中
  /// [onPressed] 点击回调
  const _SacrificeModeCard({
    required this.title,
    required this.description,
    required this.selectedColor,
    required this.selected,
    required this.onPressed,
  });

  /// 卡片标题
  final String title;

  /// 卡片说明
  final String description;

  /// 选中强调色
  final Color selectedColor;

  /// 是否选中
  final bool selected;

  /// 点击回调
  final VoidCallback onPressed;

  /// 构建资产重组类型卡片
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final backgroundColor = selected
        ? selectedColor.withValues(alpha: isDark ? 0.18 : 0.10)
        : isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.035);
    final borderColor = selected
        ? selectedColor.withValues(alpha: 0.72)
        : colorScheme.outlineVariant.withValues(alpha: isDark ? 0.28 : 0.52);

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          height: 96,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: borderColor,
                width: selected ? 1.4 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected ? selectedColor : Colors.transparent,
                        border: Border.all(
                          color: selected
                              ? selectedColor
                              : colorScheme.outlineVariant,
                        ),
                      ),
                      child: selected
                          ? Icon(
                              Icons.check_rounded,
                              size: 14,
                              color: colorScheme.onPrimary,
                            )
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    height: 1.28,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
