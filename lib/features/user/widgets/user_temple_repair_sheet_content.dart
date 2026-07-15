part of 'user_temple_repair_sheet.dart';

/// 批量补塔抽屉标题
class _TempleRepairHeader extends StatelessWidget {
  /// 创建批量补塔抽屉标题
  const _TempleRepairHeader();

  /// 构建批量补塔抽屉标题
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return const AppBottomSheetHeader(
      icon: LucideIcons.wrench,
      title: '快速补塔',
      subtitle: '补充受损圣殿',
    );
  }
}

/// 批量补塔选择栏
class _TempleRepairSelectionHeader extends StatelessWidget {
  /// 创建批量补塔选择栏
  ///
  /// [controller] 批量补塔抽屉控制器
  const _TempleRepairSelectionHeader({required this.controller});

  /// 批量补塔抽屉控制器
  final UserTempleRepairSheetController controller;

  /// 构建批量补塔选择栏
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        SizedBox(
          width: _TempleRepairRow.checkboxExtent,
          child: Checkbox(
            value: controller.isAllRepairableSelected,
            shape: const CircleBorder(),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
            onChanged: controller.repairableCount > 0 &&
                    !controller.isSubmitting &&
                    !controller.isRefreshing
                ? (_) => controller.toggleAll()
                : null,
          ),
        ),
        const SizedBox(width: _TempleRepairRow.checkboxGap),
        Expanded(
          child: Text(
            '已选择 ${controller.selectedCount} / '
            '${controller.repairableCount}',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          '共 ${controller.entries.length} 座受损圣殿',
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// 受损圣殿补塔列表行
class _TempleRepairRow extends StatelessWidget {
  /// 创建受损圣殿补塔列表行
  ///
  /// [entry] 受损圣殿补塔条目
  /// [selected] 是否已选择
  /// [enabled] 是否允许更改选择状态
  /// [onTap] 列表行点击回调
  const _TempleRepairRow({
    required this.entry,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  /// 圣殿封面宽度
  static const double coverWidth = 54;

  /// 勾选框区域宽度
  static const double checkboxExtent = 32;

  /// 勾选框与圣殿封面间距
  static const double checkboxGap = 8;

  /// 圣殿封面与信息区域间距
  static const double contentGap = 10;

  /// 圣殿信息区域起始位置
  static const double infoIndent =
      checkboxExtent + checkboxGap + coverWidth + contentGap;

  /// 受损圣殿补塔条目
  final UserTempleRepairEntry entry;

  /// 是否已选择
  final bool selected;

  /// 是否允许更改选择状态
  final bool enabled;

  /// 列表行点击回调
  final VoidCallback onTap;

  /// 构建受损圣殿补塔列表行
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final temple = entry.temple;
    final progress = temple.sacrifices <= 0
        ? 0.0
        : (temple.assets / temple.sacrifices).clamp(0.0, 1.0).toDouble();
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: entry.canRepair && enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: checkboxExtent,
                child: Checkbox(
                  value: selected,
                  shape: const CircleBorder(),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  onChanged: entry.canRepair && enabled ? (_) => onTap() : null,
                ),
              ),
              const SizedBox(width: checkboxGap),
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: coverWidth,
                  child: AspectRatio(
                    aspectRatio: 3 / 4,
                    child: TempleCoverImage(
                      coverUrl: TinygrailAssetUrls.getSmallCover(temple.cover),
                      avatarUrl:
                          TinygrailAssetUrls.normalizeAvatar(temple.avatar),
                      fallbackAvatarAlignment: Alignment.center,
                      placeholderIconSize: 24,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: contentGap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      temple.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: entry.canRepair
                            ? colorScheme.onSurface
                            : colorScheme.onSurfaceVariant,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      '${Formatters.groupedNumber(temple.assets)} / '
                      '${Formatters.groupedNumber(temple.sacrifices)}',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 4,
                        backgroundColor:
                            colorScheme.onSurfaceVariant.withValues(
                          alpha: colorScheme.brightness == Brightness.dark
                              ? 0.24
                              : 0.14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 9),
                    Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        if (!entry.hasCharacterData)
                          Text(
                            '未找到对应持股数据',
                            style: TextStyle(
                              color: colorScheme.error,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        else ...[
                          _TempleRepairMetric(
                            label: '消耗活股',
                            value: entry.requiredAmount,
                            isError: entry.requiredAmount <= 0,
                          ),
                          _TempleRepairMetric(
                            label: '可用活股',
                            value: entry.availableAmount,
                            isError: entry.requiredAmount > 0 &&
                                entry.availableAmount < entry.requiredAmount,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 补塔数据指标
class _TempleRepairMetric extends StatelessWidget {
  /// 创建补塔数据指标
  ///
  /// [label] 指标文案
  /// [value] 指标数值
  /// [isError] 是否使用错误字体色
  const _TempleRepairMetric({
    required this.label,
    required this.value,
    this.isError = false,
  });

  /// 指标文案
  final String label;

  /// 指标数值
  final int value;

  /// 是否使用错误字体色
  final bool isError;

  /// 构建补塔数据指标
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Text(
      '$label ${Formatters.groupedNumber(value)}',
      style: TextStyle(
        color: isError ? colorScheme.error : colorScheme.onSurfaceVariant,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

/// 批量补塔加载状态
class _TempleRepairLoadingState extends StatelessWidget {
  /// 创建批量补塔加载状态
  const _TempleRepairLoadingState();

  /// 构建批量补塔加载状态
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 64),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox.square(
            dimension: 24,
            child: CircularProgressIndicator(strokeWidth: 2.4),
          ),
          const SizedBox(height: 14),
          Text(
            '正在读取受损圣殿与可用活股',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// 批量补塔空状态
class _TempleRepairEmptyState extends StatelessWidget {
  /// 创建批量补塔空状态
  const _TempleRepairEmptyState();

  /// 构建批量补塔空状态
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 56),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LucideIcons.inbox,
            size: 40,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 14),
          Text(
            '没有受损圣殿',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '当前圣殿资产均未受损',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
