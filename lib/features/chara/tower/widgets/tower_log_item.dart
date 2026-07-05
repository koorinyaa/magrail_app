part of 'tower_log_panel.dart';

/// 通天塔日志项
class _TowerLogItem extends StatelessWidget {
  /// 创建通天塔日志项
  ///
  /// [item] 通天塔日志接口条目
  const _TowerLogItem({
    required this.item,
  });

  /// 通天塔日志接口条目
  final TowerLogApiItem item;

  /// 构建通天塔日志项
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final avatarUrl = TinygrailAssetUrls.normalizeAvatar(item.icon);
    final avatarHeroTag = createCharacterDetailAvatarHeroTag(
      characterId: item.characterId,
      avatarUrl: avatarUrl,
      source: item,
    );

    return Material(
      color: Colors.transparent,
      child: SizedBox(
        width: double.infinity,
        child: InkWell(
          onTap: item.characterId <= 0
              ? null
              : () => _handleCharacterTap(context, avatarUrl, avatarHeroTag),
          child: Padding(
            padding: AppSafeAreaInsets.symmetricHorizontal(
              context,
              horizontal: _towerLogHorizontalPadding,
              vertical: 8,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _TowerLogAvatar(
                  imageUrl: avatarUrl,
                  heroTag: avatarHeroTag,
                ),
                const SizedBox(width: _towerLogAvatarTextGap),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              TinygrailFormatters.decodeHtmlEntities(
                                item.characterName,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.w700,
                                    height: 1.1,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          _TowerLogRankBadge(rank: item.rank),
                          _TowerLogRankChangeBadge(
                            rank: item.rank,
                            oldRank: item.oldRank,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      _TowerLogActionButton(item: item),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Center(
                  child: Text(
                    TinygrailFormatters.relativeTime(item.logTime),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                          height: 1,
                        ),
                  ),
                ),
                SizedBox(
                  width: 20,
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.64),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 处理角色区域点击
  ///
  /// [context] 当前组件树上下文
  /// [avatarUrl] 角色头像地址
  /// [avatarHeroTag] 入口头像转场标识
  void _handleCharacterTap(
    BuildContext context,
    String avatarUrl,
    String? avatarHeroTag,
  ) {
    openCharacterDetail(
      context,
      characterId: item.characterId,
      name: item.characterName,
      avatarUrl: avatarUrl,
      avatarHeroTag: avatarHeroTag,
    );
  }
}

/// 通天塔日志头像
class _TowerLogAvatar extends StatelessWidget {
  /// 创建通天塔日志头像
  ///
  /// [imageUrl] 头像地址
  /// [heroTag] 头像转场标识
  const _TowerLogAvatar({
    required this.imageUrl,
    required this.heroTag,
  });

  /// 头像地址
  final String imageUrl;

  /// 头像转场标识
  final String? heroTag;

  /// 构建通天塔日志头像
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final avatar = CharacterAvatar(
      imageUrl: imageUrl,
      size: _towerLogAvatarSize,
      borderRadius: 12,
    );
    final resolvedHeroTag = heroTag?.trim();
    if (resolvedHeroTag == null || resolvedHeroTag.isEmpty) {
      return avatar;
    }

    return Hero(
      tag: resolvedHeroTag,
      transitionOnUserGestures: true,
      child: avatar,
    );
  }
}

/// 通天塔日志排名徽标
class _TowerLogRankBadge extends StatelessWidget {
  /// 创建通天塔日志排名徽标
  ///
  /// [rank] 通天塔排名
  const _TowerLogRankBadge({
    required this.rank,
  });

  final int rank;

  /// 构建通天塔日志排名徽标
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isHighRank = rank > 0 && rank <= 500;

    return Container(
      height: 16,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isHighRank
            ? colorScheme.primary.withValues(alpha: 0.84)
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        '#$rank',
        style: TextStyle(
          color: isHighRank ? colorScheme.onPrimary : colorScheme.onSurface,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
    );
  }
}

/// 通天塔日志排名变化徽标
class _TowerLogRankChangeBadge extends StatelessWidget {
  /// 创建通天塔日志排名变化徽标
  ///
  /// [rank] 当前排名
  /// [oldRank] 变动前排名
  const _TowerLogRankChangeBadge({
    required this.rank,
    required this.oldRank,
  });

  final int rank;
  final int oldRank;

  /// 构建通天塔日志排名变化徽标
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    if (oldRank <= 0 || rank == oldRank) {
      return const SizedBox.shrink();
    }

    final promoted = rank < oldRank;
    final value = (rank - oldRank).abs();
    final color = promoted ? const Color(0xFFFF5A91) : const Color(0xFF38A8E8);

    return Container(
      height: 16,
      margin: const EdgeInsets.only(left: 3),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            promoted
                ? Icons.arrow_upward_rounded
                : Icons.arrow_downward_rounded,
            size: 10,
            color: color,
          ),
          const SizedBox(width: 1),
          Text(
            '$value',
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

/// 通天塔日志行为按钮
class _TowerLogActionButton extends StatelessWidget {
  /// 创建通天塔日志行为按钮
  ///
  /// [item] 通天塔日志接口条目
  const _TowerLogActionButton({
    required this.item,
  });

  final TowerLogApiItem item;

  /// 构建通天塔日志行为按钮
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final username = item.userName.trim();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: username.isEmpty ? null : () => _handleUserTap(context),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: _TowerLogActionText(item: item),
        ),
      ),
    );
  }

  /// 处理用户区域点击
  ///
  /// [context] 当前组件树上下文
  void _handleUserTap(BuildContext context) {
    final username = item.userName.trim();
    if (username.isEmpty) {
      return;
    }

    context.pushNamed(
      'userDetail',
      queryParameters: {'username': username},
    );
  }
}

/// 通天塔日志行为文本
class _TowerLogActionText extends StatelessWidget {
  /// 创建通天塔日志行为文本
  ///
  /// [item] 通天塔日志接口条目
  const _TowerLogActionText({
    required this.item,
  });

  final TowerLogApiItem item;

  /// 构建通天塔日志行为文本
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final action = _resolveAction();
    final nickname = TinygrailFormatters.decodeHtmlEntities(item.nickname);
    final username = item.userName.trim();
    final displayName = nickname.isEmpty ? username : nickname;
    final amount = Formatters.groupedNumber(item.amount.abs());
    final hasUser = displayName.isNotEmpty;
    final amountText = _resolveAmountText(amount);

    final style = TextStyle(
      color: _resolveColor(),
      fontSize: 12,
      fontWeight: FontWeight.w700,
      height: 1.1,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          action,
          style: style,
        ),
        if (hasUser) ...[
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              '@$displayName',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: style,
            ),
          ),
        ],
        Text(
          ' $amountText',
          style: style,
        ),
        if (item.type == 5) ...[
          const SizedBox(width: 3),
          const Icon(
            Symbols.star,
            size: 12,
            fill: 1,
            color: Color(0xFFF2B72F),
          ),
        ],
      ],
    );
  }

  /// 解析行为文案
  String _resolveAction() {
    return switch (item.type) {
      0 => '星之力',
      2 => '鲤鱼之眼',
      3 => '精炼成功',
      4 => '精炼失败',
      5 => '星之力',
      1 => '受到攻击',
      _ => '未知',
    };
  }

  /// 解析行为数量文案
  ///
  /// [amount] 格式化后的行为数量
  String _resolveAmountText(String amount) {
    final prefix = switch (item.type) {
      0 || 2 || 3 || 4 || 5 => '+',
      1 => '-',
      _ => '',
    };

    return '$prefix$amount';
  }

  /// 解析行为颜色
  Color _resolveColor() {
    return switch (item.type) {
      0 || 2 || 3 || 5 => const Color(0xFFFF5A91),
      1 || 4 => const Color(0xFF38A8E8),
      _ => const Color(0xFF8A8F98),
    };
  }
}
