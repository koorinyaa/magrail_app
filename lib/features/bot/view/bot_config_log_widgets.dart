part of 'bot_config_page.dart';

/// bot 操作日志 sliver 列表
class _BotLogSliverList extends StatelessWidget {
  /// 创建 bot 操作日志 sliver 列表
  ///
  /// [logs] 操作日志列表
  /// [onCharacterTap] 角色 ID 点击回调
  const _BotLogSliverList({
    required this.logs,
    required this.onCharacterTap,
  });

  /// 操作日志列表
  final List<BotLogEntry> logs;

  /// 角色 ID 点击回调
  final ValueChanged<int> onCharacterTap;

  /// 构建 bot 操作日志 sliver 列表
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SliverList.separated(
      itemBuilder: (context, index) {
        return UserAssetRecordListItem(
          child: _BotLogRow(
            log: logs[index],
            onCharacterTap: onCharacterTap,
          ),
        );
      },
      separatorBuilder: (context, index) {
        final colorScheme = Theme.of(context).colorScheme;
        final isDark = colorScheme.brightness == Brightness.dark;

        return UserAssetRecordListItem(
          child: Divider(
            height: 1,
            thickness: 0.6,
            color: colorScheme.outlineVariant.withValues(
              alpha: isDark ? 0.32 : 0.58,
            ),
          ),
        );
      },
      itemCount: logs.length,
    );
  }
}

/// bot 操作日志骨架 sliver 列表
class _BotLogSkeletonSliverList extends StatelessWidget {
  /// 创建 bot 操作日志骨架 sliver 列表
  const _BotLogSkeletonSliverList();

  static const int _itemCount = 12;

  /// 构建 bot 操作日志骨架 sliver 列表
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SliverList.separated(
      itemBuilder: (context, index) {
        return const UserAssetRecordListItem(
          child: _BotLogSkeletonRow(),
        );
      },
      separatorBuilder: (context, index) {
        final colorScheme = Theme.of(context).colorScheme;
        final isDark = colorScheme.brightness == Brightness.dark;

        return UserAssetRecordListItem(
          child: Divider(
            height: 1,
            thickness: 0.6,
            color: colorScheme.outlineVariant.withValues(
              alpha: isDark ? 0.32 : 0.58,
            ),
          ),
        );
      },
      itemCount: _itemCount,
    );
  }
}

/// bot 操作日志骨架行
class _BotLogSkeletonRow extends StatelessWidget {
  /// 创建 bot 操作日志骨架行
  const _BotLogSkeletonRow();

  /// 构建 bot 操作日志骨架行
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return const Skeletonizer.zone(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Bone(
                  width: 64,
                  height: 18,
                  borderRadius: BorderRadius.all(Radius.circular(999)),
                ),
                Spacer(),
                Bone.icon(size: 12),
                SizedBox(width: 4),
                Bone.text(width: 54, fontSize: 11),
              ],
            ),
            SizedBox(height: 7),
            Bone.text(width: 230, fontSize: 12),
          ],
        ),
      ),
    );
  }
}

/// bot 操作日志状态
class _BotLogSliverState extends StatelessWidget {
  /// 创建 bot 操作日志状态
  ///
  /// [icon] 状态图标
  /// [text] 状态文案
  const _BotLogSliverState({
    required this.icon,
    required this.text,
  });

  /// 状态图标
  final IconData icon;

  /// 状态文案
  final String text;

  /// 构建 bot 操作日志状态
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: colorScheme.onSurfaceVariant, size: 28),
            const SizedBox(height: 10),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// bot 操作日志行
class _BotLogRow extends StatelessWidget {
  /// 创建 bot 操作日志行
  ///
  /// [log] 操作日志条目
  /// [onCharacterTap] 角色 ID 点击回调
  const _BotLogRow({
    required this.log,
    required this.onCharacterTap,
  });

  /// 操作日志条目
  final BotLogEntry log;

  /// 角色 ID 点击回调
  final ValueChanged<int> onCharacterTap;

  /// 构建 bot 操作日志行
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final date = log.date;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _BotLogTypeBadge(type: log.logType),
                    if (date != null) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(
                              LucideIcons.clock3,
                              size: 12,
                              color: colorScheme.onSurfaceVariant.withValues(
                                alpha: 0.58,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                TinygrailFormatters.relativeTime(
                                  date.toIso8601String(),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  height: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 7),
                _BotLogDescription(
                  text: TinygrailFormatters.decodeHtmlEntities(log.message),
                  onCharacterTap: onCharacterTap,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// bot 操作日志正文
class _BotLogDescription extends StatelessWidget {
  /// 创建 bot 操作日志正文
  ///
  /// [text] 正文文本
  /// [onCharacterTap] 角色 ID 点击回调
  const _BotLogDescription({
    required this.text,
    required this.onCharacterTap,
  });

  /// 正文文本
  final String text;

  /// 角色 ID 点击回调
  final ValueChanged<int> onCharacterTap;

  /// 构建 bot 操作日志正文
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = TextStyle(
      color: colorScheme.onSurfaceVariant,
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 1.25,
    );

    if (text.isEmpty) {
      return Text('--', style: textStyle);
    }

    return Wrap(
      spacing: 0,
      runSpacing: 2,
      children: [
        for (final part in _parseDescriptionParts())
          if (part.characterId == null)
            Text(part.text, style: textStyle)
          else
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onCharacterTap(part.characterId!),
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: Text(
                    part.text,
                    style: textStyle.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
      ],
    );
  }

  /// 拆分日志正文中的角色 ID 片段
  List<_BotLogDescriptionPart> _parseDescriptionParts() {
    final regex = RegExp(r'#(\d+)');
    final parts = <_BotLogDescriptionPart>[];
    var lastIndex = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastIndex) {
        parts.add(
          _BotLogDescriptionPart(
            text: text.substring(lastIndex, match.start),
          ),
        );
      }

      parts.add(
        _BotLogDescriptionPart(
          text: match.group(0) ?? '',
          characterId: int.tryParse(match.group(1) ?? ''),
        ),
      );
      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      parts.add(
        _BotLogDescriptionPart(
          text: text.substring(lastIndex),
        ),
      );
    }

    return parts;
  }
}

/// bot 操作日志正文片段
final class _BotLogDescriptionPart {
  /// 创建 bot 操作日志正文片段
  ///
  /// [text] 片段文本
  /// [characterId] 角色 ID
  const _BotLogDescriptionPart({
    required this.text,
    this.characterId,
  });

  /// 片段文本
  final String text;

  /// 角色 ID
  final int? characterId;
}

/// bot 日志类型标签
class _BotLogTypeBadge extends StatelessWidget {
  /// 创建 bot 日志类型标签
  ///
  /// [type] 日志类型
  const _BotLogTypeBadge({required this.type});

  /// 日志类型
  final int type;

  /// 构建 bot 日志类型标签
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = switch (type) {
      0 => const Color(0xFF16A34A),
      1 => colorScheme.error,
      2 => const Color(0xFFD97706),
      _ => colorScheme.primary,
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          _labelForType(type),
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
      ),
    );
  }

  /// 生成日志类型文案
  ///
  /// [type] 日志类型
  String _labelForType(int type) {
    return switch (type) {
      1 => '错误',
      2 => '警告',
      3 => '刮刮乐',
      4 => '混沌魔方',
      5 => '虚空道标',
      6 => 'ICO',
      7 => '每日签到',
      8 => '每周股息',
      10 => '鲤鱼之眼',
      11 => '星之力',
      _ => '普通',
    };
  }
}
