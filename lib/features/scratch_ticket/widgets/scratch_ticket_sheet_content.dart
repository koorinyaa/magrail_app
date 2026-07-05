part of 'scratch_ticket_sheet.dart';

// 环保刮刮乐选中强调色
const Color _scratchTicketNormalColor = Color(0xFF17C964);
// 幻想乡刮刮乐选中强调色
const Color _scratchTicketLotusColor = Color(0xFFF25C62);

/// 刮刮乐弹层标题区
class _ScratchHeader extends StatelessWidget {
  /// 创建刮刮乐弹层标题区
  const _ScratchHeader();

  /// 构建刮刮乐弹层标题区
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.casino_outlined,
            color: colorScheme.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '彩票抽奖',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '选择一种刮刮乐抽取',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1.15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 彩票类型选项组
class _TicketChoiceGroup extends StatelessWidget {
  /// 创建彩票类型选项组
  ///
  /// [isLotus] 是否选择幻想乡刮刮乐
  /// [lotusPriceText] 幻想乡刮刮乐价格文案
  /// [isLoadingCount] 是否正在加载幻想乡次数
  /// [isLotusCountUnknown] 幻想乡次数是否未知
  /// [isDisabled] 是否禁用
  /// [onChanged] 切换回调
  const _TicketChoiceGroup({
    required this.isLotus,
    required this.lotusPriceText,
    required this.isLoadingCount,
    required this.isLotusCountUnknown,
    required this.isDisabled,
    required this.onChanged,
  });

  /// 是否选择幻想乡刮刮乐
  final bool isLotus;

  /// 幻想乡刮刮乐价格文案
  final String lotusPriceText;

  /// 是否正在加载幻想乡次数
  final bool isLoadingCount;

  /// 幻想乡次数是否未知
  final bool isLotusCountUnknown;

  /// 是否禁用
  final bool isDisabled;

  /// 切换回调
  final ValueChanged<bool> onChanged;

  /// 构建彩票类型选项组
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final normal = _TicketChoiceCard(
      title: '环保刮刮乐',
      description: '每日可购买 3 次',
      priceText: Formatters.tinygrailCurrency(1000),
      iconBuilder: (color) => Icon(
        Icons.eco,
        color: color,
        size: 22,
      ),
      selectedColor: _scratchTicketNormalColor,
      isSelected: !isLotus,
      isDisabled: isDisabled,
      onPressed: () => onChanged(false),
    );
    final lotus = _TicketChoiceCard(
      title: '幻想乡刮刮乐',
      description: _lotusDescription,
      priceText: lotusPriceText,
      iconBuilder: (color) => SizedBox(
        width: 22,
        height: 22,
        child: Center(
          child: SvgPicture.asset(
            'assets/icons/torii.svg',
            width: 18,
            height: 18,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          ),
        ),
      ),
      selectedColor: _scratchTicketLotusColor,
      isSelected: isLotus,
      isDisabled: isDisabled,
      onPressed: () => onChanged(true),
    );

    return Row(
      children: [
        Expanded(child: normal),
        const SizedBox(width: 10),
        Expanded(child: lotus),
      ],
    );
  }

  /// 幻想乡刮刮乐卡片描述
  String get _lotusDescription {
    if (isLoadingCount) {
      return '读取次数中';
    }

    return isLotusCountUnknown ? '购买次数未知' : '价格按次数翻倍';
  }
}

/// 彩票类型选项卡
class _TicketChoiceCard extends StatelessWidget {
  /// 创建彩票类型选项卡
  ///
  /// [title] 标题
  /// [description] 描述
  /// [priceText] 价格文案
  /// [iconBuilder] 图标构建器
  /// [selectedColor] 选中强调色
  /// [isSelected] 是否选中
  /// [isDisabled] 是否禁用
  /// [onPressed] 点击回调
  const _TicketChoiceCard({
    required this.title,
    required this.description,
    required this.priceText,
    required this.iconBuilder,
    required this.selectedColor,
    required this.isSelected,
    required this.isDisabled,
    required this.onPressed,
  });

  /// 标题
  final String title;

  /// 描述
  final String description;

  /// 价格文案
  final String priceText;

  /// 图标构建器
  final Widget Function(Color color) iconBuilder;

  /// 选中强调色
  final Color selectedColor;

  /// 是否选中
  final bool isSelected;

  /// 是否禁用
  final bool isDisabled;

  /// 点击回调
  final VoidCallback onPressed;

  /// 构建彩票类型选项卡
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final backgroundColor = isSelected
        ? selectedColor.withValues(alpha: isDark ? 0.18 : 0.1)
        : isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.035);
    final borderColor = isSelected
        ? selectedColor.withValues(alpha: 0.72)
        : colorScheme.outlineVariant.withValues(alpha: isDark ? 0.28 : 0.52);

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isDisabled ? null : onPressed,
        child: SizedBox(
          height: 128,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: borderColor,
                width: isSelected ? 1.4 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    iconBuilder(
                      isSelected ? selectedColor : colorScheme.onSurfaceVariant,
                    ),
                    const Spacer(),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? selectedColor : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? selectedColor
                              : colorScheme.outlineVariant,
                        ),
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check_rounded,
                              size: 14,
                              color: colorScheme.onPrimary,
                            )
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
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
                const SizedBox(height: 5),
                Text(
                  description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  priceText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isSelected ? selectedColor : colorScheme.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    height: 1,
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

/// 购买摘要
class _PurchaseSummary extends StatelessWidget {
  /// 创建购买摘要
  ///
  /// [title] 标题
  /// [description] 说明
  /// [priceText] 支付价格文案
  const _PurchaseSummary({
    required this.title,
    required this.description,
    required this.priceText,
  });

  /// 标题
  final String title;

  /// 说明
  final String description;

  /// 支付价格文案
  final String priceText;

  /// 构建购买摘要
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return SizedBox(
      height: 64,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.035),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                priceText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colorScheme.primary,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 刮刮乐确认按钮
class _ConfirmButton extends StatelessWidget {
  /// 创建刮刮乐确认按钮
  ///
  /// [label] 按钮文案
  /// [accentColor] 当前选中票种强调色
  /// [isLoading] 是否正在提交
  /// [isDisabled] 是否禁用
  /// [onPressed] 点击回调
  const _ConfirmButton({
    required this.label,
    required this.accentColor,
    required this.isLoading,
    required this.isDisabled,
    required this.onPressed,
  });

  /// 按钮文案
  final String label;

  /// 选中票种强调色
  final Color accentColor;

  /// 是否正在提交
  final bool isLoading;

  /// 是否禁用
  final bool isDisabled;

  /// 点击回调
  final VoidCallback onPressed;

  /// 构建刮刮乐确认按钮
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isUnavailable = isLoading || isDisabled;

    return Material(
      color: isDisabled
          ? colorScheme.onSurface.withValues(alpha: 0.16)
          : accentColor,
      borderRadius: BorderRadius.circular(999),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isUnavailable ? null : onPressed,
        child: SizedBox(
          height: 44,
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.onPrimary,
                    ),
                  )
                : Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDisabled
                          ? colorScheme.onSurfaceVariant
                          : colorScheme.onPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
