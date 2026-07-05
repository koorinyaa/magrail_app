part of 'character_detail_trade_header_card.dart';

/// 删除投票列表
class _TradeHeaderKillVoteList extends StatelessWidget {
  /// 创建删除投票列表
  ///
  /// [votes] 删除投票记录
  /// [currentUserId] 当前登录用户 ID
  const _TradeHeaderKillVoteList({
    required this.votes,
    required this.currentUserId,
  });

  /// 删除投票记录
  final List<CharacterDetailKillVote> votes;

  /// 当前登录用户 ID
  final int? currentUserId;

  /// 构建删除投票列表
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (votes.isEmpty) {
      return Text(
        '暂无投票',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 280),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '已提交的删除投票',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            for (final vote in votes) ...[
              _TradeHeaderKillVoteListItem(
                vote: vote,
                currentUserId: currentUserId,
              ),
              if (vote != votes.last) const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

/// 删除投票列表条目
class _TradeHeaderKillVoteListItem extends StatelessWidget {
  /// 创建删除投票列表条目
  ///
  /// [vote] 删除投票记录
  /// [currentUserId] 当前登录用户 ID
  const _TradeHeaderKillVoteListItem({
    required this.vote,
    required this.currentUserId,
  });

  /// 删除投票记录
  final CharacterDetailKillVote vote;

  /// 当前登录用户 ID
  final int? currentUserId;

  /// 构建删除投票列表条目
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final reason = vote.reason.trim();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(
          alpha: isDark ? 0.38 : 0.56,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _voterLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (reason.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                reason,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                ),
              ),
            ],
            const SizedBox(height: 6),
            Text(
              _formatVoteTime(vote.voteTime),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 投票人展示文案
  String get _voterLabel {
    final currentUserId = this.currentUserId;
    if (currentUserId != null && vote.userId == currentUserId) {
      return '自己';
    }

    return '其他 GM';
  }

  /// 格式化投票时间
  ///
  /// [value] Tinygrail 服务端时间文本
  String _formatVoteTime(String value) {
    final parsed = TinygrailFormatters.parseServerTime(value);
    if (parsed == null) {
      return value.trim().isEmpty ? '--' : value.trim();
    }

    return DateFormat('yyyy/MM/dd HH:mm').format(parsed.toLocal());
  }
}
