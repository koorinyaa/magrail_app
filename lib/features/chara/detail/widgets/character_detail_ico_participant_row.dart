part of 'character_detail_ico_participants_section.dart';

/// ICO 参与者行
class _IcoParticipantRow extends StatelessWidget {
  /// 创建 ICO 参与者行
  ///
  /// [participant] 参与者资料
  /// [prediction] ICO 预测数据
  /// [serialNumber] 展示序号
  /// [onTap] 点击回调
  const _IcoParticipantRow({
    required this.participant,
    required this.prediction,
    required this.serialNumber,
    required this.onTap,
  });

  /// 参与者资料
  final CharacterDetailIcoParticipant participant;

  /// ICO 预测数据
  final CharacterDetailIcoPrediction prediction;

  /// 展示序号
  final int serialNumber;

  /// 点击回调
  final VoidCallback onTap;

  /// 构建 ICO 参与者行
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final expectedShares = prediction.expectedShares(participant.amount);
    final showExpectedShares = participant.amount > 0 && expectedShares > 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 60,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              children: [
                UserAvatar(
                  imageUrl: participant.avatar,
                  isBanned: participant.isBanned,
                  size: 44,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    participant.displayName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: participant.isBanned
                                          ? colorScheme.error
                                          : colorScheme.onSurface,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      height: 1.05,
                                    ),
                                  ),
                                ),
                                if (participant.lastIndex > 0) ...[
                                  const SizedBox(width: 5),
                                  UserProfileRankBadge(
                                    rank: participant.lastIndex,
                                    isCompact: true,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      _IcoParticipantAmountBadge(
                        text: participant.amountLabel,
                        backgroundColor: _amountBadgeColor,
                      ),
                      if (showExpectedShares) ...[
                        const SizedBox(height: 3),
                        Text(
                          '${Formatters.groupedNumber(expectedShares)}股',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 投入金额胶囊背景色
  Color get _amountBadgeColor {
    if (serialNumber == 1) {
      return const Color(0xFFFFC107);
    }

    return const Color(0xFFD965FF);
  }
}

/// ICO 参与者行骨架
class _IcoParticipantRowSkeleton extends StatelessWidget {
  /// 创建 ICO 参与者行骨架
  const _IcoParticipantRowSkeleton();

  /// 构建 ICO 参与者行骨架
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Skeletonizer.zone(
      child: SizedBox(
        height: 60,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Row(
            children: [
              Bone(
                width: 44,
                height: 44,
                borderRadius: BorderRadius.circular(999),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Bone(
                            width: 92,
                            height: 14,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Bone(
                          width: 34,
                          height: 13,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Bone(
                      width: 62,
                      height: 16,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    const SizedBox(height: 3),
                    Bone(
                      width: 46,
                      height: 12,
                      borderRadius: BorderRadius.circular(4),
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

/// ICO 参与者投入金额胶囊
class _IcoParticipantAmountBadge extends StatelessWidget {
  /// 创建 ICO 参与者投入金额胶囊
  ///
  /// [text] 投入金额文案
  /// [backgroundColor] 胶囊背景色
  const _IcoParticipantAmountBadge({
    required this.text,
    required this.backgroundColor,
  });

  /// 投入金额文案
  final String text;

  /// 胶囊背景色
  final Color backgroundColor;

  /// 构建 ICO 参与者投入金额胶囊
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 112),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Align(
          alignment: Alignment.center,
          widthFactor: 1,
          heightFactor: 1,
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}

/// ICO 参与者网格尺寸
final class _IcoParticipantsGridMetrics {
  /// 禁止创建 ICO 参与者网格尺寸实例
  const _IcoParticipantsGridMetrics._();

  /// 参与者网格代理
  static const SliverGridDelegateWithMaxCrossAxisExtent delegate =
      SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: 220,
    mainAxisExtent: 60,
    mainAxisSpacing: 0,
    crossAxisSpacing: 8,
  );
}
