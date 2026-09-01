part of 'top_week_section.dart';

/// 每周萌王竞拍面板
class _TopWeekAuctionPanel extends StatelessWidget {
  /// 创建每周萌王竞拍面板
  ///
  /// [entry] 每周萌王条目
  /// [onCharacterPressed] 角色详情点击回调
  /// [onAuctionPressed] 拍卖按钮点击回调
  const _TopWeekAuctionPanel({
    required this.entry,
    required this.onCharacterPressed,
    required this.onAuctionPressed,
  });

  final TopWeekEntry entry;
  final ValueChanged<TopWeekEntry> onCharacterPressed;
  final ValueChanged<TopWeekEntry> onAuctionPressed;

  /// 构建每周萌王竞拍面板
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(26),
          bottomRight: Radius.circular(26),
        ),
        child: Container(
          height: _TopWeekCard._auctionPanelHeight,
          padding: const EdgeInsets.fromLTRB(17, 8, 15, 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: 0.16),
                Colors.white.withValues(alpha: 0.10),
              ],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(26),
              bottomRight: Radius.circular(26),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.13),
                offset: const Offset(0, 1),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 16,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _TopWeekAuctionSummary(
                  entry: entry,
                  onTap: () => onCharacterPressed(entry),
                ),
              ),
              const SizedBox(width: 12),
              _TopWeekAuctionButton(
                entry: entry,
                onPressed: () => onAuctionPressed(entry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 每周萌王竞拍摘要
class _TopWeekAuctionSummary extends StatelessWidget {
  /// 创建每周萌王竞拍摘要
  ///
  /// [entry] 每周萌王条目
  /// [onTap] 点击角色名称区域回调
  const _TopWeekAuctionSummary({required this.entry, required this.onTap});

  final TopWeekEntry entry;
  final VoidCallback onTap;

  /// 构建每周萌王竞拍摘要
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        splashColor: Colors.white.withValues(alpha: 0.10),
        highlightColor: Colors.white.withValues(alpha: 0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      entry.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.96),
                        fontSize: 15.5,
                        fontWeight: FontWeight.w900,
                        height: 1.05,
                      ),
                    ),
                  ),
                  const SizedBox(width: 7),
                  LevelBadge(level: entry.level),
                ],
              ),
              const SizedBox(height: 5),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: entry.averagePrice),
                    TextSpan(
                      text: ' / ',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.72),
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    TextSpan(
                      text: '均价',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.72),
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFFE4E4E7),
                  fontSize: 12,
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

/// 每周萌王竞拍按钮
class _TopWeekAuctionButton extends StatelessWidget {
  /// 创建每周萌王竞拍按钮
  ///
  /// [entry] 每周萌王条目
  /// [onPressed] 点击回调
  const _TopWeekAuctionButton({required this.entry, required this.onPressed});

  final TopWeekEntry entry;
  final VoidCallback onPressed;

  /// 构建每周萌王竞拍按钮
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final hasUserBid = entry.hasUserBid;
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = hasUserBid
        ? colorScheme.primary.withValues(alpha: 0.96)
        : Colors.white.withValues(alpha: 0.90);
    final foregroundColor = hasUserBid ? Colors.white : const Color(0xFF11181C);

    return SizedBox(
      width: 56,
      height: 34,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(999),
          splashColor: Colors.white.withValues(alpha: 0.16),
          highlightColor: Colors.white.withValues(alpha: 0.08),
          child: Center(
            child: Text(
              hasUserBid ? '改价' : '竞拍',
              style: TextStyle(
                color: foregroundColor,
                fontSize: 12.5,
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
