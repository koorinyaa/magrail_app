part of 'top_week_section.dart';

/// 每周萌王卡片
class _TopWeekCard extends StatelessWidget {
  /// 创建每周萌王卡片
  ///
  /// [entry] 每周萌王条目
  /// [onCharacterPressed] 角色详情点击回调
  /// [onAuctionPressed] 拍卖按钮点击回调
  const _TopWeekCard({
    required this.entry,
    required this.onCharacterPressed,
    required this.onAuctionPressed,
  });

  final TopWeekEntry entry;
  final ValueChanged<TopWeekEntry> onCharacterPressed;
  final ValueChanged<TopWeekEntry> onAuctionPressed;

  static const double cardWidth = 264;
  static const double cardAspectRatio = 3 / 4;
  static const double cardRadius = 26;

  /// 图片 Hero 标识
  String get _heroTag => 'top-week-cover-${entry.rank}-${entry.characterId}';

  /// 构建每周萌王卡片
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: cardWidth,
      child: AspectRatio(
        aspectRatio: cardAspectRatio,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(cardRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 6,
                offset: const Offset(4, 3),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 2,
                offset: const Offset(1, 1),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(cardRadius),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => _openImageViewer(context),
              splashColor: Colors.white.withValues(alpha: 0.12),
              highlightColor: Colors.white.withValues(alpha: 0.06),
              customBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(cardRadius),
              ),
              child: Stack(
                children: [
                  _buildImageLayer(),
                  _buildReadingOverlay(),
                  _TopWeekRankBadge(entry: entry),
                  _buildMetrics(),
                  _buildVisibleImageViewerInkLayer(context),
                  _TopWeekAuctionPanel(
                    entry: entry,
                    onCharacterPressed: onCharacterPressed,
                    onAuctionPressed: onAuctionPressed,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 构建可见的查看大图水波纹层
  ///
  /// [context] 当前组件树上下文
  Widget _buildVisibleImageViewerInkLayer(BuildContext context) {
    return Positioned.fill(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openImageViewer(context),
          splashColor: Colors.white.withValues(alpha: 0.12),
          highlightColor: Colors.white.withValues(alpha: 0.06),
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(cardRadius),
          ),
        ),
      ),
    );
  }

  /// 打开全屏图片查看
  ///
  /// [context] 当前组件树上下文
  void _openImageViewer(BuildContext context) {
    final imageUrl =
        entry.coverUrl.isNotEmpty ? entry.coverUrl : entry.avatarUrl;
    if (imageUrl.isEmpty) {
      return;
    }

    Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) =>
            FullscreenImageViewerPage(
          imageUrl: imageUrl,
          heroTag: _heroTag,
        ),
      ),
    );
  }

  /// 构建图片层
  Widget _buildImageLayer() {
    return Positioned.fill(
      child: Hero(
        tag: _heroTag,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.40),
              width: 0.75,
            ),
          ),
          child: TempleCoverImage(
            coverUrl: entry.coverUrl,
            avatarUrl: entry.avatarUrl,
          ),
        ),
      ),
    );
  }

  /// 构建底部阅读渐变层
  Widget _buildReadingOverlay() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      height: 176,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF3A3039).withValues(alpha: 0),
              const Color(0xFF6B5F68).withValues(alpha: 0.16),
              const Color(0xFF3A3039).withValues(alpha: 0.44),
              const Color(0xFF2F2830).withValues(alpha: 0.70),
            ],
            stops: const [0, 0.20, 0.58, 1],
          ),
        ),
      ),
    );
  }

  /// 构建卡片数据区域
  Widget _buildMetrics() {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 66,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildDataCapsule(text: entry.surplus),
              _buildDataCapsule(
                text: entry.score,
                icon: Icons.insights_rounded,
              ),
            ],
          ),
          const SizedBox(height: 6),
          _TopWeekMetricRow(entry: entry),
        ],
      ),
    );
  }

  /// 构建卡片顶部数据胶囊
  ///
  /// [text] 数据文本
  /// [icon] 数据图标
  Widget _buildDataCapsule({
    required String text,
    IconData? icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: BackdropFilter(
          filter: AppBlurStyle.filter,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.32),
                width: 0.8,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: 13,
                      color: Colors.white.withValues(alpha: 0.90),
                    ),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.90),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 每周萌王排名角标
class _TopWeekRankBadge extends StatelessWidget {
  /// 创建每周萌王排名角标
  ///
  /// [entry] 每周萌王条目
  const _TopWeekRankBadge({
    required this.entry,
  });

  final TopWeekEntry entry;

  /// 构建每周萌王排名角标
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(14);

    return Positioned(
      left: 16,
      top: 16,
      child: Container(
        width: 44,
        height: 28,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: entry.rankColor.withValues(alpha: _rankColorAlpha),
          borderRadius: borderRadius,
          clipBehavior: Clip.antiAlias,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.10),
                  Colors.white.withValues(alpha: 0),
                ],
              ),
            ),
            child: Center(
              child: Text(
                '#${entry.rank}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.90),
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 解析排名角标透明度
  double get _rankColorAlpha {
    if (entry.rank == 1) {
      return 0.80;
    }

    if (entry.rank <= 3) {
      return 0.72;
    }

    if (entry.rank <= 6) {
      return 0.66;
    }

    return 0.59;
  }
}

/// 每周萌王数据行
class _TopWeekMetricRow extends StatelessWidget {
  /// 创建每周萌王数据行
  ///
  /// [entry] 每周萌王条目
  const _TopWeekMetricRow({
    required this.entry,
  });

  final TopWeekEntry entry;

  /// 构建每周萌王数据行
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      color: Colors.white.withValues(alpha: 0.74),
      fontSize: 13,
      fontWeight: FontWeight.w800,
      height: 1,
    );

    return Text.rich(
      TextSpan(
        children: [
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: const EdgeInsets.only(right: 3),
              child: Icon(
                Icons.group_rounded,
                size: 14,
                color: Colors.white.withValues(alpha: 0.74),
              ),
            ),
          ),
          TextSpan(text: entry.bidders),
          const WidgetSpan(
            child: SizedBox(width: 9),
          ),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: const EdgeInsets.only(right: 3),
              child: Icon(
                Icons.gavel_rounded,
                size: 14,
                color: Colors.white.withValues(alpha: 0.74),
              ),
            ),
          ),
          TextSpan(text: entry.bidAmount),
          const WidgetSpan(
            child: SizedBox(width: 9),
          ),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: const EdgeInsets.only(right: 3),
              child: Icon(
                Icons.account_balance_rounded,
                size: 14,
                color: Colors.white.withValues(alpha: 0.74),
              ),
            ),
          ),
          TextSpan(text: entry.valhallaAmount),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: textStyle,
    );
  }
}

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
          height: 60,
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
  const _TopWeekAuctionSummary({
    required this.entry,
    required this.onTap,
  });

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
  const _TopWeekAuctionButton({
    required this.entry,
    required this.onPressed,
  });

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
